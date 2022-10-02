
include("../src/separateLater/Sentinel1/Sentinel1.jl")
import .Sentinel1

@testset "Sentinel1.jl" begin
    @test Sentinel1.exampleFunction2()
end