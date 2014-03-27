function S = imbackground(S, se1Size, se2Size)
resizeMultiplier = 1/2; % Downsampling scale factor makes image processing go faster and smooths image
se1 = strel('disk', round(se1Size*resizeMultiplier));  %Structing elements are necessary for using MATLABS image processing functions
se2 = strel('disk',round(se2Size*resizeMultiplier));

origSize  = size(S);
% Rescale image and compute background using closing/opening.
I    = imresize(S, resizeMultiplier);
% Pad image with a reflection so that borders don't introduce artifacts
pad   = round(se2Size*resizeMultiplier);
I    = padarray(I, [pad,pad], 'symmetric', 'both');
% Perform opening/closing to get background
I     = imclose(I, se1);   % ignore small low-intensity features (inside cells)
I     = imopen(I, se2);     % ignore large high-intensity features (that are cells)
% Remove padding and resize
I     = floor(imresize(I(pad+1:end-pad, pad+1:end-pad), origSize));
% Subtract background!
S = S - I;
S(S<0)=0;
end