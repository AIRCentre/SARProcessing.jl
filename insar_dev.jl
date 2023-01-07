
using SARProcessing, SciPy, Images, Statistics




safefolderA = "test/testData/largeFiles/EO_workshop_full/S1A_IW_SLC__1SDV_20190622T015048_20190622T015115_027786_0322F1_7A8E.SAFE"
orbit_file_a = "test/testData/largeFiles/EO_workshop_full/S1A_OPER_AUX_POEORB_OPOD_20210330T183728_V20190621T225942_20190623T005942.EOF"
orbit_file_b = "test/testData/largeFiles/EO_workshop_full/S1B_OPER_AUX_POEORB_OPOD_20210330T202915_V20190627T225942_20190629T005942.EOF"
safefolderB = "test/testData/largeFiles/EO_workshop_full/S1B_IW_SLC__1SDV_20190628T014958_20190628T015025_016890_01FC87_FC0D.SAFE"


function is_point_in_swath(latitude,longitude,metadata)
    geolocation = metadata.geolocation

    is_latitude_in_range = min(geolocation.latitude...) < latitude && latitude < max(geolocation.latitude...) 
    is_longitude_in_range = min(geolocation.longitude...) < longitude && longitude < max(geolocation.longitude...)  

    return is_latitude_in_range && is_longitude_in_range
end



function is_point_in_swath(latitude, longitude, safe_path::String)
    result = [false,false,false]
    for i in 1:3
        metadata_path = SARProcessing.get_annotation_path_sentinel1(safe_path, SARProcessing.VV, i);
        metadata = SARProcessing.Sentinel1MetaData(metadata_path)
        result[i] = is_point_in_swath(latitude, longitude, metadata)
    end

    return result
end

is_point_in_swath(35.6224223,-117.7310821, safefolderA)
is_point_in_swath(35.6224223,-117.7310821, safefolderB)




polarisation = SARProcessing.VV
swath = 2
windowA = [[100 , 1500],[7600 , 20000]]
#windowA = [[5,2000],[8400,20000]]
imageA = SARProcessing.load_sentinel1_slc(safefolderA, polarisation, swath, windowA);
#SARProcessing.sar2gray(imageA.data[:,1:4:end])




metadata_path = SARProcessing.get_annotation_path_sentinel1(safefolderA, polarisation, swath);

metadataA = SARProcessing.Sentinel1MetaData(metadata_path);


interpolator_a = SARProcessing.orbit_state_interpolator(
    SARProcessing.load_precise_orbit_sentinel1(orbit_file_a)
    ,metadataA);


dem = SARProcessing.load_tandemx_dem("test/testData/largeFiles/EO_workshop_full/TDM1_DEM__30_N35W118_V01_C/DEM/TDM1_DEM__30_N35W118_DEM.tif");


dem_geodetic_coordinates = 
[  [ (SARProcessing.get_coordinate(dem,(i,j)) .* (pi/180))...,dem.heights[i,j]] for i=1:size(dem.heights)[1], j=1:size(dem.heights)[2]]

dem_geodetic_coordinates = reshape(dem_geodetic_coordinates,:);

time_range = SARProcessing.get_time_range(metadataA)
dem_in_image = [ 
    SARProcessing.is_coordinate_in_time_range(SARProcessing.geodetic2ecef(coord)
    ,time_range,interpolator_a) 
    for coord in dem_geodetic_coordinates] 

dem_geodetic_coordinates = dem_geodetic_coordinates[dem_in_image]

## TODO, bug close to image edge. returns nan
dem_sar_index = 
[ [SARProcessing.geodetic2SAR_index(coords, interpolator_a, metadataA)...] 
    for coords in dem_geodetic_coordinates];


heights = [coords[3] for coords in dem_geodetic_coordinates]

#shift_burst2 = metadataA.swath.lines_per_burst - SARProcessing.get_burst_row_offset(metadataA)[2]
#shift_burst2 = round(Int,shift_burst2)

rows = collect(windowA[1][1]:10:windowA[1][2])
columns = collect(windowA[2][1]:40:windowA[2][2])

rows_grid = ones(length(columns))' .* rows
columns_grid = columns' .* ones(length(rows))

