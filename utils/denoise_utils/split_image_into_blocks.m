function blocks=split_image_into_blocks(image, number_of_blocks)
%%%%%%%%%%%%%%%%%%
%     Image d1 x d2 (x T) is split into number_of_blocks
%     Output blocks is cell of length number_of_blocks
%%%%%%%%%%%%%%%%%%
if number_of_blocks ~= 1  
    blocks = {};  colcounter=0;
    index_rows=1:(size(image,1)/sqrt(number_of_blocks));
    index_cols=1:(size(image,2)/sqrt(number_of_blocks));
    for j=1:sqrt(number_of_blocks)
        rowcounter=0;
        for i=1:sqrt(number_of_blocks)
            blocks{i,j}=image(rowcounter+index_rows,colcounter+index_cols,:); %#ok<*AGROW>
            rowcounter=rowcounter+length(index_rows);
        end
        if rowcounter<size(image,1)
            blocks{end,j}=[blocks{end,j}(:,index_cols,:);image(rowcounter+1:end,colcounter+index_cols,:)];
        end
        colcounter=colcounter+length(index_cols);
    end
    if colcounter<size(image,2)
        rowcounter=0;
        for i=1:sqrt(number_of_blocks)
            blocks{i,end}=[blocks{i,end}(index_rows,:,:) image(rowcounter+index_rows,colcounter+1:end,:)];
            rowcounter=rowcounter+length(index_rows);
        end
        blocks{end,end}=[blocks{end,end};image(rowcounter+1:end,colcounter-length(index_cols)+1:end,:)];
    end
    blocks=reshape(blocks,number_of_blocks,1);
else
    blocks = {image(:)};
end
end