function out = freq2str(in, do_Hz)
% freq2str - Convert vector of frequency values into cell array of strings,
% where numbers above 1000 are written as 1k etc.
% 
% Usage:
%	out = freq2str(in, [do_Hz])
% 
% Input:
%	in		Frequencies as vector of doubles
%	do_Hz	If true, add unit Hz (optional, default: false)
% 
% Output:
%	out		Frequencies as cell array of strings
% 

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.91
%
% Author(s): Torben Wendt
%
% Copyright (c) 2014-2017, Torben Wendt, Steven van de Par, Stephan Ewert,
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


if nargin == 1
	do_Hz = false;
end


tsd = {'', 'k'};

numFrq = length(in);
out    = cell(numFrq, 1);

if do_Hz
	for n = 1:numFrq
		out{n} = sprintf( '%g %sHz', in(n)*(1e-3)^(in(n)>=1e3), tsd{(in(n)>=1e3)+1} );
	end
else
	for n = 1:numFrq
		out{n} = sprintf( '%g%s', in(n)*(1e-3)^(in(n)>=1e3), tsd{(in(n)>=1e3)+1} );
	end
end

