function [alignedMatrix, randomMatrix, timingAnnotation] = alignTraces_TransitionEvents(traces, transitionTiming, pastOffset, futureOffset)
% Construct a matrix of cell ids. This will be used to know which cell each
% event refers to after placing all events in a linear vector
cell_identity = repmat(1:size(transitionTiming,1), size(transitionTiming,2), 1)';
individualIdentity = cell_identity(transitionTiming > 0);
control_cells = cell_identity(transitionTiming(:,1) == 0);
individualTiming = transitionTiming(transitionTiming > 0);
timingAnnotation = zeros(length(individualTiming), 5);

alignedMatrixPast = NaN .* ones(length(individualTiming), pastOffset);
alignedMatrixFuture = NaN .* ones(length(individualTiming), futureOffset + 1);
% alignedMatrixPast = -ones(length(individualTiming), pastOffset);
% alignedMatrixFuture = -ones(length(individualTiming), futureOffset + 1);
randomMatrixPast = alignedMatrixPast;
randomMatrixFuture = alignedMatrixFuture;

for i=1:length(individualTiming)
    past_window = max(1,individualTiming(i)-pastOffset):(individualTiming(i)-1);
    future_window = individualTiming(i):min(size(traces,2),individualTiming(i)+futureOffset);
    
    
    alignedMatrixPast(i,1:length(past_window)) = fliplr(traces(individualIdentity(i), past_window));
    alignedMatrixFuture(i,1:length(future_window)) = traces(individualIdentity(i), future_window);
%  sampleCell = randsample(control_cells,1);
%  randomMatrixPast(i,1:length(past_window)) = fliplr(traces(sampleCell, past_window));
%  randomMatrixFuture(i,1:length(future_window))= traces(sampleCell, future_window);
    timingAnnotation(i,1) = individualIdentity(i);
end

alignedMatrix = horzcat(fliplr(alignedMatrixPast), alignedMatrixFuture);
randomMatrix = horzcat(fliplr(randomMatrixPast), randomMatrixFuture);

end