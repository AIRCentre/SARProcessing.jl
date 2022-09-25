using  SARProcessing, Test

@testset "SARProcessing tests" begin
    @testset "test of template functions" begin
        @test SARProcessing.greet(4) == "Hello World! 4" 
        @test 43 == 43
    end
    @testset "Load test" begin
        @test length(Sentinel1.loadSLC(4)) == 4
        @test 3 == 3
    end
end