

function constructOrbitState() 
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
        println("Debug info: ", String(Symbol(constructOrbitState)))
        println("position_length_ok: ", position_length_ok)
        println("velocity_length_ok: ", velocity_length_ok)
    end

    return testOk
end



@testset "OrbitState.jl" begin
    ####### actual tests ###############
    @test constructOrbitState() 
end