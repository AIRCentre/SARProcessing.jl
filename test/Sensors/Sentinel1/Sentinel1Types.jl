
####### Helper function ##############
create_meta_data() = SARProcessing.MetaDataSLC("VV",1,SARProcessing.DateTime(2013,7,1,12,30,59),5405)

function create_swath_slc() 
    meta_data = create_meta_data() 
    pixels = ones( Complex{Float64}, (2, 3)) .* (1.0+2.0im)
    return SARProcessing.SwathSLC(meta_data, (20,50),pixels)
end


####### Test functions ##############
function construct_meta_data_test() 
    ## Arrange
    
    ## Act
    test_meta = create_meta_data()
    
    ## Assert
    test_ok = test_meta.polarisation == "VV" && test_meta.frequency_MHz == 5405

    return test_ok
end

function construct_swath_slc_test() 
    ## Arrange

    ## Act
    test_swath = create_swath_slc()

    ## Assert
    swath_number = test_swath.metadata.swath
    data_size = size(test_swath.pixels)
    polarisation = test_swath.metadata.polarisation 

    test_ok = swath_number == 1 && data_size == (2,3) && polarisation == "VV"
    
    ## Debug
    if !test_ok
        println("Debug info: ", string(StackTraces.stacktrace()[1].func))
        println("swath_number: ", swath_number)
        println("data_size: ", data_size)
        println("polarization: ", polarisation)
    end

    return test_ok
end




@testset "Sentinel1Types.jl" begin
    ####### actual tests ###############
    @test construct_meta_data_test() 
    @test construct_swath_slc_test()
end