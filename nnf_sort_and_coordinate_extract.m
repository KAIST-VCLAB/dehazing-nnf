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

function [ neighbors ] = nnf_sort_and_coordinate_extract( nnf )
% NNF sorting, coordinates fliping and then extracting function
% Input
%   nnf: 4D nearest-neighbor field matrix
% 
% Output
%   neighbors: num_patches*2*rows*cols sorted NNF (in ascending order)

[h,w,~,~] = size(nnf);
nnf_reshaped = permute(nnf, [4,3,1,2]);

% Reshaped NNF field: 4D matrix (num_patches * 3 * h * w)
for r = 1:h
    for c = 1:w
        nnf_reshaped(:,:,r,c) = sortrows(nnf_reshaped(:,:,r,c), 3);
    end
end

% The coordinates must be calibrated to shift them by the size of padding and make them start from 1.
% The coordinates are set to be in (x,y) coordinates, so it should be fliped to be in (r,c) coordinates
neighbors = nnf_reshaped(:,2:-1:1,:,:) + 1;
end

