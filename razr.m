function varargout = razr(varargin)
% RAZR - Top-level function for RAZR engine
%
% Usage:
%   [ir, ism_setup, fdn_setup, ism_data] = RAZR(room)
%   [ir, ism_setup, fdn_setup, ism_data] = RAZR(room, op)
%   [ir, ism_setup, fdn_setup, ism_data] = RAZR(__, Name, Value)
% or:
%   RAZR            Displays short help
%   RAZR help       Displays complete help
%   RAZR about      Displays program infos
%   RAZR addpath    Adds the RAZR root directory and required folders to search path
%   RAZR rmpath     Removes the the all added folders from search path
%   RAZR demo       Starts the RAZR demo; writes a demo wav file to RAZR's root directory
%
% Input:
%   room    Structure specifying a shoebox shaped room containing a sound source
%           and a receiver. Required fields are:
%           - boxsize       Vector [x, y, z], room dimensions in m
%           - srcpos        Vector [x, y, z], source position in m
%           - recpos        Vector [x, y, z], receiver position in m
%           - recdir        Vector [az, el], receiver orientation in degrees
%           - materials     Wall surface materials. Can be specified in
%                           different ways:
%                           - A cell array of 6 material strings. The order of
%                             wall surfaces is: {-z; -y; -x; +x; +y; +z}.
%                             Material strings must be in the format
%                             "dbase.mymaterial", where "dbase" is the name of
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
%           - t60           Freq. dependent desired reverberation time in sec.
%           Note: If both materials and t60 are fields of a room, materials will
%           be used and t60 will be ignored.
%           - freq          Frequency base (in Hz) for materials (or t60) as
%                           octave band center frequencies. Optional, if
%                           materials are specified as cell array of strings
%                           (default: [250, 500, 1e3, 2e3, 4e3])
%           - TCelsius      Room temperature in Celsius (if not specified, a
%                           default value will be chosen, see COMPLEMENT_ROOM)
%           Some example rooms are defined in EXAMPLES/GET_ROOM_*.M.
%   op      Structure specifying options for RIR synthesis (optional, if empty
%           or not specified, default options are applied. All avilable options
%           are listed in GET_DEFAULT_OPTIONS). Examples how to use options are
%           given in EXAMPLES/EXAMPLE_OPTIONS.M.
%
% Name-Value-pair arguments:
%   May be all fieldnames and values of options structure
%   (see GET_DEFAULT_OPTIONS).
%
% Output:
%   ir          Room impulse response as strcuture, containing (at least) the
%               following fields:
%               - sig           Time signal of impulse response
%               - fs            Sampling rate in Hz
%               - start_spl     Time sample at which the direct sound appears
%               - name          Name of impulse response (same as op.rirname)
%               Additional fields may be created, depnding on specified options.
%   ism_setup   Structure containing ISM setup created by GET_ISM_SETUP
%   fdn_setup   Structure containing FDN setup created by GET_FDN_SETUP
%   ism_data    Structure containing geometric data for image sources
%
% Note:
%   For most usages, RAZR's root directory and all subfolders will be temporally
%   added to your Matlab search path. You can remove them using >> razr rmpath
%
% See also: SCENE, GET_DEFAULT_OPTIONS, SOP, example_*

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


if nargin == 0
    help_str = help('razr.m');
    idx_start = strfind(help_str, 'Usage:');
    idx_end = strfind(help_str, 'Input:');
    help_str = help_str((idx_start - 2):(idx_end - 1));
    help_str = strrep(help_str, 'RAZR', 'razr');
    disp(help_str);
    
elseif isstruct(varargin{1})
    razr_addpath(true);
    create_user_cfg;
    
    % razr(room, ...)
    room = varargin{1};
    
    if nargin > 1
        if isstruct(varargin{2})
            % razr(room, op, Name, Value)
            op = varargin{2};
            varargin(1:2) = [];
        else
            % razr(room, Name, Value)
            op = struct;
            varargin(1) = [];
        end
        
        if mod(length(varargin), 2)
            error('Wrong pattern of input parameters. See help razr.');
        end
        
        % pack cell arrays into cells, such that they are transformed correctly to a struct:
        idx_cell = find(cellfun(@iscell, varargin));
        for idx = idx_cell
            varargin(idx) = {varargin(idx)};
        end
        
        op = overwrite_merge(struct(varargin{:}), op, 1, 1);
    else
        op = struct;
    end
    
    [varargout{1}, varargout{2}, varargout{3}, varargout{4}] = create_rir(room, op);
    
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
            pattern = 'oldenburg.de';  % assume that email address is the last line to be printed
            readmetext = fileread(fname);
            idx_pattern = strfind(readmetext, pattern);
            disp(readmetext(1:(idx_pattern + length(pattern))));
        case 'demo'
            razr_addpath(true);
            create_user_cfg;
            razr_demo;
        otherwise
            error('Argument unknown: %s. Type "razr help" to see all options.', varargin{1});
    end
end
