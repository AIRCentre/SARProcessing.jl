

"""
General metadata need for SAR images
"""
struct MetaDataSLC
    polarisation::String
    swath::Int
    sensingTime::DateTime
    frequencyInMHz::Float64
end


"""
General subset for complex swath
"""
struct SwathSLC
    metadata::MetaDataSLC ## Sentinel 1 images has a metadata file for each swath
    indexOffset::Tuple{Int,Int}
    pixels::Array{Complex,2}
end
