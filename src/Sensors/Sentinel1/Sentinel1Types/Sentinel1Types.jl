
include("MetaDataTypes.jl")

struct Sentinel1SLC <: SingleLookComplex
    metadata::Sentinel1MetaData
    index_start::Tuple{Int,Int}
    data::Array{Complex{Float64},2}
    deramped::Bool
end

## implement interface
get_metadata(image::Sentinel1SLC) = image.metadata;
get_data(image::Sentinel1SLC) = image.data;
is_deramped(image::Sentinel1SLC) = image.deramped;