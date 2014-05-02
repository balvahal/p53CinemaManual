function filename = getDatabaseFile(database, channel, position, timepoint)
fileIndex = strcmp(database.channel_name, channel) & database.position_number == position & database.timepoint == timepoint;
if(sum(fileIndex) > 0)
    filename = database.filename{fileIndex};
else
    filename = [];
end