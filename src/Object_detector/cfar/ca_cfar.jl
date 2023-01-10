"""
The two paramter (TP)-CFAR object detection method described in The State-of-the-Art in Ship Detection in Synthetic Aperture Radar imagery, D.J. Crips, 2004, in section 5.2 Adaptive threshold algorithms

Finding CFAR for all pixels in an image.
"""
function cell_averaging_constant_false_alarm_rate(image::Matrix{T},background_size::Integer = 41,guard_size::Integer=21,target_size::Integer=3,pfa::Real=0.1) where T <: Real
    input_rows, input_columns = size(image);
    #padding image according to background image size.
    padding_size = round(Int,(background_size-1)/2);
    padded_image = add_padding(image,padding_size,NaN)
    padded_image_rows,padded_image_colums = size(padded_image)
    targets = zeros(input_rows, input_columns)
    #for each pixel in the image, determine if its part of an object.
    for i_row in 1:(padded_image_rows-background_size)
        for j_column in 1:(padded_image_colums-background_size)
            window_under_test = padded_image[i_row:i_row+background_size-1,j_column:j_column+background_size-1]
            targets[i_row,j_column] = _cell_averaging_constant_false_alarm_rate_pixel(window_under_test, guard_size, target_size, pfa)
        end
    end
    return targets
end



"""


"""
function _cell_averaging_constant_false_alarm_rate_pixel(image::Matrix{T}, guard_size::Integer = 80,target_size::Integer=3, pfa::Real = 0.0001) where T <: Real
    #determining where guard windows starts and ends in the image
    baground_size = size(image)[1]
    half_baground_size = round(Int,(baground_size-1)/2)
    half_target_size = round(Int,(target_size-1)/2)
    guard_start = round(Int,((baground_size-1)-(guard_size-1))/2)
    guard_end = round(Int, ((baground_size-1)-((baground_size-1)-(guard_size-1))/2))
    #calculating the threshold from the pfa
    cfar_threshold = sqrt(2)*SpecialFunctions.erfinv(1-2*pfa) # PFA = (1/2)-(1/2)*erf(t/sqrt(2))
    #the target pixel is the center pixel of the image
    target_kernel = image[half_baground_size-half_target_size:half_baground_size+half_target_size,half_baground_size-half_target_size:half_baground_size+half_target_size]
    target = image[half_baground_size,half_baground_size]

    cfar_threshold = cfar_threshold/sqrt(length(target_kernel))
    background_kernel = ones(Bool,size(image)...)
    background_kernel[guard_start:guard_end, guard_start:guard_end] .= false
    background = image[background_kernel]
    # finding statistics for image
    background_mean = Statistics.mean(background)
    background_std = Statistics.std(background)

    #comparing background statistics with the pixel in question.
    if Statistics.mean(target_kernel) > background_mean+background_std*cfar_threshold
        target = true
    else
        target = false
    end
    return target
end
