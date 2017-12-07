function room = complement_room(room, op)
% COMPLEMENT_ROOM - Check room structure for missing fields or errors, and add some required fields.
%
% Usage:
%   room = COMPLEMENT_ROOM(room, [op])
%
% Input:
%   room        room structure (see RAZR)
%   op          options structure (see RAZR) (optional; default: GET_DEFAULT_OPTIONS)
%
% Output:
%   room        Complemented room structure

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.92
%
% Author(s): Torben Wendt
%
% Copyright (c) 2014-2017, Torben Wendt, Steven van de Par, Stephan Ewert,
% University Oldenburg, Germany.
%
% This work is licensed under the
% Creative Commons Attribution-NonCommercial-NoDerivs 4.0 International
% License (CC BY-NC-ND 4.0).
% To view a copy of this license, visit
% http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
% Creative Commons, 444 Castro Street, Suite 900, Mountain View, California,
% 94041, USA.
%------------------------------------------------------------------------------


if nargin < 2
    op = get_default_options;
end

%% Check for required fields, set defaults for not-required fields

flds_required = {'boxsize', 'srcpos', 'recpos', 'recdir'};
numCols_required = [3, 3, 3, 2];  % required number of columns for flds_required
numFlds = length(flds_required);

for n = 1:numFlds
    if ~isfield(room, flds_required{n}) || size(room.(flds_required{n}), 2) ~= numCols_required(n)
        error('room.%s is either not specified or has wrong size.', flds_required{n});
    end
end

if ~isfield(room, 'srcdir') || isempty(room.srcdir)
    room.srcdir = [0, 0];
end

if ~isfield(room, 'TCelsius')
    room.TCelsius = 20;
end

if op.ism_enable_scattering
    if ~isfield(room, 'scat_amount')
        room.scat_amount = ones(1, 6)*0.25;
    end
    if ~isfield(room, 'scat_cutoff')
        room.scat_cutoff = ones(1, 6)*1e3;
    end
end

if any(op.enableSR)
    if ~isfield(room, 'strSize')
        room.strSize = 0.01;
    elseif room.strSize < 0 || room.strSize > 1
        error('room.strSize must be in the range 0...1.');
    else
        room.strSize = min(room.strSize, 0.99);
    end
end

%% handle multiple sources/receivers

flds = {'srcpos', 'srcdir', 'recpos', 'recdir'};
numF = length(flds);

for f = numF:-1:1
    nums(f) = size(room.(flds{f}), 1);
end

maxnum = max(nums);

if all(nums == 1 | nums == maxnum);
    for f = 1:numF
        if nums(f) == 1
            room.(flds{f}) = repmat(room.(flds{f}), maxnum, 1);
        end
    end
else
    error('Number of receivers and sources (positions and directions each) must match or be 1.');
end

%% absorption coefficients

if isfield(room, 't60')
    if isfield(room, 'materials')
        warning(...
            [sprintf('Both, materials and desired T60 are specified. T60 will be ignored.\n'), ...
            'Remove materials, if you would like to use desired T60.']);
        room = rmfield(room, 't60');
    else
        if length(room.freq) ~= length(room.t60)
            error('Lengths of room.freq and room.t60 must be equal.');
        end
        room.materials = estimate_abscoeff(room, room.t60, 'eyring');  % returns row vector
    end
end

freq_default = [250, 500, 1e3, 2e3, 4e3];

if ~isfield(room, 'freq') && iscell(room.materials)
    room.freq = freq_default;
end
    
room = add_abscoeff(room);

%room.reflcoeff = sqrt(1 - room.abscoeff);
room.absolRefl = sqrt(1 - room.abscoeff);

end
