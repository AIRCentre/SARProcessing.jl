module SARProcessing
using Dates, Statistics
import XMLDict, Images, ArchGDAL, Polynomials, LinearAlgebra

const LIGHT_SPEED = 299792458.0

include("enums.jl")
include("SARImageInterface.jl")
include("GeoCoding/GeoCoding.jl")
include("VisualiseSAR/VisualiseSAR.jl")
include("Sensors/Sensors.jl")
include("Speckle_filter/speckle_filters.jl")

end # module SARProcessing

