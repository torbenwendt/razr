function db = get_abscoeff_legacy
% GET_ABSCOEFF_LEGACY - This function stores a database of absorption
% coefficients for several materials. This database is used if the user
% specifies absorbing materials without a database, e.g., 'brick' instead of
% 'hall:brick'. See help razr for details on proper usage of materials.
% Data were mostly taken from the textbook: Hall, D. E. (1987): Basic Acoustics.
%
% Usage:
%   db = GET_ABSCOEFF_LEGACY
%
% See also: GET_ROOM_L, SMAT, MATERIAL2ABSCOEFF


db.info = 'Hall, D. E. (1987): Basic Acoustics';
db.freq = [125 250 500 1e3 2e3 4e3];

% ---- Store values in percent, divide by 100 at the end: ---- %
% ceiling:
absco.tile			= [20  40  70  80  60  40];	% acoustic tile (Ziegel, Fliese, Kachel), rigidly mounted
absco.plaster_sp	= [50  70  60  70  70  50];	% acoustic plaster, sprayed

% side wall, ceiling:
absco.gwool_conc	= [10  30  70  80  80  80];	% glass wool, 5 cm mounted on concrete
absco.gwool_panel	= [10  40  80  80  50  40];	% glass wool covered with perforated panel
absco.plaster_lath	= [20  15  10  05  04  05];	% plaster (Putz), on lath (Latte)
absco.gypsum		= [30  10  05  04  07  10];	% gypsum wallboard, 1/2 in, on studs
absco.plywood		= [60  30  10  10  10  10];	% plywood (Sperrholz) sheet, 1/4 in, on studs
absco.block_u		= [40  40  30  30  40  30];	% concrete (Beton) block, unpainted
absco.block_p		= [10  05  06  07  10  10];	% concrete (Beton) block, painted
absco.concrete		= [01  01  02  02  02  03];	% concrete (Beton), poured
absco.brick			= [03  03  03  04  05  07];	% brick
absco.plate_glass	= [20  06  04  03  02  02];	% heavy plate, glass
absco.windowglass	= [30  20  20  10  07  04];	% ordinary window glass
absco.draperies		= [07  30  50  70  70  60];	% draperies, medium velour

% floor:
absco.vinyl			= [02  03  03  03  03  02];	% vinyl tile, on concrete
absco.carp_conc		= [02  06  15  40  60  60];	% heavy carpet, on concrete
absco.carp_felt		= [10  30  40  50  60  70];	% heavy carpet, on felt (Filz) backing
absco.platf_wood	= [40  30  20  20  15  10];	% platform floor, hard wood

% misc.:
absco.uphseat_unocc	= [20  40  60  70  60  60];	% upholstered seating, unoccupied
absco.uphseat_occ	= [40  60  80  90  90  90];	% wood or metal seating, unoccupied
absco.woodseat_unocc= [02  03  03  06  06  05];	% wood or metal seating, unoccupied
absco.woodpews_occ	= [40  40  70  70  80  70];	% wooden pews (Kirchenbank), occupied

% own:
absco.none			= ones(1,6)*99;
absco.aula          = [0.09    0.0525 0.0999 0.1311 0.1592 0.2213]*1e2;
absco.lsl           = [0.09    0.2818 0.3083 0.3328 0.3205 0.2964]*1e2;
absco.officeol      = [0.09    0.2467 0.3014 0.3544 0.3193 0.2796]*1e2;
absco.lecture       = [0.09    0.1842 0.1806 0.1826 0.1817 0.1832]*1e2;
absco.corridor      = [0.09    0.1625 0.1550 0.1340 0.1483 0.1704]*1e2;
absco.kond01        = [0.09    0.0196 0.0186 0.0240 0.0313 0.0378]*1e2;
absco.kond08        = [0.09    0.1306 0.1402 0.1596 0.1770 0.1919]*1e2;

%m.pyramid1      = [0.18    0.61   1.06   1.01   1.01   1.10]*1e2;
absco.pyramid    = [0.28    0.63   0.90   0.99   0.99   0.99]*1e2;
% http://www.schaumstofflager.de/pyramidenschaumstoff/akustik-pyramidenschaumstoff-micropor-100-x-50-x-3cm-anthrazit-schaumstoff-in-bestqualitaet.html (250 Hz per Auge interpoliert)

% divide by 100:
db.absco = structfun(@(x) (x*1e-2), absco, 'UniformOutput', false);
