
include("MetaDataTypes.jl")

struct Sentinel1SLC <: SingleLookComplex
    swath_number::Int64
    metadata::Sentinel1MetaData
    index_start::Tuple{Int,Int}
    data::Array{Complex{Float64},2}
end

## implement interface
get_metadata(image::Sentinel1SLC) = image.metadata;
get_data(image::Sentinel1SLC) = image.data;