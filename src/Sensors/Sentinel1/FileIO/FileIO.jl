include("ReadTiff.jl")
include("Metadata/Sentinel1Metadata.jl")
include("PreciseOrbit.jl")


function load_sentinel1slc(safe_path::AbstractString, swath::Integer, window=nothing)
    tiff_path = ""
    metadata_path = ""
    
    data = load_tiff(tiff_path, window, convertToDouble = true, flip = true)
    metadata = Sentinel1MetaData(metadata_path)
    
    local index_start

    if isnothing(window)
        index_start = (1,1)
    else
        index_start = (window[1][1],window[2][1])
    end
    
    return Sentinel1SLC(swath, metadata, index_start, data)
end