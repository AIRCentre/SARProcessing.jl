"""
The CFAR object detection method described in The State-of-the-Art in Ship Detection in Synthetic Aperture Radar imagery, D.J. Crips, 2004, in section 5.2 Adaptive threshold algorithms

Finding CFAR for all pixels in an image.

"""
function ca_cfar(image::Matrix{Float64},background_size::Int64 = 301,guard_size::Int64=201,pfa::Float64=0.1)::Matrix{Float64}
    input_rows, input_columns = size(image);
    #padding image according to background image size.
    padding_size = round(Int,(background_size-1)/2);
    padded_image = ones(input_rows+padding_size*2,input_columns+padding_size*2);

    #all values to NaN - such that the padded values are nan
    replace!(padded_image, 1=>NaN);
    #replacing values
    padded_image[padding_size+1:input_rows+padding_size,padding_size+1:input_columns+padding_size] = image;
    padded_image_rows,padded_image_colums = size(padded_image)
    targets = zeros(input_rows, input_columns)
    i,j=1,1
    #for each pixel in the image, determine if its part of an object.
    for i_row in 1:1:(padded_image_rows-background_size)
        j = 1
        for j_column in 1:1:(padded_image_colums-background_size)
            window_under_test = padded_image[i_row:i_row+background_size-1,j_column:j_column+background_size-1]
            targets[i,j] = _cfar_pixel(window_under_test, guard_size,  pfa)
            j = j+1
        end
        i = i+1
    end

    targets = Images.ImageMorphology.dilate(targets)
    targets = Images.ImageMorphology.erode(targets)
    
    return targets
end



"""

pfa = probability for false alarm
PFA = (1/2)-(1/2)*erf(t/sqrt(2))

The following method is used to detemrine if a single pixel is a part of an object.  The statistics from the backgroundWindow is used.
Resturns 1 if the pixel is part of an object and 0 it the pixel is no object

"""
function _cfar_pixel(backgroundWindow::Matrix{Float64}, guard_size::Int64 = 80, pfa = 0.0001)::Int64
    #determining where guard windows starts and ends in the backgroundWindow
    baground_size = size(backgroundWindow)[1]
    half_baground_size = round(Int,(baground_size-1)/2)
    guardStart = round(Int,((baground_size-1)-(guard_size-1))/2)
    guardEnd = round(Int, ((baground_size-1)-((baground_size-1)-(guard_size-1))/2))
    #calculating the threshold from the pfa
    cfar_threshold = sqrt(2)*SpecialFunctions.erfinv(1-2*pfa)
    #the target pixel is the center pixel of the backgroundWindow
    target = backgroundWindow[half_baground_size,half_baground_size]

    #building background window by setting all pixels in guard window to Nan.
    for i_b in guardStart:1:guardEnd
        for j_b in guardStart:1:guardEnd
            backgroundWindow[i_b,j_b] = NaN
        end
    end
    # finding statistics for backgroundWindow
    background_mean = operations.nanmean(backgroundWindow)
    background_std = operations.nanstd(backgroundWindow)
    #comparing background statistics with the pixel in question.
    if target > background_mean+background_std*cfar_threshold
        target = 1
    else
        target = 0
    end
    return target

end