
include("../src/object_detector/filters.jl")
import .filters;



image_with_objects = zeros((39,13));
image_with_objects[20,10] = 60000;  #object
image_with_objects[4,5] = 60000; #object 








function filters_test()

    #mean filter
    mean = filters.meanFilter([7,7]);
    check = isapprox(sum(mean),1; atol = 0.1);
    check &= size(mean)==(7,7);

    
    # we have two point targets.
    check &= sum(sum.(findall.(image_with_objects.>1))) ==2;
    #sobel filter. For each point target we have 8 pixel with edges, 16 in total of edges.
    sobel = filters.sobelFilter(image_with_objects);
    check &=sum(sum.(findall.(sobel.>1)))==16;
    #sobel filter inherently check vertical and horizontal filters.

    if !check
        println("Error in test for filters")
        println(size(mean)," should be (7,7)")
        println(sum(mean),"should be approx. 1")
        println(sum(sum.(findall.(image_with_objects.>1)))," should be 2")
        println(sum(sum.(findall.(sobel.>1)))," should be 16")
    end
    return check
end


@testset "object_detector_filter_test.jl" begin
    ####### actual tests ###############
    @test filters_test()
end
