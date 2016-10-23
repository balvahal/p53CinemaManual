function IM = flatfield_correctImage(IM, offset, gain)
IM = double(IM);

% FOR SMDA
%IM = IM-double(scale12to16bit(offset));

% FOR METAMORPH old files
% IM = scale12to16bit(IM);
% IM = IM-double(offset);

% FOR METAMORPH new files
IM = IM-double(offset);

IM(IM<0) = 0;
IM = IM ./ gain;
end

function [IM] = scale12to16bit(IM)
numType = class(IM);
switch numType
    case 'double'
        IM = uint16(IM);
        IM = bitshift(IM,4);
        IM = double(IM);
    case 'uint16'
        IM = bitshift(IM,4);
end
end