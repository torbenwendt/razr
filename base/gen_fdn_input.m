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
%   isd             Struct containing metadata for highest order image srces (see SCALE_IS_PATTERN)
%   room            Room structure (see RAZR)
%   op              Options structure (see GET_DEFAULT_OPTIONS)
%   is_diffuse      Logical array specifying whether the n-th ism_sigmat contains diffuse
%                   reflections (otherwise specular)
%
% Output:
%   FDNinputmat     Signal matrix to be fed into FDN
%   fdn_setup       See input; added field: max_filtrange_input
