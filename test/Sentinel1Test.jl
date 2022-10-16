
include("../src/separateLater/Sentinel1/Sentinel1.jl")
import .Sentinel1

     
####### Helper function ##############
createMetaData() = Sentinel1.MetaDataSLC("VV",1,Sentinel1.DateTime(2013,7,1,12,30,59),5405)

function createSwathSLC() 
    metaData = createMetaData() 
    pixels = ones( Complex{Float64}, (2, 3)) .* (1.0+2.0im)
    return Sentinel1.SwathSLC(metaData, (20,50),pixels)
end

    ####### Test functions ##############
function constructMetaDataTest() 
    ## Arrange
    
    ## Act
    testMeta = createMetaData()
    
    ## Assert
    testOk = testMeta.polarisation == "VV" && testMeta.frequencyInMHz == 5405

    return testOk
end

function constructSwathSLCTest() 
    ## Arrange

    ## Act
    testSwath = createSwathSLC()

    ## Assert
    swathNumber = testSwath.metadata.swath
    datasize = size(testSwath.pixels)
    polarisation = testSwath.metadata.polarisation 

    testOk = swathNumber == 1 && datasize == (2,3) && polarisation == "VV"
    
    ## Debug
    if !testOk
        println("Debug info: ", String(Symbol(constructSwathSLCTest)))
        println("swathNumber: ", swathNumber)
        println("datasize: ", datasize)
        println("polarization: ", polarisation)
    end

    return testOk
end


function readSLCSwathTest() 
    ## Arrange
    filePath = "/Users/lupemba/Downloads/S1A_IW_SLC__1SDV_20220918T074920_20220918T074947_045056_056232_62D6.SAFE/measurement/s1a-iw3-slc-vv-20220918t074921-20220918t074946-045056-056232-006.tiff"
    window = [(501,600),(501,650)]

    if !isfile(filePath)
        println("Test image not found. Contact lupemba for the image")
        return true
    end


    ## Act
    swath = Sentinel1.readSwathSLC(filePath, window)

    ## Assert
    checkType = typeof(swath)== Matrix{ComplexF64}
    checkSize = (window[1][2]-window[1][1]+1, window[2][2]-window[2][1]+1) == size(swath)
    checkNotZero = !all(isapprox.(swath,0.0 +0.0im))

    testOk = checkType && checkSize && checkNotZero

    ## Debug
    if !testOk
        println(checkType)
        println("type of: ", typeof(swath))
        println("size: ", size(swath))
        println("data example: ", swath[end-3:end,end-3:end])
    end

    return testOk
end

@testset "Sentinel1.jl" begin
    ####### actual tests ###############
    @test constructMetaDataTest() 
    @test constructSwathSLCTest()
    @test readSLCSwathTest()

end