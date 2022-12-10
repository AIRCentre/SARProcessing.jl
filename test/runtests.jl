using Test
using SARProcessing

@testset "Test of repos" begin
    include("SARProcessingTest.jl")
    include("DEMTest.jl")
    include("Sentinel1Test.jl")
    include("VisualiseSARTest.jl")
end


