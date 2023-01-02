using Statistics


include("../separateLater/Sentinel1/Sentinel1.jl")
include("../SARProcessing.jl")
include("../separateLater/VisualiseSAR/VisualiseSAR.jl")

include("../speckle_filters/helper_functions.jl")
#include("simple.jl")
slcSubsetPath = "test/testData/s1a-iw3-slc-vv_subset_hight9800_10400_width11000_11000.tiff";
complex_image = Sentinel1.readTiff(slcSubsetPath)
abseloute_image = abs.(complex_image)



"""
Should be called something nice. maybe abseloute, since the other is complex.

these filters can be used for both SLC and GRD whereas the other file should only  be for SLC.

    - Mean filter. 
    - Lee filter
"""









""""
mean filter

Also called BoxFilter for SAR speckle reduction. Sometimes even Average filter.

"""
function speckle_mean_filter(image::Matrix{T} where T<: Real ,filter_size::Vector{N} where N<:Integer =[3,3]) 
    rows,columns = size(image)
    added_pixels = filter_size .÷ 2

    filter = mean_filter(filter_size)
    despeckle_image = fastconv(image,filter)
    despeckle_image = despeckle_image[added_pixels[1]+1:rows+added_pixels[1],added_pixels[2]+1:columns+added_pixels[2]]
    return despeckle_image
end





"""
Weighting coefficient for lee filter
"""
function _speckle_lee_weighting(subet_image::Matrix{T},full_image_variance::T)where T<: Real
    subset_variance = std(subet_image)^2
    weighting_coefficent = subset_variance/(subset_variance+full_image_variance)
    return weighting_coefficent
end


""""

"""
function _speckle_lee_filter_pixel(subset_image::Matrix{T},full_image_variance::T)where T<: Real
    #value of center pixel
    center_pixel_row,center_pixel_columns = size(subset_image).÷2
    center_pixel = subset_image[center_pixel_row,center_pixel_columns]
    #mean value
    image_mean = mean(subset_image)
    # weighting coefficient
    weighting_coefficent = _speckle_lee_weighting(subset_image,full_image_variance)
    # lee despeckled pixel value.
    despeckled_pixel = image_mean + weighting_coefficent * (center_pixel - image_mean)
    return despeckled_pixel
end


function speckle_lee_filter(image::Matrix{T} where T<: Real ,filter_size::Vector{N} where N<:Integer =[3,3])
    im_rows,im_columns = size(image)
    despeckled_image = zeros(im_rows-(filter_size[1]-1),im_columns-(filter_size[2]-1)) #÷2
    full_image_variance = std(image)^2
    for i in 1:im_rows-filter_size[1]
        for j in 1:im_columns-filter_size[2]
            despeckled_image[i,j] = _speckle_lee_filter_pixel(image[i:i+filter_size[1],j:j+filter_size[2]],full_image_variance)
        end
    end
    return despeckled_image
end


test = rand(100,100)
test2 = rand(100,100)
test2[35:1:55 , 46:1:50] .= 1.5

leetest = speckle_lee_filter(test,[9,9])
leetest2 = speckle_lee_filter(test2,[9,9])

leetest2 = speckle_lee_filter(abseloute_image,[9,9])





median(leetest2)









"""
Weighting coefficient for frost filter
"""
function speckl_frost_weighting(image,coefficient::Real = 0.01)
    coefficient = coefficient^2 
    ϵ = 0.0000001
end

""""
speckle_frost_filter

"""
function speckle_frost_filter(image::Matrix{T} where T<: Real ,filter_size::Vector{N} where N<:Integer =[5,5]) 

    return despeckle_image
end

