function [abscoeff, freq] = getAbscoeff(materials, freq)
% GETABSCOEFF - Generate absorption coefficient matrix from material specification.
% Predefined absorption coefficients are available for octave band center frequencies from 125 Hz
% to 4 kHz. Source: Hall, D. E. (1987): Basic Acoustics.
%
% Usage 1:
%   [abscoeff, freq_out] = GETABSCOEFF(materials, [freq_in]);
%
% Input:
%   materials       Surface materials as (column) cell array of material key strings
%                   (see available materials below),
%   freq_in         Frequency base in Hz: vector of standard octave band center frequencies between
%                   125 and 4e3 Hz (optional, default: [125 250 500 1e3 2e3 4e3])
%
% Output:
%   abscoeff        Absorption coefficients for specified materials and frequencies
%   freq_out        Frequency base for absorption coefficients (useful, if freq_in is not specified)
%
% Example:
%   >> abscoeff = GETABSCOEFF({'brick'; 'carp_felt'; 'windowglass'}, [250, 500, 1e3, 4e3])
%	abscoeff =
%       0.0300    0.0300    0.0400    0.0700
%       0.3000    0.4000    0.5000    0.7000
%       0.2000    0.2000    0.1000    0.0400
%
% Usage 2:
%   [abscoeff, freq_out] = GETABSCOEFF(weighted_mats, [freq_in]);
%
% Input:
%   weighted_mats   Surface materials as cell array of material key strings and weighting factors
%
% Example:
%   >> [abscoeff, freq_out] = ...
%           getAbscoeff({0.7, 'windowglass', 0.3, 'draperies'; 0.6, 'platf_wood', 0.4, 'carp_felt'})
%	abscoeff =
%       0.2310    0.2300    0.2900    0.2800    0.2590    0.2080
%       0.2800    0.3000    0.2800    0.3200    0.3300    0.3400
%	freq_out =
%       125       250       500       1000      2000      4000
%
% If Absorption coefficients are already known, this function can also be used to convert them to a
% matrix format according to the required field 'abscoeff' of the room structure used for RIR synthesis.
% Here, two futher usages are supported:
%
% Usage 3 (one frequency dependent absorption coefficient - the same for all walls):
%   [abscoeff, freq_out] = GETABSCOEFF(abscoeff_in, freq_in);
%
% Input:
%   abscoeff_in     Absorption coefficients as row vector (same number as freq_in)
%
% Usage 4 (several frequency independent absorption coefficients for several walls):
%   [abscoeff, freq_out] = GETABSCOEFF(abscoeff_in, freq_in);
%
% Input:
%   abscoeff_in     Absorption coefficients as column vector
%
% Usage 5:
%   mnames = GETABSCOEFF
%
% Output:
%   mnames      Key strings for all available materials as cell array
%
%
% Available surface materials:
% 'tile'            acoustic tile, rigidly mounted
% 'plaster_sp'      acoustic plaster, sprayed
% 'gwhool_conc'     glass whool, 5 cm mounted on concrete
% 'gwhool_panel'    glass whool covered with perforated panel
% 'plaster_lath'    plaster, on lath
% 'gypsum'          gypsum wallboard, 1/2 in, on studs
% 'plywood'         plywood sheet, 1/4 in, on studs
% 'block_u'         concrete block, unpainted
% 'block_p'         concrete block, painted
% 'concrete'        concrete, poured
% 'brick'           brick
% 'vinyl'           vinyl tile, on concrete
% 'carp_conc'       heavy carpet, on concrete
% 'carp_felt'       heavy carpet, on felt backing
% 'platf_wood'      platform floor, hard wood
% 'plate_glass'     heavy plate, glass
% 'windowglass'     ordinary window glass
% 'draperies'       draperies, medium velour
% 'uphseat_unocc'   upholstered seating, unoccupied
% 'uphseat_occ'     upholstered seating, occupied
% 'woodseat_unocc'  wood or metal seating, unoccupied
% 'woodpews_occ'    wooden pews, occupied

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


%%

freq_ref = [125 250 500 1e3 2e3 4e3];

% ceiling:
m.tile			= [20  40  70  80  60  40];	% acoustic tile (Ziegel, Fliese, Kachel), rigidly mounted
m.plaster_sp	= [50  70  60  70  70  50];	% acoustic plaster, sprayed

% side wall, ceiling:
m.gwool_conc	= [10  30  70  80  80  80];	% glass wool, 5 cm mounted on concrete
m.gwool_panel	= [10  40  80  80  50  40];	% glass wool covered with perforated panel
m.plaster_lath	= [20  15  10  05  04  05];	% plaster (Putz), on lath (Latte)
m.gypsum		= [30  10  05  04  07  10];	% gypsum wallboard, 1/2 in, on studs
m.plywood		= [60  30  10  10  10  10];	% plywood (Sperrholz) sheet, 1/4 in, on studs
m.block_u		= [40  40  30  30  40  30];	% concrete (Beton) block, unpainted
m.block_p		= [10  05  06  07  10  10];	% concrete (Beton) block, painted
m.concrete		= [01  01  02  02  02  03];	% concrete (Beton), poured
m.brick			= [03  03  03  04  05  07];	% brick
m.plate_glass	= [20  06  04  03  02  02];	% heavy plate, glass
m.windowglass	= [30  20  20  10  07  04];	% ordinary window glass
m.draperies		= [07  30  50  70  70  60];	% draperies, medium velour

