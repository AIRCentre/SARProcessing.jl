using Test
import  SARProcessing
using Dates
import .Sentinel1, ArchGDAL

include("../src/separateLater/Sentinel1/Sentinel1.jl")
include("../src/SARProcessing.jl")
using .SARProcessing

const PRECISE_ORBIT_TEST_FILE = "testData/S1A_OPER_AUX_POEORB_20221119T081845.EOF"
const SENTINEL1_SLC_METADATA_TEST_FILE = "testData/s1a-iw3-slc-vv-20220918t074921-20220918t074946-045056-056232-006.xml"


@testset "Test of repos" begin
    include("Sentinel1MetadataTest.jl")
    include("SARProcessingTest.jl")
    include("geometryUtilsTest.jl")
    include("Sentinel1Test.jl")
    include("VisualiseSARTest.jl")
    include("OrbitStateTest.jl")
    include("object_detector_cfar_test.jl")
    include("object_detector_filter_test.jl")
    include("object_detector_operations_test.jl")
end


