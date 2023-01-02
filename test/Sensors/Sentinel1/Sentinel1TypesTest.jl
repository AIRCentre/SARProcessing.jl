
function create_sentinel1SLC_test() 
    ## Arrange
    
    ## Act
    image = load_test_slc_image()

    ## Assert

    testOk = length(size(image.data))==2
    
    testOk &= image.index_start[2]==11000
    testOk &= image.metadata.header.polarisation == SARProcessing.VV
    
    ## Debug
    if !testOk
        println("Debug info: ", string(StackTraces.stacktrace()[1].func))
        println("size(image.data): ", size(image.data))
        println("image.index_start:  ", image.index_start)
        println("image.meta_data.header.polarisation: ", image.metadata.header.polarisation)
    end

    return testOk
end


function sar_image_interface_test() 
    ## Arrange
    image = load_test_slc_image()
   
    ## Act
    data = SARProcessing.get_data(image)
    meta = SARProcessing.get_metadata(image)
    polarisation = SARProcessing.get_polarisation(image)
    deramped = SARProcessing.is_deramped(image)

    ## Assert

    testOk = length(size(data))==2
    testOk &= meta.header.swath == 3
    testOk &= polarisation == SARProcessing.VV
    testOk &= deramped == false
    
    ## Debug
    if !testOk
        println("Debug info: ", string(StackTraces.stacktrace()[1].func))
        println("size(data): ", size(data))
        println("meta.header.swath:  ", meta.header.swath)
        println("polarisation: ", polarisation)
        println("deramped: ", deramped)
    end

    return testOk
end

@testset "Sentinel1TypesTest.jl" begin
    ####### actual tests ###############
    @test create_sentinel1SLC_test()
    @test sar_image_interface_test()  
end