function razr_addpath(do_add, do_force)
% RAZR_ADDPATH - Add or remove paths of required RAZR subdirectories.
% This function also creates a new file (if not existent) ./RAZR_CFG. See that file for details.
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
% Version 0.90
%
% Author(s): Torben Wendt
%
% Copyright (c) 2014-2016, Torben Wendt, Steven van de Par, Stephan Ewert,
% Universitaet Oldenburg.
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

% create user cfg file:
if ~exist('razr_cfg', 'file') && do_add
    copyfile(...
        fullfile(get_razr_path, 'base', '.razr_cfg_template.m'), ...
        fullfile(get_razr_path, 'razr_cfg.m'));
end
