module object_detector


import SpecialFunctions
import Images
import Statistics

include("object_detector/cfar/cfar.jl")
include("object_detector/operations.jl")
include("object_detector/filters.jl")
import .operations
import .filters


end
