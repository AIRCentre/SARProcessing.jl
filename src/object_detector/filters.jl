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



function edgeHorizontal()::Matrix{Float64}
    return [1 2 1;0 0 0;-1 -2 -1]
end

function edgeVertical()::Matrix{Float64}
    return [1 0 1;2 0 -1;1 0 -1]
end




function sobelFilter(input::Matrix{Float64},
                    stride::Int64 = 1,
                    padding::String="same")::Matrix{Float64}
    
    horizontal = edgeHorizontal()
    vetical = edgeVertical()
    #sobel
    horizontal_edges = conv2d(input, horizontal, stride, padding)
    vertical_edges = conv2d(input, vetical, stride, padding)
    image = sqrt.(horizontal_edges.^2+ vertical_edges.^2)
    return image
end



#end