%% load across correlations
across_cor = load('/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/OUTPUT_ACROSS_NEW/across_correlations.mat');


%% get within correlations and predictions from each subject and merge within and across
% corr. into same cell array

% myDir = '/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/OUTPUT_TEST_ACROSS_MODEL';

myDir = '/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/OUTPUT';
myFiles = dir(fullfile(myDir,'*.mat')); %gets all mat files in folder

all_cor = {};

for i = 1:size(myFiles, 1)
    % get subject id
    baseFileName = myFiles(i).name;
    fullFileName = fullfile(myDir, baseFileName);
    fprintf(1, 'Now reading %s\n', baseFileName);

    load(fullFileName, 'test');
    all_cor{i,1} = baseFileName;
    all_cor{i,2} = test;
    all_cor{i,3} = across_cor.across_correlations{i,3}; 
end

%% get average correlations and errors for across and within
avg_cor_within = 0;
avg_cor_across = 0;

avg_err_within = 0;
avg_err_across = 0;

cor_per_subject = {};
per_subj_avg_cor_within = 0;
per_subj_avg_cor_across = 0;

for i = 1:size(all_cor, 1)
    for k = 1:size(all_cor{i,2}.r, 2)
        % across all subject
        avg_cor_within = avg_cor_within + all_cor{i,2}.r(1,k);
        avg_cor_across = avg_cor_across + all_cor{i,3}.r(1,k);
        
        % per subject
        per_subj_avg_cor_within = per_subj_avg_cor_within + all_cor{i,2}.r(1,k);
        per_subj_avg_cor_across = per_subj_avg_cor_across + all_cor{i,3}.r(1,k);
        
        % errors
        avg_err_within = avg_err_within + all_cor{i,2}.err(1,k);
        avg_err_across = avg_err_across + all_cor{i,3}.err(1,k);
    end
    
    cor_per_subject{i,1} =  all_cor{i,1};
    per_subj_avg_cor_within = per_subj_avg_cor_within / size(all_cor{i,2}.r, 2);
    per_subj_avg_cor_across = per_subj_avg_cor_across / size(all_cor{i,2}.r, 2);
    cor_per_subject{i,2} =  per_subj_avg_cor_within;
    cor_per_subject{i,3} =  per_subj_avg_cor_across;
end

avg_cor_within = avg_cor_within / (size(all_cor, 1)*size(all_cor{1,2}.r, 2));
avg_cor_across = avg_cor_across / (size(all_cor, 1)*size(all_cor{1,2}.r, 2));

avg_err_within = avg_err_within / (size(all_cor, 1)*size(all_cor{1,2}.r, 2));
avg_err_across = avg_err_across / (size(all_cor, 1)*size(all_cor{1,2}.r, 2));

%% for plotting
% Plot Prediction error
figure
subplot(1,2,1), bar(1,avg_err_within), hold on, bar(2,avg_err_across), hold off
set(gca,'xtick',1:2,'xticklabel',{'Within','Across'}), ylim([0 1.5]), axis square, grid on
title('Prediction Error'), xlabel('Model'), ylabel('MSE')

% Plot test accuracy
subplot(1,2,2), bar(1,avg_cor_within), hold on, bar(2,avg_cor_across), hold off
set(gca,'xtick',1:2,'xticklabel',{'Within','Across'}), ylim([0 0.2]), axis square, grid on
title('Model Performance'), xlabel('Model'), ylabel('Correlation')

%%
% compare across vs. within for significance

z_within = atanh(cell2mat(cor_per_subject(:,2)));
z_across = atanh(cell2mat(cor_per_subject(:,3)));


[h, p, ci, stats] = ttest(z_within, z_across);




%%





















