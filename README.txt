===========================================
RAZR SOFTWARE PACKAGE FOR MATHWORK'S MATLAB
===========================================

RAZR - Room acoustics simulator

Version 0.90

Copyright (c) 2014-2016, Torben Wendt, Steven van de Par, Stephan Ewert,
Universitaet Oldenburg.
All rights reserved. 

Author: Torben Wendt
e-mail: torben.wendt@uni-oldenburg.de


===============================================================================
Algorithm reference
===============================================================================

Wendt, T., van de Par, S., Ewert, S.D. (2014): A Computationally-Efficient and
Perceptually-Plausible Algorithm for Binaural Room Impulse Response Simulation.
J. Audio Eng. Soc., Vol. 62, No. 11, pp. 748-766.

Please note: The set of default options contain some optimizations compared to
the setup described in the publication above. You can however load the original
setup by using GET_OPTIONS_JAESPAPER2014.M. To see how to use options, see also
the subsection "Getting started/Data structures", below in this file.


===============================================================================
What's in the distribution?
===============================================================================

This distribution adds an toolbox for synthesizing and analyzing binaural
room impulse responses (BRIRs) to your Matlab installation. Example simulations
are included.


Included Files
--------------

./*                     - RAZR top-level functions, README, license, disclaimer
ANALYSIS_TOOLS/
    *.M                 - Collection of tools to analyze BRIRs
    HEADPHONE_EQ/*.mat  - Equalization files for headphones
EXAMPLES/*.M            - Some examples to create BRIRs
BASE/**                 - RAZR core files
    EXTERNAL/**         - Files created by other Authors, see Credits below
    HRTF/**             - Supplementary files for HRTF application
    MEXFDN/*            - Compiled FDN mainloop
    TOOLS/*.M           - Supplementary functions for simulation and analysis

All these files must not be changed as also not permitted by RAZR's license,
unless not stated otherwise. Changes might moreover harm proper function of
this distribution. For exceptions see the following section "License and
permissions".


===============================================================================
License and permissions
===============================================================================

Unless otherwise stated, the RAZR distribution, including all files is licensed
under Creative Commons Attribution-NonCommercial-NoDerivs 4.0 International
(CC BY-NC-ND 4.0).
In short, this means that you are free to use and share (copy, distribute and
transmit) the RAZR distribution under the following conditions:

Attribution - You must attribute the RAZR distribution by acknowledgement of
              the author if it appears or if was used in any form in your work.
              The attribution must not in any way that suggests that the author
              endorse you or your use of the work.

Noncommercial - You may not use RAZR for commercial purposes.
 
No Derivative Works - You may not alter, transform, or build upon RAZR.


Exceptions are:
- The files ./BASE/EXTERNAL/**, see their respective license.

Users are explicitly granted to modify, derive their own modifications and to
distribute their modifications for the configurations, options and examples:
- The file RAZR_CFG.M in the main folder
- All files in the folder ./EXAMPLES

For further exceptions, see the license headers in the respecive files and the
section "Credits" in this file.


===============================================================================
Installation
===============================================================================

Requirements
------------

- Windows 95/98, Windows NT/2000/XP or higher, or MAC OSX, or Linux
- Mathwork's MATLAB Version 7.4 or higher


Recommended
-----------

- Sound device
- Headphones

Installation
------------

- Unzip all included files to your preferred directory.


===============================================================================
Getting Started
===============================================================================

Demo and Example scripts
------------------------

To start the demo, type "razr demo".

Besides, in the directory "EXAMPLES", you can find some example scripts, which 
demonstrate the usage of this program package. See the respective files for
details.
To start any of the examples, type "razr addpath" to temporally add all
required folders to MATLAB's path. Then type, e.g. "example_default" or
"example_options". When you have read and tried out all examples, you know the
most important features of RAZR.


Data structures
---------------

RAZR uses three essential data structures, that occur in the probably most
common usage of RAZR:

ir = razr(room, op);

(1) A room is defined as a Matlab structure, called "room" in most scripts and
functions. It contains information about the room size, wall absorption,
positions of source and receiver, and other specifications. For the required
fields of a room structure see the example rooms defined in
EXAMPLES/GET_ROOM_*.M. Both, required and optional fields are explained in the
help entry of RAZR.M. Depending on your taste and needs, you can
generate and store own rooms either in functions like the examples, as *.mat
files, directly within scripts, or by any other means. For example, for
automated RIR creation for many rooms in a loop, .mat files might be the most
convenient way to store rooms as they can easily be loaded by filename.

(2) Options for the BRIR synthesis are defined in a structure, called "op" in
most scripts and functions. All possible fields and their default values are
stored in BASE/GET_DEFAULT_OPTIONS.M.
Some of them are experimental, refer to features in development (and thus not
contained in the current version), or might read unclear. In doubt, stick to
the default or contact the author. See EXAMPLES/EXAMPLE_OPTIONS.M to see how
to use options.

(3) Room impulse responses are stored as a structure, called "ir" in most
scripts and functions. It contains the time signal itself and some metadata,
depending on your chosen options. For instance, ir can contain also the signals
for direct sound, early and late reflections in separate fields, if the option
"return_rir_parts" is set to "true".
Most of the functions in ANALYSIS_TOOLS expect a BRIR in the format of such a
structure as input parameter.

For further information, type "razr help".

Besides, a configuration structure is defined in RAZR_CFG_DEFAULT.M and
RAZR_CFG.M (internally, RAZR_CFG overloads RAZR_CFG_DEFAULT; RAZR_CFG is
created when RAZR is called the first time). Please see the respective files
for details. In contrast to the options structure, which specify how a BRIR is
to be created, in the configuration structure it is mainly defined, where RAZR
finds certain files on your computer. Hence, on different computers, the same
options can be used, whereas the configuration has to be adapted.


Using HRTFs
-----------

This program package does not contain any HRTF data. If you want to use HRTFs
(which is an essential part of the BRIR simulation) you have to get a database
from external sources.

In order to see what HRTF databases are supported, see the function apply_hrtf.
Some of them are not open access databases or not published, yet.
The following open access HRTF databases are supported:

[CIPIC]
http://interface.cipic.ucdavis.edu/sound/hrtf.html
(University of California at Davis)

To add a HRTF database to RAZR, download and extract the database to the
preferred path on your harddrive.
Then, specify that path in the file ./RAZR_CFG.M. For all supported databases,
configuration fields have already been prepared there.
If the file ./RAZR_CFG.M does not exist, run razr addpath and it will be
created.

To use the added database, two options have to be specified:
op.spat_mode = 'hrtf';
op.hrtf_database = '<KEYSTRING>';
where <KEYSTRING> is the unique key for a database. It is the same as in the
path specification in ./RAZR_CFG.M:
cfg.hrtf_path__<KEYSTRING> = path/to/database;

HRTF usage is also demonstrated in EXAMPLES/EXAMPLE_HRTF.M which is pre-
configured for the CIPIC database. To run this example with the CIPIC database,
download the database (see above link) and extract the content to a preferred
directory on your hard disk. Then replace 'path_to_database' in ./RAZR_CFG.M
(execute "razr addpath" if this file does not exist) in the CIPIC database path
definition with the path to the directory where you extracted the database. For
example, if you have unpacked the CIPIC database to ./CIPIC_hrtf_database in
the RAZR main folder, you can replace 'path_to_database' by get_razr_path, so
that it reads:

cfg.hrtf_path__cipic = [get_razr_path, filesep, ...
    'CIPIC_hrtf_database', filesep, 'standard_hrir_database'];

If you'd like to use an unsupported HRTF database, you have to create two
Matlab sripts, which will be executed by the function APPLY_HRTF:
The first script has to be named "hrtf_params_<KEYSTRING>". This script will be
called in the "otherwise" case of the first switch-case statement in
APPLY_HRTF. Hence it must contain the appropriate code as for the other cases
(the supported databases).
The second script has to be named "pick_hrtf_<KEYSTRING>". This script will be
called in the "otherwise" case ot the second switch-case statement in
APPLY_HRTF. Hence it also must contain the appropriate code as for the other
cases (the supported databases).

If you do these steps for an open-access database, be cordially invited to
share the created apply_hrtf_* function with the author, such that it can be
included in a future release.


===============================================================================
Credits
===============================================================================

This work was supported by
- DFG-FOR 1732 "Individualisierte Hoerakustik",
- Cluster of Excellence EXC 1077/1 Hearing4all.

I'd like to thank Dr. Stephan D. Ewert and Prof. Dr. Steven van de Par for
continuous support on the algorithm development and evaluation.

I'd like to thank all the people who tested earlier versions of the Software,
contributed to it, reported on bugs, or made suggestions for improvements:
Thomas Biberger, Oliver Buttler, Stephan D. Ewert, Jan-Hendrik Flessner, Nico
Goessling, Julian Grosse, Andreas Haeussler, Stefan Klockgether, Steven van de
Par, Joachim Thiemann.

All files in the directory ./BASE/EXTERNAL and all subdirectories are written
by other authors. Please see the file headers or license.txt files futher
informations on licenses. In some cases I did code modifications. For details,
see the comments in the code. The authors are:

Daniyal Amir        OVERWRITE_MERGE.M
Robert Baumgartner  HOR2GEO.M
Piotr Majdak        GEO2HORPOLAR.M
Ofek Shilon         RANDORTHMAT.M (modified Version for RAZR: RANDORTHMAT3.M)
Todd Welti          SMOOTHNEW3.M

Furthermore, some supplementary functions for HRTF databases, located in
respective subfolders of ./BASE/HRTF, are written by the following authors:

Hendrik Kayser (kayser-database), Gunnar Geissler (mk2-database).

The unreverberated sound samples in ./BASE/EXTERNAL/SAMPLES are
part of the Oldenburg Sentence Test for AFC Software Package by Stephan Ewert,
Daniel Berg, Hoertech gGmbH. See also
BASE/EXTERNAL/SAMPLES/OLSA_SENTENCES_README.TXT.
