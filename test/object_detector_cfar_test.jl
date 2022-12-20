


image_no_objects =[1:0.5:20 1:0.5:20 1:0.5:20 1:0.5:20 1:0.5:20 1:0.5:20 1:0.5:20 1:0.5:20 1:0.5:20 1:0.5:20 1:0.5:20 1:0.5:20 1:0.5:20];
image_with_objects =[1:0.5:20 1:0.5:20 1:0.5:20 1:0.5:20 1:0.5:20 1:0.5:20 1:0.5:20 1:0.5:20 1:0.5:20 1:0.5:20 1:0.5:20 1:0.5:20 1:0.5:20];
image_with_objects[20,10] = 60000;  #object
image_with_objects[4,5] = 60000; #object 
image_with_objects[25:30,5:10] .= 60000; #large object



function ca_cfar_test()

    cfar1 = SARProcessing.cell_averaging_constant_false_alarm_rate(image_no_objects,5,3,0.01);
    cfar2 = SARProcessing.constant_false_alarm_rate_with_convolution_and_pooling(image_with_objects,5,3,0.01);

    check = sum(cfar2)==8;
    check &= sum(cfar1)==0;

    if !check
        println("Error in test for CA-CFAR")
    end
    return check
end

sobel = SARProcessing.sobelFilter(image_with_objects)
cfar2 = SARProcessing.constant_false_alarm_rate_with_convolution_and_pooling(image_with_objects,9,3,0.01);
cfar1 = SARProcessing.cell_averaging_constant_false_alarm_rate(image_with_objects,5,3,0.01);


cfar1 = SARProcessing.constant_false_alarm_rate_with_convolution_and_pooling(image_no_objects,5,3,0.01);
cfar2 = SARProcessing.constant_false_alarm_rate_with_convolution_and_pooling(image_with_objects,5,3,0.01);;
sum(c)



function cp_cfar_test()

    cfar1 = object_detector.cfar.cp_cfar(image_no_objects,5,3,0.01);
    cfar2 = object_detector.cfar.cp_cfar(image_with_objects,5,3,0.01);;

    check = isapprox(sum(cfar2),8.836; atol = 0.1);
    check &= sum(cfar1)== 0;
    check &= size(cfar2) ==(39,13);
    check &= size(cfar1) ==(39,13);
    
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
