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
        function obj = p53CinemaManual_object_imageViewer(master)
            obj.master = master;
            %% get image info from first image
            %
            IM = imread(fullfile(master.obj_fileManager.rawdatapath,master.obj_fileManager.currentImageFilenames{1}));
            obj.imageResizeFactor = obj.master.obj_fileManager.imageResizeFactor;
            IM = imresize(IM, obj.imageResizeFactor);
            obj.image_width = size(IM,2);
            obj.image_height = size(IM,1);
            obj.image_widthChar = obj.image_width/master.ppChar(1);
            obj.image_heightChar = obj.image_height/master.ppChar(2);
            %% Preload images
            %
            
            obj.obj_cellTracker = p53CinemaManual_object_cellTracker(master);
            if master.obj_fileManager.preallocateMode
                master.obj_fileManager.setProgressBar(1,master.obj_fileManager.numImages,'Loading status');
                obj.imageBuffer = uint16(zeros(obj.image_height, obj.image_width, master.obj_fileManager.numImages));
                tic
                for i=1:master.obj_fileManager.numImages
                    master.obj_fileManager.setProgressBar(i,master.obj_fileManager.numImages,'Loading status');
                    % Load image
                    referenceImage = imresize(obj.readImage(i), obj.imageResizeFactor);
                    referenceImage = medfilt2(referenceImage, [3,3]);
                    %obj.imageBuffer(:,:,i) = uint8(adapthisteq(imnormalize(referenceImage)) * 255);
                    obj.imageBuffer(:,:,i) = uint8(imnormalize(imbackground(referenceImage, 10, 100)) * 255);
                    %obj.imageBuffer(:,:,i) = uint8(imnormalize(referenceImage) * 255);
                    
                    % Preprocess and find local maxima
                    if(obj.master.obj_fileManager.preprocessMode)
                        timepoint = master.obj_fileManager.currentImageTimepoints(i);
                        if(~strcmp(master.obj_fileManager.maximaChannel, master.obj_fileManager.selectedChannel))
                            referenceImageName = master.obj_fileManager.getFilename(master.obj_fileManager.selectedPosition, master.obj_fileManager.maximaChannel, master.obj_fileManager.currentImageTimepoints(i));
                            referenceImage = imread(fullfile(master.obj_fileManager.rawdatapath, referenceImageName));
                            referenceImage = medfilt2(referenceImage, [3,3]);
                            referenceImage = imbackground(referenceImage, 10, 100);
                            referenceImage = imresize(referenceImage, obj.imageResizeFactor);
                        end
                        localMaxima = getImageMaxima(referenceImage, obj.master.obj_fileManager.cellSize);
                        obj.obj_cellTracker.centroidsLocalMaxima.insertCentroids(timepoint, localMaxima);
                    end
                end
                toc
                
                %Get the range of the dataset
