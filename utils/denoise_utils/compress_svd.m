function [Ured,Vtred,meanM,keeprowids,Mlowr]=compress_svd(M,SVD_method,maxlag,confidence,mean_threshold_factor,snr_threshold)
%%%%%%%%%%%%%%%%%%
%     M : input d1 x d2 x T matrix
%%%%%%%%%%%%%%%%%%
[d1, d2, T] = size(M);
M = reshape(M,[d1*d2, T]);
meanM = mean(M,2);
M = bsxfun(@minus, M, meanM);
keeprowids=find(~isnan(meanM));
if isempty(keeprowids)
    fprintf('\tno components in block\n')
    Ured=[];Vtred=[]; 
    if nargout>4, Mlowr=nan*ones(d1*d2,T); end
else
    % Do SVD
    [U, s, V] = compute_svd(M(keeprowids,:),SVD_method);Vt=V';
    % Determine which components to keep using an autocorrelations test
    ctid = choose_rank(Vt,maxlag,confidence,mean_threshold_factor);
    idx = find(ctid(1, :) == 1);
    fprintf('\tInitial Rank : %d\n',length(idx));
    Ured = U(:,idx);
    sred = s(idx,idx);
    Vtred = sred*Vt(idx,:);
    
    % Further remove those components that have low snr
    high_snr_components = (std(Vtred,[],2)./noise_level(Vtred) > snr_threshold);
    num_low_snr_components = sum(~high_snr_components);
    fprintf('\t# low snr components: %d \n',num_low_snr_components);
    Vtred = Vtred(high_snr_components,:);
    Ured  = Ured(:,high_snr_components);
    fprintf('\tFinal Rank : %d \n',size(Vtred,1));
    if nargout>4
        Mlowr(keeprowids,:)=Ured*Vtred;
        Mlowr = bsxfun(@plus, Mlowr, meanM);
    end
end
end