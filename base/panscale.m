function lrscale = panscale(room, relcoo)
% PANSCALE - Get scaling factors for vector base amplitude panning
% 
% Usage:
%	lrscale = PANSCALE(room, relcoo)
% 
% Input:
%	room		room structure (see RAZR)
%	relcoo		Coordinates of sound source (cartesian), relative to receiver postion
% 
% Ausgabe:
%	lrscale		= [lscale', rscale']; rows represent sound sources

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


numSrc = size(relcoo, 1);

% Vector in direction of interaural axis:
[ex, ey, ez] = sph2cart(dg2rd(room.recdir(1)) - pi/2, 0, 1);
e = repmat([ex, ey, ez], numSrc, 1);

relcoo_norm = relcoo*0;			% prealloc normalized direction vectors

for n = 1:numSrc
	relcoo_norm(n, :) = relcoo(n, :)/norm(relcoo(n, :), 2);
end

sp = dot(e', relcoo_norm');		% scalar product (per row)

lscale = (1 - sp);%*0.5;
rscale = (1 + sp);%*0.5;
lrscale = [lscale', rscale'];
