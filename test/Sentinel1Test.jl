
include("../src/separateLater/Sentinel1/Sentinel1.jl")
import .Sentinel1

@testset "Sentinel1.jl" begin
     
    ####### Generate test data ##############
    createMetaData() = Sentinel1.MetaData("VV",Sentinel1.DateTime(2013,7,1,12,30,59),5405)
    function createComplexSwath(swath) 
        pixels = ones( Complex{Float64}, (2, 3)) .* (1.0+2.0im)
        return Sentinel1.ComplexSwath(swath,(20,50),pixels)
    end

     ####### Test functions ##############
    function constructMetaDataTest() 
        testMeta = createMetaData()
        return testMeta.polarisation == "VV" && testMeta.frequencyInMHz == 5405
    end

    function constructComplexSwathTest() 
        testSwath = createComplexSwath(1)
        return testSwath.swath == 1 && size(testSwath.pixels) == (2,3)
    end

    function constructComplexImageTest() 
        testImage= Sentinel1.ComplexImage(createMetaData(), [createComplexSwath(swath) for swath =1:3])
        return testImage.metadata.polarisation == "VV" && length(testImage.swathArray) == 3
    end



    ####### actual tests ###############
    @test constructMetaDataTest() 
    @test constructComplexSwathTest() 
    @test constructComplexImageTest() 

end