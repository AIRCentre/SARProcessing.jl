
include("../src/separateLater/Sentinel1/Sentinel1.jl")
import .Sentinel1

@testset "Sentinel1.jl" begin
     
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
        
        if !testOk
            println("Debug info: ", String(Symbol(constructSwathSLCTest)))
            println("swathNumber: ", swathNumber)
            println("datasize: ", datasize)
            println("polarization: ", polarisation)
        end

        return testOk
    end


    ####### actual tests ###############
    @test constructMetaDataTest() 
    @test constructSwathSLCTest() 

end