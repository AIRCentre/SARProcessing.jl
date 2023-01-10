
const EDGE_HORIZONTAL = [1 2 1;0 0 0;-1 -2 -1]
const EDGE_VERTICAL = [1 0 -1;2 0 -2;1 0 -1]

""""
    mean_filter

Creates a mean filter for a image

# Examples
    filter = meanFilter([3,3])
    or
    filter = meanFilter([3])
"""
function mean_filter(size::Vector{Int64}=[3,3])::Matrix{Float64}
    if length(size)==1
        size = [size[1],size[1]]
    end
    return ones(size[1],size[2])./(size[1]*size[2])
end







""""
    sobelFilter(input::Matrix{Float64},stride::Int64 = 1,padding::String="same")::Matrix{Float64}

Creates a sobelFilter for a image using edgeVertical() and edgeHorizontal()

# Examples
    sobel_image = filters.sobelFilter(image)
"""
function sobel_filter(input::Matrix{T} where T <: Real,
                    stride::Integer = 1,
                    padding::String="same")
    #sobel
    horizontal_edges = conv2d(input, EDGE_HORIZONTAL, stride, padding)
    vertical_edges = conv2d(input, EDGE_VERTICAL, stride, padding)
    image = sqrt.(horizontal_edges.^2+ vertical_edges.^2)
    return image
end
