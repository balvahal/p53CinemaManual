function subIM = subImage(IM, coord)
    x = coord(1);
    y = coord(2);
    width = coord(3);
    height = coord(4);
    subIM = IM(y:(y+height),x:(x+width));
end