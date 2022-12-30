
"""
sar2gray(data::AbstractArray; p_quantile = 0.85)

Maps the data to values between 0 and 1 and convert into a gray scaled image. 
The minimum `data` value is mapped to 0 and all values above the `p_quantile` is mapped to 1
"""
function sar2gray(data::AbstractArray{T}; p_quantile = 0.85) where T <: Real
    min_value = minimum(reshape(data,:))
    factor = quantile(reshape(data,:),p_quantile) - min_value
    return Images.Gray.( (data .- min_value) ./ factor )
end


function sar2gray(data::AbstractArray{T}; p_quantile = 0.85) where T <: Complex
    return sar2gray( abs2.(data), p_quantile = p_quantile)
end
