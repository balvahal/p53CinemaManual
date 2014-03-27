classdef smFISHStack < TiffStack
    % A class to manipulate smFISH stack data, extending the general
    % TiffStack  class and implementing Kyle's algorithm (smfishStackPreprocessing)
    % noise reduction by matched filtering with a guassian kernel
    % create gaussian filter that approximates 3D PSF of the microscope.
    % Distance units are in micrometers.
    
    properties
        sumProjection;
        stampProjection;
        maxProjection;
        IM;
    end
    
    properties(Hidden)
        % Define default value for experiment parameters
        objective = 60;             %as in 60x
        NA = 1.4;                   %typical of 60x oil immersion objections
        rindex = 1.51;              %typical refractive index of oil
        camerapixellength = 6.45;   %Both cameras in the Lahav have pixel dimensions of 6.45 x 6.45 um.
        zstepsize = 0.3;            %User defined with z-stack is obtained
        wavelength = .67;           %Cy5 probe wavelength approximately 670 nanometers
        
        % Properties used during stack processing
        % These are defined during variable initialization
        tempI1, tempI2,IMMeanIntensity;
        hLoG, hMeanxy, hMeanz, hGaus, xy, z, pixelRatio;
    end
    
    methods
        function obj = smFISHStack(stackfile)
            obj@TiffStack(stackfile);
            obj = obj.variableInitialization;
        end
        function obj = variableInitialization(obj)
            sigmaXYos = 0.21 * obj.wavelength / obj.NA; %lateral st. dev of the gaussian filter in object space
            sigmaZos = 0.66 * obj. wavelength * obj.rindex/(obj.NA^2) ;%axial st. dev of the gaussian filter in object space
            Pxy = obj.camerapixellength / obj.objective; %lateral pixel size
            sigmaXY = sigmaXYos/Pxy; %lateral st. dev of gaussian filter in image space
            sigmaZ = sigmaZos/obj.zstepsize; %axial st. dev of gaussian filter in image space
            
            obj.xy = round(3*sigmaXY);
            obj.z = round(3*sigmaZ);
            
            xyMLV = round(4*sigmaXY);
            zMLV = round(4*sigmaZ);
            K = 1/((2*pi)^(3/2)*sqrt(sigmaXY^2*sigmaZ)); % log3d coefficient
            log3d = @(x,y,z) K*exp(-0.5*(x^2/sigmaXY+y^2/sigmaXY+z^2/sigmaZ))*((x^2-4*sigmaXY)/(4*sigmaXY^2)+(y^2-4*sigmaXY)/(4*sigmaXY^2)+(z^2-4*sigmaZ)/(4*sigmaZ^2));

            obj.hLoG = zeros(2*obj.xy+1,2*obj.xy+1,2*obj.z+1);
            for i=1:2*obj.xy+1
                for j=1:2*obj.xy+1
                    for k=1:2*obj.z+1
                        obj.hLoG(i,j,k) = log3d(i-1-obj.xy,j-1-obj.xy,k-1-obj.z); %the 3D filter
                    end
                end
            end
            
            %tune the filter so that it does not amplify the signal.
            temp1 = ones(2*obj.xy+1,2*obj.xy+1,2*obj.z+1);
            obj.hLoG=-obj.hLoG; %otherwise the center weight, the largest weight, is negative.
            temp2 = sum(sum(sum(temp1.*obj.hLoG)));
            obj.hLoG=obj.hLoG/temp2;
            K2=1/(xyMLV*xyMLV*zMLV);
            obj.hMeanxy=ones(1,xyMLV);
            obj.hMeanz=K2*ones(1,zMLV);
            %3D Gaussian Filter\Stamp\PSF approximation
            mu = [0,0,0]; %zero mean gaussian
            SIGMA = [sigmaXY,0,0;0,sigmaXY,0;0,0,sigmaZ];
            obj.hGaus = zeros(2*obj.xy+1,2*obj.xy+1,2*obj.z+1);
            for i=1:2*obj.xy+1
                for j=1:2*obj.xy+1
                    for k=1:2*obj.z+1
                        obj.hGaus(i,j,k) = mvnpdf([i-1-obj.xy,j-1-obj.xy,k-1-obj.z],mu,SIGMA); %the 3D filter
                    end
                end
            end
            obj.hGaus=obj.hGaus*(2^5)/(max(max(max(obj.hGaus))));
            obj.pixelRatio = sigmaZ/sigmaXY;
        end
        function IM_bkg = JaredsBackground(obj)
            IM_bkg = zeros(obj.height, obj.width, obj.numFrames);
            resizeMultiplier = 1/2; % Downsampling scale factor makes image processing go faster and smooths image
            seSize2 = 25; % I find the value of 25 works well with 60x, binning 1, mRNA FISH images
            se2 = strel('disk', double(uint16(seSize2*resizeMultiplier)));  %Structing elements are necessary for using MATLABS image processing functions
            origSize  = size(obj.imstack);
            for k=1:origSize(3)
                % Rescale image and compute background using closing/opening.
                I    = imresize(obj.imstack(:,:,k), resizeMultiplier);
                pad   = ceil(seSize2*resizeMultiplier);
                % Pad image with a reflection so that borders don't introduce artifacts
                I    = padarray(I, [pad,pad], 'symmetric', 'both');
                % Perform opening/closing to get background
                I     = imopen(I, se2);     % ignore high-intensity features typical of mRNA spots
                % Remove padding and resize
                I     = floor(imresize(I(pad+1:end-pad, pad+1:end-pad), origSize(1:2)));
                IM_bkg(:,:,k) = IM_bkg(:,:,k) - I;
            end
            %IM_bkg(IM_bkg < 0) = 0;
        end
        function obj = stackProcessing(obj)
            sizeOfImage = [obj.height, obj.width, obj.numFrames];
            obj.tempI1 = zeros(sizeOfImage);
            obj.tempI2 = zeros(sizeOfImage);
            obj.IMMeanIntensity = zeros(sizeOfImage);
            
            % Substract background using Jared's method (disk)
            obj.IM = obj.JaredsBackground;
            %----- enhance diffraction limited spots using the LoG filter -----
            %obj.IM = imfilter(obj.IM, obj.hLoG, 'symmetric');
            
        end
    end
    
end

