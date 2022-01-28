# Annotations Guide

The current workflow utilizes [Synapse Vile Fiew](https://python-docs.synapse.org/build/html/Views.html) to control data I/O, meaning that to run the end to end pipeline, data will be required to be properly annotated so that the worfkflow will be able to refer to each Synapse ID location in every step of the data pipeline. 
**Each Synapse ID should be annotated uniquely under the Synapse Project and be refered as a query statement in `utils/fetch_id_utils.R`.**

### Annotations Mapping 
| pipelineStep |
| :-------------- |
| feature extraction |
| feature processing |
| analysis | 
| prediction |
| figures |

| analysisType | analysisSubtype | filter |
| :-------------- | :-----------| :----------- |
| demographics-v2 | | 
| tapping-v2 | | 20 seconds cutoff
| walk30secs-v2 | | 5-seconds window </br>  7.5-seconds window
| tremor-v2 | | |
| passive-gait | passive-gait triggers | |

| processingType |
|:-------------- |
| aggregation |

| tool |
|:--------------|
| pdkit-rotation |
| mhealthtools |


| task |
|:--------------|
| tapping |
| walking |
| tremor |
