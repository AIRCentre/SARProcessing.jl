module VisualiseSAR
import SARProcessing
using Statistics, Images


"""
sar2grayimage(data::AbstractArray; p_quantile = 0.85)

Maps the data to values between 0 and 1 and convert into a grayscaled image. 
The minimum `data` value is mapped to 0 and all values above the `p_quantile` is mapped to 1
"""
function sar2grayimage(data::AbstractArray{T}; p_quantile = 0.85) where T <: Real
    minvalue = minimum(reshape(data,:))
    factor = quantile(reshape(data,:),p_quantile) - minvalue
    return Gray.( (data .- minvalue) ./ factor )
end



function sar2grayimage(data::AbstractArray{T}; p_quantile = 0.85) where T <: Complex
    return sar2grayimage( abs2.(data), p_quantile = p_quantile)
end

end 