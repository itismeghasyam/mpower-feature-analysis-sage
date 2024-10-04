# mPower Feature ETL & Analysis
This Github Repository is used for running Dockerized MPower ETL Processes, it manages your python/R environment and streamlines worfklow from feature-extraction, aggregation, analysis, and prediction

Maintainer: 
1. pranav.anbarasu@sagebase.org
2. meghasyam@sagebase.org
3. aryton.tediarjo@sagebase.org (Retired as of 28th Jan 2022)

### About
This repository is used as a ETL wrapper for fetching mPower features based on different feature extraction tools. 
Here are our current supported tools in this ETL Github repository:
- [Mhealthtools](https://github.com/Sage-Bionetworks/mhealthtools/blob/master/R/get_tapping_features.R)
- [PDKit](https://github.com/pdkit/pdkit)

## Manually running (recommended if you need to run step-by-step and/or debug):
Manually run each script in the [Makefile](Makefile) in the specified order. The Docker usage instructions below do work, but running the pipeline using the docker method makes it harder to debug, run step-by-step, and analyze outputs/processes at each step.

## Running in Docker (not recommended if you need to debug):
Docker image is designed to build R & Python Environment and deployed in a container. Environment in R uses `renv` and Python `virtualenv` package management.  

### 1. Clone the repository: 
```zsh
git clone https://github.com/Sage-Bionetworks/mpower-feature-analysis.git
```
### 2. Build Image:
```zsh
docker build -t 'mpower-feature-analysis' .
```
### 3. Run Image as Container:
```zsh
docker run -itd mpower-feature-analysis
```
Notes: Argument -itd is used to make sure that container is run in detached mode (not removed after running once)

### 4. Execute Container:
#### Check Container ID:
```zsh
docker ps -a
```
Using this command, it will output container that contains the saved image. Fetch the container ID to proceed.

#### Fetch container ID and create Synapse Authentication:
```zsh
docker exec -it <CONTAINER_ID> make authenticate PARAMS="-u <username> -p <password> -g <git_token>"
```


#### Use same container ID and use Makefile to rerun workflow:
```zsh
docker exec -it <CONTAINER_ID> make rerun
```

## Contributing Docs:
Guidelines to contribute to this Github Repository will be documented in [`/docs`](https://github.com/Sage-Bionetworks/mpower-feature-analysis/tree/master/docs)
