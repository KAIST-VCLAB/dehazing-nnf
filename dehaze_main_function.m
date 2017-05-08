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
function dehaze_main_function(params)
    addpath('patchmatch-2.1\');
    addpath('weighted_median_filter\');

    %% Parameters
    patchsize = 15; patchsize_for_pm = 7;
    flag_gamma = 1; percentile = 2;
    gammaval = params.gammaval; % can be changed for optimized performance (e.g. 1.5)
    t_lowerbound = params.t_lowerbound; % scenes having large portion of infinite depth: 0.4 (e.g. ny17_input.png), others: 0.1
    extra_for_pm = floor(patchsize_for_pm/2);
    cores = 8;  number_of_neighbors = 17;   nn_iters = 8;
    median_radius = params.median_radius; % gradual depth for 30 (e.g. cones_input.png), abrupt depth for 60 (e.g. house_input.png)
    smoothness_penalty = 1e-1;  iter = 1e3; pow_num = 2; patchsize_mrf = patchsize;

    img = imread(params.input_hazy_image);
    [h,w,ch] = size(img);

    paddedimg = padarray(img, [extra_for_pm,extra_for_pm], 'symmetric');

    %% Patchmatch
    tic;
    fprintf('patchmatch starts\n');
    % tic;
    nnf = nnmex(paddedimg, paddedimg, 'gpucpu', patchsize_for_pm, nn_iters, [], [], [], [], cores, [], [], [], [], [], number_of_neighbors);
    toc
    fprintf('patchmatch finished\n\n');

    clear paddedimg

    nnf = nnf(1:h,1:w,:,:);
    nnf = nnf_sort_and_coordinate_extract(nnf);

    img = im2double(img);
    guide = img;
    labimg = rgb2lab(img);

    %% Airlight estimation
    A = atmospheric_estimate_dark_channel_avg(img);
    labA = rgb2lab(reshape(A,1,1,ch));


    %% Gamma correction
    hgamma = vision.GammaCorrector(gammaval,'Correction','De-Gamma');
    img = step(hgamma, img);
    A = reshape(step(hgamma, reshape(A,1,1,ch)),ch,[]);

    %% Transmission estimation
    [tt, ~] = transmission_estimate_noloop_minA_outlier(img, patchsize, A, percentile);

    %% Angle outliers
    tt2 = angle_estimate(A, img, tt, labimg, t_lowerbound);
    % If a pixel's luminance is larger than the atmospheric vector's luminance,
    % then we can see that it is lying on a very bright region, so it should be
    % rejected while estimating transmission values.

    %% Too bright regions
    too_bright_regions = labimg(:,:,1) > labA(1);
    tt2(too_bright_regions) = nan;
    tt3 = inpaint_nans(tt2, 4);


    %% Clamping
    tt3(tt3>1) = 1;     tt3(tt3<0) = 0;

    %% Statistical smoothing using MRFs
    toc
    fprintf('MRF estimation starts\n');
    est_t = gmrf_estimate_prop_aug(guide, tt3, nnf, patchsize_mrf, smoothness_penalty, iter, pow_num);
    toc
    fprintf('MRF estimation finished\n');

    %% Weight median filter (refining)
    fprintf('WMF starts\n');
    est_t2 = jointWMF(est_t, guide, median_radius);
    toc
    fprintf('WMF finished\n');

    %% Minimum T
    min_t = 0.01;
    est_t2(est_t2<min_t) = min_t;

    %% Dehazing with the transmission
    t_stack = repmat(est_t2, [1,1,ch]);
    A_stack = repmat(reshape(A, 1, 1, ch), [h,w,1]);
    J = double((img - (1 - t_stack) .* A_stack) ./ (t_stack*1));
    J(J<0) = 0;

    if flag_gamma == 1
        hgamma1 = vision.GammaCorrector(gammaval,'Correction','Gamma');
        y = step(hgamma1, J);
    else
        y = J;
    end

    toc
    figure; subplot(1,2,1); imshow(guide); title('input'); subplot(1,2,2); imshow(y); title('dehazed');
    figure; imshow(est_t2); hold on; colormap(gca,jet); colorbar;   hold off;    title('transmission');

    str = strsplit(params.input_hazy_image, '.');
    imwrite(y, [str{1} '_dehazed_output.png']);
    imwrite(im2uint8(est_t2), [str{1} '_transmission_map.png']);
end