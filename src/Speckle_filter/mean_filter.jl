@doc """
    mean filter

Also called BoxFilter for SAR speckle reduction. Sometimes even Average filter.

## examples

descpek_mean_3 = speckle_mean_filter(abseloute_image,[3,3])

descpek_mean_3 = speckle_mean_filter(abseloute_image,[9,9])
"""
function speckle_mean_filter(image::Matrix{T} where T<: Real ,filter_size::Vector{N} where N<:Integer =[3,3])::Matrix{Real}
    @assert length(filter_size) ==2  "Filter size must be [int,int] for height and widht of filter."
    @assert iseven(filter_size[1]) !=true  "Filter height must be uneven, is $(filter_size[1])."
    @assert iseven(filter_size[2]) !=true  "Filter width must be uneven, is $(filter_size[2])."
    @assert size(image)[1]>=filter_size[1]  "Image must be larger than filter. Image height $(size(image)[1]) filter height $(filter_size[1])"
    @assert size(image)[2]>=filter_size[2]  "Image must be larger than filter. Image width $(size(image)[2]) filter width $(filter_size[2])"
    

    im_rows,im_columns = size(image)
    despeckled_image = zeros(im_rows-(filter_size[1]-1),im_columns-(filter_size[2]-1)) #÷2
    
    for i in 1:im_rows-filter_size[1]+1
        for j in 1:im_columns-filter_size[2]+1
            despeckled_image[i,j] = mean(image[i:i+filter_size[1]-1,j:j+filter_size[2]-1])
        end
    end
    
    return despeckled_image
end