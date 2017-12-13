function varargout = razr(varargin)
% RAZR - Top-level function for RAZR engine
%
% Usage:
%   [ir, ism_setup, fdn_setup, ism_data] = RAZR(room)
%   [ir, ism_setup, fdn_setup, ism_data] = RAZR(room, op)
%   [ir, ism_setup, fdn_setup, ism_data] = RAZR(rooms, adj)
%   [ir, ism_setup, fdn_setup, ism_data] = RAZR(rooms, adj, op)
%   [ir, ism_setup, fdn_setup, ism_data] = RAZR(__, Name, Value)
% or:
%   RAZR            Displays short help
%   RAZR help       Displays complete help
%   RAZR about      Displays program infos
%   RAZR addpath    Adds the RAZR root directory and required folders to path
%   RAZR rmpath     Removes the the all added folders from search path
%   RAZR demo       Starts the RAZR demo (writes a wav file to RAZR's root dir.)
%
% Input:
%   room    Structure specifying a shoebox shaped room containing a sound source
%           and a receiver. Required fields are:
%
%           - boxsize       Vector [x, y, z], room dimensions in m
%           - srcpos        Vector [x, y, z], source position in m
%           - recpos        Vector [x, y, z], receiver position in m
%           - recdir        Vector [az, el], receiver orientation in degrees
%
%           Multiple source-receiver positions can be specified by using
%           matrices instead of row vectors. The number of srcpos, recpos and
%           recdir (i.e., number of rows) must either match, or only one of them
%           must be larger than 1.
%
%           - materials     Wall surface materials. Can be specified in
%                           different ways:
%                           - A cell array of 6 material strings. The order of
%                             wall surfaces is: {-z; -y; -x; +x; +y; +z}.
%                             Material strings must be in the format
%                             "dbase:mymaterial", where "dbase" is the name of
%                             an absorbing-material database that contains ab-
%                             sorption coefficients stored under "mymaterial".
%                             An example is given in GET_ROOM_L. Databases are
%                             stored in files GET_ABSCOEFF_<DBASE>.M. Own data-
%                             bases can be created in the same format and will
%                             automatically be recognized. An example database
%                             is: GET_ABSCOEFF_HALL.
%                           - A row vector containing absorption coefficients
%                             matching the frequencies stored in room.freq.
%                             Same values for all walls.
%                           - A column vector containing six frequency-indepen-
%                             dent absorption coefficients for each wall. Order
%                             of wall surfaces: [-z; -y; -x; +x; +y; +z].
%                           - A matrix containing frequency-dependent absorption 
%                             coefficients for six walls. Frequencies along row,
%                             walls along column. Order of walls: see above.
%                           - A scalar number specifying one absorption
%                             coefficient, same for all walls and frequencies.
%                           Internally, a new field "abscoeff" will be creaated
%                           being a matrix containing frequency dependent
%                           absorption coefficients for all room surfaces.
%           Instead of materials, a desired reverberation time can be specified:
%
%           - t60           Freq. dependent desired reverberation time in sec.
%
%           Note: If both materials and t60 are fields of a room, materials will
%           be used and t60 will be ignored.
%
%           - freq          Frequency base (in Hz) for materials (or t60) as
%                           octave band center frequencies. Optional, if
%                           materials are specified as cell array of strings.
%                           Default: [250, 500, 1e3, 2e3, 4e3]
%
%           - TCelsius      Room temperature in Celsius. It will influence the
%                           speed of sound. See also SPEEDOFSOUND. If not
%                           specified, TCelsius defaults to 20.
%
%           Some example rooms are defined in EXAMPLES/GET_ROOM_*.M.
%
%   rooms   Vector of rooms. To simulate two coupled rooms, each room must con-
%           tain an extra field: a door. The following fields are required:
%
%           - door.name     Name of the door as a string.
%           - door.wall     ID of the wall where the door is placed. Must be a
%                           value out of [-2, -1, 1, 2] corresponding to
%                           [-y, -x, +x, +y]
%           - door.pos      [x/y, z] position (lower vertex) at specified wall
%           - door.size     [width, height]
%
%           door can be a vector of multiple of these structures. However,
%           simulation is supported only for one door up to now.
%           The room vector must in total contain one source and one receiver
%           that are in the same room or in two neighboring rooms. For a room
%           that contains no src/rec the respective field must be an empty array.
%           For an example, see GET_COUPLED_ROOMS.M.
%           If length(rooms) > 2, those two rooms are taken into account, which
%           contain the source and the receiver. If source and receiver are
%           inside the same room and length(rooms) > 2, that adjacent room with
%           the highest estimated reverberation time will be taken into account.
%           Note: If a room vector is passed, adj must be passed, too (see
%           below).
%           An example to simulate two coupled rooms is provided in
%           EXAMPLE_COUPLED.M.
%
%   op      Structure specifying options for RIR synthesis (optional, if empty
%           or not specified, default options are applied. All avilable options
%           are listed in GET_DEFAULT_OPTIONS). Examples how to use options are
%           given in EXAMPLES/EXAMPLE_OPTIONS.M.
%
%   adj     Cell array containing adjacency specification for coupled rooms. For
%           specifications, names of rooms and doors are used.
%           Example:
%
%           adj = {...
%               'roomA_name', 'door_A1', 'roomB_name', 'door_B1'; ...
%               'roomA_name', 'door_A2', 'roomC_name', 'door_C1'}
%
%           This specifies a connection from room 'roomA_name' via door
%           'door_A1' to room 'roomB' via door 'door_B1' and a connection from
%           room 'roomA' via door 'door_A2' to room 'roomC' via door 'door_C1'.
%           An example to simulate two coupled rooms is provided in
%           EXAMPLE_COUPLED.M.
%
% Name-Value-pair arguments:
%   May be all fieldnames and values of options structure
%   (see GET_DEFAULT_OPTIONS).
%
% Output:
%   ir          Room impulse response as strcuture, containing (at least) the
%               following fields:
%
%               - sig           Time signal of impulse response
%               - fs            Sampling rate in Hz
%               - start_spl     Time sample at which the direct sound appears
%               - name          Name of impulse response (same as op.rirname)
%
%               Additional fields may be created, depnding on specified options.
%
%   ism_setup   Structure containing ISM setup created by GET_ISM_SETUP
%   fdn_setup   Structure containing FDN setup created by GET_FDN_SETUP
%   ism_data    Structure containing geometric data for image sources
%
% Example:
%   See EXAMPLE_DEFAULT, EXAMPLE_OPTIONS, EXAMPLE_MULTIPLE_SRC,
%   EXAMPLE_COUPLED_ROOMS
%
% Note:
%   For most usages, RAZR's root directory and all subfolders will be temporally
%   added to your MATLAB search path. You can remove them using >> razr rmpath
%
% Please see also the README and the changelog.
%
% See also: example_*, GET_ROOM_L, SCENE, SOP, GET_DEFAULT_OPTIONS

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.93
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


if nargin == 0
    help_str = help('razr.m');
    idx_start = strfind(help_str, 'Usage:');
    idx_end = strfind(help_str, 'Input:');
    help_str = help_str((idx_start - 2):(idx_end - 1));
    help_str = strrep(help_str, 'RAZR', 'razr');
    disp(help_str);
    
elseif isstruct(varargin{1})
    % razr(room, …)
    
    razr_addpath(true);
    create_user_cfg;
    adj_exists = false;
    room = varargin{1};
    varargin(1) = [];
    
    if ~isempty(varargin)
        if iscell(varargin{1})
            % remaining varargins: adj, …
            adj = varargin{1};
            adj_exists = true;
            varargin(1) = [];
        end
        
        if ~isempty(varargin)
            if isstruct(varargin{1})
                % remaining varargins: op, …
                op = varargin{1};
                varargin(1) = [];
            else
                op = struct;
            end
            
            if ~isempty(varargin)
                % remaining varargins: Name, Value, …
                if mod(length(varargin), 2)
                    error('Wrong pattern of input parameters. See help razr.');
                end
                
                % pack cell arrays into cells, such that they are transformed
                % correctly to a struct:
                idx_cell = find(cellfun(@iscell, varargin));
                for idx = idx_cell
                    varargin(idx) = {varargin(idx)};
                end
                
                op = overwrite_merge(struct(varargin{:}), op, 1, 1);
            end
        else
            % razr(room, adj)
            op = struct;
        end
    else
        % razr(room)
        op = struct;
    end
    if length(room) > 1 && ~adj_exists
        error('Adjacency specification not passed to razr.');
    end
    
    if adj_exists
        [varargout{1}, varargout{4}, varargout{2}, varargout{3}] = ...
            create_crir(room, adj, op);
    else
        [varargout{1}, varargout{2}, varargout{3}, varargout{4}] = ...
            create_rir(room, op);
    end
    
else
    switch varargin{1}
        case 'help'
            help razr.m
        case 'addpath'
            razr_addpath(true);
            create_user_cfg;
        case 'rmpath'
            razr_addpath(false);
        case 'about'
            % prints first section of README:
            fname = fullfile(get_razr_path, 'README');
            % assume that email address is the last line to be printed:
            pattern = 'oldenburg.de';
            readmetext = fileread(fname);
            idx_pattern = strfind(readmetext, pattern);
            disp(readmetext(1:(idx_pattern + length(pattern))));
        case 'demo'
            razr_addpath(true);
            create_user_cfg;
            razr_demo;
        otherwise
            error('Argument unknown: %s. Type "razr help" to see all options.', ...
                varargin{1});
    end
end
