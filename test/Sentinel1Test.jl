
include("../src/separateLater/Sentinel1/Sentinel1.jl")
import .Sentinel1

@testset "Sentinel1.jl" begin
     
    ####### Generate test data ##############
    createMetaData() = Sentinel1.MetaDataSLC("VV",1,Sentinel1.DateTime(2013,7,1,12,30,59),5405)
    
    function createSwathSLC() 
        metaData = createMetaData() 
        pixels = ones( Complex{Float64}, (2, 3)) .* (1.0+2.0im)
        return Sentinel1.SwathSLC(metaData, (20,50),pixels)
    end

     ####### Test functions ##############
    function constructMetaDataTest() 
        testMeta = createMetaData()
        return testMeta.polarisation == "VV" && testMeta.frequencyInMHz == 5405
    end

    function constructSwathSLCTest() 
        testSwath = createSwathSLC()
        return testSwath.metadata.polarisation == "VV" && testSwath.metadata.swath == 1 && size(testSwath.pixels) == (2,3)
    end


    ####### actual tests ###############
    @test constructMetaDataTest() 
    @test constructSwathSLCTest() 

end