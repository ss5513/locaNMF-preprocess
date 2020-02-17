function Mall=combine_blocks(dimsM, Mc, dimsMc)
%%%%%%%%%%%%%%%%%%
%     Reshape blocks given by compress_blocks
%%%%%%%%%%%%%%%%%%
d1=dimsM(1); d2=dimsM(2); T=dimsM(3);
k = size(Mc,1);
Mall = nan*ones(d1, d2, T);
i=0; j=0;
for ii = 1:k
    %           shape of current block
    d1c=dimsMc(ii,1); d2c=dimsMc(ii,2);
    Mn = Mc(ii,1:d1c*d2c,:);
    Mn = reshape(Mn,[d1c,d2c,T]);
    Mall(i+1:i+d1c, j+1:j+d2c, :) = Mn;
    i =i+ d1c;
    if i == d1
        j =j+d2c;
        i = 0;
    end
end
end