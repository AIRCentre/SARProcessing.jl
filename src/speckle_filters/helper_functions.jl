
function variance_to_mean_ratio(image_window)
    # ϵ added for numerical stability. #Simon, is this an issue in julia?
    ϵ = 0.00000001
    return (std(image_window) / (mean(image_window)^2 + ϵ))
end



function equivalent_number_of_looks(image_window)
    # ϵ added for numerical stability. #Simon, is this an issue in julia?
    ϵ = 0.00000001
    return mean(image_window)^2  / (std(image_window+ ϵ))
end




########
# the methods below are implmented in another .jl file not yet pulled...
#  They should therefore be removed here later on....
#
##########

""""
meanFilter
    Creates a mean filter for a iamge

examples:
        filter = meanFilter([3,3])
        or 
        filter = meanFilter([3]) 
copy of what is in object detector... 
"""
function mean_filter(size::Vector{N} where N<:Integer=[3,3])
    if length(size)==1
        size = [size[1],size[1]]
    end
    return ones(size[1],size[2])./(size[1]*size[2])
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



