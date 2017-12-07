function out = rootmeansq(in, dim)
% ROOTMEANSQ - Calculate root mean square of input matrix.
% 
% Usage:
%	out = ROOTMEANSQ(in, [dim])
% 
% Input:
%	in		Input matrix
%	dim		Dimension along which the rms is calculated
%			(optional, default: 1)

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


if nargin < 2
	dim = 1;
end

out = sqrt(mean(in.^2, dim));
