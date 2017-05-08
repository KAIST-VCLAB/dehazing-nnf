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

function [ t_out ] = gmrf_estimate_prop_aug( img, t_in, nnf, patchsize, smoothness, iter, pow_num)
% [ t_out ] = gmrf_estimate_prop_aug( img, t_in, nnf, patchsize, smoothness, iter, pow_num)
% Perform statistical smoothing using a Gaussian MRF model
% Input
%   img: input hazy image (RGB)
%   t_in: initial estimate of transmission map
%   nnf: NNF (num_patches * 2 (r,c) * rows * cols)
%   patchsize: patchsize
%   smoothness: smoothness penalty coefficient
%   iter: # of iterations
%   pow_num: power of the smoothness coefficient
% Output
%   t_out: smoothed transmission map

iterations = iter;
var_s = 1/smoothness;
var_s_nnf = 1/(1e+5);           % the smaller, the smoother
power = pow_num;
[h,w,~] = size(img);

%% Estimating the variance of t
padt = padarray(t_in, [floor(patchsize/2), floor(patchsize/2)], 'symmetric');
colpadt = im2col(padt, [patchsize, patchsize]);
varmap = reshape(nanvar(colpadt), h,w);

epsilon = eps;

v = (exp(-varmap*1e10));
% v = 1 ./ varmap;
v(v == 0) = epsilon;
v(isnan(v)) = 0;
var_t = (v .* t_in);
var_t(isnan(var_t)) = 0;

t_out = (t_in);

%% Fill the coefficients of the smoothness term.
% 1. adjacent cells
fill = 1e20; 
% img = (double(im2uint8(img)));
img = rgb2lab(img);
up = ([zeros(1,w);1 ./ sum(abs(img(2:h,:,:) - img(1:(h-1),:,:)).^power,3)]) / var_s;
down = ([1 ./ sum(abs(img(1:(h-1),:,:) - img(2:h,:,:)).^power,3); zeros(1,w)]) / var_s;
left = ([zeros(h,1), 1 ./ sum(abs(img(:, 2:w,:) - img(:,1:(w-1),:)).^power,3)]) / var_s;
right = ([1 ./ sum(abs(img(:, 1:(w-1),:) - img(:,2:w,:)).^power,3), zeros(h,1)]) / var_s;
up(isinf(up)) = fill;  down(isinf(down)) = fill;  left(isinf(left)) = fill;  right(isinf(right)) = fill;

% 2. Neighbours from the NNF
% removing neighbours indicating myself
[num_neigh,~,~,~] = size(nnf);
nnf = nnf(2:num_neigh,:,:,:);

[num_neigh,~,~,~] = size(nnf);
t_nei = (zeros(h,w,num_neigh,'single'));
rimg = img(:,:,1);  gimg = img(:,:,2);  bimg = img(:,:,3);
nei_penalty = (zeros(h,w,num_neigh,'single'));
sub = zeros(h,w,num_neigh);

for i = 1:num_neigh
    ridx = squeeze(nnf(i,1,:,:));
    cidx = squeeze(nnf(i,2,:,:));
    sub(:,:,i) = sub2ind([h,w],ridx,cidx);
    nei_penalty(:,:,i) = (1 ./ (abs(rimg - rimg(sub(:,:,i))).^power + abs(gimg - gimg(sub(:,:,i))).^power + abs(bimg - bimg(sub(:,:,i))).^power) / var_s_nnf);
end


nei_penalty(isinf(nei_penalty)) = fill;
nei_penalty = (nei_penalty);
sum_nei = up + down + left + right + sum(nei_penalty,3);
zerosW = (zeros(1,w));  zerosH = (zeros(h,1));


%% regularization iteration
for i = 1:iterations
    t_up = ([zerosW; t_out(1:(h-1),:)]);
    t_down = [t_out(2:h,:); zerosW];
    t_left = [zerosH, t_out(:,1:(w-1))];
    t_right = [t_out(:, 2:w), zerosH];
    for j = 1:num_neigh
        t_nei(:,:,j) = t_out(sub(:,:,j));
    end
 
    t_out = nansum(cat(3, var_t, up.*t_up, down.*t_down, left.*t_left, right.*t_right, nansum(t_nei.*nei_penalty,3)), 3) ./ (v + sum_nei);
end

t_out = double((t_out));
end

