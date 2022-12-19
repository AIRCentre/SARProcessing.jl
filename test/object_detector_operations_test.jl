
include("../src/object_detector/operations.jl")
import .operations;



function operations_test()
    array = [0.01 2 3; 1 NaN 3; 3 0.02 1];
    array2 = [0.01 2 3; 1 2 3; 3 0.02 1];

    #can compute mean and std in arrays with nan.
    check = isapprox(operations.nanmean(array),1.62; atol = 0.1);
    check &= isapprox(operations.nanstd(array),1.297; atol = 0.1);  

    
    binaryse = operations.binarize_array(array2,0.4);

    check &= sum(binaryse)==7;
    check &= maximum(binaryse) ==1;
    check &= minimum(binaryse) ==0;

    operations.mask_array!(array2);


    check &= count(isnan, array2)==2;
    check &= count(!isnan, array2)==7;

    

    if !check
        println("Error in test for filters")
    end
    return check
end


@testset "object_detector_operations_test.jl" begin
    ####### actual tests ###############
    @test operations_test()
end
