%% RUNNING TONES DECODING ON CLUSTER (all_subjects):
% add paths & init packages:
addpath('/mnt/obob/obob_ownft');

cfg = [];
cfg.package.hnc_condor = true;
obob_init_ft(cfg); % Initialize obob_ownft

addpath('/mnt/obob/staff/jschubert/myfuns'); % must be set after obob_init_ft
addpath('/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/cluster_jobs');
addpath('/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit');

% create struct for cluster job
cfg = [];
cfg.mem = '30G'; %per subj
cfg.adjust_mem = true;
condor_struct = obob_condor_create(cfg);

% data paths
OUTDIR = '/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/OUTPUT';
PREPROC_DIR = '/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/cocktail_preproc_contin/';
FS=100;

% get subjects
all_subjects = js_getsubjectsfrom(PREPROC_DIR);

%%%% send to cluster
condor_struct = obob_condor_addjob_cell(condor_struct, 'main', ...
  all_subjects, PREPROC_DIR, OUTDIR, FS);
obob_condor_submit(condor_struct);

