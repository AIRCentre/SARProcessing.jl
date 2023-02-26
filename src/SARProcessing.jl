module SARProcessing
using Dates, Statistics
import XMLDict, Images, ArchGDAL, Polynomials, LinearAlgebra, SciPy





const LIGHT_SPEED = 299792458.0

include("enums.jl")
include("SARImageInterface.jl")
include("MetaDataUtils.jl")
include("GeoCoding/GeoCoding.jl")
include("VisualiseSAR/VisualiseSAR.jl")
include("Sensors/Sensors.jl")
include("Speckle_filter/speckle_filters.jl")
include("InSAR/InSAR.jl")
include("Object_detector/object_detector.jl")


end # module SARProcessing

