function sns=noise_level(Vt,method,range_ff)
if nargin<2, method='logmexp'; end
if nargin<3, range_ff=[0.25,0.5]; end

sns=zeros(size(Vt,1),1);
for i = 1:size(Vt,1)
    [Pxx,ff] = pwelch(Vt(i,:),hanning(256),256/2,256,1,'onesided');
    Pxx_ind = Pxx(ff > range_ff(1) & ff < range_ff(2));
    switch method
        case 'mean'
            sns(i)=sqrt(mean(Pxx_ind/2));
        case 'median'
            sns(i)=sqrt(median(Pxx_ind/2));
        case 'logmexp'
            sns(i)=sqrt(exp(mean(log(Pxx_ind/2))));
    end
end
end