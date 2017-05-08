--------------------------------------------------------------------------------------------------
Background
--------------------------------------------------------------------------------------------------

For information please see the paper:

 - Dehazing using Non-Local Regularization with Iso-Depth Neighbor-Fields
   VISAPP 2017, Incheol Kim, Min H. Kim
   http://vclab.kaist.ac.kr/visapp2017/index.html


Please cite this paper if you use this code in an academic publication.

Our algorithm is tested in the environment: Windows 10 with MATLAB R2016a.

--------------------------------------------------------------------------------------------------
Dependencies (3rd parties)
--------------------------------------------------------------------------------------------------
1. PatchMatch MATLAB Mex Version 2.1 (Connelly Barnes): included in the folder 'patchmatch-2.1'
2. JointWMF - Joint-Histogram Weighted Median Filter Version 1.1 (Qi Zhang): included in the folder 'weighted_median_filter'
3. NaN inpainting algorithm (John D'Errico): included as a file, named as 'inpaint_nans.m'

--------------------------------------------------------------------------------------------------
Contents
--------------------------------------------------------------------------------------------------
1. dehaze_main_script.m
Our main script to perform dehazing.

2. angle_estimate.m, atmospheric_estimate_dark_channel_avg.m, dark_channel_estimate.m, dehaze_main_function.m, gmrf_estimate_prop_aug.m, , nnf_sort_and_coordinate_extract.m, transmission_estimate_noloop_minA_outlier.m
Functions needed for dehazing are implemented here.


--------------------------------------------------------------------------------------------------
How to use it
--------------------------------------------------------------------------------------------------

First, a user should include a hazy image inside the folder having the m files above.
Then, execute the program by running dehaze_main_script.m with arguments. For details of arguments, please see the code and the paper.

--------------------------------------------------------------------------------------------------
Comments on some parameters
--------------------------------------------------------------------------------------------------
In dehaze_main_script.m:

params.input_hazy_image: input image's name
params.gammaval: A gamma value (default=2.2). It can be changed for optimized performance (e.g. 1.5)
params.t_lowerbound: A lower bound of transmission in our angle outlier rejection. 
	- parameter selection: scenes having large portion of infinite depth: 0.4 (e.g. ny17_input.png, pumpkins_input.png), others: 0.1
params.median_radius: A parameter in the weighted median filter
		- parameter selection: scenes having gradual depth: 30 (e.g. cones_input.png), abrupt depth: 60 (e.g. house_input.png)