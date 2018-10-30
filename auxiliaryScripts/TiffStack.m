classdef TiffStack < handle
    % A general class for manipulating Tiff Stack objects
    
    properties
        imstack;
        numFrames;
        width;
        height;
        sourceFile;
    end
    
    methods
        function obj = TiffStack(stackfile)
            %% Read stack file
            warning off MATLAB:imagesci:Tiff:libraryWarning;
            info = imfinfo(stackfile);
            obj.numFrames = numel(info);
            obj.width = info(1).Width;
            obj.height = info(1).Height;
            obj.sourceFile = stackfile;
            
            obj.imstack = zeros(obj.height, obj.width, obj.numFrames);
            IM = Tiff(stackfile, 'r');
            for i=1:numel(info)
                %obj.imstack(:,:,i) = imbackground(IM.read, 10, 100);
                obj.imstack(:,:,i) = IM.read;
                if ~IM.lastDirectory
                    IM.nextDirectory;
                end
            end
        end
        
        function obj = correctFlatfield(obj, ffoffset, ffgain)
            for i=1:obj.numFrames
                obj.imstack(:,:,i) = flatfield_correctImage(obj.imstack(:,:,i), ffoffset, ffgain);
            end
        end
        
        function projection = maxProjection(obj)
            projection = obj.imstack(:,:,1);
            for i=2:obj.numFrames
                tempImage = obj.imstack(:,:,i);
                maxPositions = projection < tempImage;
                projection(maxPositions) = tempImage(maxPositions);
            end
        end
        
        function projection = meanProjection(obj)
            projection = obj.imstack(:,:,1);
            for i=2:obj.numFrames
                tempImage = obj.imstack(:,:,i);
                projection = projection + tempImage;
            end
            projection = projection / obj.numFrames;
        end
        
        function strip = imstrip(obj, by)
            imageSequence = 1:by:obj.numFrames;
            strip = zeros(obj.height, obj.width * length(imageSequence));
            counter = 1;
            for i=imageSequence
                strip(1:obj.height, counter:(counter+obj.width-1)) = obj.imstack(:,:,i);
                counter = counter +obj.width;
            end
        end
        
    end
    
end

