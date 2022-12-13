using Dates
function constructOrbitState() 
    ## Arrange

    x = Dates.DateTime("20140529 120000", "yyyymmdd HHMMSS")
  

    ## Act

    testOrbitState = SARProcessing.OrbitState(x, [787193.490191, 787193.490191, 787193.490191], [787193.490191, 787193.490191, 787193.490191])

    ## Assert
    positionlinkOk = length(testOrbitState.position) == 3

    velocitylinkOk = length(testOrbitState.velocity) == 3
    testOk = positionlinkOk && velocitylinkOk
    
    ## Debug
    if  true #!testOk
        println("Debug info: ", String(Symbol(constructOrbitState)))
        println("positionlinkOk: ", positionlinkOk)
        println("velocitylinkOk: ", velocitylinkOk)
    end

    return testOk
end

@testset "preciseorbit.jl" begin
    ####### actual tests ###############
    @test constructOrbitState() 
end