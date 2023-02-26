
"""
Add padding to array

Q for simon:

"""
function add_padding(array::Matrix{T} where T<: Real, padding_width::Integer=7, pad_value::Real=P where P<: Real )
    input_rows, input_columns = size(array);
    padded_image = ones(input_rows+padding_width*2,input_columns+padding_width*2)*pad_value;
    padded_image[padding_width+1:input_rows+padding_width,padding_width+1:input_columns+padding_width] = array;
    return padded_image
end


"""
    binarize_array(image::Matrix{T}, threshold::Real= 0.0001) where T<:Real

Making a mask with boolean values of image

# Examples
    bool_array = binarize_array(rand(10,10), threshold= 0.0001)
"""
function binarize_array(image::Matrix{T}, threshold::Real= 0.0001) where T<:Real
    binary_image = similar(image,T)
    binary_image[image .> threshold].=1;
    binary_image[image .< threshold].=0;
    return convert.(Bool,binary_image)
end



"""
Making a mask with 1/NaN values of image

# Examples
    array_with_nan = mask_array_nan(rand(10,10), 0.5)
"""
function mask_array_nan(image::Matrix{T}, threshold::Real = 0.5) where T<:Real
    mask_image = similar(image,T)
    mask_image[image .> threshold].=1;
    mask_image[image .< threshold].=NaN;
    return mask_image
end





""""
Find center locations of objects in a binary image.

# Example
    object_centers = object_locations(binary_array)
"""
function object_locations(image::Matrix{T}) where T <: Real
    #objects using using label components.
    binary_array = copy(image)
    if T!=Float64
        binary_array = convert.(Float64,binary_array)
    end
    objects = Images.label_components(binary_array,bkg = trues(5,5));
    #finding the center x and y coordinate for each object.
    unique_objects = unique(objects)[2:length(unique(objects))] #not counting background.
    x_coordinate = [round(Int64,Statistics.mean(first.(Tuple.(findall(x->x==j, objects))))) for j in unique_objects]
    y_coordinate = [round(Int64,Statistics.mean(last.(Tuple.(findall(x->x==j, objects))))) for j in unique_objects]
    object_center = [[x_coordinate[i],y_coordinate[i]] for i in 1:1:length(y_coordinate)]
    binary_array = nothing
    return object_center
end





"""
Extracting a subset from an image. The subset will be extraxted from the image row/column defined by coordinate and size subset_size.

# Input
    image: The image array
    coordinate::Vector{Int64}. Center coordinate of subset, in image geometry.
    subset_size::Vector{Int64}=[75,75]. Size of the subset.

# Output
    subset::Array{Float64, 3}. The three dimensional subset [rows,columns,dimensions.] with dimension=1 for an input 2D array.
"""
function get_subset(image::Matrix{T} where T<:Real, coordinate::Vector{P}, subset_size::Vector{P} = [75,75]) where P<:Integer
    half_window_row = round(Int64,(subset_size[1]-1)/2);
    half_window_column = round(Int64,(subset_size[2]-1)/2);
    subset = image[coordinate[1]-half_window_row:coordinate[1]+half_window_row,coordinate[2]-half_window_column:coordinate[2]+half_window_column,:];
    if size(subset)[3]==1
        subset = dropdims(subset;dims=3)
    end
    return subset
end






"""
Convolution function copied from Yosi Pramajaya. Credits goes to him. In his blogpost, he showed this implementation was faster than many others..
See https://towardsdatascience.com/understanding-convolution-by-implementing-in-julia-3ed744e2e933

dont want to have too many packages. I therefore wont use Convolution pkg.

# Input
    input::Matrix{Float64}. The input image,
    filter::Matrix{Float64}. The  filter/kernel to convolve
    stride::Int64 = 1. Stride of the convolution.
    padding::String = "valid". If padding is used ["valid" or "same"]

# Output
    result::Matrix{Float64}. convolved image.

# Example
    #define a filter.
    average_pool_filter = filters.meanFilter([2,2])
    #perform convolution.
    image = operations.conv2d(image, average_pool_filter,2, "same")

"""
function conv2d(input::Matrix{T} where T<:Real, filter::Matrix{P} where P<: Real, stride::Integer = 1, padding::String = "valid")
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



# credit https://github.com/aamini/FastConv.jl
# direct version (do not check if threshold is satisfied)
@generated function fastconv(E::Array{T,N}, k::Array{T,N}) where {T,N}
    quote

        retsize = [size(E)...] + [size(k)...] .- 1
        retsize = tuple(retsize...)
        ret = zeros(T, retsize)

        convn!(ret,E,k)
        return ret

    end
end

# credit https://github.com/aamini/FastConv.jl
# in place helper operation to speedup memory allocations
@generated function convn!(out::Array{T}, E::Array{T,N}, k::Array{T,N}) where {T,N}
    quote
        @inbounds begin
            @nloops $N x E begin
                @nloops $N i k begin
                    (@nref $N out d->(x_d + i_d - 1)) += (@nref $N E x) * (@nref $N k i)
                end
            end
        end
        return out
    end
end
