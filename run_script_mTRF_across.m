%% RUNNING TONES DECODING ON CLUSTER (all_subjects):
% add paths & init packages:
addpath('/mnt/obob/obob_ownft');

cfg = [];
cfg.package.hnc_condor = true;
obob_init_ft(cfg); % Initialize obob_ownft

addpath('/mnt/obob/staff/jschubert/myfuns'); % must be set after obob_init_ft
addpath('/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/cluster_jobs');

% create struct for cluster job
cfg = [];
cfg.mem = '150G'; 
cfg.adjust_mem = true;
condor_struct = obob_condor_create(cfg);

directory = '/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/cocktail_preproc_contin';

FS = 100;

%%%% send to cluster
condor_struct = obob_condor_addjob_cell(condor_struct, 'new_main_across', ...
  directory, FS);
obob_condor_submit(condor_struct);

