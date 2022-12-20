""""
The The constant false alarm rate with convolution and pooling (CP-CFAR) object detection method described in:
Z. Cui, H. Quan, Z. Cao, S. Xu, C. Ding and J. Wu, "SAR Target CFAR Detection Via GPU Parallel Operation," 
in IEEE Journal of Selected Topics in Applied Earth Observations and Remote Sensing, 
vol. 11, no. 12, pp. 4884-4894, Dec. 2018, doi: 10.1109/JSTARS.2018.2879082.

"""
function constant_false_alarm_rate_with_convolution_and_pooling(image::Matrix{T},
                                                                background_size::Integer = 41,
                                                                guard_size::Integer = 21,
                                                                pfa::Real = 0.0001) where T <: Real
    resize_rows,resize_columns = size(image)
    #sobel
    image = SARProcessing.sobelFilter(image)
    # average pooling
    average_pool_filter = meanFilter([2,2])
    image = conv2d(image, average_pool_filter,2, "same")
    image = cell_averaging_constant_false_alarm_rate(image,background_size,guard_size,pfa)
    image = Images.ImageMorphology.dilate(image)
    image = Images.ImageMorphology.erode(image)
    #median filter
    kernel_size = (3,3)
    image = Images.ImageFiltering.mapwindow(Statistics.median,image,kernel_size)
    #reseize image to original size
    image = Images.imresize(image,(resize_rows,resize_columns))
    return image
end

