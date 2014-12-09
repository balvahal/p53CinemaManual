function database = SMDADatabaseTilePositions(database)
tilePosition = regexp(database.filename, 'tile(\d)', 'tokens', 'once');
tilePosition = cellfun(@str2double, {tilePosition{:}});
database.position_number = (database.position_number - 1) * 4 + tilePosition';
end