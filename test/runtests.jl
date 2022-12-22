using SARProcessing, Test, Dates, LinearAlgebra
import ArchGDAL, Images


const PRECISE_ORBIT_TEST_FILE = "testData/S1A_OPER_AUX_POEORB_20221119T081845.EOF"
const SENTINEL1_SLC_METADATA_TEST_FILE = "testData/s1a-iw3-slc-vv-20220918t074921-20220918t074946-045056-056232-006.xml"
const slcSubsetWindow = [(9800,10400),(11000,12400)]
const slcSubsetPath = "testData/s1a-iw3-slc-vv_subset_hight9800_10400_width11000_11000.tiff"

@testset "Test of repos" begin
    include("GeoCoding/CoordinateTransformationTest.jl")
    include("GeoCoding/OrbitStateTest.jl")
    include("GeoCoding/DEMTest.jl")
    
    include("VisualiseSAR/VisualiseSARTest.jl")

    include("Sensors/Sentinel1/Sentinel1Types.jl")
    include("Sensors/Sentinel1/Sentinel1ReadTiffTest.jl")
    include("Sensors/Sentinel1/Sentinel1MetadataTest.jl")
end


