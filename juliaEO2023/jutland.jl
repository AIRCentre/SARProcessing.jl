### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# ╔═╡ 9620f3e8-432d-450a-8a94-a6c62b4e776e
import Pkg,Images

# ╔═╡ fb29e2ce-76e9-49f4-8058-e6869f4cb6c1
Pkg.activate("../")

# ╔═╡ fc0f512a-edd2-4e04-ba32-d5c8b6c832e4
using Revise

# ╔═╡ 8d550650-c2e5-4581-8288-1173a81b04a7
using Statistics

# ╔═╡ 18b99604-a9f3-11ed-0440-f155fefb9d63
using SARProcessing

# ╔═╡ c2f27e16-b4a3-42e1-a8d0-39ac069119ef
using FileIO

# ╔═╡ 1d970fd0-b0b2-4c5e-b3fe-ba50b2e16cec
import SciPy

# ╔═╡ dd72dd02-6ab1-4923-8aa3-5383850545b2
begin
	reflector_coordinates = [
		[(56 + 33/60 + 42.5556/(60*60)),(8 + 18/60 + 26.874/(60*60)),42.753],
		[(56 + 33/60 + 44.4528/(60*60)),(8 + 18/60 + 24.865/(60*60)),43.282],
		[(56 + 33/60 + 42.8652/(60*60)),(8 + 18/60 + 22.104/(60*60)),44.475]]
	reflector_coordinates = [[elem[1] *pi/180, elem[2]*pi/180,elem[3]] for elem in reflector_coordinates]
end

# ╔═╡ 040defe5-f7ff-4377-b228-a8bc5a0c475c
function plot_phase(img)
    phase = (angle.(img) .+pi)./(2*pi)

    return Images.Colors.RGB{Float32}.(1 .-phase.^2,4 .*(phase .-  phase.^2),phase.^2)
end


# ╔═╡ 167ead2b-c26e-4e0e-b24e-b4730246328a
function plot_multiple_sar(rgb_data; p_quantile = 0.85)
    scaled_data = [ abs2.(data) for data in rgb_data]
    min_value = minimum(reshape(scaled_data[1],:))
    factor = quantile(reshape(scaled_data[1],:),p_quantile) - min_value

    scaled_data = [ (data .- min_value) ./ factor for data in scaled_data]

    img =[Images.Colors.RGB(scaled_data[1][i,j],scaled_data[2][i,j],scaled_data[3][i,j]) 
        for i=1:size(scaled_data[1])[1], j=1:size(scaled_data[1])[2]]
    return img
end

# ╔═╡ c11838a2-3f98-4c83-946e-876291339bb2
# Additinal coherence estimation function, not yet implemented in the SARProcessing.jl package
function complex_coherence(master, slave, flat, kernel)
    # Define relevant image signals
    signal_1 = master .* conj.(slave) .* flat
    signal_2 = abs2.(master)
    signal_3 = abs2.(slave)
    kernel_1 = convert.(eltype(signal_1),kernel)
    kernel_2 = convert.(eltype(signal_2),kernel)
    kernel_3 = convert.(eltype(signal_3),kernel)

    # Compute real and imaginary parts seperately
    interferogram =  SARProcessing.fastconv(signal_1, kernel_1)
    master_intensity = SARProcessing.fastconv(signal_2, kernel_2)
    slave_intensity = SARProcessing.fastconv(signal_3, kernel_3)

    # Compute the complex coherence
    complex_coherence = interferogram ./ (sqrt.(master_intensity .* slave_intensity));

    return complex_coherence
end;

# ╔═╡ dbbfc59e-20b5-48a7-96ca-8c2742201a7a
md"""
### Set paths
"""

# ╔═╡ b8807dbb-1d47-4605-a31c-ccfc7f172df5
folder = "../test/testData/largeFiles/jutland/"

# ╔═╡ 3ed6d526-d3ba-4941-802f-32c9999d410d
readdir(folder)

# ╔═╡ cc060628-5f05-4f1a-beda-107d6f597fd4
image1_folder = folder* "S1B_IW_SLC__1SDV_20170408T053951_20170408T054019_005065_008DBC_AEEF.SAFE";

# ╔═╡ db169dbb-59bd-4524-9f5b-50aed13cb8de
image2_folder = folder * "S1B_IW_SLC__1SDV_20170420T053952_20170420T054019_005240_0092C6_3820.SAFE";