%                 quantileRange = quantile(double(obj.imageBuffer(:)), [0.01, 0.99]);
%                 obj.imageBuffer = double((obj.imageBuffer - quantileRange(1))) / double(quantileRange(2)) * (2^16-1);
%                 obj.imageBuffer = uint8(bitshift(uint16(obj.imageBuffer), -8));
                
                master.obj_fileManager.setProgressBar(0,master.obj_fileManager.numImages,'Loading status');
            end
            obj.selectedCell = 0;
            obj.potentialMergeCell = 0;
            %obj.setFrame(1);
            
            
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
            handles3 = guidata(obj.gui_zoomMap);
            colormap(handles3.axesZoomMap,cmap);
        end
        %% findImageHistogram
        % Assumes image is uint8 0-255.
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
            obj.gui_imageViewer = p53CinemaManual_gui_imageViewer(obj.master, obj.master.obj_fileManager.maxHeight);
            obj.gui_contrast = p53CinemaManual_gui_contrast(obj.master);
            obj.gui_zoomMap = p53CinemaManual_gui_zoomMap(obj.master);
            obj.setFrame(1);
        end
        
        %% Frame switching functions
        function setFrame(obj, frame)
            previousFrame = obj.currentFrame;
            frame = min(max(frame,1), obj.master.obj_fileManager.numImages);
            directionality = sign(frame - previousFrame);
            
            obj.currentFrame = frame;
            obj.currentTimepoint = obj.master.obj_fileManager.currentImageTimepoints(frame);
            
            imageViewerHandles = guidata(obj.gui_imageViewer);
            fileManagerHandles = guidata(obj.master.obj_fileManager.gui_fileManager);
            
            set(imageViewerHandles.htextFrameNumber, 'String', ['Timepoint:', num2str(obj.currentTimepoint), '/', num2str(obj.master.obj_fileManager.maxTimepoint)]);
            
            if(obj.master.obj_fileManager.preallocateMode && get(fileManagerHandles.hpopupPimaryChannel, 'Value') == get(imageViewerHandles.hpopupViewerChannel, 'Value'))
                obj.currentImage = obj.imageBuffer(:,:,frame);
            else
                viewerChannel = getCurrentPopupString(imageViewerHandles.hpopupViewerChannel);
                filename = obj.master.obj_fileManager.getFilename(obj.master.obj_fileManager.selectedPosition, viewerChannel, obj.currentTimepoint);
                if(~isempty(filename))
                    IM = imresize(imread(fullfile(obj.master.obj_fileManager.rawdatapath, filename)), obj.imageResizeFactor);
                    IM = imnormalize_quantile(IM, 1) * 255;
                    if(get(imageViewerHandles.hcheckboxPreprocessFrame, 'Value'))
                        IM = medfilt2(IM, [3,3]);
                        IM = uint8(imbackground(IM, 10, 100));
                    end
                    %IM = uint8(imnormalize_quantile(IM, 1) * 255);
                    obj.currentImage = IM;
                end
            end
            %obj.updateContrastHistogram;
            
            % Predictive tracking
            if(obj.master.obj_fileManager.preprocessMode && obj.obj_cellTracker.isTracking && ~obj.obj_cellTracker.centroidsTracks.getValue(obj.currentTimepoint, obj.selectedCell))
                d1 = Inf; d2 = Inf;
                if(obj.currentFrame > 1)
                    referenceTimepoint = obj.master.obj_fileManager.currentImageTimepoints(frame-1);
                    referenceCentroid = obj.obj_cellTracker.centroidsTracks.getCentroid(referenceTimepoint, obj.selectedCell);
                    [prediction1, ~, d1] = obj.obj_cellTracker.centroidsLocalMaxima.getClosestCentroid(obj.currentTimepoint, referenceCentroid, obj.obj_cellTracker.getDistanceRadius);
                end
                if(obj.currentFrame < length(obj.master.obj_fileManager.currentImageTimepoints))
                    referenceTimepoint = obj.master.obj_fileManager.currentImageTimepoints(frame+1);
                    referenceCentroid = obj.obj_cellTracker.centroidsTracks.getCentroid(referenceTimepoint, obj.selectedCell);
                    [prediction2, ~, d2] = obj.obj_cellTracker.centroidsLocalMaxima.getClosestCentroid(obj.currentTimepoint, referenceCentroid, obj.obj_cellTracker.getDistanceRadius);
                end
                if(~isinf(d1) || ~isinf(d2))
                    if(d1 < d2)
                        obj.obj_cellTracker.centroidsTracks.setCentroid(obj.currentTimepoint, obj.selectedCell, prediction1, 0);
                    else
                        obj.obj_cellTracker.centroidsTracks.setCentroid(obj.currentTimepoint, obj.selectedCell, prediction2, 0);
                    end
                end
            end
            
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
            obj.obj_cellTracker.deleteCellData(obj.selectedCell);
            obj.setSelectedCell(0);
            obj.obj_cellTracker.setAvailableCells;
            obj.obj_cellTracker.stopTracking;
            obj.setImage;
        end
        
        %% Image manipulation
        function IM = readImage(obj, index)
            fname = fullfile(obj.master.obj_fileManager.rawdatapath,obj.master.obj_fileManager.currentImageFilenames{index});
            IM = imread(fname);
            %IM = uint8(bitshift(IM, -4));
        end
        
        function setImage(obj)
            handles = guidata(obj.gui_imageViewer);
            handlesZoomMap = guidata(obj.gui_zoomMap);
            set(handles.sourceImage,'CData',obj.currentImage);
            set(handlesZoomMap.sourceImage,'CData',obj.currentImage);
            sliderStep = get(handles.hsliderExploreStack,'SliderStep');
            set(handles.hsliderExploreStack,'Value',sliderStep(1)*(obj.currentFrame-1));
            
            % Set division event patch
            cellFateEventCentroids = vertcat(obj.obj_cellTracker.centroidsDivisions.getCentroids(obj.currentTimepoint), ...
                obj.obj_cellTracker.centroidsDeath.getCentroids(obj.currentTimepoint));
            set(handles.cellFateEventPatch, 'XData', cellFateEventCentroids(:,2), 'YData', cellFateEventCentroids(:,1));
            
            set(handles.currentCellTrace, 'xdata', [], 'ydata', []);            
            if(obj.selectedCell)
                % Set selected cell patch
                selectedCentroid = obj.obj_cellTracker.centroidsTracks.getCentroid(obj.currentTimepoint, obj.selectedCell);
                set(handles.selectedCellPatch, 'XData', selectedCentroid(:,2), 'YData', selectedCentroid(:,1));
                dividingCell = any(obj.obj_cellTracker.centroidsDivisions.getCentroid(obj.currentTimepoint, obj.selectedCell) > 0);
                deathCell = any(obj.obj_cellTracker.centroidsDeath.getCentroid(obj.currentTimepoint, obj.selectedCell) > 0);
                
                currentTrack = obj.obj_cellTracker.centroidsTracks.getCellTrack(obj.selectedCell);
                set(handles.currentCellTrace, 'xdata', currentTrack(currentTrack(:,2) > 0,2), 'ydata', currentTrack(currentTrack(:,2) > 0,1));
                if(sum(obj.obj_cellTracker.centroidsTracks.getCentroid(obj.currentTimepoint, obj.selectedCell) == 0) > 0)
                    set(handles.currentCellTrace, 'color', 'green');
                else
                    set(handles.currentCellTrace, 'color', 'red');
                end
                
                currentTrackLength = sum(currentTrack(:,1) > 0);
                if(currentTrackLength >= 3 && any(selectedCentroid > 0));
                    obj.obj_cellTracker.setEnableSplit('on');
                else
                    obj.obj_cellTracker.setEnableSplit('off');
                end
                
                % Reset potential merge prompts
                set(handles.mergeEventPatch, 'XData', [], 'YData', []);
                obj.obj_cellTracker.setEnableMerge('off');
                obj.potentialMergeCell = 0;
                set(handles.neighborCellTrace, 'xdata', [], 'ydata', []);
                % Try to find potential neighbors to merge to selected cell
                if(~dividingCell && ~deathCell)
                    [neighborCentroid, neighborCell, distance] = obj.obj_cellTracker.centroidsTracks.getCentroidsInRange(obj.currentTimepoint, selectedCentroid, 3);
                    targetNeighbor = find(neighborCell ~= obj.selectedCell);
                    
                    if(~isempty(targetNeighbor))
                        closestNeighbor = find(distance(targetNeighbor) == min(distance(targetNeighbor)), 1, 'first');
                        neighborCentroid = neighborCentroid(targetNeighbor(closestNeighbor),:); 
                        neighborCell = neighborCell(targetNeighbor(closestNeighbor));
                        
                        dividingCell = any(obj.obj_cellTracker.centroidsDivisions.getCentroid(obj.currentTimepoint, neighborCell) > 0);
                        deathCell = any(obj.obj_cellTracker.centroidsDeath.getCentroid(obj.currentTimepoint, neighborCell) > 0);

                        if(~dividingCell && ~deathCell)
                            set(handles.mergeEventPatch, 'XData', [neighborCentroid(:,2), selectedCentroid(:,2)], 'YData', [neighborCentroid(:,1), selectedCentroid(:,1)]);
                            % Set potential link and activate merge button
                            obj.obj_cellTracker.setEnableMerge('on');
                            obj.potentialMergeCell = neighborCell;
                            neighborTrack = obj.obj_cellTracker.centroidsTracks.getCellTrack(neighborCell);
                            %set(handles.neighborCellTrace, 'xdata', neighborTrack(neighborTrack(:,2) > 0,2), 'ydata', neighborTrack(neighborTrack(:,2) > 0,1));
                            set(handles.neighborCellTrace, 'xdata', [], 'ydata', []);
                        end
                    end
                end
            end
            
            % Set tracked centroids patch
            trackedCentroids = obj.obj_cellTracker.centroidsTracks.getCentroids(obj.currentTimepoint);
            set(handles.trackedCellsPatch, 'XData', trackedCentroids(:,2), 'YData', trackedCentroids(:,1));
            
            if(~obj.master.obj_fileManager.preprocessMode)
                return;
            end
            
            lookupRadius = obj.obj_cellTracker.getDistanceRadius;
            currentPoint = obj.pixelxy;
            if(~isempty(currentPoint))
                highlightedCentroids = obj.obj_cellTracker.centroidsLocalMaxima.getCentroidsInRange(obj.currentTimepoint, fliplr(currentPoint), lookupRadius);
                set(handles.cellsInRangePatch, 'XData', highlightedCentroids(:,2), 'YData', highlightedCentroids(:,1));
                
                closestCentroid = obj.obj_cellTracker.centroidsLocalMaxima.getClosestCentroid(obj.currentTimepoint, fliplr(currentPoint), lookupRadius);
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
        %% Delete function
        function delete(obj)
            obj.obj_cellTracker.delete;
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