




function filter_sobel_test()
    image_with_objects = zeros((30,30));
    image_with_objects[20,10] = 5;  #object
    image_with_objects[4,5] = 5; #object 

    #Checking Sobel Filter:
    #sobel filter. For each point target we have 8 pixel with edges, 16 in total of edges.
    sobel = SARProcessing.sobel_filter(image_with_objects);
    check =sum(sum.(findall.(sobel.>1)))==16;
    #
    #sobel filter inherently check vertical and horizontal filters.
    #the corner edges should be sqrt((5*1)^2 + (5*-1)^2)) = 7.07. 
    #no edges should be 0 
    #and horizontal and vertical should be sqrt((-2*5)^2 + 0) = 10.
    check &= sum( round.(Int,unique(sobel)) .∈ [[0,7,10]])==3;
    #sum of sobel filter should then be #Objects x 7.07*number_of_corners_in_each_object + 10*number_of_hor/ver_edges_in_object
    # sum = 2*(4*7.07 + 4*10) = 136.56
    check &= isapprox(sum(sobel),136.56;atol=0.1);
    if !check
        println("Error in test for filters")
    end
    return check
end


function filter_mean_test()
    image_with_objects = zeros((30,30));
    image_with_objects[20,10] = 5;  #object
    image_with_objects[4,5] = 5; #object 
    
    # we have two point targets.
    check = sum(sum.(findall.(image_with_objects.>1))) ==2;
    #checking the mean filter function
    mean = SARProcessing.mean_filter([7,7]);
    check &= isapprox(sum(mean),1; atol = 0.1);
    check &= size(mean)==(7,7);
    #checking the mean filter applied on the image.
    mean_no_padding = SARProcessing.conv2d(image_with_objects, SARProcessing.mean_filter([3,3]));
    mean_with_padding = SARProcessing.conv2d(image_with_objects, SARProcessing.mean_filter([3,3]),1,"same");
    check &= size(mean_with_padding) ==size(image_with_objects);
    check &= size(mean_no_padding) ==(size(image_with_objects)[1]-2,size(image_with_objects)[2]-2);
    check &= isapprox(sum(mean_no_padding),10;atol=0.1) == isapprox(sum(mean_with_padding),10;atol=0.1);
    

    if !check
        println("Error in test for filters")
        println(size(mean)," should be (7,7)")
        println(sum(mean),"should be approx. 1")
        println(sum(sum.(findall.(image_with_objects.>1)))," should be 2")
        println(size(mean_with_padding),size(image_with_objects),"should be equal")
        println(size(mean_no_padding),(size(image_with_objects)[1]-2,size(image_with_objects)[2]-2),"should be equal")
        println(size(mean_no_padding),(size(image_with_objects)[1],size(image_with_objects)[2]),"should not be equal")
        println(sum(mean_no_padding),sum(mean_with_padding)," should both be 10")
    end
    return check
end


@testset "object_detector_filter_test.jl" begin
    ####### actual tests ###############
    @test filter_mean_test()
    @test filter_sobel_test()
end