# ╔═╡ 369b3354-d447-4c3f-b9ec-9a12edaf6e16
orbit_states_1 =  SARProcessing.load_precise_orbit_sentinel1(
	folder * "S1B_OPER_AUX_POEORB_OPOD_20210307T032901_V20170407T225942_20170409T005942.EOF"
);

# ╔═╡ 3350747f-7ce9-44df-8955-26fd298733d2
orbit_states_2 =  SARProcessing.load_precise_orbit_sentinel1(
	folder * "S1B_OPER_AUX_POEORB_OPOD_20210307T081333_V20170419T225942_20170421T005942.EOF"
);

# ╔═╡ f1739bd3-bf19-414e-b7c1-724363c7c2f7
md"""
### Load DEM
"""

# ╔═╡ 221e515f-f31a-4659-9387-6521a95f6fcc
dem = SARProcessing.load_tandemx_dem(folder*"/TDM1_DEM__30_N56E008_V01_C/DEM/TDM1_DEM__30_N56E008_DEM.tif");

# ╔═╡ 1abbf843-9a55-4e6d-aad2-47139e7c73e1
md"""
 ### Define area of interrest
"""

# ╔═╡ 8f2a1a89-1180-444f-bc59-ccaed8291da4
window1 = [[100,1400],[1500,10000]]

# ╔═╡ 5b43d270-9413-4d34-b08d-e8f34726cace


# ╔═╡ 9fc71dc3-e1c1-4478-9d7b-4622e78d0725
begin
	polarisation = SARProcessing.VV
	burst_number = 1
	swath = 3
end;

# ╔═╡ c0b83088-c528-4fa5-a7d9-0477e9803f39
md"""
### Load image 1
"""

# ╔═╡ f613ffe9-8da5-49ed-91a8-be6210cde9a6
image1 = SARProcessing.load_sentinel1_slc(image1_folder,polarisation,swath, window1);

# ╔═╡ d9a801e5-7b65-49e6-a655-1103609adce4
orbit_interpolator_1 = SARProcessing.orbit_state_interpolator(orbit_states_1,image1.metadata);

# ╔═╡ d65878b1-1efb-4281-8741-1fd161c950ba
SARProcessing.sar2gray(image1.data[1:end,1:4:end])

# ╔═╡ 5b48f424-2f50-4750-9834-9dbc548c00ec
md"""
### Find the Lemvig reflectors 
"""

# ╔═╡ 14384d7e-37e9-4576-a4cd-a236b5482f75
reflector_index_image_1 = 
[ [SARProcessing.geodetic2SAR_index(coords, orbit_interpolator_1, image1.metadata,burst_number)...] 
    for coords in reflector_coordinates]

# ╔═╡ 81bb167b-0712-4ea3-a4e2-ab8f9efe743f
begin
	syntese_index = load("/Users/lupemba/Documents/git repos/SARProcessing.jl/test/testData/largeFiles/jutland/syntese_reference/reflector_index.jld2")["reflector_index"]
	syntese_index = [syntese_index[1,:],syntese_index[2,:],syntese_index[3,:]]
end

# ╔═╡ a6bcf777-0c36-41d1-bbc4-e74749c1efa8
syntese_index .- reflector_index_image_1

# ╔═╡ 0495cbf9-9019-4851-a659-3551c4eaf902
rio1 = let
	pad = 5
	row = [ (elem[1] - window1[1][1] +1) for elem in reflector_index_image_1]
	column = [ (elem[2] - window1[1][2] +1)  for elem in reflector_index_image_1]

	rio = [round(Int,min(row...)-pad):round(Int,max(row...)+pad), 
	round(Int,min(column...)-pad):round(Int,max(column...)+pad)] 

end

# ╔═╡ 64a02512-108f-466c-afed-58487493cfed
let
	color_img = Images.Colors.RGB.(SARProcessing.sar2gray(image1.data[rio1[1],rio1[2]],p_quantile = 0.985))
	
	row = [ (elem[1] - window1[1][1] +1) for elem in reflector_index_image_1]
	column = [ (elem[2] - window1[1][2] +1) for elem in reflector_index_image_1]

	row_in_rio = round.(Int, row .- rio1[1].start .+ 1)
	coulmn_in_rio = round.(Int,column.- rio1[2].start .+ 1)

	for i = 1:3
		color_img[row_in_rio[i],coulmn_in_rio[i]] = Images.Colors.RGB(1.0,0,0)
	end
	color_img
