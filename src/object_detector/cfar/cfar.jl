module cfar


include("ca_cfar.jl")
include("cp_cfar.jl")

include("../operations.jl")
include("../filters.jl")

import .operations
import .filters

import SpecialFunctions
import Statistics
import Images

end
