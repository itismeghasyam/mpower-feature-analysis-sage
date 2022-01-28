rerun: update project features aggregate documentation

update:
	git pull

authenticate:
	Rscript utils/authenticate.R ${PARAMS}
	
project:
	. /root/env/bin/activate && python3 synapseformation/create_project.py

features:
	Rscript feature_extraction/extract_demographics.R || exit 1
	Rscript feature_extraction/extract_mhealthtools_tremor_features.R || exit 1
	Rscript feature_extraction/extract_mhealthtools_tapping_features.R || exit 1
	Rscript feature_extraction/extract_pdkit_rotation_walk30secs_features.R || exit 1
	Rscript feature_extraction/extract_pdkit_rotation_passive_features.R || exit 1
	
aggregate_users:
	Rscript feature_processing/aggregate_users/aggregate_tapping_features.R || exit 1
	Rscript feature_processing/aggregate_users/aggregate_walk30secs_features.R || exit 1
	Rscript feature_processing/aggregate_users/aggregate_tremor_features.R || exit 1
	
superusers:
	Rscript feature_processing/superusers/get_baseline_demo.R || exit 1
	Rscript feature_processing/superusers/get_baseline_activity.R || exit 1
	Rscript analysis/pd_severity/get_superusers_predicted_prob.R || exit 1
	
passive_gait_analysis:
	Rscript analysis/passive_gait_analysis/get_passive_records_distb_metrics.R
	Rscript analysis/knit_analysis_to_synapse.R
	
documentation: 
	Rscript wiki/knit_md.R || exit 1
