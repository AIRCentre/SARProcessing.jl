module filters
include("operations.jl")
using .operations


""""
meanFilter
    Creates a mean filter for a iamge

examples:
        filter = meanFilter([3,3])
        or 
        filter = meanFilter([3]) 

"""
function meanFilter(size::Vector{Int64}=[3,3])::Matrix{Float64}
    if length(size)==1
        size = [size[1],size[1]]
    end
    return ones(size[1],size[2])./(size[1]*size[2])
end

""""
edgeHorizontal
    Creates a edgeHorizontal for a iamge

examples:
        filter = edgeHorizontal()
"""
function edgeHorizontal()::Matrix{Float64}
    return [1 2 1;0 0 0;-1 -2 -1]
end

""""
edgeVertical
    Creates a edgeVertical for a iamge

examples:
        filter = edgeVertical()
"""
function edgeVertical()::Matrix{Float64}
    return [1 0 1;2 0 -1;1 0 -1]
end



""""
sobelFilter(input::Matrix{Float64},stride::Int64 = 1,padding::String="same")::Matrix{Float64}
    Creates a sobelFilter for a image using edgeVertical() and edgeHorizontal()

examples:
        sobel_image = filters.sobelFilter(image)
"""
function sobelFilter(input::Matrix{Float64},
                    stride::Int64 = 1,
                    padding::String="same")::Matrix{Float64}
    
    horizontal = edgeHorizontal()
    vetical = edgeVertical()
    #sobel
    horizontal_edges = operations.conv2d(input, horizontal, stride, padding)
    vertical_edges = operations.conv2d(input, vetical, stride, padding)
    image = sqrt.(horizontal_edges.^2+ vertical_edges.^2)
    return image
end



end