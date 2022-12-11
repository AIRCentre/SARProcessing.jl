using Test
import  SARProcessing

@testset "Test of repos" begin
    include("SARProcessingTest.jl")
    include("geometryUtilsTest.jl")
    include("Sentinel1Test.jl")
    include("VisualiseSARTest.jl")
end


