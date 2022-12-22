

"""
SwathSLC

A datatype for a Sentinel 1 Single Look Complex (SLC) swath subset. 

# Arguments
- `metadata::MetaDataSLC`: Meta data for the Sentinel 1 swath
- `indexOffset::Tuple{Int,Int}`: Pixel offeset of the subset with respect to the complete swath
- `pixels::Array{Complex,2}`: The pixel values of the swath subset
"""
struct MetaDataSLC
    polarisation::String
    swath::Int
    sensing_time::DateTime
    frequency_MHz::Float64
end


"""
    SwathSLC

    A datatype for a Sentinel 1 Single Look Complex (SLC) swath subset. 
    
    # Arguments
    - `metadata::MetaDataSLC`: Meta data for the Sentinel 1 swath
    - `indexOffset::Tuple{Int,Int}`: Pixel offeset of the subset with respect to the complete swath
    - `pixels::Array{Complex,2}`: The pixel values of the swath subset
"""
struct SwathSLC
    metadata::MetaDataSLC ## Sentinel 1 images has a metadata file for each swath
    index_offset::Tuple{Int,Int}
    pixels::Array{Complex,2}
end
