""""
Structures and constructors for the metadata. 
    Sentinel1MetaData
        - ::Sentinel1Header
        - ::Sentinel1ProductInformation
        - ::Sentinel1ImageInformation
        - ::Sentinel1SwathTiming
        - ::Vector{Sentinel1BurstInformation}
        - ::Sentinel1GeolocationGrid
"""
#currently, it is called "Sentinel1MetaData" to allow for a later abstract structures with MetaData for different satellites.



##################
### Structures
##################
##base.@kwdef not a part of stable julia. Probably will be future release(?)
"""
Sentinel1Header

returns structure of Sentinel1Header from metadata in .xml
"""
Base.@kwdef struct Sentinel1Header
    mission_id::String
    product_type::String
    polarisation::Polarisation
    mission_data_take_id::Int
    swath::Int
    mode::String
    start_time::Float64
    stop_time::Float64
    absolute_orbit_number::Int
    image_number::String
end


"""
Sentinel1ProductInformation

returns structure of product information 
"""
Base.@kwdef struct Sentinel1ProductInformation
    pass::String
    timeliness_category::String
    platform_heading::Float64
    projection::String
    range_sampling_rate::Float64
    radar_frequency::Float64
    azimuth_steering_rate::Float64
end



"""
Sentinel1ImageInformation

returns structure of Sentinel1ImageInformation from metadata in .xml
"""
Base.@kwdef struct Sentinel1ImageInformation
    range_pixel_spacing::Float64
    azimuth_frequency::Float64
    slant_range_time_seconds::Float64  # are stored as float because of accuracy
    incidence_angle_mid_swath::Float64
    azimuth_pixel_spacing::Float64
    number_of_samples::Int
end

"""
Sentinel1SwathTiming

returns structure of Sentinel1SwathTiming from metadata in .xml
"""
Base.@kwdef struct Sentinel1SwathTiming
    lines_per_burst::Int64
    samples_per_burst::Int64
    burst_count::Int32
end




"""
Sentinel1DopplerCentroid

returns structure of Sentinel1DopplerCentroid from metadata in .xml
Sentinel1DopplerCentroid is calculated for each burst, and is therefore saved in each burst
"""
Base.@kwdef struct Sentinel1DopplerCentroid
    polynomial::Vector{Float64}
    t0::Float64
end




"""
Sentinel1AzimuthFmRate

returns structure of Sentinel1AzimuthFmRate from metadata in .xml
Sentinel1AzimuthFmRate is calculated for each burst, and is therefore saved in each burst
"""
Base.@kwdef struct Sentinel1AzimuthFmRate
    polynomial::Vector{Float64}
    t0::Float64
end




"""
Sentinel1BurstInformation

returns structure of Sentinel1BurstInformation from metadata in .xml
Sentinel1BurstInformation contain information from Sentinel1DopplerCentroid and Sentinel1AzimuthFmRate
"""
Base.@kwdef struct Sentinel1BurstInformation
    burst_number::Int32
    azimuth_time::Float64
    sensing_time::Float64
    azimuth_anx_time::Millisecond
    byte_offset::Int64
    first_valid_sample::Vector{Int64}
    last_valid_sample::Vector{Int64}
    burst_id::Int64
    absolute_burst_id::Int64
    azimuth_fm_rate::Sentinel1AzimuthFmRate
    doppler_centroid::Sentinel1DopplerCentroid
end



"""
Sentinel1GeolocationGrid

returns structure of Sentinel1GeolocationGrid from metadata in .xml
"""
Base.@kwdef struct Sentinel1GeolocationGrid
    lines::Vector{Int64}
    samples::Vector{Int64}
    latitude::Vector{Float64}
    longitude::Vector{Float64}
    azimuth_time::Vector{Float64}
    slant_range_time_seconds::Vector{Float64} # are stored as float because of accuracy
    elevation_angle::Vector{Float64}
    incidence_angle::Vector{Float64}
    height::Vector{Float64}
end



