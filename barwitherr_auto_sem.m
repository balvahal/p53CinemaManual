function [] = barwitherr_auto_sem(values, multiplier)
    averages = zeros(length(values),1);
    sem = zeros(length(values),1);
    for i=1:length(values)
        averages(i) = mean(values{i});
        sem(i) = std(values{i}) / sqrt(length(values{i})) * multiplier;
    end
    barwitherr(sem, averages);
end