end

# ╔═╡ e9d2f76e-eb99-4fad-b8ad-c7b3dbc7e92a
md"""
### Find heights of points 
"""

# ╔═╡ 85367f6d-932a-4362-b6b0-695714681a87
reflector_index_image_1_visual = [
	[1125.53,6085.5], 
	[1121.5,6098],
	[1125.5,6110.0]]

# ╔═╡ 8d0a71de-c667-4bc9-b23d-5cd2472e4f4c
dem_geodetic_coordinates = let 
	# helper function to convert latitude and longitude to radians for the DEM heights
	dem_geodetic_coordinates = 
	[  [ (SARProcessing.get_coordinate(dem,(i,j)) .* (pi/180))...,dem.heights[i,j]] for i=1:size(dem.heights)[1], j=1:size(dem.heights)[2]];
	
	dem_geodetic_coordinates = reshape(dem_geodetic_coordinates,:);
	
	# find the part of the DEM which overlaps with the satellite acquisition
	dem_in_image = [ 
	    SARProcessing.is_coordinate_in_time_range(SARProcessing.geodetic2ecef(coord)
	    ,SARProcessing.get_time_range(image1.metadata),orbit_interpolator_1) 
	    for coord in dem_geodetic_coordinates] 
	
	# crop the DEM, so we only get the area of interest
	dem_geodetic_coordinates[(dem_in_image .& .!(isnan.(reshape(dem.heights,:))))]
end

# ╔═╡ a4e3fe14-cb26-4fe4-bba6-25e2a9a7b032
begin
	dem_sar_index = 
	[ [SARProcessing.geodetic2SAR_index(coords, orbit_interpolator_1, image1.metadata,burst_number)...] 
	    for coords in dem_geodetic_coordinates];
	
	# unpack the heights that match
	heights = [coords[3] for coords in dem_geodetic_coordinates]
end

