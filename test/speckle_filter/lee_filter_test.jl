function lee_filter_test()
    #Arrange
    complex_image = load_test_slc_image()
    abseloute_image = abs.(complex_image.data);
    #act
    descpek_lee_3 = SARProcessing.speckle_lee_filter(abseloute_image,[3,3]);
    descpek_lee_9 = SARProcessing.speckle_lee_filter(abseloute_image,[9,9]);
    descpek_lee_15 = SARProcessing.speckle_lee_filter(abseloute_image,[15,15]);

    
    lee_3_size = size(descpek_lee_3)
    lee_9_size = size(descpek_lee_9)
    lee_15_size = size(descpek_lee_15)
    #Assert

    check = isapprox(descpek_lee_3[1,1],39.96;atol=0.1)
    check &= isapprox(descpek_lee_9[1,1],83.85;atol=0.1)
    check &= isapprox(descpek_lee_15[1,1],64.91;atol=0.1)

    # org size = (601,1401).
    # size of [3x3] should thus be (599,1399)
    # size of [9x9] should thus be (593,1393)
    check &= lee_3_size ==(599,1399)
    check &= lee_9_size ==(593,1393)
    check &= lee_15_size ==(587,1387)
    if !check
        println("Size of Lee filter: $(lee_3_size) ==(599,1399)")
        println("Size of Lee filter: $(lee_9_size) ==(593,1393)")
        println("Size of Lee filter: $(lee_15_size) ==(587,1387)")

        println("Value from Lee filter: $(descpek_lee_3[1,1]) ==39.96")
        println("Value from Lee filter: $(descpek_lee_9[1,1]) ==83.85")
        println("Value from Lee filter: $(descpek_lee_15[1,1]) ==64.91")
    end


    return check
end



@testset "lee_filter_test.jl" begin
    @test lee_filter_test()  
end