
function read_sentinel1_orbit_test() 
    ## Arrange
    

    ## Act
    orbit_states = SARProcessing.load_precise_orbit_sentinel1(PRECISE_ORBIT_TEST_FILE)

    ## Assert

    testOk = length(orbit_states) == 9361
    
    testOk &= orbit_states[1].time == Dates.DateTime(2022,10,29,22,59,42)
    testOk &= isapprox(orbit_states[1].position[3],-1206834.603441)
    
    testOk &= orbit_states[end].time == Dates.DateTime(2022,10,31,00,59,42)
    testOk &= isapprox(orbit_states[end].velocity[1],2398.415421)
    
    ## Debug
    if !testOk
        println("Debug info: ", String(Symbol(constructOrbitState)))
        println("length(orbit_states): ", length(orbit_states))
        println("orbit_states[1]: ", orbit_states[1])
        println("orbit_states[end]: ", orbit_states[end])
    end

    return testOk
end


@testset "PreciseOrbitTest.jl" begin
    ####### actual tests ###############
    @test read_sentinel1_orbit_test() 
end