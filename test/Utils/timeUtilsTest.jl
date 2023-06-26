


@testset "timeUtilsTest.jl" begin
    @test SARProcessing.period_to_float_seconds(Millisecond(2)) ≈ 0.002
    @test SARProcessing.period_to_float_seconds(Nanosecond(4)) ≈ 4*10^(-9)
    @test SARProcessing.period_to_float_seconds(
        TimesDates.TimeDate(2000,1,1,12,1) - TimesDates.TimeDate(2000,1,1,12,0)) ≈ 60
    @test SARProcessing.float_seconds_to_period(2.3) isa Period
end