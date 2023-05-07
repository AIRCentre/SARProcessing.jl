module SARProcessing
using Dates, Statistics
import XMLDict, Images, ArchGDAL, Polynomials, LinearAlgebra, TimesDates

const LIGHT_SPEED = 299792458.0

period_to_float_seconds(nanoSeconds::Nanosecond) = Float64(nanoSeconds.value *10^-9)
period_to_float_seconds(milliseconds::Millisecond) = Float64(milliseconds.value *10^-3)
period_to_float_seconds(seconds::Second) = Float64(seconds.value)

float_seconds_to_period(seconds::Real) = Nanosecond(round(seconds*10^9))

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

