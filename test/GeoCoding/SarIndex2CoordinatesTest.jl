

function approx_point_test() 
    ## Arrange
    # data from metadata file geolocationGridPoint (10598, 6055)
    
    theta = 3.784327810329249e+01 *pi/180 
    expected_point =  [3.858889230794824e+01*pi/180, 
        -2.706292464272735e+01 *pi/180,
         1.234132796525955e-04]

    orbit_states = SARProcessing.load_precise_orbit_sentinel1(PRECISE_ORBIT_TEST_FILE2)
    image = load_test_slc_image()
    interpolator = SARProcessing.orbit_state_interpolator(orbit_states,image.metadata)
    time =  "2022-09-18T07:49:40.819491"
    ## act 
        approx_point(orbit_state,theta_0)
    ## Debug
    if !test_ok
        println("Debug info: ", String(Symbol(find_zero_doppler_time_test)))
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
    row_image = SARProcessing.get_image_rows(image.metadata, SAR_index[1])

    test_ok =  (10180 < row_image[1]) & (row_image[1] < 10220) # from visual inspection of the test image
    test_ok &= (11573 < SAR_index[2]) & (SAR_index[2] < 11773) # from visual inspection of the test image

    
    ## Debug
    if !test_ok
        println("Debug info: ", String(Symbol(find_zero_doppler_time_test)))
        println("SAR_index: ", SAR_index)
        println("row_image: ", row_image)
    end

    return test_ok
end



@testset "coordinates2indexTest.jl" begin
    ####### actual tests ###############
    @test find_zero_doppler_time_test() 
    @test ecef2SAR_index_test()
end