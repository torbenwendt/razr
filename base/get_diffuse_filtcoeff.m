% GET_DIFFUSE_FILTCOEFF - Calculation of the filter coefficients for diffuse reflections (Shelving
% Method)
%
% Usage:
%   [bDiff, aDiff] = GET_DIFFUSE_FILTCOEFF(room, op)
%
% Input:
%   room            room structure (see RAZR)
%   op              options structure (see RAZR)
%
% Output:
%   bDiff, aDiff    filter coefficients for diffuse reflections as cell
%                   array (row = wall index, column = IS order)
%   bSpec, aSpec    filter coefficients for corresponding low-pass
