

abstract type DEM end

############# DEM Interface begin ######################################

"""
    get_coordinate(dem::T,index::Tuple{Integer,Integer}) where T <: DEM

Get the coordinate for a certain index in the DEM.
(All the DEM's are stored as a matrix of heights)
"""
function get_coordinate(dem::T,index::Tuple{Integer,Integer}) where T <: DEM
     ErrorException("Not implemented for the following DEM type, $T")
end


"""
    get_index(dem::T,coordinate::Tuple{Real,Real}) where T <: DEM

Get the index of the DEM corresponding to the coordinate.
(All the DEM's are stored as a matrix of heights)
"""
function get_index(dem::T,coordinate::Tuple{Real,Real}) where T <: DEM
    ErrorException("Not implemented for the following DEM type, $T")
end

############# DEM Interface end ######################################


"""
    TandemxDEM <: DEM

A DEM implementation for Tandem-X DEM data.
"""
struct TandemxDEM <: DEM
    heights::Array{Float32,2}
    coordinate_offset::Tuple{Float64,Float64} ## lat lon
    coordinate_spacing::Tuple{Float64,Float64} ## lat lon
end

# No data value from documentation https://geoservice.dlr.de/web/dataguide/tdm90/
const TANDEX_DEM_NO_DATA_VALUE = -32767.0

"""
    load_tandemx_dem(tiffPath::String) -> TandemxDEM

Load a Tandem-X DEM tiff. The Tandem-X DEM's can be downloaded from https://download.geoservice.dlr.de/TDM90/.
Note: Invalid values are replaced with missing
"""
function load_tandemx_dem(tiffPath::String; missing_values::Real=NaN)
    dataset = ArchGDAL.readraster(tiffPath)

    transform = ArchGDAL.getgeotransform(dataset)

    coordinate_offset = (transform[4],transform[1])
    coordinate_spacing = (transform[6],transform[2])

    heights = dataset[:,:,1]
    heights = permutedims(heights, (2, 1));

    # Remove values close to or below the no data value
    invalid = heights .< (TANDEX_DEM_NO_DATA_VALUE + 1000)
    heights[invalid] .= missing_values

    # check that all ridicules values are removed
    @assert !any(heights .< -1000)

    return TandemxDEM(heights, coordinate_offset, coordinate_spacing)
end


function get_coordinate(dem::TandemxDEM,index::Tuple{Integer,Integer})
    return dem.coordinate_offset .+ (index.-1) .* dem.coordinate_spacing
end


function get_index(dem::TandemxDEM,coordinate::Tuple{Real,Real})
    return (coordinate .- dem.coordinate_offset) ./ dem.coordinate_spacing .+ 1
end
