


image_no_objects = [i for i=1:0.5:20.5, j=1:40];
image_with_objects =[i for i=1:0.5:20.5, j=1:40]
image_with_objects[20,10] = 60000;  #object
image_with_objects[4,5] = 60000; #object 
image_with_objects[20:30,20:33] .= 60000; #large object




function ca_cfar_test()

    cfar1 = SARProcessing.cell_averaging_constant_false_alarm_rate(image_no_objects,5,3,0.01);
    cfar2 = SARProcessing.cell_averaging_constant_false_alarm_rate(image_with_objects,5,3,0.01);

    check = sum(cfar2)==8;
    check &= sum(cfar1)==0;

    if !check
        println("Error in test for CA-CFAR")
    end
    return check
end

cfar1 = SARProcessing.constant_false_alarm_rate_with_convolution_and_pooling(image_no_objects,5,3,0.01);
cfar2 = SARProcessing.constant_false_alarm_rate_with_convolution_and_pooling(image_with_objects,5,3,0.01);
size(cfar1)
function cp_cfar_test()

    cfar1 = SARProcessing.constant_false_alarm_rate_with_convolution_and_pooling(image_no_objects,5,3,0.01);
    cfar2 = SARProcessing.constant_false_alarm_rate_with_convolution_and_pooling(image_with_objects,5,3,0.01);

    check = sum(cfar2)==8;
    check &= sum(cfar1)==0;


    check &= size(cfar2) ==(40,40);
    check &= size(cfar1) ==(40,40);
    
    if !check
        println("Error in test for CP-CFAR")
    end
    return check
end


@testset "object_detector_cfar_test.jl" begin
    ####### actual tests ###############
    @test ca_cfar_test()
    @test cp_cfar_test()
end