sar_grid_heights = SciPy.interpolate.griddata(
    hcat(dem_sar_index...)',heights, (reshape(rows_grid,:), reshape(columns_grid,:)) )


sar_grid_heights = reshape(sar_grid_heights,size(rows_grid))

#SARProcessing.sar2gray(sar_grid_heights)

geo_points = [SARProcessing.sar_index2geodetic(rows[i], columns[j] ,sar_grid_heights[i,j],
                interpolator_a,
                metadataA) for i=1:length(rows), j=1:length(columns) ]

```
struct GeocodeTable
    rows::Vector
    columns:: Vector
    geodetic_point::Matrix
end


geocode_table = GeocodeTable(rows,columns,geo_points)
```

metadata_path = SARProcessing.get_annotation_path_sentinel1(safefolderB, polarisation, swath);

metadataB = SARProcessing.Sentinel1MetaData(metadata_path);


interpolator_b = SARProcessing.orbit_state_interpolator(
    SARProcessing.load_precise_orbit_sentinel1(orbit_file_b)
    ,metadataB);


grid_image2 =
    [ [SARProcessing.geodetic2SAR_index(coords, interpolator_b, metadataB)...] 
        for coords in geo_points];



burst_offset_b = round.(Int,SARProcessing.get_burst_row_offset(metadataB))
# lowest row in grid_image2 is 4028.57 which is line 4 in burst 4

windowB_row = [grid_image2[1,1][1],grid_image2[end,end][1]] .+ ((4-1)*metadataB.swath.lines_per_burst- burst_offset_b[4])
windowB_column = [grid_image2[1,1][2],grid_image2[end,end][2]]

window_B = [ [windowB_row[1]-50,windowB_row[2]+50] ,[windowB_column[1]-50,windowB_column[2]+50]]
window_B = [round.(Int,x) for x in window_B]


imageB = SARProcessing.load_sentinel1_slc(safefolderB, polarisation, swath, window_B);
SARProcessing.sar2gray(imageB.data[:,1:4:end])


## deramp

mid_burst_state_b = SARProcessing.get_burst_mid_states(imageB, interpolator_b)
mid_burst_state_b = mid_burst_state_b[SARProcessing.get_burst_numbers(imageB) .==4]
mid_burst_speed_b = SARProcessing.get_speed.(mid_burst_state_b)[1]

phase_ramp_b = SARProcessing.phase_ramp(
    collect( window_B[1][1]:window_B[1][2]), 
    collect( window_B[2][1]:window_B[2][2]), 
4, mid_burst_speed_b, metadataB)

function plot_phase(img)
    phase = (angle.(img) .+pi)./(2*pi)

    return Images.Colors.RGB{Float32}.(1 .-phase.^2,4 .*(phase .-  phase.^2),phase.^2)
end

plot_phase(exp.(-phase_ramp_b .* im)[:,1:4:end])
# deramp image B

imageB.data .= imageB.data .* exp.(-phase_ramp_b .* im)
imageB.deramped = true


burst_shift = ((4-1)*metadataB.swath.lines_per_burst- burst_offset_b[4])

imageB_row_interpolator = SciPy.interpolate.interp2d(
    columns,rows,[index[1] for index in grid_image2].+burst_shift)

imageB_column_interpolator = SciPy.interpolate.interp2d(
        columns,rows,[index[2] for index in grid_image2])

rows_B_target = reshape(imageB_row_interpolator(
    collect(windowA[2][1]:windowA[2][2]),
    collect(windowA[1][1]:windowA[1][2])),:)

columns_B_target = reshape(imageB_column_interpolator(
    collect(windowA[2][1]:windowA[2][2]),
    collect(windowA[1][1]:windowA[1][2])),:)

imageB_data_interpolator = SciPy.interpolate.RegularGridInterpolator(
    (collect( window_B[1][1]:window_B[1][2]),
    collect( window_B[2][1]:window_B[2][2])),
    imageB.data)


resampled_data = imageB_data_interpolator(
    [
        [rows_B_target[i],columns_B_target[i]] 
        for i =1:length(columns_B_target)
    ]
    )



delta_r = (collect(windowA[2][1]:windowA[2][2])' .* ones(size(imageA.data)[1])) .- reshape(columns_B_target,size(imageA.data));
delta_r *= SARProcessing.get_range_pixel_spacing(metadataA);

lambda =  299792458.0/metadataA.product.radar_frequency

flat_inteferogram = exp.(4*pi.*delta_r./lambda.*im)

plot_phase(flat_inteferogram[:,1:4:end])

full_columns_A = nothing
rows_B_target = nothing
columns_B_target = nothing


function plot_multiple_sar(rgb_data; p_quantile = 0.85)
    scaled_data = [ abs2.(data) for data in rgb_data]
    min_value = minimum(reshape(scaled_data[1],:))
    factor = quantile(reshape(scaled_data[1],:),p_quantile) - min_value

    scaled_data = [ (data .- min_value) ./ factor for data in scaled_data]

    img =[Images.Colors.RGB(scaled_data[1][i,j],scaled_data[2][i,j],scaled_data[3][i,j]) 
        for i=1:size(scaled_data[1])[1], j=1:size(scaled_data[1])[2]]
    return img
end


resampled_data = reshape(resampled_data,size(imageA.data));

plot_multiple_sar([resampled_data[:,1:4:end],imageA.data[:,1:4:end],imageA.data[:,1:4:end]])

# reramp image resampled


mid_burst_state_a = SARProcessing.get_burst_mid_states(imageA, interpolator_a)
mid_burst_state_a = mid_burst_state_a[SARProcessing.get_burst_numbers(imageA) .==1]
mid_burst_speed_a = SARProcessing.get_speed.(mid_burst_state_a)[1]

phase_ramp_a = SARProcessing.phase_ramp(
    collect( windowA[1][1]:windowA[1][2]), 
    collect( windowA[2][1]:windowA[2][2]), 
1, mid_burst_speed_a, metadataA)

resampled_data .= resampled_data .* exp.(phase_ramp_a .* im)

### create inferogram ?
plot_phase((imageA.data .* conj.(resampled_data))[:,1:4:end])
plot_phase((imageA.data .* conj.(resampled_data) .*flat_inteferogram)[:,1:4:end] )

# credit https://github.com/aamini/FastConv.jl
# direct version (do not check if threshold is satisfied)
@generated function fastconv(E::Array{T,N}, k::Array{T,N}) where {T,N}
    quote

        retsize = [size(E)...] + [size(k)...] .- 1
        retsize = tuple(retsize...)
        ret = zeros(T, retsize)

        convn!(ret,E,k)
        return ret

    end
end

# credit https://github.com/aamini/FastConv.jl
# in place helper operation to speedup memory allocations
@generated function convn!(out::Array{T}, E::Array{T,N}, k::Array{T,N}) where {T,N}
    quote
        @inbounds begin
            @nloops $N x E begin
                @nloops $N i k begin
                    (@nref $N out d->(x_d + i_d - 1)) += (@nref $N E x) * (@nref $N k i)
                end
            end
        end
        return out
    end
end


function complex_coherence(master, slave, flat, kernel)
    # Define relevant image signals
    signal_1 = master .* conj.(slave) .* flat
    signal_2 = abs2.(master)
    signal_3 = abs2.(slave)
    kernel_1 = convert.(eltype(signal_1),kernel)
    kernel_2 = convert.(eltype(signal_2),kernel)
    kernel_3 = convert.(eltype(signal_3),kernel)

    # Compute real and imaginary parts seperately
    interferogram =  fastconv(signal_1, kernel_1)
    master_intensity = fastconv(signal_2, kernel_2)
    slave_intensity = fastconv(signal_3, kernel_3)

    # Compute the complex coherence
    complex_coherence = interferogram ./ (sqrt.(master_intensity .* slave_intensity));



    return complex_coherence
end

kernel = ones(4,14)
coherence =  complex_coherence(imageA.data, resampled_data,flat_inteferogram, kernel)


plot_phase(coherence[:,1:4:end])
Images.Gray.(abs.(coherence[:,1:4:end]))


maximum(sar_grid_heights[.!isnan.(sar_grid_heights)])
minimum(sar_grid_heights[.!isnan.(sar_grid_heights)])

using Images

Gray.((sar_grid_heights .- 500) ./1300)

maximum([x[1] for x in dem_sar_index]) 
minimum([x[1] for x in dem_sar_index]) 

maximum([x[2] for x in dem_sar_index]) 
minimum([x[2] for x in dem_sar_index]) 

window = [[5,2000],[8400,20000]]














metadata_path = SARProcessing.get_annotation_path_sentinel1(safefolderA, polarisation, swath);

metadataA = SARProcessing.Sentinel1MetaData(metadata_path);

argmin(metadataA.geolocation.latitude)
metadataA.geolocation.lines[1]

findfirst(metadataA.geolocation.latitude .> 36)

metadataA.geolocation.lines[61]
windowA = [[1 , 3000],[7600 , 20000]]

findfirst(metadataA.geolocation.longitude .> -118 )

metadataA.geolocation.samples[end]


metadataA.swath.lines_per_burst
## take two first burst of imageA 



max(metadataA.geolocation.samples...)
min(metadataA.geolocation.longitude...)


get_annotation_path_sentinel1(safe_path::AbstractString, polarisation::Polarisation, swath::Integer)
metadata = Sentinel1MetaData(metadata_path)
files =  readdir(folder)









approx_image_footprint(meta_data,window) = [[latitude_min,latitude_max]],[[longitude_min,longitude_max]]
approx_image_window(metadata, points) = # use geogridpoints 


function get_height_sar_grid(rows,columns,interpolator, metadata, dem_subset)
    dem_sar_index = coordinates2index(dem_sub_set)
    heights_sar_grid_interpolator = interpolator(dem_sar_index, dem_sub_set.heights)
    heights_sar_gird = heights_sar_grid_interpolator( rows,columns)
    return heights_sar_gird 
end

coords = index2coordinates(rows,columns, heights ,interpolator, metadata) ::Matrix


# LOOK up table start 
struct GeoCodeTable
    columns:: Vector
    rows::Vector
    heights::Matrix
    latitude::Matrix
    longitude::Matrix
end


struct CoregisteredSLC
    metadata::MetaData
    data::Matrix
    flattening::Matrix
end

struct SingleLookComplexStack
    geocode_table::GeoCodeTable
    primary_image::SingleLookComplex
    secondary_images::Vector{CoregisteredSLC}
end


function interpolate_image_to_primary(secondary_image,orbit_interpolator_secondary, GeoCodeTable)
    index_secondary_image_sparse = coordinates2index(GeoCodeTable.coords,orbit_interpolator_secondary, metadata_secondary)
    index_secondary_image_dense = blabla

    ##get flattening or similar thing 
    deramp(secondary_image)
    data_interpolator = interpolate(data)
    reasample_data = data_interpolator(index_secondary_image_dense)
    return reasample_data
end

end 