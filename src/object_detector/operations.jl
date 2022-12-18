module operations



import Statistics
import Images

nanmean(x) = Statistics.mean(filter(!isnan,x))
nanmean(x,y) = mapslices(nanmean,x,dims=y)

nansum(x) = sum(filter(!isnan,x))
nansum(x,y) = mapslices(nansum,x,dims=y)


nanstd(x) = Statistics.std(filter(!isnan,x))
nanstd(x,y) = mapslices(nanstd,x,dims=y)






"""
Thanks to Yosi Pramajaya. I copied this from him.

dont want to have too many packages. I therefore wont use Convolition pkg.
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




function binarize_array(image::Matrix{Float64}, threshold::Float64 = 0.0001)::Matrix{Int64}
    image[image .> threshold].=1;
    image[image .< threshold].=0;
    return round.(Int64,image)
end

function binarize_array(image::Matrix{Int64}, threshold::Float64 = 0.0001)::Matrix{Int64}
    return image
end


function mask_array!(image::Matrix{Float64}, threshold::Float64 = 0.0001)::Matrix{Float64}
    image[image .> threshold].=1;
    image[image .< threshold].=NaN;
    return image
end



function mask_array!(image::Matrix{Int64}, threshold::Float64 = 0.0001)::Matrix{Float64}
    image = convert.(Float32, image)
    image[image .> 0.5].=1;
    image[image .< 0.5].=NaN;
    return image
end





function object_locations(binary_array::Matrix{Int64})
    #objects using using label components.
    objects = Images.label_components(binary_array);
    #finding the center x and y coordinate for each object. 
    x_coordinate = [round(Int64,Statistics.mean(first.(Tuple.(findall(x->x==j, objects))))) for j in unique(objects)]
    y_coordinate = [round(Int64,Statistics.mean(last.(Tuple.(findall(x->x==j, objects))))) for j in unique(objects)]
    object_center = [[x_coordinate[i],y_coordinate[i]] for i in 1:1:length(y_coordinate)]
    return object_center
end
    

function get_subset(image,coordinate::Vector{Int64}, subset_size::Vector{Int64}=[75,75])
    half_window_row = round(Int64,(subset_size[1]-1)/2);
    half_window_column = round(Int64,(subset_size[2]-1)/2);
    subset = image[coordinate[1]-half_window_row:coordinate[1]+half_window_row,coordinate[2]-half_window_column:coordinate[2]+half_window_column,:];
    return subset
end


end

