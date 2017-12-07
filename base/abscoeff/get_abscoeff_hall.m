function db = get_abscoeff_hall
% GET_ABSCOEFF_HALL - This function stores a database of absorption coefficients
% for several materials. Data were taken from the textbook:
% Hall, D. E. (1987): Basic Acoustics.
%
% Usage:
%   db = GET_ABSCOEFF_HALL
%
% You can create own databases by copying and editing this file. Using materials
% from a specified database is demonstrated in GET_ROOM_L.
% 
% See also: GET_ROOM_L, SMAT, MATERIAL2ABSCOEFF


db.info = 'Hall, D. E. (1987): Basic Acoustics';
db.freq = [125 250 500 1e3 2e3 4e3];

% ---- Store values in percent, divide by 100 at the end: ---- %
% ceiling:
absco.tile                  = [20  40  70  80  60  40]; % acoustic tile, rigidly mounted
absco.plaster_sprayed       = [50  70  60  70  70  50]; % acoustic plaster, sprayed

% side wall, ceiling:
absco.glasswool_on_concr    = [10  30  70  80  80  80]; % glass wool, 5 cm mounted on concrete
absco.glasswool_panel       = [10  40  80  80  50  40]; % glass wool covered with perforated panel
absco.plaster_on_lath       = [20  15  10  05  04  05]; % plaster, on lath
absco.gypsum                = [30  10  05  04  07  10]; % gypsum wallboard, 1/2 in, on studs
absco.plywood               = [60  30  10  10  10  10]; % plywood sheet, 1/4 in, on studs
absco.concrete_block        = [40  40  30  30  40  30]; % concrete block, unpainted
absco.concrete_block_painted= [10  05  06  07  10  10]; % concrete block, painted
absco.concrete              = [01  01  02  02  02  03]; % concrete, poured
absco.brick                 = [03  03  03  04  05  07]; % brick
absco.glass_plate           = [20  06  04  03  02  02]; % heavy plate, glass
absco.windowglass           = [30  20  20  10  07  04]; % ordinary window glass
absco.draperies             = [07  30  50  70  70  60]; % draperies, medium velour

% floor:
absco.vinyl             = [02  03  03  03  03  02]; % vinyl tile, on concrete
absco.carpet_on_conc    = [02  06  15  40  60  60]; % heavy carpet, on concrete
absco.carpet_on_felt    = [10  30  40  50  60  70]; % heavy carpet, on felt (Filz) backing
absco.platform_wood     = [40  30  20  20  15  10]; % platform floor, hard wood

% misc.:
absco.seat_upholstered  = [20  40  60  70  60  60]; % upholstered seating, unoccupied

% TODO: Check material names (See Hall book):
absco.occupied_seat     = [40  60  80  90  90  90]; % wood or metal seating, unoccupied
absco.woodseat_unocc    = [02  03  03  06  06  05]; % wood or metal seating, unoccupied

absco.wooden_pews_occup = [40  40  70  70  80  70]; % wooden pews (Kirchenbank), occupied

% divide by 100:
db.absco = structfun(@(x) (x*1e-2), absco, 'UniformOutput', false);
