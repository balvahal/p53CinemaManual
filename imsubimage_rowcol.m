function subImage = imsubimage_rowcol(image, cropping)
    subImage = image(cropping(1):(cropping(1)+cropping(3)-1), cropping(2):(cropping(2)+cropping(4)-1));
end