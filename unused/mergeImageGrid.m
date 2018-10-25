function mergedImage = mergeImageGrid(UL, UR, LL, LR, coordinates)
    UL = imsubimage_rowcol(UL, coordinates{1});
    UR = imsubimage_rowcol(UR, coordinates{1});
    LL = imsubimage_rowcol(LL, coordinates{2});
    LR = imsubimage_rowcol(LR, coordinates{2});
    
    temp1 = vertcat(UL, LL);
    temp2 = vertcat(UR, LR);
    
    temp1 = imsubimage_rowcol(temp1, coordinates{3});
    temp2 = imsubimage_rowcol(temp2, coordinates{4});
    
    mergedImage = horzcat(temp1, temp2);
end