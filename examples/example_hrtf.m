% Example script for RIR creation demonstrating how to use HRTFs.
%
% See also: example_*, RAZR


%% Please see EXAMPLE_DEFAULT and EXAMPLE_OPTIONS first for a demonstration of the basic concepts
%% of RAZR.
%%

% Note: This script can only run, if a HRTF database is linked to RAZR.
% See the section "Using HRTFs/HRIRs" in the README for details.

clear;

% Get a room:
room = get_room_L;

% Specify, that we want to use HRTFs for spatialization:
op.spat_mode = 'hrtf';

% Now we must specify the HRTF database we would like to use. For this, the
% option op.hrtf_database is used.
% RAZR supports HRTF databases stored in the SOFA format
% (https://www.sofaconventions.org), as well as other formats.
% For SOFA databases, the SOFA API for Matlab/Octave is required. See the README
% (Section "Using HRTFs/HRIRs") for instructions how to get the API and how to
% link it to RAZR.
% To use a SOFA database, we can directly assign a .sofa filename, e.g.,
%
% op.hrtf_database = path/to/database.sofa;
%
% More conveniently, we can link a .sofa file to RAZR by using a custom shortcut
% and specifying the according filename in RAZR_CFG.M. There, the filename must
% be stored as a field of cfg:
%
% cfg.sofa_file__<shortcut> = path/to/database.sofa;
%
% (note the double underscore before <shortcut>). In case we would like to link
% the SOFA-formatted FABIAN database and we choose the <shortcut> == fabian, we
% would write:
op.hrtf_database = 'fabian.sofa';
% Note: Though we are using the shortcut, we still need the suffix ".sofa" to
% tell razr that a SOFA-formatted database is used.
%
% In order to use an HRTF database in a non-SOFA format, we need to specify a
% shortcut and the database directory in RAZR_CFG.M. In this case, the cfg
% needs a field like this:
%
% cfg.hrtf_path__<shortcut> = path/to/database;
%
% (note the double underscore before <shortcut>). We would choose this database
% by setting the option
%
% op.hrtf_database = '<shortcut>';
% 
% In addition, for every non-SOFA database there need to be two extra functions:
% hrtf_par_<shortcut>
% pick_hrir_<shortcut>
% For some databases, these are already provided in the folder /base/hrtf.
% (Please note: Some of them are not open access databases or not published,
% yet.) If we wanted to add another non-SOFA database we would need to write
% these two functions in a similar manner according to our new database. If you
% do this for an open-access database, be cordially invited to share the created
% functions with the author, such that they may be included in a future release.
%
% To summarize. we can use HRTF databases in three ways:
% SOFA format:
%   (1) op.hrtf_database = path/to/database.sofa
%   (2) op.hrtf_database = shortcut.sofa
% Non-SOFA format:
%   (3) op.hrtf_database = shortcut
% For cases 2, 3 a shortcut must be specified in RAZR_CFG.M
% For details, please see the section "Getting Started" -> "Using HRTFs" in the
% README.

% BRIR synthesis:
ir = razr(room, op);

% Convolve BRIR with a test signal. (Here, using another test signal, see doc of
% apply_rir for details):
[out, in] = apply_rir(ir, 'src', 'olsa2');

return

%% You can listen to the result by the following command:
soundsc(out{1}, ir.fs);
