

###### Function to create testdata

## createSLCsubset() is only included as a reference to show how the slc subset is made
function createSLCsubset()
    filePath = "testData/largeFiles/S1A_IW_SLC__1SDV_20220918T074920_20220918T074947_045056_056232_62D6.SAFE/measurement/s1a-iw3-slc-vv-20220918t074921-20220918t074946-045056-056232-006.tiff"
    
    if !isfile(filePath)
        println("S1A_IW_SLC__1SDV_20220918T074920_20220918T074947_045056_056232_62D6.SAFE not found")
    end

    swathSub = SARProcessing.load_tiff(filePath, slcSubsetWindow, convertToDouble=false)
    
    ArchGDAL.create(
        slcSubsetPath,
        driver = ArchGDAL.getdriver("GTiff"),
        width=size(swathSub)[2],
        height=size(swathSub)[1],
        nbands=1,
        dtype=eltype(swathSub)
    ) do newFile
        ArchGDAL.write!(newFile,  permutedims(swathSub, (2, 1)), 1)
    end

end

####### Test functions ##############

function load_tiffTest() 
    ## Arrange
    window = [(100,200),(200,550)]

    ## Act
    swath = SARProcessing.load_tiff(slcSubsetPath, window)

    ## Assert
    checkType = typeof(swath)== Matrix{ComplexF64}
    checkSize = (window[1][2]-window[1][1]+1, window[2][2]-window[2][1]+1) == size(swath)
    checkNotZero = !all(isapprox.(swath,0.0 +0.0im))

    testOk = checkType && checkSize && checkNotZero

    ## Debug
    if !testOk
        println("Debug info: ", string(StackTraces.stacktrace()[1].func))
        println(checkType)
        println("type of: ", typeof(swath))
        println("size: ", size(swath))
        println("data example: ", swath[end-3:end,end-3:end])
    end

    return testOk
end


@testset "Sentinel1ReadTiffTest.jl" begin
    ####### actual tests ###############
    @test load_tiffTest()
end