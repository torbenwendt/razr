function db = get_abscoeff_hall
% GET_ABSCOEFF_HALL - This function stores a database of absorption coefficients
% for several materials. Data were taken from the textbook:
% Hall, D. E. (1987): Basic Acoustics.
%
% To use materials from this file specify, e.g.,
% room.materials = {hall:carpet_on_conc, ...}
% as demonstrated in GET_ROOM_L.
%
% Usage:
%   db = GET_ABSCOEFF_HALL
%
% Creating and using own material databases:
%   You can create own databases by copying and editing this file. The fieldname
%   'absco' must not be changed. The filename must have the form
%   get_abscoeff_<dbname>.m.
%   Example:
%   If you create your own database called "mymats", the filename must be
%   get_abscoeff_mymats.m. To add absorption coefficients for a material, e.g.,
%   "wallpaper" to that file, it must be set as
%   db.absco.wallpaper = [...];
%   To use "wallpaper" for a room, specify:
%   room.material = {'mymats:wallpaper', ...}
% 
% See also: SMAT, GET_ROOM_L, MATERIAL2ABSCOEFF


db.info = 'Hall, D. E. (1987): Basic Acoustics';
db.freq = [125 250 500 1e3 2e3 4e3];

% ---- Store values in percent, divide by 100 at the end: ---- %
% ceiling:
db.absco.tile                  = [20  40  70  80  60  40]; % acoustic tile, rigidly mounted
db.absco.plaster_sprayed       = [50  70  60  70  70  50]; % acoustic plaster, sprayed

% side wall, ceiling:
db.absco.glasswool_on_concr    = [10  30  70  80  80  80]; % glass wool, 5 cm mounted on concrete
db.absco.glasswool_panel       = [10  40  80  80  50  40]; % glass wool covered with perforated panel
db.absco.plaster_on_lath       = [20  15  10  05  04  05]; % plaster, on lath
db.absco.gypsum                = [30  10  05  04  07  10]; % gypsum wallboard, 1/2 in, on studs
db.absco.plywood               = [60  30  10  10  10  10]; % plywood sheet, 1/4 in, on studs
db.absco.concrete_block        = [40  40  30  30  40  30]; % concrete block, unpainted
db.absco.concrete_block_painted= [10  05  06  07  10  10]; % concrete block, painted
db.absco.concrete              = [01  01  02  02  02  03]; % concrete, poured
db.absco.brick                 = [03  03  03  04  05  07]; % brick
db.absco.glass_plate           = [20  06  04  03  02  02]; % heavy plate, glass
db.absco.windowglass           = [30  20  20  10  07  04]; % ordinary window glass
db.absco.draperies             = [07  30  50  70  70  60]; % draperies, medium velour

% floor:
db.absco.vinyl             = [02  03  03  03  03  02]; % vinyl tile, on concrete
db.absco.carpet_on_conc    = [02  06  15  40  60  60]; % heavy carpet, on concrete
db.absco.carpet_on_felt    = [10  30  40  50  60  70]; % heavy carpet, on felt (Filz) backing
db.absco.platform_wood     = [40  30  20  20  15  10]; % platform floor, hard wood

% misc.:
db.absco.seat_upholstered  = [20  40  60  70  60  60]; % upholstered seating, unoccupied

% TODO: Check material names (See Hall book):
db.absco.occupied_seat     = [40  60  80  90  90  90]; % wood or metal seating, unoccupied
db.absco.woodseat_unocc    = [02  03  03  06  06  05]; % wood or metal seating, unoccupied

db.absco.wooden_pews_occup = [40  40  70  70  80  70]; % wooden pews, occupied

% divide by 100:
db.absco = structfun(@(x) (x*1e-2), db.absco, 'UniformOutput', false);
