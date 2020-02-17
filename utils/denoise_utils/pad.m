function result=pad(array, reference_shape, array_type)
%%%%%%%%%%%%%%%%%%
%     array: Array to be padded
%     reference_shape: tuple of size of narray to create
%     array_type: values to pad with. Default: nan
%%%%%%%%%%%%%%%%%%
if nargin<3, array_type=nan; end
    
%       Create an array of zeros with the reference shape
result = array_type*ones(reference_shape);
result(1:size(array,1),1:size(array,2),:)=array;
end