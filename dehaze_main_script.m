%{
/****************************************************************************

- Codename: Dehazing using Non-Local Regularization with Iso-Depth Neighbor-Fields (VISAPP 2017)

- Writers:   Incheol Kim(kimic89@gmail.com), Min H. Kim (minhkim@kaist.ac.kr)

- Institute: KAIST Visual Computing Laboratory

- Bibtex:
	
@InProceedings{KimKim:visapp:2017,
  author  = {Incheol Kim and Min H. Kim},
  title   = {Dehazing using Non-Local Regularization
            with Iso-Depth Neighbor-Fields},
  booktitle = {Proc. Int. Conf. Computer Vision,
            Theory and Applications (VISAPP 2017)},
  address = {Porto, Portugal},
  year = {2017},
  pages = {},
}

- Incheol Kim and Min H. Kim have developed this software and related documentation
  (the "Software"); confidential use in source form of the Software,
  without modification, is permitted provided that the following
  conditions are met:
  1. Neither the name of the copyright holder nor the names of any
  contributors may be used to endorse or promote products derived from
  the Software without specific prior written permission.
  2. The use of the software is for Non-Commercial Purposes only. As
  used in this Agreement, "Non-Commercial Purpose" means for the
  purpose of education or research in a non-commercial organisation
  only. "Non-Commercial Purpose" excludes, without limitation, any use
  of the Software for, as part of, or in any way in connection with a
  product (including software) or service which is sold, offered for
  sale, licensed, leased, published, loaned or rented. If you require
  a license for a use excluded by this agreement,
  please email [minhkim@kaist.ac.kr].
  
- License:  GNU General Public License Usage
  Alternatively, this file may be used under the terms of the GNU General
  Public License version 3.0 as published by the Free Software Foundation
  and appearing in the file LICENSE.GPL included in the packaging of this
  file. Please review the following information to ensure the GNU General
  Public License version 3.0 requirements will be met:
  http://www.gnu.org/copyleft/gpl.html.

- Warranty: KAIST-VCLAB MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE
  SUITABILITY OF THE SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
  LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
  PARTICULAR PURPOSE, OR NON-INFRINGEMENT. KAIST-VCLAB SHALL NOT BE LIABLE FOR ANY
  DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING
  THIS SOFTWARE OR ITS DERIVATIVES

*****************************************************************************/
%}

%% Main script

close all;
clear;

%% Main parameters
params.input_hazy_image = 'house_input.png';          % input image's name
params.gammaval = 2.2;                                 % Can be changed for optimized performance (e.g. 1.5). 2.2 is recommended for most scenes.
params.t_lowerbound = 0.1;                             % Scenes having large portion of infinite depth: 0.4 (eg. ny17_input.png), others: 0.1
params.median_radius = 60;                             % Gradual depth for 30 (e.g. cones_input.png), abrupt depth for 60 (e.g. house_input.png)

%% Dehazing
dehaze_main_function(params);                          % Run the main function