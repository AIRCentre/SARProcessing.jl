 
function mean_filter_test()
    #Arrange
    complex_image = load_test_slc_image()
    abseloute_image = abs.(complex_image.data);
    #act
    descpek_mean_3 = SARProcessing.speckle_mean_filter(abseloute_image,[3,3]);
    descpek_mean_9 = SARProcessing.speckle_mean_filter(abseloute_image,[9,9]);
    descpek_mean_15 = SARProcessing.speckle_mean_filter(abseloute_image,[15,15]);

    mean_3_size = size(descpek_mean_3)
    mean_9_size = size(descpek_mean_9)
    mean_15_size = size(descpek_mean_15)
    #Assert
    check = mean(abseloute_image[1:3,1:3])  == descpek_mean_3[1,1]
    check &= isapprox(descpek_mean_3[1,1],42.03;atol=0.1)
    check &= mean(abseloute_image[1:9,1:9])  == descpek_mean_9[1,1]
    check &= isapprox(descpek_mean_9[1,1],65.92;atol=0.1)
    check &= mean(abseloute_image[1:15,1:15])  == descpek_mean_15[1,1]
    check &= isapprox(descpek_mean_15[1,1],62.55;atol=0.1)

    # org size = (601,1401).
    # size of [3x3] should thus be (599,1399)
    # size of [9x9] should thus be (593,1393)
    check &= mean_3_size ==(599,1399)
    check &= mean_9_size ==(593,1393)
    check &= mean_15_size ==(587,1387)
    if !check
        println("Size of Mean filter: $(mean_3_size) ==(599,1399)")
        println("Size of Mean filter: $(mean_9_size) ==(593,1393)")
        println("Size of Mean filter: $(mean_15_size) ==(587,1387)")

        println("Value from Mean filter: $(descpek_mean_3[1,1]) ==42.03")
        println("Value from Mean filter: $(descpek_mean_9[1,1]) ==65.92")
        println("Value from Mean filter: $(descpek_mean_15[1,1]) ==62.55")
    end
    
    return check
end



@testset "mean_filter_test.jl" begin
    @test mean_filter_test()  
end