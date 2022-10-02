

"""
General metadata need for SAR images
"""
struct MetaData
    polarisation::String
    sensingTime::DateTime
    frequencyInMHz::Float64
end


"""
General subset for complex swath
"""
struct ComplexSwath
    swath::Int
    indexOffset::Tuple{Int,Int}
    pixels::Array{Complex,2}
end


"""
A complex image with 1 or more swaths
"""
struct ComplexImage
    metadata::MetaData
    swathArray::Array{ComplexSwath,1}
end