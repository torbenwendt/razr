function [azel, el] = wrap_angles(azel, isdeg)
% WRAP_ANGLES - Wrap azimuth and elevation angles to the ranges [-180, 180] and [-90, 90],
% respectively.
%
% Usage:
%   [azimelev] = WRAP_ANGLES(azel, isdeg)
% or:
%   [azim, elev] = WRAP_ANGLES(azel, isdeg)
%
% Input:
%   azel        Matrix containing corresponding azimuth and elevation angles in columns
%   isdeg       Flag, specifying whether az and el are specified in degrees (otherwise rad)
%
% Output:
%   azimelev    Wrapped angles (same format as input matrix)
% or:
%   azim, elev  Wrapped angles in separate vectors

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


if ~isdeg
    azel = rd2dg(azel);
end

ang_orig = azel;

azel = wrap_to_180(azel);

wn = azel(:, 2) < -90;
wp = azel(:, 2) >  90;
azel(wn, 2) = -180 - azel(wn, 2);
azel(wp, 2) =  180 - azel(wp, 2);

azel(wn | wp, 1) = wrap_to_180(azel(wn | wp, 1) + 180);

%% for debugging: comparison to other method

if 0
    numAng = size(azel, 1);
    [x, y, z] = sph2cart(dg2rd(ang_orig(:, 1)), dg2rd(ang_orig(:, 2)), ones(numAng, 1));
    [azim, elev] = cart2sph(x, y, z);
    azim = rd2dg(azim);
    elev = rd2dg(elev);
    
    iseq_az = all(...
        round(azel(:, 1)*1e3) == round(azim*1e3) | ...
        (abs(round(azel(:, 1)*1e3)) == 180*1e3 & abs(round(azim*1e3)) == 180*1e3))
    iseq_el = all(round(azel(:, 2)*1e3) == round(elev*1e3))
    
    lab = {'Azimuth', 'Elevation'};
    figure;
    for n = 1:2
        subplot(1, 2, n)
        pol1 = polar(dg2rd(ang_orig(:, n)), ones(numAng, 1), 'o');
        hold on;
        pol2 = polar(dg2rd(azel(:, n)), ones(numAng, 1), 'o');
        set(pol1, 'color', 'r', 'markerfacecolor', 'r');
        set(pol2, 'color', 'b', 'markersize', 10, 'linewidth', 2);
        title(lab{n});
        legend([pol1, pol2], 'orig', 'wrapped', 'location', 'southoutside');
    end
end

%%
if ~isdeg
    azel = dg2rd(azel);
end

if nargout == 2
    el = azel(:, 2);
    azel = azel(:, 1);
end

end

function ang = wrap_to_360(ang)
% Replacement for Matlab's wrapTo360, for compatibility.

ispositive = ang > 0;
ang = mod(ang, 360);
ang((ang == 0) & ispositive) = 360;

end

function ang = wrap_to_180(ang)
% Replacement for Matlab's wrapTo180, for compatibility.

q = (ang < -180) | (180 < ang);
ang(q) = wrap_to_360(ang(q) + 180) - 180;

end
