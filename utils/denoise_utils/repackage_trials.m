function [dimsM,trial_idxs]=repackage_trials(data_root,blockfiles_root,which_channel,numfiles,numblocks)
temp_root=fullfile(blockfiles_root,'temp'); 
if ~isdir(temp_root), mkdir(temp_root); end
dimsM = zeros(3,1);

%% Save all trials in separate files per block (1 file per block per filename)
% These are temporary files
trial_idxs=[];
for i = 1:numfiles
    trialpath=fullfile(data_root,strcat(which_channel,'_trial_',num2str(i),'.mat'));
    if exist(trialpath,'file')
        fprintf('Loading .mat datafile: %s\n',strcat(which_channel,'_trial_',num2str(i),'.mat'));
        dataset = load(trialpath); 
    else
        continue; 
    end
    if strcmp(which_channel,'blue'), gcampmat=dataset.blueDataMat; else, gcampmat=dataset.hemoDataMat; end
    clear dataset;
	gcampmat = trim_data(gcampmat); % applies brainmask and deletes empty rows and columns
    dimsM(1)=size(gcampmat,1); dimsM(2)=size(gcampmat,2); dimsM(3)=dimsM(3)+size(gcampmat,3);
    blocks=split_image_into_blocks(gcampmat, numblocks);
    for blocknum = 1:numblocks
        temppath=fullfile(temp_root,strcat(which_channel,'_trial',num2str(i),'_',num2str(blocknum),'of',num2str(numblocks),'.mat'));
        gcampblock = blocks{blocknum};
        save(temppath,'gcampblock');
    end
    % which time index corresponds to which trial
    trial_idxs=[trial_idxs;i*ones(size(gcampmat,3),1)]; %#ok<AGROW>
end
save(fullfile(data_root,'trial_metadata.mat'),'dimsM','trial_idxs');

% which trials are being used in the analysis
load(fullfile(data_root,'trial_metadata.mat'));
which_trials=unique(trial_idxs);
%% Save all blocks in one file each (1 file per block)
for blocknum = 1:numblocks
    savefile=fullfile(blockfiles_root,strcat(which_channel,'_alltrials_',num2str(blocknum),'of',num2str(numblocks)));
    gcampmat=[];
    for t = 1:length(which_trials)
        temppath=fullfile(temp_root,strcat(which_channel,'_trial',num2str(which_trials(t)),'_',num2str(blocknum),'of',num2str(numblocks),'.mat'));
        if ~exist(temppath,'file'), continue; end
        load(temppath,'gcampblock');
        gcampmat=cat(3,gcampmat,gcampblock);
    end
    save(savefile,'gcampmat','-v7.3');
end
%% Delete all temporary files created earlier
rmdir(temp_root,'s');