###########################################################
#' Script to get baseline activity
#' for super-PD across tapping, tremor, walking
#' 
#' @author: aryton.tediarjo@sagebase.org
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
    "get_baseline_activity.R")
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
        annotations = SUPERUSERS_OUTPUT_REF$[[1]]$annotations
    ),
    tap = list(
        table = SYN_ID_REF$table$tap,
        feature = SYN_ID_REF$feature_extraction$tap_20_secs,
        filename = SUPERUSERS_OUTPUT_REF$tap[[1]]$output_filename,
        provenance = SUPERUSERS_OUTPUT_REF$tap[[1]]$provenance,
        annotations = SUPERUSERS_OUTPUT_REF$tap[[1]]$annotations),
    tremor = list(
        table = SYN_ID_REF$table$tremor,
        feature = SYN_ID_REF$feature_extraction$tremor,
        filename = SUPERUSERS_OUTPUT_REF$tremor[[1]]$output_filename,
        provenance = SUPERUSERS_OUTPUT_REF$tremor[[1]]$provenance,
        annotations = SUPERUSERS_OUTPUT_REF$tremor[[1]]$annotations),
    walk = list(
        table = SYN_ID_REF$table$walk,
        feature = SYN_ID_REF$feature_extraction$walk_7.5,
        filename = SUPERUSERS_OUTPUT_REF$walk[[1]]$output_filename,
        provenance = SUPERUSERS_OUTPUT_REF$walk[[1]]$provenance,
        annotations = SUPERUSERS_OUTPUT_REF$walk[[1]]$annotations))

#' Function to filter enrollment
#' used to filter activity (baseline)
#' 
#' @param data
#' @return filtered data
filter_enrollment <- function(data){
    data %>% 
        dplyr::arrange(createdOn) %>% 
        dplyr::mutate(
            days_since_start = 
                difftime(createdOn, min(.$createdOn), units = "days")) %>% 
        dplyr::filter(days_since_start <= lubridate::ddays(14)) %>%
        dplyr::select(-days_since_start)
}

#' Helper function to get baseline data 
#' @table synapse table dataframe
#' @return table with filtered activities
get_baseline <- function(table){
    # get & clean metadata from synapse table
    table %>% 
        dplyr::group_by(healthCode) %>% 
        nest() %>% 
        dplyr::mutate(data = purrr::map(data, filter_enrollment)) %>%
        unnest(data) %>% 
        dplyr::ungroup() %>%
        dplyr::select(recordId, 
                      externalId,
                      healthCode, 
                      createdOn,
                      version,
                      build,
                      phoneInfo,
                      medTimepoint)
}


main <- function(){
    # query param
    query_param <- "`substudyMemberships` LIKE '%superusers%'"
    
    purrr::map(REF_LIST, function(activity_ref){
        table_id <- activity_ref$table
        feature_id <- activity_ref$feature
        output_filename <- activity_ref$filename
        provenance_name <- activity_ref$provenance$name
        provenance_description <- activity_ref$provenance$description
        
        # get metadata to filter sensor
        metadata <- get_table(
            synapse_tbl = table_id, 
            query_params = "where `substudyMemberships` LIKE '%superusers%'") %>%
            curate_med_timepoint() %>%
            curate_app_version() %>%
            curate_phone_info() %>%
            get_baseline()
        
        # merge feature with cleaned metadata
        data <- synGet(feature_id)$path %>% 
            fread() %>%
            dplyr::inner_join(
                metadata, by = c("recordId")) %>%
            dplyr::select(recordId, 
                          externalId,
                          healthCode, 
                          createdOn,
                          version,
                          build,
                          phoneInfo,
                          medTimepoint,
                          everything())
        
        # if window exist, remove NA
        if("window" %in% names(data)){
            data <- data %>%
                tidyr::drop_na(window)
        }
        
        # save to synapse
        save_to_synapse(
            data = data,
            output_filename = output_filename, 
            parent = UDALL_PARENT_ID,
            name = provenance_name,
            description = provenance_description,
            annotations = activity_ref$annotations,
            used = c(table_id, feature_id),
            executed = GIT_URL)
    })
}

main()