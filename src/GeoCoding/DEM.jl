

abstract type DEM end

############# DEM Interface begin ######################################

"""
    getCoordinate(dem::T,index::Tuple{Integer,Integer}) where T <: DEM

    Get the coordinate for a certain index in the DEM. 
    (All the DEM's are stored as a matrix of heights)
"""
function getCoordinate(dem::T,index::Tuple{Integer,Integer}) where T <: DEM
     ErrorException("Not implemented for the following DEM type, $T")
end


"""
    getIndex(dem::T,coordinate::Tuple{Real,Real}) where T <: DEM

    Get the index of the DEM corresponding to the coordinate. 
    (All the DEM's are stored as a matrix of heights)
"""
function getIndex(dem::T,coordinate::Tuple{Real,Real}) where T <: DEM
    ErrorException("Not implemented for the following DEM type, $T")
end

############# DEM Interface end ######################################


"""
    TandemxDEM <: DEM

    A DEM implementation for Tandem-X DEM data.
"""
struct TandemxDEM <: DEM
    heights::Array{Union{Missing,Float32},2}
    coordinateOffset::Tuple{Float64,Float64} ## lat lon
    coordinateSpacing::Tuple{Float64,Float64} ## lat lon
end



"""
    loadTandemxDEM(tiffPath::String) -> TandemxDEM

    Load a Tandem-X DEM tiff. The Tandem-X DEM's can be downloaded from https://download.geoservice.dlr.de/TDM90/.
    Note: Invalid values are replaced with missing 
"""
function loadTandemxDEM(tiffPath::String)
    dataset = ArchGDAL.readraster(tiffPath)

    transform = ArchGDAL.getgeotransform(dataset)

    coordinateOffset = (transform[4],transform[1])
    coordinateSpacing = (transform[6],transform[2])

    dataset = dataset[:,:,1]
    dataset = permutedims(dataset, (2, 1));

    heights = Array{Union{Missing,Real},2}(missing,size(dataset)...)
    valid = dataset .> -3000.0
    heights[valid] .= dataset[valid]

    return TandemxDEM(heights, coordinateOffset, coordinateSpacing)
end


function getCoordinate(dem::TandemxDEM,index::Tuple{Integer,Integer})
    return dem.coordinateOffset .+ (index.-1) .* dem.coordinateSpacing
end


function getIndex(dem::TandemxDEM,coordinate::Tuple{Real,Real})
    return (coordinate .- dem.coordinateOffset) ./ dem.coordinateSpacing .+ 1
end

