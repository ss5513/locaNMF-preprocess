function [Y,Uc,Vc]=denoise_dataset(Y,brainmask,fdir,autocorr_test,snr_test)
%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs:
% Y: widefield video. Dimensions [pixels x pixels x time].
% brainmask: mask with nans for outside of field of view. [pixels x pixels]
% fdir: path to save results. String.
% autocorr_test: Perform autocorrelations test to decide number of components to keep
% snr_test: Perform SNR test to decide number of components to keep
%%%%%%%%%%%%%%%%%%%%%%%%
%% Set defaults
if nargin<1
    error('Please provide root filename with dataset')
end
if nargin<2, brainmask=ones(size(Y,1),size(Y,2)); end
if nargin<3, fdir='./'; end
if nargin<4, autocorr_test=1; end
if nargin<5, snr_test=1; end

%% Set parameters
SVD_method = 'randomized';
maxlag = 5;
confidence = 0.99;
mean_threshold_factor=1.5;
snr_threshold = 1.6;

%% Denoise data
fprintf('Denoising Data\n');
datadims=size(Y);
Y = reshape(Y,datadims(1)*datadims(2),datadims(3));
brainmask_flat = reshape(brainmask,datadims(1)*datadims(2),1);
Y(isnan(brainmask_flat),:)=[];

[U, s, V] = compute_svd(Y,SVD_method,datadims(3)); Vt=V';
% Determine which components to keep using an autocorrelations test
if autocorr_test
    ctid = choose_rank(Vt,maxlag,confidence,mean_threshold_factor);
else
    ctid=ones(2,size(Vt,2));
end
idx = find(ctid(1, :) == 1);
    
fprintf('\tInitial Rank : %d\n',length(idx));
Uc = U(:,idx);
sred = s(idx,idx);
Vc = sred*Vt(idx,:);

% Further remove those components that have low snr
if size(Vc,2)>256 && snr_test
    high_snr_components = (std(Vc,[],2)./noise_level(Vc) > snr_threshold);
    num_low_snr_components = sum(~high_snr_components);
    fprintf('\t# low snr components: %d \n',num_low_snr_components);
    Vc = Vc(high_snr_components,:);
    Uc  = Uc(:,high_snr_components);
end

full_U=nan(datadims(1)*datadims(2),size(Uc,2));
full_U(~isnan(brainmask_flat),:)=Uc;
Y=reshape(full_U*Vc,datadims(1),datadims(2),datadims(3));
Uc=reshape(full_U,datadims(1),datadims(2),size(full_U,2));
save(fullfile(fdir,'Vc_Uc.mat'),'Uc','Vc','brainmask');
