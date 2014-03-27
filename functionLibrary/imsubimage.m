function subImage = imsubimage(image, cropping)
    %subImage = image(cropping.y:(cropping.y+cropping.height-1), cropping.x:(cropping.x+cropping.width-1));
    subImage = image(cropping(2):(cropping(2)+cropping(4)-1), cropping(1):(cropping(1)+cropping(3)-1));
end