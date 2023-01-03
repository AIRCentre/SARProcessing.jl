

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

    reference_time =  DateTime("2022-10-29T23:04:32") #same as orbit_states[30].time
    end_time =  Dates.value(orbit_states[40].time - reference_time) / 1000.0
    time_35 = Dates.value(orbit_states[35].time - reference_time) / 1000.0 ## same as DateTime("2022-10-29T23:05:22")

    ## Act
    interpolator = SARProcessing.orbit_state_interpolator(orbit_states,(0.0, end_time), reference_time)

    ## Assert

    #check a point in the data vs interpolation
    state_35_interpolated = interpolator(time_35) 

    testOk =  all(isapprox.(state_35_interpolated.position, orbit_states[35].position , atol = 1))
    testOk &= all(isapprox.(state_35_interpolated.velocity, orbit_states[35].velocity , atol = 1))

    #check point close to data assuming constant speed vs. interpolation
    position_next_interpolated = interpolator(time_35 + 1).position
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
    ref_time1 = orbit_states[30].time
    end_time1 = Dates.value(orbit_states[40].time.-ref_time1) /1000.0
    ref_time2 = orbit_states[100].time
    end_time2 =Dates.value(orbit_states[110].time.-ref_time2) /1000.0
    
    ## Act
    # create two interpolators at the same time
    interpolator1 = SARProcessing.orbit_state_interpolator(orbit_states,(0.0, end_time1), ref_time1)
    interpolator2 = SARProcessing.orbit_state_interpolator(orbit_states,(0.0, end_time2), ref_time2)

    ## Assert

    #Check first interpolator
    t_35 = Dates.value(orbit_states[35].time.-ref_time1) /1000.0
    state_35_interpolated = interpolator1(t_35) 
    testOk =  all(isapprox.(state_35_interpolated.position, orbit_states[35].position , atol = 1))
    testOk &= all(isapprox.(state_35_interpolated.velocity, orbit_states[35].velocity , atol = 1))

    #Check second interpolator
    t_105 = Dates.value(orbit_states[105].time.-ref_time2)/1000.0
    state_105_interpolated = interpolator2(t_105) 
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
    interpolator = SARProcessing.orbit_state_interpolator(orbit_states,image.metadata)

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