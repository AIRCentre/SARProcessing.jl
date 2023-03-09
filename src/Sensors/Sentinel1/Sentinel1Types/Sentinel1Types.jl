
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

"""
    get_window(image::Sentinel1SLC)

Returns the window of the complete Sentinel image covered the "image"
"""
function get_window(image::Sentinel1SLC)
    rows_start = image.index_start[1]
    rows_end = size(image.data)[1] + image.index_start[1] - 1

    columns_start = image.index_start[2]
    columns_end = size(image.data)[2] + image.index_start[2] - 1

    return [[rows_start, rows_end],[columns_start, columns_end]]
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


function get_burst_mid_times(image::Sentinel1SLC)
    mid_times = get_burst_mid_times(image.metadata)
    return mid_times
end
