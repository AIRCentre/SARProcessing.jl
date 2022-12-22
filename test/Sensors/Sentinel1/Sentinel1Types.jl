
####### Helper function ##############
createMetaData() = SARProcessing.MetaDataSLC("VV",1,SARProcessing.DateTime(2013,7,1,12,30,59),5405)

function createSwathSLC() 
    metaData = createMetaData() 
    pixels = ones( Complex{Float64}, (2, 3)) .* (1.0+2.0im)
    return SARProcessing.SwathSLC(metaData, (20,50),pixels)
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
        println("Debug info: ", string(StackTraces.stacktrace()[1].func))
        println("swathNumber: ", swathNumber)
        println("datasize: ", datasize)
        println("polarization: ", polarisation)
    end

    return testOk
end




@testset "Sentinel1Types.jl" begin
    ####### actual tests ###############
    @test constructMetaDataTest() 
    @test constructSwathSLCTest()
end