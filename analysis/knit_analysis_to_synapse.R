#######################################
#' Script to run passive gait contribution
#' into notebook and visualize in synapse
#' 
#' @author aryton.tediarjo@sagebase.org
######################################
library(knit2synapse)
library(synapser)
synLogin()
createAndKnitToFileEntity("analysis/passive_gait_analysis/passive_gait_contribution.Rmd", 
                          parentId = "syn26842601", 
                          fileName = "passive_data_contbribution.html",
                          used = "syn24682745") 