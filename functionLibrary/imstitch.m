function outputImage = imstitch(im1, im2, offset, horizontal)
    if(~horizontal)
        temp = im1';
        im1 = im2';
        im2 = temp;
    end
    width = size(im2,2);
    intersection = (im1(:,(width-offset+1):width) + im2(:,1:offset)) ./ 2;
    %outputImage = horzcat(im1(:,1:(width-offset)), intersection ,im2(:,(offset+1):width));
    outputImage = horzcat(im1(), im2(:,(offset+1):width));
    if(~horizontal)
        outputImage = outputImage';
    end
end