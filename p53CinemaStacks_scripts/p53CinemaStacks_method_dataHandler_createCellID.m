%% p53CinemaManual_method_dataHandler_createCellID
% create a unique cellID
function newCellID = p53CinemaManual_method_dataHandler_createCellID(obj_dataH)
%%
% The cell id will be constructed from:
%
% * the group label
% * the stage position number where the cell was located
% * the first timepoint where the cell exists
% * the date the image was acquired
% * the row and col in the image of the cell centroid at the first
% timepoint
% * the name of the microscope where the image was acquired
%
% |microscope name, group label, 4-digit year, 2-digit month, 2-digit day,
% stage position number, timepoint, row, col|
currentTimepoint = obj_dataH.master.obj_imageViewer.currentTimepoint;
pixelRowCol = obj_dataH.master.obj_imageViewer.pixelRowCol;
selectedGroup = obj_dataH.master.obj_fileManager.selectedGroup;
selectedPosition = obj_dataH.master.obj_fileManager.selectedPosition;
logicalvector = obj_dataH.master.data.database.timepoint == currentTimepoint &...
    strcmp(obj_dataH.master.data.database.group_label,selectedGroup) &...
    obj_dataH.master.data.database.position_number == selectedPosition;
if sum(logicalvector) >= 1 && any(strcmp('matlab_serial_date_number',obj_dataH.master.data.database.Properties.VariableNames))
    ind = find(logicalvector,1,'first');
    mydate = obj_dataH.master.data.database(ind).matlab_serial_date_number;
else
    mydate = now;
end
mytokens = regexp(datestr(mydate,29),'(\d{4})-(\d{2})-(\d{2})','tokens');
newCellID = sprintf('%s%s%s%s%s%d%dr%dc%d',...
    'unknown',...
    selectedGroup,...
    mytokens{1}{1},...
    mytokens{1}{2},...
    mytokens{1}{3},...
    selectedPosition,...
    currentTimepoint,...
    pixelRowCol(1),...
    pixelRowCol(2));
end