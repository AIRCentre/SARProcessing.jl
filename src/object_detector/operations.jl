module operations



import Statistics
import Images



""""
nanmean()
    computing the mean of an array, x, while neglegting NaN values.
"""
nanmean(x) = Statistics.mean(filter(!isnan,x))
nanmean(x,y) = mapslices(nanmean,x,dims=y)

""""
nanstd()
    computing the std of an array, x, while neglegting NaN values.
"""
nanstd(x) = Statistics.std(filter(!isnan,x))
nanstd(x,y) = mapslices(nanstd,x,dims=y)






"""
function conv2d(input::Matrix{Float64}, filter::Matrix{Float64}, stride::Int64 = 1, padding::String = "valid")::Matrix{Float64}

    Convolution function copied from Yosi Pramajaya. Credits goes to him. In his blogpost, he showed this implementation was faster than many others..
    See https://towardsdatascience.com/understanding-convolution-by-implementing-in-julia-3ed744e2e933

    dont want to have too many packages. I therefore wont use Convolution pkg.

    Input:
        input::Matrix{Float64}. The input image,
        filter::Matrix{Float64}. The  filter/kernel to convolve
        stride::Int64 = 1. Stride of the convolution.
        padding::String = "valid". If padding is used ["valid" or "same"]

    Output:
        result::Matrix{Float64}. convolved image.

    Example:
        #define a filter.
        average_pool_filter = filters.meanFilter([2,2])
        #perform convolution.
        image = operations.conv2d(image, average_pool_filter,2, "same")

"""
function conv2d(input::Matrix{Float64}, filter::Matrix{Float64}, stride::Int64 = 1, padding::String = "valid")::Matrix{Float64}
    input_r, input_c = size(input)
    filter_r, filter_c = size(filter)

    if padding == "same"
        pad_r = (filter_r - 1) ÷ 2 # Integer division.
        pad_c = (filter_c - 1) ÷ 2 # Needed because of Type-stability feature of Julia

        input_padded = zeros(input_r+(2*pad_r), input_c+(2*pad_c))
        for i in 1:input_r, j in 1:input_c
            input_padded[i+pad_r, j+pad_c] = input[i, j]
        end
        input = input_padded
        input_r, input_c = size(input)
    elseif padding == "valid"
        # We don't need to do anything here
    else 
        throw(DomainError(padding, "Invalid padding value"))
    end

    result = zeros((input_r-filter_r) ÷ stride + 1, (input_c-filter_c) ÷ stride + 1)
    result_r, result_c = size(result)

    ir = 1 
    ic = 1
    sum = 0
    for i in 1:result_r
        for j in 1:result_c
            for k in 1:filter_r 
                for l in 1:filter_c 
                    result[i,j] += input[ir+k-1,ic+l-1]*filter[k,l]
                    sum = sum+input[ir+k-1,ic+l-1]*filter[k,l]
                end
            end
            ic += stride
        end
        ir += stride 
        ic = 1 # Return back to 1 after finish looping over column
    end
    return result
end



""""
function binarize_array(image::Matrix{Float64}, threshold::Float64 = 0.0001)::Matrix{Int64}
    Binarizing all pixels in an array. Values < Threshold => 0. Values > Threshold => 1

    input:
        image::Matrix{Float64}
        threshold::Float64 =  0.0001

    output:
        image::Matrix{Int64}: Image with ones and zeros.
"""
function binarize_array(image::Matrix{Float64}, threshold::Float64 = 0.0001)::Matrix{Int64}
    image[image .> threshold].=1;
    image[image .< threshold].=0;
    return round.(Int64,image)
end

""""
function binarize_array(image::Matrix{Int64}, threshold::Float64 = 0.0001)::Matrix{Int64}
    Binarizing all pixels in an array. Values < Threshold => 0. Values > Threshold => 1

    input:
        image::Matrix{Float64}
        threshold::Float64 =  0.0001

    output:
        image::Matrix{Int64}: Image with ones and zeros.
"""
function binarize_array(image::Matrix{Int64}, threshold::Float64 = 0.0001)::Matrix{Int64}
    return image
end

""""
mask_array!(image::Matrix{Float64}, threshold::Float64 = 0.5)::Matrix{Float64}
    Masking all pixels in an array. Values < Threshold => Nan. Values > Threshold => 1

    input:
        image::Matrix{Int64}: Binary image with 0 and 1. Can be made, e.g., from the operations.binarize_array() function
        threshold::Float64 = 0.5: When the value is [0,1], 0s are turned to NaNs. 

    output:
        image::Matrix{Float64}: Image with NaNs.
"""
function mask_array!(image::Matrix{Float64}, threshold::Float64 = 0.5)::Matrix{Float64}
    image[image .> threshold].=1;
    image[image .< threshold].=NaN;
    return image
end


""""
mask_array!(image::Matrix{Int64}, threshold::Float64 = 0.5)::Matrix{Float64}
    Masking all pixels in an array. Values < Threshold => Nan. Values > Threshold => 1

    input:
        image::Matrix{Int64}: Binary image with 0 and 1. Can be made, e.g., from the operations.binarize_array() function
        threshold::Float64 = 0.5: When the value is [0,1], 0s are turned to NaNs. 

    output:
        image::Matrix{Float64}: Image with NaNs.
"""
function mask_array!(image::Matrix{Int64}, threshold::Float64 = 0.5)::Matrix{Float64}
    image = convert.(Float32, image)
    image[image .> threshold].=1;
    image[image .< threshold].=NaN;
    return image
end




""""
object_locations(binary_array::Matrix{Int64})::Vector{Vector{Int64}}

    Find center locations of objects in a binary image.

    Input:
        binary_array::Matrix{Int64}

    Output:
        object_center::Vector{Vector{Int64}}. Vector of Vector{row,column} locations of each object.

    Example:
        object_centers = object_locations(binary_array)
"""
function object_locations(binary_array::Matrix{Int64})::Vector{Vector{Int64}}
    #objects using using label components.
    objects = Images.label_components(binary_array);
    #finding the center x and y coordinate for each object. 
    x_coordinate = [round(Int64,Statistics.mean(first.(Tuple.(findall(x->x==j, objects))))) for j in unique(objects)]
    y_coordinate = [round(Int64,Statistics.mean(last.(Tuple.(findall(x->x==j, objects))))) for j in unique(objects)]
    object_center = [[x_coordinate[i],y_coordinate[i]] for i in 1:1:length(y_coordinate)]
    return object_center
end
    




"""
function get_subset(image,coordinate::Vector{Int64}, subset_size::Vector{Int64}=[75,75])::Array{Float64, 3}
    Extracting a subset from an image. The subset will be extraxted from the image row/column defined by coordinate and size subset_size.

    Input:
        image: The image array
        coordinate::Vector{Int64}. Center coordinate of subset, in image geometry.
        subset_size::Vector{Int64}=[75,75]. Size of the subset. 

    Output:
        subset::Array{Float64, 3}. The three dimensional subset [rows,columns,dimensions.] with dimension=1 for an input 2D array.


"""
function get_subset(image,coordinate::Vector{Int64}, subset_size::Vector{Int64}=[75,75])::Array{Float64, 3}
    half_window_row = round(Int64,(subset_size[1]-1)/2);
    half_window_column = round(Int64,(subset_size[2]-1)/2);
    subset = image[coordinate[1]-half_window_row:coordinate[1]+half_window_row,coordinate[2]-half_window_column:coordinate[2]+half_window_column,:];
    return subset
end


end

