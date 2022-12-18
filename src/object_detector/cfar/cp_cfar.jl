""""
The The constant false alarm rate with convolution and pooling (CP-CFAR) object detection method described in:
Z. Cui, H. Quan, Z. Cao, S. Xu, C. Ding and J. Wu, "SAR Target CFAR Detection Via GPU Parallel Operation," 
in IEEE Journal of Selected Topics in Applied Earth Observations and Remote Sensing, 
vol. 11, no. 12, pp. 4884-4894, Dec. 2018, doi: 10.1109/JSTARS.2018.2879082.

"""
function cp_cfar(image::Matrix{Float64},background_size::Int64 = 301,guard_size::Int64=201,pfa::Float64=0.1)::Matrix{Float64}
    resize_rows,resize_columns = size(image)
    #sobel
    image = filters.sobelFilter(image)
    # average pooling
    average_pool_filter = filters.meanFilter([2,2])
    image = operations.conv2d(image, average_pool_filter,2, "same")
    image = ca_cfar(image,background_size,guard_size,pfa)
    image = Images.ImageMorphology.dilate(image)
    image = Images.ImageMorphology.erode(image)
    #median filter
    kernel_size = (3,3)
    image = Images.ImageFiltering.mapwindow(Statistics.median,image,kernel_size)
    #reseize image to original size
    image = Images.imresize(image,(resize_rows,resize_columns))
    return image
end

