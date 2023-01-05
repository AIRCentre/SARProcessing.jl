
"""
Weighting coefficient for lee filter

"""
function _speckle_lee_weighting(subet_image::Matrix{T},full_image_variance::T)where T<: Real
    subset_variance = std(subet_image)^2
    #E[(z - approx(z))^2] is approximated by local variance.
    weighting_coefficent = subset_variance/(subset_variance+full_image_variance)


    return weighting_coefficent
end


""""
despeckled pixel value

"""
function _speckle_lee_filter_pixel(subset_image::Matrix{T},full_image_variance::T)where T<: Real
    
    #value of center pixel
    center_pixel_row,center_pixel_columns = size(subset_image).÷2
    center_pixel = subset_image[center_pixel_row,center_pixel_columns]
    #mean value
    subset_mean = mean(subset_image)
    # weighting coefficient
    weighting_coefficent = _speckle_lee_weighting(subset_image,full_image_variance)
    # lee despeckled pixel value.
    despeckled_pixel = subset_mean + weighting_coefficent * (center_pixel - subset_mean)
    return despeckled_pixel
end

@doc """
    original speckle lee filter for SAR images, see 'Refined Filtering of Image Noise Using Local Statistics' (1980)




## examples
descpeckled_image = SARProcessing.speckle_lee_filter(speckle_image,[9,9]);
descpeckled_image = speckle_lee_filter(speckle_image,[9,9]);
descpeckled_image = speckle_lee_filter(speckle_image,[3,3]);
"""
function speckle_lee_filter(image::Matrix{T} where T<: Real ,filter_size::Vector{N} where N<:Integer =[3,3])::Matrix{Real}
    @assert length(filter_size) ==2  "Filter size must be [int,int] for height and widht of filter."
    @assert iseven(filter_size[1]) !=true  "Filter height must be uneven, is $(filter_size[1])."
    @assert iseven(filter_size[2]) !=true  "Filter width must be uneven, is $(filter_size[2])."
    @assert size(image)[1]>=filter_size[1]  "Image must be larger than filter. Image height $(size(image)[1]) filter height $(filter_size[1])"
    @assert size(image)[2]>=filter_size[2]  "Image must be larger than filter. Image width $(size(image)[2]) filter width $(filter_size[2])"
    


    im_rows,im_columns = size(image)
    #creating palceholder image:
    despeckled_image = zeros(im_rows-(filter_size[1]-1),im_columns-(filter_size[2]-1)) #÷2
    full_image_variance = std(image)^2
    for i in 1:im_rows-filter_size[1]+1
        for j in 1:im_columns-filter_size[2]+1
            despeckled_image[i,j] = _speckle_lee_filter_pixel(image[i:i+filter_size[1]-1,j:j+filter_size[2]-1],full_image_variance)
        end
    end    
    return despeckled_image
end




