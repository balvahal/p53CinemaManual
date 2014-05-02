filter_size = 30;
result = zeros(size(IM,1), size(IM,2));
for i=1:(size(IM,1)-filter_size)
    fprintf('row: %d\n', i);
    for j=1:(size(IM,2)-filter_size)
        subImage = IM(i:(i+filter_size - 1), j:(j+filter_size - 1));
        subImage = double(subImage);
        [y,x] = ksdensity(subImage(:));
        result(i,j) = sum(y > 0.05);
    end
end