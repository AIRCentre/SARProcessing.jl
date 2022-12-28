

function construct_orbit_state_test() 
    ## Arrange
    x = Dates.DateTime("20140529 120000", "yyyymmdd HHMMSS")
  

    ## Act
    testOrbitState = SARProcessing.OrbitState(x, [787193.490191, 787193.490191, 787193.490191], [787193.490191, 787193.490191, 787193.490191])

    ## Assert
    position_length_ok = length(testOrbitState.position) == 3
    velocity_length_ok = length(testOrbitState.velocity) == 3

    testOk = position_length_ok && velocity_length_ok
    
    ## Debug
    if !testOk
        println("Debug info: ", String(Symbol(construct_orbit_state_test)))
        println("position_length_ok: ", position_length_ok)
        println("velocity_length_ok: ", velocity_length_ok)
    end

    return testOk
end


function interpolation_test() 
    ## Arrange
    orbit_states = SARProcessing.load_precise_orbit_sentinel1(PRECISE_ORBIT_TEST_FILE)

    start_time =  DateTime("2022-10-29T23:04:32") #same as orbit_states[30].time
    end_time =  DateTime("2022-10-29T23:06:12") # same as orbit_states[40].time
    time_35 = orbit_states[35].time ## same as DateTime("2022-10-29T23:05:22")

    ## Act
    interpolator = SARProcessing.orbit_state_interpolator(orbit_states,(start_time, end_time))

    ## Assert

    #check a point in the data vs interpolation
    state_35_interpolated = interpolator(time_35) 

    testOk =  all(isapprox.(state_35_interpolated.position, orbit_states[35].position , atol = 1))
    testOk &= all(isapprox.(state_35_interpolated.velocity, orbit_states[35].velocity , atol = 1))

    #check point close to data assuming constant speed vs. interpolation
    position_next_interpolated = interpolator(time_35 + Second(1)).position
    position_next_simple = orbit_states[35].position .+ orbit_states[35].velocity

    testOk &= all(isapprox.(position_next_interpolated, position_next_simple, atol = 10))

    ## Debug
    if !testOk
        println("Debug info: ", String(Symbol(interpolation_test)))
        println("state_35_interpolated: ", state_35_interpolated)
        println("orbit_states[35]: ", orbit_states[35])
        println("position_next_interpolated: ", position_next_interpolated)
        println("position_next_simple ", position_next_simple)
    end

    return testOk
end



function interpolation_multiple_test()  
    ## Arrange
    orbit_states = SARProcessing.load_precise_orbit_sentinel1(PRECISE_ORBIT_TEST_FILE)
    
    ## Act
    # create two interpolators at the same time
    interpolator1 = SARProcessing.orbit_state_interpolator(orbit_states,(orbit_states[30].time, orbit_states[40].time))
    interpolator2 = SARProcessing.orbit_state_interpolator(orbit_states,(orbit_states[100].time, orbit_states[110].time))

    ## Assert

    #Check first interpolator
    state_35_interpolated = interpolator1(orbit_states[35].time) 
    testOk =  all(isapprox.(state_35_interpolated.position, orbit_states[35].position , atol = 1))
    testOk &= all(isapprox.(state_35_interpolated.velocity, orbit_states[35].velocity , atol = 1))

    #Check second interpolator
    state_105_interpolated = interpolator2(orbit_states[105].time) 
    testOk &=  all(isapprox.(state_105_interpolated.position, orbit_states[105].position , atol = 1))
    testOk &= all(isapprox.(state_105_interpolated.velocity, orbit_states[105].velocity , atol = 1))

    ## Debug
    if !testOk
        println("Debug info: ", String(Symbol(interpolation_multiple_test)))
        println("state_35_interpolated: ", state_35_interpolated)
        println("orbit_states[35]: ", orbit_states[35])
        println("state_105_interpolated: ", state_105_interpolated)
        println("orbit_states[105]: ", orbit_states[105])
    end

    return testOk
end


function interpolation_with_image_test()  
    ## Arrange
    orbit_states = SARProcessing.load_precise_orbit_sentinel1(PRECISE_ORBIT_TEST_FILE2)
    image = load_test_slc_image()
    
    ## Act
    interpolator = SARProcessing.orbit_state_interpolator(orbit_states,image)

    ## Assert
    mid_burst_state = SARProcessing.get_burst_mid_states(image,interpolator)
    speed = SARProcessing.get_speed.(mid_burst_state)

    testOk = length(speed) == 1  # test image subset only covers one swath
    testOk &= isapprox(7500,speed[1],rtol = 0.1)  #satellite speed is around 7.5 km/s

    ## Debug
    if !testOk
        println("Debug info: ", String(Symbol(interpolation_with_image_test)))
        println("speed: ", speed)
    end

    return testOk
end


@testset "OrbitState.jl" begin
    ####### actual tests ###############
    @test construct_orbit_state_test() 
    @test interpolation_test()
    @test interpolation_multiple_test() 
    @test interpolation_with_image_test()
end