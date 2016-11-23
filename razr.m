function varargout = razr(varargin)
% RAZR - Top-level function for RAZR engine
%
% Usage:
%   [ir, ism_setup, fdn_setup, ism_data] = RAZR(room)
%   [ir, ism_setup, fdn_setup, ism_data] = RAZR(room, op)
%   [ir, ism_setup, fdn_setup, ism_data] = RAZR(__, Name, Value)
% or:
%   RAZR            (displays short help)
%   RAZR help       (displays complete help)
%   RAZR about      (displays program infos)
%   RAZR addpath    (adds the RAZR root directory and all required subfolders to search path)
%   RAZR rmpath     (removes the RAZR root directory and all added subfolders from search path)
%   RAZR demo       (starts the RAZR demo; writes a demo wav file to RAZR's root directory)
%
% Input:
%   room    Structure specifying a shoebox shaped room containing a sound source and a receiver.
%           Required fields:
%           - boxsize       Vector [x, y, z] containig room dimensions in m
%           - srcpos        Vector [x, y, z] specifying source position
%           - recpos        Vector [x, y, z] specifying receiver position
%           - recdir        Vector [azim, elev] specifying receiver orientation in degrees
%           - materials     Wall surface materials. Can be specified in several ways:
%                           - Cell array of material key strings. For available materials see
%                             GETABSCOEFF. Order of wall surfaces: {-z; -y; -x; +x; +y; +z}.
%                           - Row vector containing wall absorption coefficients for frequencies
%                             specified in room.freq (see next required field). Same for all walls.
%                           - Column vector containing frequency independent absorption coefficients
%                             for each wall. Order of wall surfaces: [-z; -y; -x; +x; +y; +z].
%                           - Matrix containing frequency-dependent absorption coefficients,
%                             different for all walls. Frequencies along row, walls along column.
%                             Order of walls as in previous point.
%                           - A scalar specifying one absorption coefficient, same for all walls and
%                             frequencies.
%                           Internally, the function GETABSCOEFF is used to generate a matrix
%                           containing absorption coefficients for all frequency bands and all six
%                           walls.
%           Instead of materials, a desired reverberation time can be specified:
%           - t60           Frequency dependent (see freq below) desired reverberation time in sec.
%           Note: If both materials and t60 are fields of a room, materials will be used and t60
%           ignored.
%           - freq          Frequency base for materials (or t60) as octave band center frequencies
%                           in Hz. Optional, if materials is specified as key-string cell array;
%                           default: [250, 500, 1e3, 2e3, 4e3]
%           - TCelsius      Room temperature in Celsius (if not specified, a default value will be
%                           chosen, see COMPLEMENT_ROOM)
%           Some example rooms are defined in EXAMPLES/GET_ROOM_*.M.
%   op      Structure specifying options for RIR synthesis (optional, if empty or not specified,
%           default options are applied. All avilable options are listed in GET_DEFAULT_OPTIONS).
%           Examples how to use options are given in EXAMPLES/EXAMPLE_OPTIONS.M.
%
% Name-Value-pair arguments:
%   May be all fieldnames and values of options structure (see GET_DEFAULT_OPTIONS).
%
% Output:
%   ir          Room impulse response as strcuture, containing (at least) the following fields (some
%               additional fields can be created, if corresponding options are set, see
%               GET_DEFAULT_OPTIONS):
%               - sig           Time signal of impulse response
%               - fs            Sampling rate in Hz
%               - start_spl     Time sample at which the direct sound appears in the signal
%               - name          Name of impulse response (same as op.rirname)
%   ism_setup   Structure containing ISM setup (mostly filter coefficients) created by GET_ISM_SETUP
%   fdn_setup   Structure containing FDN setup (mostly filter coefficients) created by GET_FDN_SETUP
%   ism_data    Structure containing geometric data for image sources
%
% Note:
%   For most usages, RAZR's root directory and all subfolders will be temporally added to your
%   Matlab search path.
%
% See also: GET_DEFAULT_OPTIONS, SCENE, example_*

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



if nargin == 0
    help_str = help('razr.m');
    idx_start = strfind(help_str, 'Usage:');
    idx_end = strfind(help_str, 'Input:');
    help_str = help_str((idx_start - 2):(idx_end - 1));
    help_str = strrep(help_str, 'RAZR', 'razr');
    disp(help_str);
    
elseif isstruct(varargin{1})
    razr_addpath(true);
    
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
        case 'rmpath'
            razr_addpath(false);
        case 'about'
            % prints first section of README:
            fname = fullfile(get_razr_path, 'README.txt');
            pattern = 'oldenburg.de';  % assume that email address is the last line to be printed
            readmetext = fileread(fname);
            idx_pattern = strfind(readmetext, pattern);
            disp(readmetext(1:(idx_pattern + length(pattern))));
        case 'demo'
            razr_addpath(true);
            razr_demo;
        otherwise
            error('Argument unknown: %s. Type "razr help" to see all options.', varargin{1});
    end
end
