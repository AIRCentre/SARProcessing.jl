
abstract type SARImage end

function get_metadata(image::T)::MetaData where T <: SARImage
    throw(ErrorException("get_metadata(image::T) must be implemented for all SARImage types. Type: $T"))
end

function get_data(image::T)::MetaData where T <: SARImage
    throw(ErrorException("get_data(image::T) must be implemented for all SARImage types. Type: $T"))
end

abstract type SingleLookComplex <: SARImage end

abstract type ComplexBurst <: SARImage end

abstract type MetaData end


