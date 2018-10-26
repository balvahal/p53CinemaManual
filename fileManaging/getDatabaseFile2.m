function filename = getDatabaseFile2(database, group, channel, position, timepoint)
if(~iscell(database.channel_name))
    channel_filter = database.channel_name == str2double(channel);
else
    channel_filter = strcmp(database.channel_name, channel);
end

if(~iscell(database.group_label))
    group_filter = database.group_label == str2double(group);
else
    group_filter = strcmp(database.group_label, group);
end


fileIndex = channel_filter & database.position_number == position & database.timepoint == timepoint & group_filter;

if(sum(fileIndex) > 0)
    filename = database.filename{fileIndex};
else
    filename = [];
end