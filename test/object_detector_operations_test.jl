

image_with_objects =zeros(50,50);
image_with_objects[20,10] = 60000;  #object. 1 object
image_with_objects[4,5] = 60000; #object. 1 object
image_with_objects[20:30,20:30] .= 60000; #large object. 121 objects


function operations_test()
    array = [0.01 2 3; 1 2 3; 3 0.02 1];
    #can compute mean and std in arrays with nan.
    binaryse = SARProcessing.binarize_array(array,0.4);
    check = sum(binaryse)==7;
    check &= maximum(binaryse) ==1;
    check &= minimum(binaryse) ==0;
    masked = SARProcessing.mask_array_nan(array);
    check &= count(isnan, masked)==2;
    check &= count(!isnan, masked)==7;
    if !check
        println("Error in test for filters")
    end
    return check
end





function operations_label_test()

    binary_array = SARProcessing.binarize_array(image_with_objects,0.5)
    check =sum(binary_array) == 123 # 121 in large blob. two seperate
    coordinates = SARProcessing.object_locations(convert.(Float64,binary_array));
    check &= length(coordinates) == 3; #we have 2 small obejcts and one large object.
    
    #location of objects
    check &= [coordinates[1][1],coordinates[1][2]]==[4,5]
    check &= [coordinates[2][1],coordinates[2][2]]==[20,10]
    check &= [coordinates[3][1],coordinates[3][2]]==[25,25]


    subset = SARProcessing.get_subset(image_with_objects,coordinates[1] ,[5,5]);
    check &= size(subset)==(5,5)
    check &= isapprox(mean(subset),2400;atol=0.1)
    if !check
        println("Error in test for labelleing")
    end
    return check

end

@testset "object_detector_operations_test.jl" begin
    ####### actual tests ###############
    @test operations_test()
    @test operations_label_test()
end
