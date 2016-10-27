%% p53Cinema Data in source object
% The data captured in a set of images is used to create many data features
% including the signal traces of a cell, spatial tracking information, and
% in silico temporal based synchronization. A source object will contain
% all the data extracted from a set of images in format that is most
% convenient with the method used to generate the data. From the source
% object, derivative data organization or presentation schemes can be
% derived that make the data convenient to interact with.
classdef p53Cinema_singleCellAnnotation_object_imageViewer < handle
    properties
        gui_imageViewer;
        gui_contrast;
        gui_zoomMap;
        obj_featureTracker;
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
        pixelRowCol;
        pixelxy;
        imageResizeFactor;
        
        selectedCell;
        potentialMergeCell;
        
        contrastHistogram;
        
        zoomArray = [1, 0.8, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1];
        zoomIndex = 1;
    end
    events
        
    end
    methods
        %% object constructor
        %
        function obj = p53Cinema_singleCellAnnotation_object_imageViewer(master)
            obj.master = master;
            fileManagerHandles = guidata(master.obj_fileManager.gui_fileManager);
            %% get image info from first image
            %
            IM = imread(fullfile(master.obj_fileManager.rawdatapath,master.obj_fileManager.currentImageFilename),1);
            obj.imageResizeFactor = obj.master.obj_fileManager.imageResizeFactor;
            IM = imresize(IM, obj.imageResizeFactor);
            obj.image_width = size(IM,2);
            obj.image_height = size(IM,1);
            obj.image_widthChar = obj.image_width/master.ppChar(1);
            obj.image_heightChar = obj.image_height/master.ppChar(2);
            obj.obj_featureTracker = p53Cinema_singleCellAnnotation_object_featureTracker(master);
            %% Preload images
            %
            if master.obj_fileManager.preallocateMode
                master.obj_fileManager.setProgressBar(1,master.obj_fileManager.numImages,'Loading status');
                obj.imageBuffer = uint16(zeros(obj.image_height, obj.image_width, master.obj_fileManager.numImages));
                for i=1:master.obj_fileManager.numImages
                    master.obj_fileManager.setProgressBar(i,master.obj_fileManager.numImages,'Loading status');
                    % Load image
                    referenceImage = imresize(obj.readImage(i), obj.imageResizeFactor);
                    
                    if(get(fileManagerHandles.hcheckboxPrimaryBackground, 'Value'))
                        %referenceImage = imbackground(referenceImage, 10, 100);
                        obj.imageBuffer(:,:,i) = uint16(referenceImage);
                    else
                        obj.imageBuffer(:,:,i) = referenceImage;
                    end
                    
                    % Preprocess and find local maxima
                    if(obj.master.obj_fileManager.preprocessMode)
                        timepoint = master.obj_fileManager.currentImageTimepoints(i);
                        
                        predictionMode = master.obj_fileManager.predictionMode;
                        switch predictionMode
                            case 'Intensity'
                                localMaxima = getImageMaxima_Intensity(referenceImage, obj.master.obj_fileManager.cellSize);
                            case 'Shape'
                                localMaxima = getImageMaxima_Shape(referenceImage, obj.master.obj_fileManager.cellSize);
                        end
                        
                        obj.obj_featureTracker.centroidsLocalMaxima.insertCentroids(timepoint, localMaxima);
                    end
                end
                master.obj_fileManager.setProgressBar(0,master.obj_fileManager.numImages,'Loading status');
            end
            obj.selectedCell = 0;
            obj.potentialMergeCell = 0;
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
            myRelativePoint = myCurrentPoint - axesOrigin([1,2]);
            if any(myRelativePoint<0) || ...
                    myRelativePoint(1) > axesOrigin(3) || ...
                    myRelativePoint(2) > axesOrigin(4)
                obj.pixelxy = [];
                obj.pixelRowCol = [];
            else
                myXLim = get(handles.axesImageViewer,'XLim');
                myYLim = get(handles.axesImageViewer,'YLim');
                
                x = myRelativePoint(1)/axesOrigin(3)*(myXLim(2)-myXLim(1))+myXLim(1);
                y = (axesOrigin(4)-myRelativePoint(2))/axesOrigin(4)*(myYLim(2)-myYLim(1))+myYLim(1);

                obj.pixelxy = [x,y];
                obj.pixelxy = ceil(obj.pixelxy);
                obj.pixelRowCol = fliplr(obj.pixelxy);
                
            end
            out = obj.pixelxy;
        end
        %% getPixelRowCol
        % Find the location of mouse relative to the image in the viewer.
        % This function takes into account that the axes YDir is reversed
        % and that the point on the disply may not be 1:1 with the pixels
        % of the image.
        function out = getPixelRowCol(obj)
            myCurrentPoint = get(obj.gui_imageViewer,'CurrentPoint');
            handles = guidata(obj.gui_imageViewer);
            axesOrigin = get(handles.axesImageViewer,'Position');
            myRelativePoint = myCurrentPoint - axesOrigin([1,2]);
            if any(myRelativePoint<0) || ...
                    myRelativePoint(1) > axesOrigin(3) || ...
                    myRelativePoint(2) > axesOrigin(4)
                obj.pixelRowCol = [];
                obj.pixelxy = [];
            else
                myXLim = get(handles.axesImageViewer,'XLim');
                myYLim = get(handles.axesImageViewer,'YLim');
                
                x = myRelativePoint(1)/axesOrigin(3)*(myXLim(2)-myXLim(1))+myXLim(1);
                y = (axesOrigin(4)-myRelativePoint(2))/axesOrigin(4)*(myYLim(2)-myYLim(1))+myYLim(1);
                obj.pixelRowCol = [y,x];
                obj.pixelRowCol = ceil(obj.pixelRowCol);
                obj.pixelxy = fliplr(obj.pixelRowCol);
                
            end
            out = obj.pixelRowCol;
        end
        %% resetContrast
        % Set the contrast to reflect the full uint16 range, i.e. 0-(2^16-1).
        function obj = resetContrast(obj)
            handles = guidata(obj.gui_imageViewer);
            colormap(handles.axesImageViewer,gray((2^16-1)));
        end
        %% findImageHistogram
        function obj = findImageHistogram(obj)
            obj.contrastHistogram = hist(reshape(obj.currentImage,1,[]),0:1:(2^16-1));
        end
        %% AutoContrast
        function obj = autoContrast(obj)
            handles = guidata(obj.gui_contrast);
            if(obj.master.obj_fileManager.preallocateMode)
                validPixels = obj.imageBuffer(find(obj.imageBuffer > 0));
                randomSample = validPixels(ceil(rand(1,100000) * length(validPixels) - 1) + 1);
                minValue = min(randomSample(randomSample > quantile(randomSample, 0.01)));
                maxValue = max(randomSample(randomSample < quantile(randomSample(:), 0.9999)));
            else
                minValue = min(obj.currentImage);
                maxValue = max(obj.currentImage);
            end
            if(isempty(minValue))
                minValue = 0;
            end
            if(isempty(maxValue))
                maxValue = 2^16 - 1;
            end
            set(handles.sliderMin,'Value', double(minValue)/(2^16-1));
            set(handles.sliderMax,'Value', double(maxValue)/(2^16-1));
            obj.newColormapFromContrastHistogram;
        end
        %% newColormapFromContrastHistogram
        function obj = newColormapFromContrastHistogram(obj)
            handles = guidata(obj.gui_contrast);
            sstep = get(handles.sliderMin,'SliderStep');
            mymin = ceil(get(handles.sliderMin,'Value')/sstep(1));
            mymax = ceil(get(handles.sliderMax,'Value')/sstep(1));
            cmap = colormap(gray(mymax-mymin+1));
            cmap = vertcat(zeros(mymin,3),cmap,ones((2^16-1)-mymax,3));
            handles2 = guidata(obj.gui_imageViewer);
            colormap(handles2.axesImageViewer,cmap);
            handles3 = guidata(obj.gui_zoomMap);
            colormap(handles3.axesZoomMap,cmap);
        end
        %% findImageHistogram
        function obj = updateContrastHistogram(obj)
            obj.findImageHistogram;
            handles = guidata(obj.gui_contrast);
            plot(handles.axesContrast,log(obj.contrastHistogram+1));
        end
        %% launchImageViewer
        % A indiosyncrasy of using an object wrapper for guis is that the
        % object must be constructed before the guis can have access to its
        % properties. Therefore this method should be called immediately
        % following the construction of the object.
        function obj = launchImageViewer(obj)
            %% Launch the gui
            %
            obj.gui_imageViewer = p53Cinema_singleCellAnnotation_gui_imageViewer(obj.master, obj.master.obj_fileManager.maxHeight);
            obj.gui_contrast = p53Cinema_singleCellAnnotation_gui_contrast(obj.master);            
            obj.gui_zoomMap = p53Cinema_singleCellAnnotation_gui_zoomMap(obj.master);
            obj.autoContrast;
            obj.setFrame(1);
        end
        
        %% Frame switching functions
        function setFrame(obj, frame)
            frame = min(max(frame,1), obj.master.obj_fileManager.numImages);
            
            obj.currentFrame = frame;
            obj.currentTimepoint = obj.master.obj_fileManager.currentImageTimepoints(frame);
            
            imageViewerHandles = guidata(obj.gui_imageViewer);
            fileManagerHandles = guidata(obj.master.obj_fileManager.gui_fileManager);
            
            set(imageViewerHandles.htextFrameNumber, 'String', ['Timepoint:', num2str(obj.currentTimepoint), '/', num2str(obj.master.obj_fileManager.maxTimepoint)]);
            
            % Use the image in the buffer is the user is scanning in the
            % primary image channel and data has been preallocated
            if(obj.master.obj_fileManager.preallocateMode && get(fileManagerHandles.hpopupPrimaryChannel, 'Value') == get(imageViewerHandles.hpopupViewerChannel, 'Value'))
                obj.currentImage = obj.imageBuffer(:,:,frame);
            else
                % Load images one by one
                viewerChannel = getCurrentPopupString(imageViewerHandles.hpopupViewerChannel);
                filename = obj.master.obj_fileManager.getFilename(obj.master.obj_fileManager.selectedPosition, viewerChannel, obj.currentTimepoint);
                if(~isempty(filename))
                    IM = imresize(imread(fullfile(obj.master.obj_fileManager.rawdatapath, filename)), obj.imageResizeFactor);
                    if(get(imageViewerHandles.hcheckboxPreprocessFrame, 'Value'))
                        IM = uint16(imbackground(IM, 10, 100));
                    end
                    obj.currentImage = IM;
                end
                % If centroids have not been identified during
                % preallocation and preprocessing, use this opportunity to
                % find them.
                if(~obj.master.obj_fileManager.preprocessMode)
                    timepoint = obj.currentTimepoint;
                    
                    predictionMode = obj.master.obj_fileManager.predictionMode;
                    switch predictionMode
                        case 'Intensity'
                            localMaxima = getImageMaxima_Intensity(obj.currentImage, obj.master.obj_fileManager.cellSize);
                        case 'Shape'
                            localMaxima = getImageMaxima_Shape(obj.currentImage, obj.master.obj_fileManager.cellSize);
                    end
                    obj.obj_featureTracker.centroidsLocalMaxima.insertCentroids(timepoint, localMaxima);
                end
            end
            %obj.updateContrastHistogram;
            
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
       
        %% Image manipulation
        function IM = readImage(obj, index)
            fname = fullfile(obj.master.obj_fileManager.rawdatapath,obj.master.obj_fileManager.currentImageFilename);
            IM = imread(fname,obj.master.obj_fileManager.currentImageTimepoints(index));
        end
        
        function setImage(obj)
            handles = guidata(obj.gui_imageViewer);
            handlesZoomMap = guidata(obj.gui_zoomMap);
            featureTrackerHandles = guidata(obj.obj_featureTracker.gui_featureTracker);

            set(handles.sourceImage,'CData',obj.currentImage);
            set(handlesZoomMap.sourceImage,'CData',obj.currentImage);
            sliderStep = get(handles.hsliderExploreStack,'SliderStep');
            set(handles.hsliderExploreStack,'Value',sliderStep(1)*(obj.currentFrame-1));
            
            % Set tracked centroids patch
            [trackedCentroids, currentFrameCentroids] = obj.obj_featureTracker.centroidsFeatures.getCentroids(obj.currentTimepoint);
            set(handles.trackedCellsPatch, 'XData', trackedCentroids(:,2), 'YData', trackedCentroids(:,1));

            if(obj.selectedCell)
                % Set selected cell patch
                selectedCentroid = obj.obj_featureTracker.centroidsFeatures.getCentroid(obj.currentTimepoint, obj.selectedCell);
                set(handles.selectedCellPatch, 'XData', selectedCentroid(:,2), 'YData', selectedCentroid(:,1));
            else
                set(handles.selectedCellPatch, 'XData', [], 'YData', []);
            end
            
            lookupRadius = obj.obj_featureTracker.getDistanceRadius;
            currentPoint = obj.pixelxy;
            if(~isempty(currentPoint))
                highlightedCentroids = obj.obj_featureTracker.centroidsLocalMaxima.getCentroidsInRange(obj.currentTimepoint, fliplr(currentPoint), lookupRadius);
                set(handles.cellsInRangePatch, 'XData', highlightedCentroids(:,2), 'YData', highlightedCentroids(:,1));
                
                closestCentroid = obj.obj_featureTracker.centroidsLocalMaxima.getClosestCentroid(obj.currentTimepoint, fliplr(currentPoint), lookupRadius);
                set(handles.closestCellPatch, 'XData', closestCentroid(:,2), 'YData', closestCentroid(:,1));
            end
        end
        
        %%
        %
        function obj = zoomIn(obj)
            if obj.zoomIndex < length(obj.zoomArray)
                obj.zoomIndex = obj.zoomIndex + 1;
            else
                return
            end
            %%
            % get the patch position
            newHalfWidth = obj.image_width*obj.zoomArray(obj.zoomIndex)/2;
            newHalfHeight = obj.image_height*obj.zoomArray(obj.zoomIndex)/2;
            handles = guidata(obj.gui_zoomMap);
            set(handles.zoomMapRect,'Visible','off');
            myVertices = get(handles.zoomMapRect,'Vertices');
            myCenter = (myVertices(3,:)-myVertices(1,:))/2+myVertices(1,:);
            myVertices(1,:) = round(myCenter + [-newHalfWidth,-newHalfHeight]);
            myVertices(2,:) = round(myCenter + [newHalfWidth,-newHalfHeight]);
            myVertices(3,:) = round(myCenter + [newHalfWidth,newHalfHeight]);
            myVertices(4,:) = round(myCenter + [-newHalfWidth,newHalfHeight]);
            set(handles.zoomMapRect,'Vertices',myVertices);
            set(handles.zoomMapRect,'Visible','on');
            obj.zoomPan;
        end
        %%
        %
        function obj = zoomOut(obj)
            if obj.zoomIndex > 2
                obj.zoomIndex = obj.zoomIndex - 1;
            elseif obj.zoomIndex == 2
                obj.zoomTop;
                return
            else
                return
            end
            %%
            % get the patch position
            newHalfWidth = obj.image_width*obj.zoomArray(obj.zoomIndex)/2;
            newHalfHeight = obj.image_height*obj.zoomArray(obj.zoomIndex)/2;
            handles = guidata(obj.gui_zoomMap);
            set(handles.zoomMapRect,'Visible','off');
            myVertices = get(handles.zoomMapRect,'Vertices');
            myCenter = (myVertices(3,:)-myVertices(1,:))/2+myVertices(1,:);
            %%
            % make sure the center does not move the rectangle |off screen|
            if myCenter(1) - newHalfWidth < 1
                myCenter(1) = newHalfWidth + 1;
            elseif myCenter(1) + newHalfWidth > obj.image_width
                myCenter(1) = obj.image_width - newHalfWidth;
            end
            
            if myCenter(2) - newHalfHeight < 1
                myCenter(2) = newHalfHeight + 1;
            elseif myCenter(2) + newHalfHeight > obj.image_height
                myCenter(2) = obj.image_height - newHalfHeight;
            end
            
            myVertices(1,:) = round(myCenter + [-newHalfWidth,-newHalfHeight]);
            myVertices(2,:) = round(myCenter + [newHalfWidth,-newHalfHeight]);
            myVertices(3,:) = round(myCenter + [newHalfWidth,newHalfHeight]);
            myVertices(4,:) = round(myCenter + [-newHalfWidth,newHalfHeight]);
            set(handles.zoomMapRect,'Vertices',myVertices);
            set(handles.zoomMapRect,'Visible','on');
            obj.zoomPan;
        end
        %%
        %
        function obj = zoomTop(obj)
            obj.zoomIndex = 1;
            handles = guidata(obj.gui_zoomMap);
            set(handles.zoomMapRect,'Visible','off');
            set(handles.zoomMapRect,'Vertices',[1, 1;obj.image_width, 1;obj.image_width, obj.image_height;1, obj.image_height])
            obj.zoomPan;
        end
        %%
        %
        function obj = zoomPan(obj)
            % Adjust the imageViewer limits to reflect the zoomMapRect
            % position
            handles = guidata(obj.gui_zoomMap);
            myVertices = get(handles.zoomMapRect,'Vertices');
            handles2 = guidata(obj.gui_imageViewer);
            newXLim = [myVertices(1,1)-0.5,myVertices(3,1)+0.5];
            newYLim = [myVertices(1,2)-0.5,myVertices(3,2)+0.5];
            set(handles2.axesImageViewer,'XLim',newXLim);
            set(handles2.axesImageViewer,'YLim',newYLim);
        end
        %%
        %
        function obj = zoomRecenter(obj, centroid)
            % The centroid received should be in the [centroid_row,
            % centroid_col] format
            % Check that the centroid does not go out of the boundaries of
            % the image given the zoom.
            newHalfWidth = obj.image_width*obj.zoomArray(obj.zoomIndex)/2;
            newHalfHeight = obj.image_height*obj.zoomArray(obj.zoomIndex)/2;
            centroid(2) = max(centroid(2), newHalfWidth);
            centroid(2) = min(centroid(2), obj.image_width-newHalfWidth);
            centroid(1) = max(centroid(1), newHalfHeight);
            centroid(1) = min(centroid(1), obj.image_height-newHalfHeight);
            
            % Define new vertices
            handles = guidata(obj.gui_zoomMap);
            newVertices = [centroid(2) - newHalfWidth, centroid(1) - newHalfHeight; ...
                centroid(2) + newHalfWidth-1, centroid(1) - newHalfHeight; ...
                centroid(2) + newHalfWidth-1, centroid(1) + newHalfHeight-1; ...
                centroid(2) - newHalfWidth, centroid(1) + newHalfHeight-1];
            set(handles.zoomMapRect,'Vertices', newVertices);
            guidata(obj.gui_zoomMap, handles);
            obj.zoomPan;
        end
        %% Delete function
        function delete(obj)
            obj.obj_featureTracker.delete;
            delete(obj.gui_contrast);
            delete(obj.gui_imageViewer);
            delete(obj.gui_zoomMap);
        end
        %%
        function str = getCurrentPopupString(hh)
            %# getCurrentPopupString returns the currently selected string in the popupmenu with handle hh
            
            %# could test input here
            if ~ishandle(hh) || strcmp(get(hh,'Type'),'popupmenu')
                error('getCurrentPopupString needs a handle to a popupmenu as input')
            end
            
            %# get the string - do it the readable way
            list = get(hh,'String');
            val = get(hh,'Value');
            if iscell(list)
                str = list{val};
            else
                str = list(val,:);
            end
        end

    end
end