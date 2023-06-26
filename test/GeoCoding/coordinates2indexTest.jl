

function find_zero_doppler_time_test() 
    ## Arrange
    ecef_coordinate = [5000, 0, 0]
    start_time = TimesDates.TimeDate("2022-10-29T23:06:12")

    test_interpolator = t -> 
        begin

            t_seconds = SARProcessing.period_to_float_seconds(t - start_time)
            x = 80000
            y = 0
            z = -2000 + 1000 * t_seconds
            
            pos = [x,y,z]
            v = [0,0,1000]

            return  SARProcessing.OrbitState(t,pos,v )
        end
  
    expected_zero_doppler_time = Second(2) + start_time

    ## Act
    zero_doppler_time = SARProcessing.find_zero_doppler_time(ecef_coordinate, [start_time,start_time + Second(4)] , 
        test_interpolator, tolerance_in_seconds= Nanosecond(4))

    ## Assert
    test_ok =  abs(zero_doppler_time- expected_zero_doppler_time) <= Nanosecond(4)
    
    ## Debug
    if !test_ok
        println("Debug info: ",string(StackTraces.stacktrace()[1].func))
        println("zero_doppler_time: ", zero_doppler_time)
    end

    return test_ok
end


function ecef2SAR_index_test() 
    ## Arrange
    geodetic_coordinate = [38.6393705 * pi / 180 ,-27.2264349 * pi / 180, 58.82] # The hight is the local geoid height
    orbit_states = SARProcessing.load_precise_orbit_sentinel1(PRECISE_ORBIT_TEST_FILE2)
    image = load_test_slc_image()
    interpolator = SARProcessing.orbit_state_interpolator(orbit_states,image.metadata)

    ## Act
    SAR_index = SARProcessing.geodetic2SAR_index(geodetic_coordinate, interpolator, image.metadata)

    ## Assert

    # the code have been compared with the old syntese project. SAR_index[1] have been change from 9163.02432962588
    #TODO Validate the results using other inSAR software  
    test_ok =  isapprox(SAR_index[1],9163.1798823, atol=10^-4)
    test_ok &= isapprox(SAR_index[2],11661.243018795767, atol=10^-4)

    
    ## Debug
    if !test_ok
        println("Debug info: ", string(StackTraces.stacktrace()[1].func))
        println("SAR_index: ", SAR_index)
    end

    return test_ok
end



@testset "coordinates2indexTest.jl" begin
    ####### actual tests ###############
    @test find_zero_doppler_time_test() 
    @test ecef2SAR_index_test()
end