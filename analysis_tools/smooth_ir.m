function erg = smooth_ir(ir, framelen_sec)

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


if nargin < 2
    framelen_sec = 2e-3;
end

framelen = round(framelen_sec*ir.fs);
ramplen = floor(framelen/2);

ergsig = mean(ir.sig, 2).^2;

sig_buf = hannbuf(ergsig, framelen, ramplen);
erg = mean(squeeze(sig_buf), 1)';
