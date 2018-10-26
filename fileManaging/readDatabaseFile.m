function database = readDatabaseFile(filename)
    database = readtable(filename, 'Delimiter', '\t');
    if(~iscell(database.channel_name))
        database.channel_name = num2str(database.channel_name);
        database.channel_name = arrayfun(@(x) {x}, database.channel_name);
    end
    if(~iscell(database.group_label))
        database.group_label = num2str(database.group_label);
        database.group_label = arrayfun(@(x) {x}, database.group_label);
    end
end