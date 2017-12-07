function razr_addpath(do_add, do_force)
% RAZR_ADDPATH - Add or remove paths of required RAZR subdirectories.
%
% Usage:
%   RAZR_ADDPATH([do_add], [do_force])
%
% Input:
%   do_add      If true, add paths of all required subdirectories to the search path, otherwise
%               remove them (optional parameter, default: true)
%   do_force    If true, do not rely on persistent flag storing whether path has been added already
%               (optional; default: false)

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
    do_force = false;
    if nargin < 1
        do_add = true;
    end
end

persistent already_added

if isempty(already_added)
    already_added = false;
end

if ((already_added && do_add) || (~already_added && ~do_add)) && ~do_force
    return;
elseif do_add
    pathfcn = @addpath;
else
    pathfcn = @rmpath;
end

razr_path = get_razr_path;

files = dir(razr_path);
fnames_ignore = {'.', '..', '.git'};

for n = 1:length(files)
    if ~ismember(files(n).name, fnames_ignore) && files(n).isdir
        pathfcn(genpath([razr_path, filesep, files(n).name]));
    end
end

pathfcn(razr_path);

already_added = do_add;
