%% main
classdef new_main_across < obob_condor_job
    methods
        function run(obj, directory, fs)
            addpath('/mnt/obob/obob_ownft');

            obob_init_ft; % Initialize obob_ownft

            addpath('/mnt/obob/staff/jschubert/myfuns'); % must be set after obob_init_ft
            addpath('/mnt/obob/staff/jschubert/toolboxes/mTRF-Toolbox/mtrf');
            addpath('/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/cluster_jobs');
            addpath('/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/');

            % myDir = '/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/cocktail_preproc_contin';
            myDir = directory;
            myFiles = dir(fullfile(myDir,'*.mat')); %gets all mat files in struct
            
            across_correlations = {};
            
            % determine the subject to exclude from model training for
            % later model evaluation
            for j = 1:size(myFiles, 1)
                all_stim_subjects = {};
                all_resp_subjects = {};
                
                for k = 1:size(myFiles, 1)                
                % this if statement iteratively always excludes one subj. for
                % evaluation
                  if k ~= j
                      % get subject id
                      baseFileName = myFiles(k).name;
                      fullFileName = fullfile(myDir, baseFileName);
                      fprintf(1, 'Now reading %s\n', baseFileName);
                      load(fullFileName);

                      % singel speaker trials auswählen

                      all_ss_trials = find(data.trialinfo(:,4) == 0); % ss means single speaker
                      cfg = [];
                      cfg.trials = all_ss_trials;
                      data = ft_selectdata(cfg, data);

                      % resampling
                      cfg = [];
                      % cfg.resamplefs = fs;
                      cfg.resamplefs = fs;
                      data = ft_resampledata(cfg, data);

                      data.trial = cellfun(@(x) transpose(zscore(x,0,2)), data.trial, 'UniformOutput', false);

                      stim = {};
                      resp = {};
                      for i=1:size(data.trial,2)
                        stim{1,i} = data.trial{1,i}(:,307:357);
                        resp{1,i} = data.trial{1,i}(:,1:306);
                      end

                      all_stim = vertcat(stim{:});
                      all_resp = vertcat(resp{:});

                      all_stim_subjects{1,k} = all_stim;
                      all_resp_subjects{1,k} = all_resp;
                  end
                end
                
                number_of_included_subjects = size(all_stim_subjects);

                all_stim_subjects = vertcat(all_stim_subjects{:});
                all_resp_subjects = vertcat(all_resp_subjects{:});

                % split data into training/test sets
                nfold = 6; testTrial = 1;
                [strain,rtrain,stest,rtest] = mTRFpartition(all_stim_subjects,all_resp_subjects,nfold,testTrial);

                % Model hyperparameters
                Dir = -1; % direction of causality
                tmin = 0; % minimum time lag (ms)
                tmax = 250; % maximum time lag (ms)
                lambda = 10.^(-6:2:6); % regularization parameters

                % Run efficient cross-validation
                cv = mTRFcrossval(strain,rtrain,fs,Dir,tmin,tmax,lambda,'zeropad',0,'fast',1);


                % Find optimal regularization value
                [rmax,idx] = max(mean(mean(cv.r),3));
                % Train model
                model = mTRFtrain(strain,rtrain,fs,Dir,tmin,tmax,lambda(idx),'zeropad',0);

                
                % get subject id of to be evaluated subject
                baseFileName = myFiles(j).name;
                fullFileName = fullfile(myDir, baseFileName);
                fprintf(1, 'Now for evaluation: reading %s\n', baseFileName);
                load(fullFileName);
                
                % do everything the same as in the for loop for the
                % subjects included in the model building
                
                % singel speaker trials auswählen
                  all_ss_trials = find(data.trialinfo(:,4) == 0); % ss means single speaker
                  cfg = [];
                  cfg.trials = all_ss_trials;
                  data = ft_selectdata(cfg, data);

                  % resampling
                  cfg = [];
                  % cfg.resamplefs = fs;
                  cfg.resamplefs = fs;
                  data = ft_resampledata(cfg, data);

                  data.trial = cellfun(@(x) transpose(zscore(x,0,2)), data.trial, 'UniformOutput', false);

                  stim = {};
                  resp = {};
                  for i=1:size(data.trial,2)
                    stim{1,i} = data.trial{1,i}(:,307:357);
                    resp{1,i} = data.trial{1,i}(:,1:306);
                  end

                  eval_stim = vertcat(stim{:});
                  eval_resp = vertcat(resp{:});
                
                
                % Test model
                [pred,test] = mTRFpredict(eval_stim,eval_resp,model,'zeropad',0);
                
                across_correlations{j,1} = baseFileName;
                across_correlations{j,2} = pred;
                across_correlations{j,3} = test;
                
            end
            
            % just for confirmation:
            number_of_trials = size(data.trial,2)
            
            
            %% save results:
            %------------------------------------------------------------------------
            %fname_2save = obj.get_fname_2save(outdir, subject_id); % saved fileName in outdir
            %
            save('/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/OUTPUT_ACROSS_NEW/across_correlations.mat', 'across_correlations', 'number_of_included_subjects', 'number_of_trials', '-v7.3');
        end
        % get fname_2save fun
%         function fname_2save = get_fname_2save(obj, outdir, subject_id)
%             fname_2save = fullfile(outdir,['full_model', '.mat']);
%         end % of get_fname_2save fun
    end
end




