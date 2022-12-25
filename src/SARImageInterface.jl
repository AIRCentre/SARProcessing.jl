
abstract type SARImage end

function get_metadata(image::T) where T <: SARImage
    throw(ErrorException("get_metadata(image::T) must be implemented for all SARImage types. Type: $T"))
end

function get_data(image::T) where T <: SARImage
    throw(ErrorException("get_data(image::T) must be implemented for all SARImage types. Type: $T"))
end

abstract type SingleLookComplex <: SARImage end

function is_deramped(image::T) where T <: SingleLookComplex
    throw(ErrorException("is_deramped(image::T) must be implemented for all SingleLookComplex types. Type: $T"))
end

abstract type ComplexBurst <: SARImage end

abstract type MetaData end

function get_polarisation(meta_data::T) where T <: MetaData
    throw(ErrorException("get_polarisation(meta_data::T)must be implemented for all MetaData types. Type: $T"))
end

function get_polarisation(image::T) where T <: SARImage
    meta_data = get_metadata(image)
    return (get_polarisation(meta_data))
end



