
include("MetaDataTypes.jl")

mutable struct Sentinel1SLC <: SingleLookComplex
    metadata::Sentinel1MetaData
    index_start::Tuple{Int,Int}
    data::Array{Complex{Float64},2}
    deramped::Bool
end

## implement interface
get_metadata(image::Sentinel1SLC) = image.metadata;
get_data(image::Sentinel1SLC) = image.data;
is_deramped(image::Sentinel1SLC) = image.deramped;
get_time_range(image::Sentinel1SLC) = (image.metadata.header.start_time, image.metadata.header.stop_time)

"""
get_window(image::Sentinel1SLC)

    Returns the window of the complete Sentinel image covered the "image"
"""
function get_window(image::Sentinel1SLC)
    index_1_start = image.index_start[1]
    index_1_end = size(image.data)[1] + image.index_start[1] - 1

    index_2_start = image.index_start[2]
    index_2_end = size(image.data)[2] + image.index_start[2] - 1

    return [[index_1_start, index_1_end],[index_2_start, index_2_end]]
end

"""
get_burst_numbers(image::Sentinel1SLC)

    Returns list of burst included in the image subset
"""
function get_burst_numbers(image::Sentinel1SLC)
    lines_per_burst = image.metadata.swath.lines_per_burst
    window = get_window(image)
    index_1_range = window[1]
    
    burst_start = Integer(ceil( (index_1_range[1]-1) / lines_per_burst)) 
    burst_end = Integer(ceil( (index_1_range[2]-1) / lines_per_burst)) 
    
    return burst_start:burst_end
end

function get_burst_start_times(image::Sentinel1SLC)

    meta_data = image.metadata
    burst_numbers = get_burst_numbers(image)
    burst_info = meta_data.bursts[burst_numbers]

    return [element.azimuth_time for element in burst_info]
end

function get_burst_mid_times(image::Sentinel1SLC)
    lines_per_burst = image.metadata.swath.lines_per_burst
    azimuth_frequency = image.metadata.image.azimuth_frequency
    half_burst_period = Millisecond(round(Int,lines_per_burst / (2 * (azimuth_frequency*0.001) )))
    return get_burst_start_times(image) .+ half_burst_period 
end

get_burst_mid_states(image::Sentinel1SLC, interpolator) = [interpolator(t) 
                                                            for t in get_burst_mid_times(image)]

