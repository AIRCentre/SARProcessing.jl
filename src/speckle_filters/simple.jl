"""
Should be called something nice. maybe abseloute, since the other is complex.

these filters can be used for both SLC and GRD whereas the other file should only  be for SLC.
"""
function speckle_mean_filter(iamge::Matrix{T} where T<: Real ,filter_size::Vector{N} where N<:Integer =[3,3]) 
    rows,columns = size(iamge)
    added_pixels = filter_size .÷ 2

    filter = mean_filter(filter_size)
    despeckle_image = fastconv(iamge,filter)
    despeckle_image = despeckle_image[added_pixels[1]+1:rows+added_pixels[1],added_pixels[2]+1:columns+added_pixels[2]]
    return despeckle_image
end


"""
Weighting coefficient for frost filter
"""
function speckl_frost_weighting(image,coefficient::Real = 0.01)
    coefficient = coefficient^2 
    ϵ = 0.0000001
end

""""
Weighting coefficient for frost filter
"""
function speckle_frost_filter(image::Matrix{T} where T<: Real ,filter_size::Vector{N} where N<:Integer =[3,3]) 

    return despeckle_image
end


"""
Weighting coefficient for frost filter
"""
function speckle_lee_filter(image::Matrix{T} where T<: Real ,filter_size::Vector{N} where N<:Integer =[3,3]) 
    mean_image = speckle_mean_filter(image,filter_size)
    mean_image_squarred = speckle_mean_filter(image.^2,filter_size)
    image_mean_varince = mean_image_squarred - mean_image.^2
    image_variance = var(image)

    image_weights = image_variance./(image_variance.+image_mean_varince)
    
    return mean_image.+ image_weights.*(abseloute_image - mean_image)
end





