function gcampmat=trim_data(gcampmat,brainmask)
%%%%%%%%%%%%%%%%%%
% Any entire row or column with brainmask=0 is cut out of the gcamp images.
% gcampmat is of size Height x Width x Time
% if brainmask is not provided, take nans in the first frame as brainmask
%%%%%%%%%%%%%%%%%%
if nargin<2, brainmask=~isnan(gcampmat(:,:,1)); end 
fprintf('Data Shape : [%d,%d,%d]\n',size(gcampmat));
delrowids=[];
delcolids=[];
for i=1:size(brainmask,1)
    if ~any(brainmask(i,:)), delrowids=[delrowids;i]; end %#ok<AGROW>
end
for j=1:size(brainmask,2)
    if ~any(brainmask(:,j)), delcolids=[delcolids;j]; end %#ok<AGROW>
end
gcampmat(delrowids,:,:)=[];
gcampmat(:,delcolids,:)=[];
fprintf('Trimmed Data Shape : [%d,%d,%d]\n',size(gcampmat));
end