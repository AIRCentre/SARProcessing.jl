function median_filter_test()
    #Arrange
    complex_image = load_test_slc_image()
    abseloute_image = abs.(complex_image.data);
    #act
    descpek_median_3 = SARProcessing.speckle_median_filter(abseloute_image,[3,3]);
    descpek_median_9 = SARProcessing.speckle_median_filter(abseloute_image,[9,9]);
    descpek_median_15 = SARProcessing.speckle_median_filter(abseloute_image,[15,15]);

    median_3_size = size(descpek_median_3)
    median_9_size = size(descpek_median_9)
    median_15_size = size(descpek_median_15)
    #Assert
    check = median(abseloute_image[1:15,1:15])  == descpek_median_15[1,1]
    check &= isapprox(descpek_median_15[1,1],57.30;atol=0.1)
    
    check &= median(abseloute_image[1:9,1:9])  == descpek_median_9[1,1]
    check &= isapprox(descpek_median_9[1,1],58.549;atol=0.1)
    
    check &= median(abseloute_image[1:3,1:3])  == descpek_median_3[1,1]
    check &= isapprox(descpek_median_3[1,1],40.0;atol=0.1)

    # org size = (601,1401).
    # size of [3x3] should thus be (599,1399)
    # size of [9x9] should thus be (593,1393)
    check &= median_3_size ==(599,1399)
    check &= median_9_size ==(593,1393)
    check &= median_15_size ==(587,1387)
    if !check
        println("Size of Median filter: $(median_3_size) ==(599,1399)")
        println("Size of Median filter: $(median_9_size) ==(593,1393)")
        println("Size of Median filter: $(median_15_size) ==(587,1387)")

        println("Value from Median filter: $(descpek_median_3[1,1]) ==40.0")
        println("Value from Median filter: $(descpek_median_9[1,1]) ==58.549")
        println("Value from Median filter: $(descpek_median_15[1,1]) ==57.30")
    end
    
    return check
end


@testset "median_filter_test.jl" begin
    @test median_filter_test()  
end