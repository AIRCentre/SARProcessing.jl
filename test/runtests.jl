using SARProcessing, Test, Dates, LinearAlgebra
using Statistics
import ArchGDAL, Images


const PRECISE_ORBIT_TEST_FILE = "testData/S1A_OPER_AUX_POEORB_20221119T081845.EOF"
const PRECISE_ORBIT_TEST_FILE2 = "testData/S1A_OPER_AUX_RESORB_OPOD_20220918T093241_V20220918T053155_20220918T084925.EOF"
const SENTINEL1_SLC_METADATA_TEST_FILE = "testData/s1a-iw3-slc-vv-20220918t074921-20220918t074946-045056-056232-006.xml"
const SLC_SUBSET_WINDOW = [(9800,10400),(11000,12400)]
const SLC_SUBSET_PATH = "testData/s1a-iw3-slc-vv_subset_hight9800_10400_width11000_11000.tiff"
const SLC_SAFE_PATH = "testData/largeFiles/S1A_IW_SLC__1SDV_20220918T074920_20220918T074947_045056_056232_62D6.SAFE/"

function load_test_slc_image()
    metadata = SARProcessing.Sentinel1MetaData(SENTINEL1_SLC_METADATA_TEST_FILE)
    index_start = (SLC_SUBSET_WINDOW[1][1],SLC_SUBSET_WINDOW[2][1])
    data = SARProcessing.load_tiff(SLC_SUBSET_PATH)
    return SARProcessing.Sentinel1SLC(metadata,index_start,data,false)
end


@testset "Test of repos" begin
    include("GeoCoding/CoordinateTransformationTest.jl")
    include("GeoCoding/OrbitStateTest.jl")
    include("GeoCoding/DEMTest.jl")
    include("GeoCoding/coordinates2indexTest.jl")
    include("GeoCoding/SarIndex2CoordinatesTest.jl")
    
    include("VisualiseSAR/VisualiseSARTest.jl")

    include("Sensors/Sentinel1/Sentinel1TypesTest.jl")
    include("Sensors/Sentinel1/Sentinel1ReadTiffTest.jl")
    include("Sensors/Sentinel1/Sentinel1MetadataTest.jl")
    include("Sensors/Sentinel1/FileIoTest.jl")
    include("Sensors/Sentinel1/PreciseOrbitTest.jl")

    include("InSAR/InSARTest.jl")
    include("object_detector/object_detector_cfar_test.jl")
    include("object_detector/object_detector_filter_test.jl")
    include("object_detector/object_detector_operations_test.jl")

end


