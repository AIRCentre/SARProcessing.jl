include("ReadTiff.jl")
include("Metadata/Sentinel1Metadata.jl")
include("PreciseOrbit.jl")


function load_sentinel1slc(safe_path::AbstractString, polarisation::Polarisation, swath::Integer, window=nothing)
    tiff_path = get_data_path_sentinel1(safe_path, polarisation, swath)
    metadata_path = get_annotation_path_sentinel1(safe_path, polarisation, swath)
    
    data = load_tiff(tiff_path, window, convertToDouble = true, flip = true)
    metadata = Sentinel1MetaData(metadata_path)
    
    local index_start

    if isnothing(window)
        index_start = (1,1)
    else
        index_start = (window[1][1],window[2][1])
    end
    
    return Sentinel1SLC( metadata, index_start, data,false)
end



function get_annotation_path_sentinel1(safe_path::AbstractString, polarisation::Polarisation, swath::Integer)

    files = readdir(joinpath(safe_path,"annotation"))
    file_name = _find_file_sentinel1(files, polarisation, swath)
    return joinpath(safe_path,"annotation",file_name) 
end

function get_data_path_sentinel1(safe_path::AbstractString, polarisation::Polarisation, swath::Integer)

    files = readdir(joinpath(safe_path,"measurement"))
    file_name = _find_file_sentinel1(files, polarisation, swath)
    return joinpath(safe_path,"measurement",file_name) 
end

function _find_file_sentinel1(files::Vector{T},polarisation::Polarisation, swath::Integer) where T <: AbstractString

    files_with_correct_name_format = files[ [ length(split(name,"-")) == 9 for name in files ] ]
    files_name_parts = [split(name,"-") for name in files_with_correct_name_format]

    files_polarisation = [ parse(Polarisation,name_parts[4]) for name_parts in files_name_parts]
    files_swath = [ parse(Int64,name_parts[2][3]) for name_parts in files_name_parts]

    file_name = files_with_correct_name_format[ (files_polarisation .== polarisation) .& (files_swath .==swath)]

    if length(file_name) != 1
        throw(ErrorException("Error, $(length(file_name)) files found"))
    end

    return file_name[1]
end
