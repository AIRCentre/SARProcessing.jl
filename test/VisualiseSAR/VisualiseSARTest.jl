

function sar2gray_test(T::Type,size_to_test) 
## Arrange
data = rand(T,size_to_test) .- 4
## Act
img = SARProcessing.sar2gray(data)

## Assert
testOk = (size(img) == size_to_test) && (eltype(img) <: Images.Gray)

## Debug
if !testOk
    println("Debug info: ", string(StackTraces.stacktrace()[1].func))
    println("size(img): ", size(img))
    println("img: ", img)
end

return testOk
end


@testset "VisualiseSARTest.jl" begin
    @test sar2gray_test(Complex{Float64},(9,5))
    @test sar2gray_test(Float64,(9,8))  
end