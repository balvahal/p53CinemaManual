%%
%
function [obj_movie] = p53CinemaManual_method_movie_movies4AllCells(obj_movie)
mydata = obj_movie.obj_data;
%%
% for every cell and every channel create an animated gif
cellnames = mydata.cellPerspective.keys;
channelnames = unique(mydata.database.channel_name);
cmap = colormap(hsv(256));
for i = 1:length(cellnames)
    mycellhash = mydata.cellPerspective(cellnames{i});
    timepoints = mycellhash('timepoints');
    centroids = mycellhash('manualTrackingData');
    for j = 1:length(channelnames)
        n = 1;
        newfilename = sprintf('cell%s_w%s_s%d.gif',cellnames{i},channelnames{j},mycellhash('stagePositionNumber'));
        for t = timepoints
            %find the file
            logicalvector = mydata.database.timepoint == t &...
                strcmp(mydata.database.channel_name,channelnames{j}) &...
                mydata.database.position_number == mycellhash('stagePositionNumber');
            if sum(logicalvector == 1) 
                myfilename = mydata.database.filename{logicalvector};
            else
                warning('MovieAllCell:missingImage','image might be missing');
                continue
            end
            %open the file
            IM = imread(fullfile(mydata.imagepath,myfilename));
            %verify the subimage is smaller than the input image
            mysize = size(IM);
            mysize = round(mysize*obj_movie.resizeNumber);
            if mysize(1) < obj_movie.size(1) || mysize(2) < obj_movie.size(2)
                warning('MovieAllCell:inputImageSmall','the input image is smaller than the subimage');
                break
            end
            %locate cell in image
            xy = centroids(n,:);
            IM2 = extractImage(IM,xy,obj_movie);
            IM2 = bitshift(IM2,-4);
            IM2 = uint8(imnormalize(IM2)*255);
            if n == 1
            %if the first frame create file
            imwrite(IM2,cmap,fullfile(obj_movie.outputdirectory,newfilename),'gif','LoopCount',Inf,'DelayTime',obj_movie.framerate);
            else
            %else append the image
            imwrite(IM2,cmap,fullfile(obj_movie.outputdirectory,newfilename),'gif','WriteMode','append','DelayTime',obj_movie.framerate);
            end
            n = n+1;
        end
    end
end
end

function [IM] = extractImage(IMin,rowcol,obj_movie)
%rescale image
if obj_movie.resizeNumber ~= 1
    IMin = imresize(IMin,obj_movie.resizeNumber);
    rowcol = round(rowcol*obj_movie.resizeNumber);
end
%compensate for border
mysize = size(IMin);
colbounds = max(1,rowcol(2)-round(obj_movie.size(1)/2));
colbounds(2) = min(colbounds + obj_movie.size(1) - 1,mysize(2));
ybounds = max(1,rowcol(1)-round(obj_movie.size(1)/2));
ybounds(2) = min(ybounds + obj_movie.size(2) - 1,mysize(1));
%check border calculations
if colbounds(2)-colbounds(1) + 1 ~= obj_movie.size(1) ||...
        ybounds(2) - ybounds(1) + 1 ~= obj_movie.size(2)
    error('extractImage:inputImageSmall','the input image was smaller than the requested subimage');
end
%find subimage
IM = IMin(ybounds(1):ybounds(2),colbounds(1):colbounds(2));
end