

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

function sar2gray_SARImage_test() 
    ## Arrange
    image = load_test_slc_image()
    ## Act
    gray_image = SARProcessing.sar2gray(image)

    ## Assert
    testOk = size(gray_image) == size(SARProcessing.get_data(image))
    testOk &= eltype(gray_image) <: Images.Gray

    ## Debug
    if !testOk
        println("Debug info: ", string(StackTraces.stacktrace()[1].func))
        println("size(gray_image): ", size(gray_image))
        println("gray_image[1:3,1:4]: ", gray_image[1:3,1:4])
    end

    return testOk
end


@testset "VisualiseSARTest.jl" begin
    @test sar2gray_test(Complex{Float64},(9,5))
    @test sar2gray_test(Float64,(9,8))
    @test sar2gray_SARImage_test()  
end