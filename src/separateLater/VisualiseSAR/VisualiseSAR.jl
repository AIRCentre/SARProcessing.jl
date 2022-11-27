module VisualiseSAR
import SARProcessing
using Statistics, Images

function sar2grayimage(data::AbstractArray{T}; p_quantile = 0.85) where T <: Real
    minvalue = minimum(reshape(data,:))
    factor = quantile(reshape(data,:),p_quantile) - minvalue
    return Gray.( (data .- minvalue) ./ factor )
end



function sar2grayimage(data::AbstractArray{T}; p_quantile = 0.85) where T <: Complex
    return sar2grayimage( abs2.(data), p_quantile = p_quantile)
end

end 