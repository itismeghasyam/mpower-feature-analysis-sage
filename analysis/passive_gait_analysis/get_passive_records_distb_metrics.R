###############################################
#' Script to run passive gait
#' records contributions, this 
#' script will fetch data related to:
#' - How much time is passive contribution 
#' happening after an active task
#' - How many consecutive records
#' 
#' @author aryton.tediarjo@sagebase.org
################################################
library(synapser)
library(tidyverse)
library(data.table)
library(ggplot2)
library(patchwork)
library(githubr)
source("utils/helper_utils.R")

synLogin()

####################################
#### Global Variables
####################################
SCRIPT_PATH <- file.path(
    "analysis", 
    "passive_gait_analysis",
    "get_passive_records_distb_metrics.R")
GIT_URL = get_github_url(
    git_token_path = config::get("git")$token_path,
    git_repo = config::get("git")$repo_endpoint,
    script_path = SCRIPT_PATH)

PARENT_ID <- "syn26842601"
OUTPUT_FILE <- "passive_gait_contributions_metrics.tsv"
PASSIVE_TBL <- "syn17022539"
TAP_TBL <- "syn15673381"
WALK_TBL <- "syn12514611"
TREMOR_TBL <- "syn12977322"

####################################
#### instantiate github #### 
####################################
setGithubToken(readLines(GIT_TOKEN_PATH))
GIT_URL <- githubr::getPermlink(
    GIT_REPO, repositoryPath = SCRIPT_PATH,
    ref = "branch",
    refName = 'main')

passive <- synTableQuery(
    glue::glue("select * from {PASSIVE_TBL}"))$asDataFrame() %>% 
    dplyr::filter(!str_detect(dataGroups, "test_user")) %>%
    dplyr::select(recordId, phoneInfo, healthCode, createdOn) %>%
    dplyr::mutate(
        operatingSystem = case_when(
            str_detect(tolower(phoneInfo), "ios") ~ "IOS",
            TRUE ~ "Android"),
        type = "passive")
tapping <- synTableQuery(
    glue::glue("select * from {TAP_TBL}"))$asDataFrame() %>% 
    dplyr::filter(!str_detect(dataGroups, "test_user"))%>%
    dplyr::select(recordId, healthCode, createdOn) %>%
    dplyr::mutate(type = "active")
walking <- synTableQuery(
    glue::glue("select * from {WALK_TBL}"))$asDataFrame() %>% 
    dplyr::filter(!str_detect(dataGroups, "test_user")) %>%
    dplyr::select(recordId, healthCode, createdOn) %>%
    dplyr::mutate(type = "active")
tremor <- synTableQuery(
    glue::glue("select * from {TREMOR_TBL}"))$asDataFrame() %>% 
    dplyr::filter(!str_detect(dataGroups, "test_user")) %>%
    dplyr::select(recordId, healthCode, createdOn) %>%
    dplyr::mutate(type = "active")
OS_summary <- passive %>% 
    dplyr::group_by(healthCode) %>% 
    summarise(OS = last(operatingSystem))


#' Note: sort all activity into per day format
#' Assume that 
get_consec_days <- function(data){
    data %>% 
        dplyr::filter(type == "passive") %>%
        dplyr::mutate(date = lubridate::as_date(createdOn)) %>%
        dplyr::arrange(date) %>%
        dplyr::group_by(date) %>%
        dplyr::summarise(
            n = n_distinct(recordId)) %>%
        dplyr::mutate(
            diff_up = c(0,diff(date)),
            diff_down = as.numeric(lead(.$date) - .$date)) %>%
        group_by(group = rleid(diff_up > 1)) %>% 
        dplyr::ungroup() %>%
        dplyr::mutate(group = case_when((
            diff_up > 1 & diff_down == 1) ~ (group + 1), 
            TRUE ~ as.numeric(group)),
            consecutive_group = dense_rank(group)) %>% 
        dplyr::group_by(consecutive_group) %>% 
        dplyr::summarise(cons_day = n(), nrecords = sum(n)) %>% 
        dplyr::summarise_at(
            .vars = c("cons_day", "nrecords"), 
            .funs = list(
                "max"= max, 
                "min" = min,
                "mean" = mean, 
                "med" = median,
                "iqr" = IQR, 
                "sd" = sd,
                "total" = sum), na.rm = T)
}

#' Function to get duration of time
#' between an active task and passive gait trigger
get_duration_after_active <- function(data){
    data %>%
        dplyr::arrange(createdOn) %>%
        dplyr::mutate(type_lag = lag(type),
                      date_lag = lag(createdOn)) %>% 
        dplyr::mutate(active_to_passive = case_when(
            (type == "passive" & 
                 type_lag == "active") ~ createdOn - date_lag,
            TRUE ~ NA)) %>%
        dplyr::filter(type == "passive", type_lag == "active") %>%
        dplyr::summarise_at(
            .vars = c("active_to_passive"), 
            .funs = list(
                "since_last_active_max"= max, 
                "since_last_active_min" = min,
                "since_last_active_mean" = mean, 
                "since_last_active_med" = median,
                "since_last_active_iqr" = IQR, 
                "since_last_active_sd" = sd,
                "since_last_active_total" = sum), na.rm = T)
}

#' Helper function to run metrics
#' calculation
get_passive_activity_metrics <- function(data) {
    consec_days <- get_consec_days(data)
    duration_since_active <- get_duration_after_active(data)
    return(cbind(consec_days, duration_since_active) %>% 
               tibble::as_tibble())
}

result <- passive %>% 
    dplyr::select(-phoneInfo, -operatingSystem) %>%
    rbind(., walking, tremor, tapping) %>% 
    dplyr::filter(healthCode %in% unique(passive$healthCode)) %>%
    tidyr::nest(activities = !healthCode) %>%
    dplyr::mutate(metrics = purrr::map(
        activities, get_passive_activity_metrics)) %>%
    dplyr::select(-activities) %>%
    tidyr::unnest(metrics) %>% 
    dplyr::left_join(OS_summary, by = c("healthCode"))

save_to_synapse(
    data = result,
    output_filename = OUTPUT_FILE,
    parent = PARENT_ID,
    used = c(TAP_TBL, TREMOR_TBL, WALK_TBL, PASSIVE_TBL),
    activityName = "get passive gait contribution metrics",
    activityDescription = "get several passive gait metrics")
