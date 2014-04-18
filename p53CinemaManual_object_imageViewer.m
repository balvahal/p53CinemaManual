%% p53Cinema Data in source object
% The data captured in a set of images is used to create many data features
% including the signal traces of a cell, spatial tracking information, and
% in silico temporal based synchronization. A source object will contain
% all the data extracted from a set of images in format that is most
% convenient with the method used to generate the data. From the source
% object, derivative data organization or presentation schemes can be
% derived that make the data convenient to interact with.
classdef p53CinemaManual_object_imageViewer < handle
    properties
        gui_imageViewer;
        gui_contrast;
        gui_zoomMap;
        obj_cellTracker;
        master;
        
        isMyButtonDown = false;
        
        imageOrigin;
        displaySize;
        
        image_width;
        image_height;
        image_widthChar;
        image_heightChar;
        
        imageBuffer;
        currentImage;
        currentTimepoint;
        currentFrame = 1;
        pixelxy;
        
        selectedCell;
        
        contrastHistogram;
    end
    events
        
    end
    methods
        %% object constructor
        % 
        function obj = p53CinemaManual_object_imageViewer(master)
            obj.master = master;
            %% get image info from first image
            %
            myinfo = imfinfo(fullfile(master.obj_fileManager.rawdatapath,master.obj_fileManager.currentImageFilenames{1}));
            obj.image_width = myinfo.Width;
            obj.image_height = myinfo.Height;
            obj.image_widthChar = obj.image_width/master.ppChar(1);
            obj.image_heightChar = obj.image_height/master.ppChar(2);
            %% Preload images
            %
            
            obj.obj_cellTracker = p53CinemaManual_object_cellTracker(master);
            if master.obj_fileManager.preallocateMode
                obj.imageBuffer = uint8(zeros(obj.image_height, obj.image_width, master.obj_fileManager.numImages));
                for i=1:master.obj_fileManager.numImages
                    obj.imageBuffer(:,:,i) = obj.readImage(i);
                end
                %% Preprocess images
                %
                for i=1:master.obj_fileManager.numImages
                    timepoint = master.obj_fileManager.currentImageTimepoints(i);
                    if(strcmp(master.obj_fileManager.maximaChannel, master.obj_fileManager.selectedChannel))
                        referenceImage = obj.imageBuffer(:,:,i);
                    else
                        referenceImageName = master.obj_fileManager.getFilename(master.obj_fileManager.selectedPosition, master.obj_fileManager.maximaChannel, master.obj_fileManager.currentImageTimepoints(i));
                        referenceImage = imread(fullfile(master.obj_fileManager.rawdatapath, referenceImageName));
                    end
                    localMaxima = getImageMaxima(referenceImage);
                    obj.obj_cellTracker.centroidsLocalMaxima.insertCentroids(timepoint, localMaxima);
                end
            end
            obj.selectedCell = 0;
            obj.setFrame(1);
            
            
        end
        %% getPixelxy
        % Find the location of mouse relative to the image in the viewer.
        % This function takes into account that the axes YDir is reversed
        % and that the point on the disply may not be 1:1 with the pixels
        % of the image.
        function out = getPixelxy(obj)
            myCurrentPoint = get(obj.gui_imageViewer,'CurrentPoint');
            handles = guidata(obj.gui_imageViewer);
            axesOrigin = get(handles.axesImageViewer,'Position');
            myRelativePoint = myCurrentPoint - axesOrigin(1:2);
            if any(myRelativePoint<0) || ...
                    myRelativePoint(1) > obj.image_widthChar || ...
                    myRelativePoint(2) > obj.image_heightChar
                obj.pixelxy = [];
            else
                x = ceil(myRelativePoint(1)*obj.master.ppChar(1));
                y = ceil((axesOrigin(4)-myRelativePoint(2))*obj.master.ppChar(2));
                obj.pixelxy = [x,y];
            end
            out = obj.pixelxy;
        end
        %% resetContrast
        % Set the contrast to reflect the full uint8 range, i.e. 0-255.
        function obj = resetContrast(obj)
            handles = guidata(obj.gui_imageViewer);
            colormap(handles.axesImageViewer,gray(255));
        end
        %% findImageHistogram
        % Assumes image is uint8 0-255.
        function obj = findImageHistogram(obj)
            obj.contrastHistogram = hist(reshape(obj.currentImage,1,[]),-0.5:1:255.5);
        end
        %% newColormapFromContrastHistogram
        % Assumes image is uint8 0-255.
        function obj = newColormapFromContrastHistogram(obj)
            handles = guidata(obj.gui_contrast);
            sstep = get(handles.sliderMin,'SliderStep');
            mymin = ceil(get(handles.sliderMin,'Value')/sstep(1));
            mymax = ceil(get(handles.sliderMax,'Value')/sstep(1));
            cmap = colormap(gray(mymax-mymin+1));
            cmap = vertcat(zeros(mymin,3),cmap,ones(255-mymax,3));
            handles2 = guidata(obj.gui_imageViewer);
            colormap(handles2.axesImageViewer,cmap);
        end
        %% findImageHistogram
        % Assumes image is uint8 0-255.
        function obj = updateContrastHistogram(obj)
            obj.findImageHistogram;
            handles = guidata(obj.gui_contrast);
            plot(handles.axesContrast,obj.contrastHistogram);
        end
        %% launchImageViewer
        % A indiosyncrasy of using an object wrapper for guis is that the
        % object must be constructed before the guis can have access to its
        % properties. Therefore this method should be called immediately
        % following the construction of the object.
        function obj = launchImageViewer(obj)
            %% Launch the gui
            %
            obj.gui_imageViewer = p53CinemaManual_gui_imageViewer(obj.master);
            obj.gui_contrast = p53CinemaManual_gui_contrast(obj.master);
            obj.gui_zoomMap = p53CinemaManual_gui_zoomMap(obj.master);       
        end
        
        %% Frame switching functions
        function setFrame(obj, frame)
            frame = min(max(frame,1), obj.master.obj_fileManager.numImages);
            obj.currentFrame = frame;
            if(obj.master.obj_fileManager.preallocateMode)
                obj.currentImage = obj.imageBuffer(:,:,frame);
            else
                obj.currentImage = obj.readImage(frame);
            end
            obj.currentTimepoint = obj.master.obj_fileManager.currentImageTimepoints(frame);
            obj.setImage;
        end
        
        function nextFrame(obj)
            obj.setFrame(obj.currentFrame + 1);
            obj.setImage;
        end
        
        function previousFrame(obj)
            obj.setFrame(obj.currentFrame - 1);
            obj.setImage;
        end
        
        function setSelectedCell(obj, selectedCell)
            obj.selectedCell = selectedCell;
        end
        
        function deleteSelectedCellTrack(obj)
            obj.obj_cellTracker.centroidsTracks.deleteTrack(obj.selectedCell);
            obj.setSelectedCell(0);
            obj.obj_cellTracker.setAvailableCells;
            obj.obj_cellTracker.stopTracking;
            obj.setImage;
        end
        
        %% Image manipulation
        function IM = readImage(obj, index)
            IM = imread(fullfile(obj.master.obj_fileManager.rawdatapath,obj.master.obj_fileManager.currentImageFilenames{index}));
            IM = uint8(bitshift(IM, -4));
        end
        
        function setImage(obj)
            if(isempty(obj.gui_imageViewer))
                return;
            end
            
            handles = guidata(obj.gui_imageViewer);
            set(handles.sourceImage,'CData',obj.master.obj_imageViewer.currentImage);
            sliderStep = get(handles.hsliderExploreStack,'SliderStep');
            set(handles.hsliderExploreStack,'Value',sliderStep(1)*(obj.master.obj_imageViewer.currentFrame-1));
            
            trackedCentroids = obj.master.obj_imageViewer.obj_cellTracker.centroidsTracks.getCentroids(obj.master.obj_imageViewer.currentTimepoint);
            set(handles.trackedCellsPatch, 'XData', trackedCentroids(:,2), 'YData', trackedCentroids(:,1));
            
            if(obj.master.obj_imageViewer.selectedCell)
                selectedCentroid = obj.master.obj_imageViewer.obj_cellTracker.centroidsTracks.getCentroid(obj.master.obj_imageViewer.currentTimepoint, obj.master.obj_imageViewer.selectedCell);
                set(handles.selectedCellPatch, 'XData', selectedCentroid(:,2), 'YData', selectedCentroid(:,1));
            else
                set(handles.selectedCellPatch, 'XData', [], 'YData', []);
            end
            
            if(~obj.master.obj_fileManager.preprocessMode)
                return;
            end
            
            lookupRadius = obj.master.obj_imageViewer.obj_cellTracker.getDistanceRadius;
            currentPoint = obj.master.obj_imageViewer.pixelxy;
            if(~isempty(currentPoint))
                highlightedCentroids = obj.master.obj_imageViewer.obj_cellTracker.centroidsLocalMaxima.getCentroidsInRange(master.obj_imageViewer.currentTimepoint, fliplr(currentPoint), lookupRadius);
                set(handles.cellsInRangePatch, 'XData', highlightedCentroids(:,2), 'YData', highlightedCentroids(:,1));
                
                closestCentroid = obj.master.obj_imageViewer.obj_cellTracker.centroidsLocalMaxima.getClosestCentroid(master.obj_imageViewer.currentTimepoint, fliplr(currentPoint), lookupRadius);
                set(handles.closestCellPatch, 'XData', closestCentroid(:,2), 'YData', closestCentroid(:,1));
            end
        end

        
        %% Delete function
        function delete(obj)
            obj.obj_cellTracker.delete;
            delete(obj.gui_contrast);
            delete(obj.gui_imageViewer);
            delete(obj.gui_zoomMap);
        end
    end
end