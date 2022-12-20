@doc raw"""
    The CFAR object detection method described in The State-of-the-Art in Ship Detection in Synthetic Aperture Radar imagery, D.J. Crips, 2004, in section 5.2 Adaptive threshold algorithms

Finding CFAR for all pixels in an image.
"""
function cell_averaging_constant_false_alarm_rate(image::Matrix{T},background_size::Integer = 41,guard_size::Integer=21,pfa::Real=0.1) where T <: Real
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
            targets[i_row,j_column] = _cell_averaging_constant_false_alarm_rate_pixel(window_under_test, guard_size,  pfa)
        end
    end    
    return targets
end



@doc raw"""
_cell_averaging_constant_false_alarm_rate_pixel(backgroundWindow::Matrix{T}, guard_size::Integer = 80, pfa::Real = 0.0001) where T <: Real

    The following method is used to detemrine if a single pixel is a part of an object.  The statistics from the backgroundWindow is used.
    Returns 1 if the pixel is part of an object and 0 it the pixel is no object

pfa = probability for false alarm


"""
function _cell_averaging_constant_false_alarm_rate_pixel(image::Matrix{T}, guard_size::Integer = 80, pfa::Real = 0.0001) where T <: Real
    #determining where guard windows starts and ends in the image
    baground_size = size(image)[1]
    half_baground_size = round(Int,(baground_size-1)/2)
    guardStart = round(Int,((baground_size-1)-(guard_size-1))/2)
    guardEnd = round(Int, ((baground_size-1)-((baground_size-1)-(guard_size-1))/2))
    #calculating the threshold from the pfa
    cfar_threshold = sqrt(2)*SpecialFunctions.erfinv(1-2*pfa) # PFA = (1/2)-(1/2)*erf(t/sqrt(2))
    #the target pixel is the center pixel of the image
    target = image[half_baground_size,half_baground_size]
    
    background_kernel = ones(Bool,size(image)...)
    background_kernel[guardStart:guardEnd, guardStart:guardEnd] .= false
    background = image[background_kernel]
    # finding statistics for image
    background_mean = Statistics.mean(background)
    background_std = Statistics.std(background)
    #comparing background statistics with the pixel in question.
    if target > background_mean+background_std*cfar_threshold
        target = 1
    else
        target = 0
    end
    return target
end

