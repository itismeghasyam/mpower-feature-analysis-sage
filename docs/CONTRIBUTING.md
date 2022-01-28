# Contributing Guide

To contribute to this analysis workflow, please for this repository and create PR for any new changes made to the analysis.

## Fork and clone this repository
See the [Github docs](https://help.github.com/articles/fork-a-repo/) for how to make a copy (a fork) of a repository to your own Github account.

Then, [clone the repository](https://help.github.com/articles/cloning-a-repository/) to your local machine so you can begin making changes.

Add this repository as an [upstream remote](https://help.github.com/en/articles/configuring-a-remote-for-a-fork) on your local git repository so that you are able to fetch the latest commits.

On your local machine make sure you have the latest version of the `develop` branch:

```
git checkout develop
git pull upstream develop
```

## Development Life Cycle
To add an analysis into this repostiory and add it as part of the workflow, several steps are required
1. Annotate each file accordingly
2. Add I/O controls to config.yml
3. Add query to `utils/fetch_file_id.R'
4. Include as part of the target in the Makefile

### Config.yml guide
The workflow uses [config.yml](https://github.com/Sage-Bionetworks/mpower-feature-analysis/blob/master/config.yml) to control to I/O of the file, it is used to manage output reference such as:
- output_filename
- provenance
- annotations
Some of the feature extraction pipeline are indexed as a list to represent variety of filters/QC-steps that we did from our analysis. Thus, make sure that the config file is able to properly control the output of your workflow. **The schema of the config.yml is still loosely based on what is convenient for the workflow, thus it can still be a subject of change in the future.**


### File Annotations Guide
This analysis workflow uses Synapse Annotations and File View to control the I/O of the analysis (parentIds, fileIds etc). 


There are several working components in which files are queried based on their annotations.


- pipelineStep: which pipeline step it is (feature extraction, curation analysis, etc.)
- analysisType: which analysis does the script belongs to
- analysisSubtype: subset of the analysis Type
- task: tasks done corresponding to the analysis

Adding these 4 annotations to each of the files, will keep track data locations in Synapse

Click [here](https://github.com/Sage-Bionetworks/mpower-feature-analysis/blob/master/docs/ANNOTATIONS.md) for current available annotations.

**Note: Make sure to add [Synapse Annotations](https://python-docs.synapse.org/build/html/Annotations.html) to new file entities and make changes to [docs/ANNOTATIONS.md](https://github.com/Sage-Bionetworks/mpower-feature-analysis/blob/master/docs/ANNOTATIONS.md) as part of the Github PR.**

### Fetching File IDs:
To fetch fileIDs, check [utils/fetch_id_utils.R](https://github.com/Sage-Bionetworks/mpower-feature-analysis/blob/master/utils/fetch_id_utils.R). The script contains function that can fetch each and every part of the analysis. Edit the file with new function, or new annotations for adding new analysis.

### Adding Workflow to Makefile
Workflow is streamlined by [GNU Makefile](https://github.com/Sage-Bionetworks/mpower-feature-analysis/blob/master/Makefile), to add new workflow into the analysis, create/edit rules inside the [Makefile](https://github.com/Sage-Bionetworks/mpower-feature-analysis/blob/master/Makefile)


