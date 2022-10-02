
include("../src/separateLater/VisualiseSAR/VisualiseSAR.jl")
import .VisualiseSAR


@testset "VisualiseSARTest.jl" begin
    @test VisualiseSAR.exampleFunction3()
end