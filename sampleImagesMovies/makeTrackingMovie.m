function [] = makeTrackingMovie(database, rawdatapath, group, position, channel, centroids, cell_ids, resizeFactor, colors, outputFile)
validImages = strcmp(string(database.group_label), group) & database.position_number == position & strcmp(database.channel_name, channel);
database = database(validImages,:);

[~,ordering] = sort(database.timepoint);
database = database(ordering,:);

maxValue = [];

figure; set(gcf, 'Color', 'white');
position = get(gcf, 'Position');
position(3:4) = 512;
set(gcf, 'Position', position);
progress = 0;
for i=1:1:size(database,1)
    %for i=1:1:30
    if(i/size(database,1) > progress)
        fprintf('%d ', progress * 100);
        progress = progress + 0.1;
    end
    IM = imread(fullfile(rawdatapath, database.filename{i}));
    IM = double(imresize(IM, resizeFactor));
    IM = log(IM);
    IM = imbackground(IM, round(10*resizeFactor), round(100*resizeFactor));
    if(isempty(maxValue))
        maxValue = max(IM(:)) * 1;
    end
    IM = IM - quantile(IM(:), 0.05); IM(IM < 0) = 0;
    IM = double(IM) / double(maxValue);
    IM(IM > 1) = 1;
    IM = im2rgb(IM);
    
    h = image(IM); hold all;
    set(gca, 'Position', [0,0,1,1]);
    axis off;
    
    windowSize = 30; % Length of trail in number of frames
    alphaValues = fliplr((1/windowSize):(1/windowSize):1);
    alphaValues = fliplr(logspace(1,2,windowSize)/10^2);
    for j=1:length(cell_ids)
        currentCentroids = centroids.getCellTrack(cell_ids(j)) * resizeFactor;
        currentCentroids = currentCentroids(1:i,:);
        currentCentroids = currentCentroids(currentCentroids(:,1) > 0,:);
        if(~isempty(currentCentroids))
            alphaValue = 1;
            for k=fliplr(max(2,size(currentCentroids,1)-(windowSize-1)):size(currentCentroids,1))
                line(currentCentroids((k-1):k,2),currentCentroids((k-1):k,1),'Color',[colors(j,:), alphaValues(alphaValue)], 'LineWidth', 2);
                hold all;
                alphaValue = alphaValue + 1;
            end
            %plot(currentCentroids(:,2), currentCentroids(:,1), 'Color', colors(j,:), 'LineWidth', 1.5);
        end
    end
    hold off;
    
    % Comment this line when writing the images
    drawnow;
    
    % Comment these two lines to troubleshoot (it will run faster but won't write images)
    imageData = getframe(gcf);
    imwrite(imageData.cdata, outputFile, 'WriteMode', 'append', 'Compression', 'none');
end
fprintf('%d\n', 100);

end