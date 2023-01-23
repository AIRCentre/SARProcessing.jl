

function find_zero_doppler_time_test() 
    ## Arrange
    ecef_coordinate = [5000, 0, 0]
    test_interpolator = t -> 
        begin
            x = 80000
            y = 0
            z = -2000 + 1000 * t
            
            pos = [x,y,z]
            v = [0,0,1000]

            return  SARProcessing.OrbitState(DateTime("2022-10-29T23:06:12"),pos,v )
        end
  
    expected_zero_doppler_time = 2.0

    ## Act
    zero_doppler_time = SARProcessing.find_zero_doppler_time(ecef_coordinate, [0,3.5] , 
        test_interpolator, tolerance_in_seconds= 10^-6)

    ## Assert
    test_ok =  isapprox(zero_doppler_time, expected_zero_doppler_time, atol=10^-6) 
    
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
    SAR_index = SARProcessing.geodetic2SAR_index(geodetic_coordinate, interpolator, image.metadata, 7)
    ## change the functions


    ## Assert
    row_image = SARProcessing.get_image_rows(image.metadata, SAR_index[1])

    test_ok =  (1070 < row_image[1]) & (row_image[1] < 1150) # from visual inspection of the test image
    test_ok &= (11573 < SAR_index[2]) & (SAR_index[2] < 11773) # from visual inspection of the test image

    
    ## Debug
    if !test_ok
        println("Debug info: ", string(StackTraces.stacktrace()[1].func))
        println("SAR_index: ", SAR_index)
        println("row_image: ", row_image)
    end

    return test_ok
end


function azimuth_time_to_row_test() 
    ## Arrange
    image = load_test_slc_image()
    start_times = SARProcessing.get_burst_start_times(image.metadata)

    ## Act
    row_in_burst = [SARProcessing.azimuth_time2row_in_burst(start_times[i],image.metadata, i) for i=eachindex(start_times)]
    time = [SARProcessing.row_in_burst2azimuth_time(1.0,image.metadata, i) for i=eachindex(start_times)]


    ## Assert
    test_ok = all( isapprox.(row_in_burst,1.0))
    test_ok &= all(time .== start_times)
    ## Debug
    if !test_ok
        println("Debug info: ", string(StackTraces.stacktrace()[1].func))
        println("row_in_burst: ", row_in_burst)
        println("time: ", time)
        println("start_times: ", start_times)
    end

    return test_ok
end


function range_to_column_test() 
    ## Arrange
    image = load_test_slc_image()
    near_range = SARProcessing.get_near_range(image.metadata)

    ## Act
    column =SARProcessing.range2column(near_range, image.metadata)


    ## Assert
    test_ok =  isapprox.(column,1.0)
    ## Debug
    if !test_ok
        println("Debug info: ", string(StackTraces.stacktrace()[1].func))
        println("near_range: ", near_range)
        println("column: ", column)
    end

    return test_ok
end


@testset "coordinates2indexTest.jl" begin
    ####### actual tests ###############
    @test find_zero_doppler_time_test() 
    @test ecef2SAR_index_test()
    @test azimuth_time_to_row_test() 
    @test range_to_column_test() 
end