"""
Sentinel1MetaData:
    Metadata structure for the Sentinel-1 satellite for each burst in the swath.

    General metadata info is kept in the following structures:
        - Sentinel1Header
        - Sentinel1ProductInformation
        - Sentinel1ImageInformation
        - Sentinel1SwathTiming
        - Sentinel1GeolocationGrid
    Sentinel1BurstInformation specific Info is kept in 
        - Vector{Sentinel1BurstInformation}
   
Example:
    slcMetadata = Sentinel1MetaData(meta_dict)

    Input:
        meta_dict: xml file.

    can be accessed as, e.g., 
    slcMetadata.product.radar_frequency --> 5.40500045433435e9::Float64
    slcMetadata.header.swath --> 1::Int
    slcMetadata.header.mode --> "IW"::String
    slcMetadata.header.polarisation --> "VH"::String
"""
Base.@kwdef struct Sentinel1MetaData <: MetaData
    reference_time::DateTime
    header::Sentinel1Header
    product::Sentinel1ProductInformation
    image::Sentinel1ImageInformation
    swath::Sentinel1SwathTiming
    bursts::Vector{Sentinel1BurstInformation}
    geolocation::Sentinel1GeolocationGrid
end


get_polarisation(meta_data::Sentinel1MetaData) = meta_data.header.polarisation
get_range_sampling_rate(meta_data::Sentinel1MetaData) = meta_data.product.range_sampling_rate
get_azimuth_frequency(meta_data::Sentinel1MetaData) = meta_data.image.azimuth_frequency
get_slant_range_time_seconds(meta_data::Sentinel1MetaData) = meta_data.image.slant_range_time_seconds
get_time_range(meta_data::Sentinel1MetaData) = (meta_data.header.start_time, meta_data.header.stop_time)
get_reference_time(meta_data::Sentinel1MetaData) = meta_data.reference_time
get_incidence_angle_mid_degrees(meta_data::Sentinel1MetaData)= meta_data.image.incidence_angle_mid_swath

function get_burst_start_times(meta_data::Sentinel1MetaData)
    return [element.azimuth_time for element in meta_data.bursts]
end

function get_burst_mid_times(meta_data::Sentinel1MetaData)
    burst_duration_in_seconds = get_burst_duration(meta_data)
    half_burst_period = Millisecond(round(Int, burst_duration_in_seconds/2 *1000))
    return get_burst_start_times(meta_data) .+ half_burst_period 
end

function get_burst_end_times(meta_data::Sentinel1MetaData)
    burst_duration_in_seconds = get_burst_duration(meta_data)
    burst_duration = Millisecond(round(Int, burst_duration_in_seconds*1000))
    return get_burst_start_times(meta_data) .+ burst_duration 
end

function get_burst_duration(meta_data::Sentinel1MetaData)
    lines_per_burst = meta_data.swath.lines_per_burst
    azimuth_frequency = meta_data.image.azimuth_frequency
    burst_duration_in_seconds = lines_per_burst /azimuth_frequency
    return burst_duration_in_seconds
end

function get_burst_row_offset(meta_data::Sentinel1MetaData)
    azimuth_frequency = get_azimuth_frequency(meta_data)
    bursts_start_times = get_burst_start_times(meta_data)
    time_delta_bursts = bursts_start_times .- meta_data.header.start_time
    burst_row_offset = time_delta_bursts.* azimuth_frequency
    return burst_row_offset
end

function get_burst_start_row(meta_data::Sentinel1MetaData)
    lines_per_burst = meta_data.swath.lines_per_burst

    return 1 .+ [n*lines_per_burst for n in 0:(length(meta_data.bursts)-1)]

end


"""
get_image_rows(meta_data::Sentinel1MetaData, row_from_first_burst)

Converts the row number representing a unique azimuth time, row_from_first_burst, 
to the number in the full image. Note that two results are returned when the row appears in
two bursts
"""
function get_image_rows(meta_data::Sentinel1MetaData, row_from_first_burst)
    burst_row_offset = get_burst_row_offset(meta_data)
    lines_per_burst = meta_data.swath.lines_per_burst
    burst_start_row = get_burst_start_row(meta_data)

    row_in_burst = row_from_first_burst .- burst_row_offset 

    is_row_in_burst =  (1 .<= row_in_burst) .& (row_in_burst .<= lines_per_burst)

    image_row = row_in_burst .+ burst_start_row .- 1

    return image_row[is_row_in_burst]
end
