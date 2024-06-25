###########################################################
#' Script to get superPD cohort demographics 
#' information
#' 
#' @author aryton.tediarjo@sagebase.org
############################################################
library(synapser)
library(data.table)
library(synapser)
library(tidyverse)
library(githubr)
source("utils/curation_utils.R")
source("utils/helper_utils.R")
source("utils/fetch_id_utils.R")
synapser::synLogin()

#' Global Variables
N_CORES <- config::get("cpu")$n_cores
SYN_ID_REF <- list(
    table = config::get("table"),
    feature_extraction = get_feature_extraction_ids())
SUPERUSERS_OUTPUT_REF <- config::get("superusers")
UDALL_PARENT_ID <- "syn26142249"
SCRIPT_PATH <- file.path(
    "feature_processing", 
    "superusers",
    "get_baseline_demo.R")
GIT_URL = get_github_url(
    git_token_path = config::get("git")$token_path,
    git_repo = config::get("git")$repo_endpoint,
    script_path = SCRIPT_PATH)

# Feature to table mapping
REF_LIST <- list(
    demo = list(
        table = SYN_ID_REF$table$demo,
        feature = SYN_ID_REF$feature_extraction$demo,
        filename = SUPERUSERS_OUTPUT_REF$demo[[1]]$output_filename,
        provenance = SUPERUSERS_OUTPUT_REF$demo[[1]]$provenance,
        annotations = SUPERUSERS_OUTPUT_REF$demo[[1]]$annotations
    )
    
)


# get metadata to filter sensor
metadata <- get_table(
    synapse_tbl = REF_LIST$demo$table, 
    query_params = "where `substudyMemberships` LIKE '%superusers%'") %>%
    dplyr::select(externalId, healthCode) %>%
    distinct()

# get demo
demo <- fread(synGet(REF_LIST$demo$feature)$path) %>%
    dplyr::inner_join(metadata) %>%
    dplyr::select(externalId, healthCode, everything())

# save to synapse
save_to_synapse(
    data = demo,
    output_filename = REF_LIST$demo$filename,
    parent = UDALL_PARENT_ID,
    annotations = REF_LIST$demo$annotations,
    activityName = REF_LIST$demo$provenance$name,
    activityDescription = REF_LIST$demo$provenance$description,
    used = c(REF_LIST$demo$feature, 
             REF_LIST$demo$table),
    executed = GIT_URL)
