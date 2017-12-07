% GEN_FDN_INPUT - Perform mapping of ISM-output matrices to FDN input channels. For matrices
% containing diffuse reflections, corresponding processing is performed.
%
% Usage:
%   [FDNinputmat, fdn_setup] = gen_fdn_input(...
%       ism_sigmat, ism_setup, fdn_setup, ism_data, isd, room, op, is_diffuse)
%
% Input:
%   ism_sigmat      Multichannel ISM output. Matrix or cell array of several matrices
%   ism_setup       Output of GET_ISM_SETUP
%   fdn_setup       Output of GET_FDN_SETUP
%   ism_data        Struct containing metadata for image sources (output of IMAGE_SOURCE_MODEL)
%   room            Room structure (see RAZR)
%   op              Options structure (see GET_DEFAULT_OPTIONS)
%   is_diffuse      Logical array specifying whether the n-th ism_sigmat contains diffuse
%                   reflections (otherwise specular)
%
% Output:
%   FDNinputmat     Signal matrix to be fed into FDN
%   fdn_setup       See input; some fields added

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.92
%
% Author(s): Torben Wendt, Nico Goessling
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
