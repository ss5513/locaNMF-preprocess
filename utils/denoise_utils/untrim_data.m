function gcampmat_untrimmed=untrim_data(gcampmat,brainmask)
%%%%%%%%%%%%%%%%%%
% Any entire row or column with brainmask=0 is added back into the gcamp images.
% gcampmat is of size Height x Width x Time
% brainmask needs to be provided
%%%%%%%%%%%%%%%%%%
if nargin<2, brainmask=~isnan(gcampmat(:,:,1)); end 
fprintf('Data Shape : [%d,%d,%d]\n',size(gcampmat));
gcampmat_untrimmed=nan(size(brainmask,1),size(brainmask,2),size(gcampmat,3));
delrowids=[];
delcolids=[];
for i=1:size(brainmask,1)
    if ~any(brainmask(i,:)), delrowids=[delrowids;i]; end %#ok<AGROW>
end
for j=1:size(brainmask,2)
    if ~any(brainmask(:,j)), delcolids=[delcolids;j]; end %#ok<AGROW>
end
gcampmat_untrimmed(setdiff(1:size(brainmask,1),delrowids),setdiff(1:size(brainmask,2),delcolids),:)=gcampmat;
fprintf('Untrimmed Data Shape : [%d,%d,%d]\n',size(gcampmat_untrimmed));
end