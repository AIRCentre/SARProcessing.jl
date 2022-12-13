using Test
import  SARProcessing
import Dates

const PRECISE_ORBIT_TEST_FILE = "testData/S1A_OPER_AUX_POEORB_20221119T081845.EOF"

@testset "Test of repos" begin
    include("SARProcessingTest.jl")
    include("Sentinel1Test.jl")
    include("VisualiseSARTest.jl")
    include("OrbitStateTest.jl")
end


