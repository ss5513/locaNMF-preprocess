% Process Dataset
%% Get root folder and filename with data
fdir='./'; % path to data
% data filename. Should have calcium imaging video saved as 'Y' with dimensions [pixels x pixels x time]
fname='data.mat'; 

%% Add paths and load data
addpath(genpath('./utils/'));
data = load(fullfile(fdir,fname));
if ~isfield(data,'Y'), error('Data file should have widefield video saved as Y');
else, Y=data.Y; clear data;
end

%% Get brainmask
set(0,'DefaultFigureWindowStyle','docked'); warning('off','images:imshow:magnificationMustBeFitForDockedFigure')
fprintf('Click the vertices to define a brainmask.\nRight click to finish and close polygon.\nDouble-click inside polygon to accept it.\n');
R=roipoly(max(Y,[],3)./max(Y(:)));
brainmask=double(R);
brainmask(brainmask==0)=NaN;
Y=repmat(brainmask,1,1,size(Y,3)).*Y;
imshow(max(Y,[],3)./max(Y(:)))

%% Denoise data
autocorr_test=1; % Autocorrelation test to determine number of components
snr_test=1; % SNR test to determine number of components
% Denoise using SVD. If neither autocorr or snr tests, then keep all components.
[dataset,Uc,Vc]=denoise_dataset(Y,brainmask,fdir,autocorr_test,snr_test);

%% Align data to atlas + get inverse atlas
load('atlas.mat')
tform = align_recording_to_allen(max(dataset,[],3)); % align <-- input any function of data here
invT=pinv(tform.T); % invert the transformation matrix
invT(1,3)=0; invT(2,3)=0; invT(3,3)=1; % set 3rd dimension of rotation artificially to 0
invtform=tform; invtform.T=invT; % create the transformation with invtform as the transformation matrix
atlas=imwarp(atlas,invtform,'interp','nearest','OutputView',imref2d(size(dataset(:,:,1)))); % setting the 'OutputView' is important
atlas=round(atlas);

%% Plot the warped atlas
figure; subplot(1,2,1); imagesc(max(dataset,[],3)); axis image
subplot(1,2,2); imagesc(atlas); axis image

%% Save the warped atlas
save(fullfile(fdir,'atlas.mat'),'atlas','areanames','invtform');