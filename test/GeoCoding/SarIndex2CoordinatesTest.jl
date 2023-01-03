

function approx_point_test() 
    ## Arrange
    # data from metadata file geolocationGridPoint (10598, 6055)
    
    theta = 3.784327810329249e+01 *pi/180 
    expected_point =  [3.858889230794824e+01, 
        -2.706292464272735e+01,
         1.234132796525955e-04]

    orbit_states = SARProcessing.load_precise_orbit_sentinel1(PRECISE_ORBIT_TEST_FILE2)
    image = load_test_slc_image()
    interpolator = SARProcessing.orbit_state_interpolator(orbit_states,image.metadata)
    time =  SARProcessing.parse_delta_time("2022-09-18T07:49:40.819491",image.metadata.reference_time)

    orbit_state = interpolator(time)

    ## act 
    point = SARProcessing.approx_point(orbit_state,theta)

    point_geodetic = SARProcessing.ecef2geodetic(point)
    
    #Assert
    test_ok = isapprox(point_geodetic[1] * 180/pi, expected_point[1], atol=1.0)
    test_ok &= isapprox(point_geodetic[2] * 180/pi, expected_point[2], atol=1.0)
    # The approx_point returns a point on the reference ellipsoid so the height should be 0. 
    test_ok &= isapprox(point_geodetic[3], 0.0, atol=1.0) 

    ## Debug
    if !test_ok
        println("Debug info: ", string(StackTraces.stacktrace()[1].func))
        println("Latitude: ", point_geodetic[1] * 180/pi)
        println("longitude: ", point_geodetic[2]* 180/pi)
        println("height: ", point_geodetic[3])
    end

    return test_ok
end

function sar_index2geodetic_test(latitude,longitude,height) 
    ## Arrange
     geodetic_coordinate = [latitude * pi / 180 ,longitude * pi / 180, height]
     orbit_states = SARProcessing.load_precise_orbit_sentinel1(PRECISE_ORBIT_TEST_FILE2)
     image = load_test_slc_image()
     interpolator = SARProcessing.orbit_state_interpolator(orbit_states,image.metadata)
     SAR_index = SARProcessing.geodetic2SAR_index(geodetic_coordinate, interpolator, image.metadata)
 
     ## Act
     point_geodetic = SARProcessing.sar_index2geodetic(SAR_index..., geodetic_coordinate[3], 
     interpolator,
     image.metadata)
     
    
    #Assert
    computed_latitude = point_geodetic[1]* 180/pi
    computed_longitude = point_geodetic[2]* 180/pi
    computed_height = point_geodetic[3]


    test_ok = isapprox(computed_latitude, latitude, atol=0.00001)
    test_ok &= isapprox(computed_longitude, longitude, atol=0.00001)
    test_ok &= isapprox(computed_height, height, atol=0.01)

    ## Debug
    if !test_ok
        println("Debug info: ", string(StackTraces.stacktrace()[1].func))
        println("dif_latitude: ", computed_latitude- latitude)
        println("dif_longitude: ", computed_longitude - longitude)
        println("dif_height: ", computed_height-height)
    end

    return test_ok
end

@testset "SarIndex2CoordinatesTest.jl" begin
    ####### actual tests ###############
    @test approx_point_test()
    @test sar_index2geodetic_test(38.6393705 ,-27.2813912 , 204) 
    @test sar_index2geodetic_test(38.6393705 ,-27.2813912 , 204) 
    @test sar_index2geodetic_test(38.2550504,-27.1807716 , -40.0) 
end