% floor:
m.vinyl			= [02  03  03  03  03  02];	% vinyl tile, on concrete
m.carp_conc		= [02  06  15  40  60  60];	% heavy carpet, on concrete
m.carp_felt		= [10  30  40  50  60  70];	% heavy carpet, on felt (Filz) backing
m.platf_wood	= [40  30  20  20  15  10];	% platform floor, hard wood

% misc.:
m.uphseat_unocc	= [20  40  60  70  60  60];	% upholstered seating, unoccupied
m.uphseat_occ	= [40  60  80  90  90  90];	% wood or metal seating, unoccupied
m.woodseat_unocc= [02  03  03  06  06  05];	% wood or metal seating, unoccupied
m.woodpews_occ	= [40  40  70  70  80  70];	% wooden pews (Kirchenbank), occupied

% own:
m.none			= ones(1,6)*99;
m.aula          = [0.09    0.0525 0.0999 0.1311 0.1592 0.2213]*1e2;
m.lsl           = [0.09    0.2818 0.3083 0.3328 0.3205 0.2964]*1e2;
m.officeol      = [0.09    0.2467 0.3014 0.3544 0.3193 0.2796]*1e2;
m.lecture       = [0.09    0.1842 0.1806 0.1826 0.1817 0.1832]*1e2;
m.corridor      = [0.09    0.1625 0.1550 0.1340 0.1483 0.1704]*1e2;
m.kond01        = [0.09    0.0196 0.0186 0.0240 0.0313 0.0378]*1e2;
m.kond08        = [0.09    0.1306 0.1402 0.1596 0.1770 0.1919]*1e2;

%m.pyramid1      = [0.18    0.61   1.06   1.01   1.01   1.10]*1e2;
m.pyramid        = [0.28    0.63   0.90   0.99   0.99   0.99]*1e2;	% http://www.schaumstofflager.de/pyramidenschaumstoff/akustik-pyramidenschaumstoff-micropor-100-x-50-x-3cm-anthrazit-schaumstoff-in-bestqualitaet.html (250 Hz per Auge interpoliert)

mnames = fieldnames(m);

%% Input parameters

if nargin < 2
    freq = freq_ref;
    if nargin < 1
        abscoeff = mnames;
        if nargout > 1
            error('Too many output parameters.');
        end
        return;
    end
end

%%
if iscell(materials)
    % search indices of 'freq_ref', which refer to the values of 'freq_in':
    fidx = zeros(1, length(freq));
    for n = 1:length(freq)
        fidx_tmp = find(freq_ref == freq(n));
        if ~isempty(fidx_tmp)
            fidx(n) = fidx_tmp;
        end
    end
    
    freq(fidx == 0) = [];
    fidx(fidx == 0) = [];
    
    [numSurf, numCols] = size(materials);
    abscoeff = zeros(numSurf, length(freq));
    
    if numCols == 1
        % without weighting (standard mode):
        for n = 1:numSurf
            tmp = m.(materials{n});
            abscoeff(n, 1:length(fidx)) = tmp(fidx);
        end
        
    elseif numCols == 4
        % with weighting:
        w = cell2mat(materials(:, [1 3]));      % weighting of the materials
        for n = 1:numSurf
            tmp1 = m.(materials{n, 2});
            tmp2 = m.(materials{n, 4});
            abscoeff(n, 1:length(fidx)) = w(n, 1)*tmp1(fidx) + w(n, 2)*tmp2(fidx);
        end
    else
        error('Cell array ''materials'' must be either column array or have 4 columns for weighting mode.');
    end
    
    abscoeff = abscoeff/100;
    
elseif isnumeric(materials)
    if numel(materials) == 1
        abscoeff = repmat(6, length(freq));
    elseif iscolvec(materials)
        % same for all frequencies:
        abscoeff = repmat(materials, 1, length(freq));
        
    elseif isrowvec(materials)
        % same for all walls, freq dependent:
        if length(materials) ~= length(freq)
            error([sprintf('Lengths of frequency and coefficient vectors must match.\n'), ...
                'length(materials) = %d, length(freq) = %d'], length(materials), length(freq));
        end
        abscoeff = repmat(materials, 6, 1);
    else
        abscoeff = materials;
    end
end

if size(abscoeff, 1) ~= 6
    warning('For BRIR synthesis 6 wall materials are required.');
end
