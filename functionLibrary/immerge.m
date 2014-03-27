function coordinates = immerge(im1, im2, im3, im4)
[horzOffsetA, cA, temp5] = imstitch2d_v2(im1, im4, 1);
[horzOffsetB, cB, temp6] = imstitch2d_v2(im2, im3, 1);
[vertOffsetA, cC, finalImage] = imstitch2d_v2(temp5, temp6, 0);
imagesc(adapthisteq(imnormalize(finalImage)));
end