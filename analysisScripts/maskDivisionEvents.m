function matrix = maskDivisionEvents(matrix, divisions)
    for i=1:size(matrix, 1)
        %fprintf('%d\n', i);
        divisionEvents = find(divisions(i,:));
        [peakValue,peaks] = findpeaks(matrix(i,:));
        [~,valleys] = findpeaks(-matrix(i,:));
        
        for j=1:length(divisionEvents)
            %fprintf('%d\n', j);

            if(divisionEvents(j) == 1 || divisionEvents(j) == size(matrix,2))
                continue;
            end
            distance = abs(peaks - divisionEvents(j));
            [~, minLoc] = min(distance);
            minLoc = minLoc(1);
            divisionPeak = peaks(minLoc);
            
            valleysA = valleys(valleys < divisionPeak);
            if(~isempty(valleysA))
                distance = abs(divisionPeak - valleysA);
                [~, minLoc] = min(distance);
                minLoc = minLoc(1);
                boundaryA = valleysA(minLoc);
            else
                boundaryA = divisionPeak;
            end
            valleysB = valleys(valleys > divisionPeak);
            if(~isempty(valleysB))
                distance = abs(divisionPeak - valleysB);
                [~, minLoc] = min(distance);
                minLoc = minLoc(1);
                boundaryB = valleysB(minLoc);
            else
                boundaryB = divisionPeak;
            end
            
            matrix(i,boundaryA:boundaryB) = interp1q(([boundaryA, boundaryB])', (matrix(i,[boundaryA, boundaryB]))', (boundaryA:boundaryB)');
        end
    end
end