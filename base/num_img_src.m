function n = num_img_src(ords)
% NUM_IMG_SRC - Number of image sources of specified order for a shoebox-shaped room
%
% Usage:
%   n = NUM_IMG_SRC(ords)
%
% Input:
%   ords    Maximum image source order or vector [minOrd, maxOrd]

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



if all(length(ords) ~= [1, 2])
    error('ords must have length 1 or 2.');
end

numIS = @(M) (round((2/3*M.*(M + 1) + 1).*(2*M + 1)));
n = numIS(max(ords));

Nlower = min(ords);

if length(ords) == 2 && Nlower ~= 0
    n = n - numIS(Nlower - 1);
end
