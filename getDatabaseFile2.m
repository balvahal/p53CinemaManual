function filename = getDatabaseFile2(database, group, channel, position, timepoint)
fileIndex = strcmp(database.channel_name, channel) & database.position_number == position & database.timepoint == timepoint & strcmp(database.group_label, group);

if(sum(fileIndex) > 0)
    filename = database.filename{fileIndex};
else
    filename = [];
end