# ╔═╡ 79d1b46d-bcfd-4439-aa42-e101d047b73f
reflector_heights = let
	x = [elem[1] for elem in reflector_index_image_1_visual]
	y = [elem[2] for elem in reflector_index_image_1_visual]
	SciPy.interpolate.griddata(
    hcat(dem_sar_index...)',heights, (x, y) )
end

# ╔═╡ 9cce6e3d-add4-40eb-882b-257f61984451
md"""
### Interpolate heights and Create Look up table
"""

# ╔═╡ 71d067d6-2eae-4899-9ecd-0595a5b7f1d8
begin
	rows_range = image1.index_start[1] : (image1.index_start[1] + size(image1.data)[1]-1)
	columns_range = image1.index_start[2]  : (image1.index_start[2] + size(image1.data)[2]-1)
	
	rows = collect( rows_range.start:1:rows_range.stop)
	columns =  collect( columns_range.start:1:columns_range.stop)
	
	rows_grid = ones(length(columns))' .* rows
	columns_grid = columns' .* ones(length(rows));
end;

# ╔═╡ acc6b564-1fbc-4c20-9a08-583eb43ff3bc
begin
 ## interpolate the heights to the sar idex grid
	interpolated_heights = SciPy.interpolate.griddata(
	    hcat(dem_sar_index...)',heights, (reshape(rows_grid,:), reshape(columns_grid,:)) )
	
	
	interpolated_heights = reshape(interpolated_heights,size(rows_grid))

	interpolated_heights[isnan.(interpolated_heights) .| (interpolated_heights.==0)] .= 40
	SARProcessing.sar2gray(interpolated_heights)
end


# ╔═╡ ce61fa9a-0537-42c6-9c6d-830c9877b307
sar_grid_coordinate = [SARProcessing.sar_index2geodetic(rows[i], columns[j] ,interpolated_heights[i,j],
                orbit_interpolator_1,
                image1.metadata,1) for i=1:length(rows), j=1:length(columns) ]


# ╔═╡ 5f386383-d922-4039-9ca3-6f6419cebef6
md"""
## Load Image 2
"""

# ╔═╡ a6061329-b7b8-429c-a47e-a73b15202f1f
window2 = window1

# ╔═╡ 85b73eb0-74e2-458a-8d81-00e2b9d557e6
image2 = SARProcessing.load_sentinel1_slc(image2_folder,polarisation,swath, window2);

# ╔═╡ e38a6729-c59d-42f7-b0f4-e82a0cbfe2d4
SARProcessing.sar2gray(image2.data[1:end,1:4:end])

# ╔═╡ f4f7d5bf-1efb-4471-9155-4bcb57e7b90f
orbit_interpolator_2 = SARProcessing.orbit_state_interpolator(orbit_states_2,image2.metadata);

# ╔═╡ 14aac71e-3b62-4ee5-9cde-330562c757f7
grid_image2 =
    [ [SARProcessing.geodetic2SAR_index(coords, orbit_interpolator_2, image2.metadata,burst_number)...] 
        for coords in sar_grid_coordinate];


# ╔═╡ 2000eda5-55ea-4b59-92b0-babe6bcb9fa8
md"""
Example of match between the images
"""

# ╔═╡ 3d38e0e4-43cf-474e-909d-5e83fd1a7ac5
(rows[10],columns[13]), grid_image2[10,13]

# ╔═╡ 7ae5e6d8-888d-4db1-8e96-1d44409c8ec3
md"""
### Resampling the images 
"""

# ╔═╡ 3cc52d69-47c2-481b-b5a5-a7d6851af85d
begin
	rows_range2 = window2[1][1]:window2[1][2]
	burst_row_range2 = rows_range2
	columns_range2 = window2[2][1]:window2[2][2]
end;

# ╔═╡ 2915d019-d529-4942-b998-bbded5885fd3
mid_burst_state_2 = SARProcessing.get_burst_mid_states(image2, orbit_interpolator_2);

# ╔═╡ 3bbfa9fe-fe7d-4ce5-b774-68bfb2de4c7c
mid_burst_speed_2 = SARProcessing.get_speed.(mid_burst_state_2)[burst_number]

# ╔═╡ bad30458-8e2f-4e04-ba86-e2832fa538a2


# ╔═╡ 2201f751-f4f7-4422-85d2-f0a7841d22b4


# ╔═╡ 56fcb44c-a881-4ce0-9040-ef49335d9624
phase_ramp2 = SARProcessing.phase_ramp(
        rows_range2, 
        columns_range2, 
    burst_number, mid_burst_speed_2, image2.metadata);

# ╔═╡ 38b0e9b1-1658-463b-b3b7-fe16989fc9fa
plot_phase(exp.(-phase_ramp2 .* im)[1:end,1:4:end])

# ╔═╡ 9a3999dc-5c05-41c0-8b93-4fb5dae39365
image2_deramped = image2.data .* exp.(-phase_ramp2 .* im);

# ╔═╡ 500600a5-7d7d-49a2-b02e-aa16febb6132


# ╔═╡ 7c674390-5c99-4ded-ad45-d0a876857e09
rows_target2 = let
	image2_row_interpolator = SciPy.interpolate.interp2d(
	    columns,rows,[index[1] for index in grid_image2])
	
	reshape(image2_row_interpolator(
	    collect(columns_range),
	    collect(rows_range)),:)
end

# ╔═╡ 6af12a04-8d59-4c51-9e5a-375d5724134d
columns_target2 = let
	image2_column_interpolator = SciPy.interpolate.interp2d(
	        columns,rows,[index[2] for index in grid_image2])
	
	reshape(image2_column_interpolator(
	    collect(columns_range),
	    collect(rows_range)),:)

end

# ╔═╡ cfdd2cfb-714a-45ce-b681-d20e4e0c1522

resampled_data = let
	
	image2_real = real.(image2_deramped)
	image2_imag = imag.(image2_deramped)

	
	image2_data_interpolator_real = SciPy.interpolate.RegularGridInterpolator(
	    (collect( rows_range2),
	    collect( columns_range2)),
	    image2_real, bounds_error=false, fill_value=zero(eltype(image2_real)));

	
	image2_data_interpolator_imag = SciPy.interpolate.RegularGridInterpolator(
	    (collect( rows_range2),
	    collect( columns_range2)),
	    image2_imag, bounds_error=false, fill_value=zero(eltype(image2_imag)));

	resampled_data_real = image2_data_interpolator_real(
    [
        [rows_target2[i],columns_target2[i]] 
        for i =1:length(columns_target2)
    ]
    )

	resampled_data_imag = image2_data_interpolator_imag(
    [
        [rows_target2[i],columns_target2[i]] 
        for i =1:length(columns_target2)
    ]
    )

	resampled_data_real = reshape(resampled_data_real,size(image1.data))
	resampled_data_imag = reshape(resampled_data_imag,size(image1.data))

	resampled_data_real .+ resampled_data_imag .* im
end;

# ╔═╡ cacbbd31-be80-45ff-9f78-4a1a02b64b28
SARProcessing.sar2gray(resampled_data[1:end,1:4:end])


# ╔═╡ c369962b-21e3-4fc6-841b-1c09d2b503c9
image_2_resampled = let 
	
	phase_ramp2 = SARProcessing.phase_ramp(
    	rows_target2,
		columns_target2, 
    	burst_number, 
		mid_burst_speed_2, 
		image2.metadata);
	
	resampled_data.* exp.(reshape(phase_ramp2,size(resampled_data)) .* im)
end; 

# ╔═╡ bbadcd95-1073-4d36-bbc4-6e23d27478f0
plot_multiple_sar([
	image_2_resampled[1:end,1:4:end],
	image1.data[1:end,1:4:end],
	image1.data[1:end,1:4:end]])

# ╔═╡ 5e4e8977-6d36-4d52-ab1c-657380f05ecb
plot_phase((image1.data .* conj.(image_2_resampled))[:,1:4:end] )

# ╔═╡ 8d06b5ab-4bd6-4f19-b700-466c2acb8043
md"""
### Compute the flattening 
"""

# ╔═╡ bd9a9811-7ea0-4113-a7cc-12bc61d23771
begin 
	delta_r = (collect(columns_range)' .* ones(length(rows_range))) .- reshape(columns_target2,size(image1.data));
	delta_r *= SARProcessing.get_range_pixel_spacing(image1.metadata);
	
	lambda =  SARProcessing.LIGHT_SPEED/image1.metadata.product.radar_frequency
	
	flat_interferogram = exp.(4*pi.*delta_r./lambda.*im);
end;

# ╔═╡ dd496deb-e257-406c-91d4-d3f54698bb23
plot_phase((image1.data .* conj.(image_2_resampled) .* flat_interferogram)[:,1:4:end] )

# ╔═╡ 830daa71-6362-423d-b7d4-8bd2fb784357
begin
	kernel = ones(4,14)
	coherence =  complex_coherence(image1.data, image_2_resampled,flat_interferogram, kernel);
end;

# ╔═╡ 86a7e0c3-62a5-4121-b4cf-ee9184244385
Images.Gray.(abs.(coherence[:,1:4:end]))

# ╔═╡ 5e77bb3d-d864-4b4b-9544-a1b5e5f9acdd
plot_phase.(coherence[:,1:4:end])

# ╔═╡ 5cf9296e-7211-440e-bc89-36613e681ed2


# ╔═╡ eae07156-eed6-4a03-9146-75b97a1fe469


# ╔═╡ Cell order:
# ╠═9620f3e8-432d-450a-8a94-a6c62b4e776e
# ╠═8d550650-c2e5-4581-8288-1173a81b04a7
# ╠═1d970fd0-b0b2-4c5e-b3fe-ba50b2e16cec
# ╠═fb29e2ce-76e9-49f4-8058-e6869f4cb6c1
# ╠═fc0f512a-edd2-4e04-ba32-d5c8b6c832e4
# ╠═18b99604-a9f3-11ed-0440-f155fefb9d63
# ╠═dd72dd02-6ab1-4923-8aa3-5383850545b2
# ╠═040defe5-f7ff-4377-b228-a8bc5a0c475c
# ╠═167ead2b-c26e-4e0e-b24e-b4730246328a
# ╠═c11838a2-3f98-4c83-946e-876291339bb2
# ╟─dbbfc59e-20b5-48a7-96ca-8c2742201a7a
# ╠═b8807dbb-1d47-4605-a31c-ccfc7f172df5
# ╟─3ed6d526-d3ba-4941-802f-32c9999d410d
# ╠═cc060628-5f05-4f1a-beda-107d6f597fd4
# ╠═db169dbb-59bd-4524-9f5b-50aed13cb8de
# ╠═369b3354-d447-4c3f-b9ec-9a12edaf6e16
# ╠═3350747f-7ce9-44df-8955-26fd298733d2
# ╟─f1739bd3-bf19-414e-b7c1-724363c7c2f7
# ╠═221e515f-f31a-4659-9387-6521a95f6fcc
# ╟─1abbf843-9a55-4e6d-aad2-47139e7c73e1
# ╠═8f2a1a89-1180-444f-bc59-ccaed8291da4
# ╠═5b43d270-9413-4d34-b08d-e8f34726cace
# ╠═9fc71dc3-e1c1-4478-9d7b-4622e78d0725
# ╟─c0b83088-c528-4fa5-a7d9-0477e9803f39
# ╠═f613ffe9-8da5-49ed-91a8-be6210cde9a6
# ╠═d9a801e5-7b65-49e6-a655-1103609adce4
# ╠═d65878b1-1efb-4281-8741-1fd161c950ba
# ╟─5b48f424-2f50-4750-9834-9dbc548c00ec
# ╠═14384d7e-37e9-4576-a4cd-a236b5482f75
# ╠═c2f27e16-b4a3-42e1-a8d0-39ac069119ef
# ╠═81bb167b-0712-4ea3-a4e2-ab8f9efe743f
# ╠═a6bcf777-0c36-41d1-bbc4-e74749c1efa8
# ╠═0495cbf9-9019-4851-a659-3551c4eaf902
# ╠═64a02512-108f-466c-afed-58487493cfed
# ╟─e9d2f76e-eb99-4fad-b8ad-c7b3dbc7e92a
# ╟─85367f6d-932a-4362-b6b0-695714681a87
# ╟─8d0a71de-c667-4bc9-b23d-5cd2472e4f4c
# ╟─a4e3fe14-cb26-4fe4-bba6-25e2a9a7b032
# ╠═79d1b46d-bcfd-4439-aa42-e101d047b73f
# ╟─9cce6e3d-add4-40eb-882b-257f61984451
# ╠═71d067d6-2eae-4899-9ecd-0595a5b7f1d8
# ╠═acc6b564-1fbc-4c20-9a08-583eb43ff3bc
# ╠═ce61fa9a-0537-42c6-9c6d-830c9877b307
# ╟─5f386383-d922-4039-9ca3-6f6419cebef6
# ╠═a6061329-b7b8-429c-a47e-a73b15202f1f
# ╠═85b73eb0-74e2-458a-8d81-00e2b9d557e6
# ╠═e38a6729-c59d-42f7-b0f4-e82a0cbfe2d4
# ╠═f4f7d5bf-1efb-4471-9155-4bcb57e7b90f
# ╠═14aac71e-3b62-4ee5-9cde-330562c757f7
# ╟─2000eda5-55ea-4b59-92b0-babe6bcb9fa8
# ╠═3d38e0e4-43cf-474e-909d-5e83fd1a7ac5
# ╟─7ae5e6d8-888d-4db1-8e96-1d44409c8ec3
# ╠═3cc52d69-47c2-481b-b5a5-a7d6851af85d
# ╠═2915d019-d529-4942-b998-bbded5885fd3
# ╠═3bbfa9fe-fe7d-4ce5-b774-68bfb2de4c7c
# ╠═bad30458-8e2f-4e04-ba86-e2832fa538a2
# ╠═2201f751-f4f7-4422-85d2-f0a7841d22b4
# ╠═56fcb44c-a881-4ce0-9040-ef49335d9624
# ╠═38b0e9b1-1658-463b-b3b7-fe16989fc9fa
# ╠═9a3999dc-5c05-41c0-8b93-4fb5dae39365
# ╠═500600a5-7d7d-49a2-b02e-aa16febb6132
# ╠═7c674390-5c99-4ded-ad45-d0a876857e09
# ╠═6af12a04-8d59-4c51-9e5a-375d5724134d
# ╠═cfdd2cfb-714a-45ce-b681-d20e4e0c1522
# ╠═cacbbd31-be80-45ff-9f78-4a1a02b64b28
# ╠═c369962b-21e3-4fc6-841b-1c09d2b503c9
# ╠═bbadcd95-1073-4d36-bbc4-6e23d27478f0
# ╠═5e4e8977-6d36-4d52-ab1c-657380f05ecb
# ╟─8d06b5ab-4bd6-4f19-b700-466c2acb8043
# ╠═bd9a9811-7ea0-4113-a7cc-12bc61d23771
# ╠═dd496deb-e257-406c-91d4-d3f54698bb23
# ╠═830daa71-6362-423d-b7d4-8bd2fb784357
# ╠═86a7e0c3-62a5-4121-b4cf-ee9184244385
# ╠═5e77bb3d-d864-4b4b-9544-a1b5e5f9acdd
# ╠═5cf9296e-7211-440e-bc89-36613e681ed2
# ╠═eae07156-eed6-4a03-9146-75b97a1fe469
