
###############################################
##### SARImage #####
abstract type SARImage end

# Interface methods
function get_metadata(image::T) where T <: SARImage
    throw(ErrorException("get_metadata(image::T) must be implemented for all SARImage types. Type: $T"))
end

function get_data(image::T) where T <: SARImage
    throw(ErrorException("get_data(image::T) must be implemented for all SARImage types. Type: $T"))
end




function get_polarisation(image::T) where T <: SARImage
    meta_data = get_metadata(image)
    return (get_polarisation(meta_data))
end

function get_time_range(image::T) where T <: SARImage
    meta_data = get_metadata(image)
    return (get_time_range(meta_data))
end

###############################################
##### SingleLookComplex #####

abstract type SingleLookComplex <: SARImage end

# Interface methods
function is_deramped(image::T) where T <: SingleLookComplex
    throw(ErrorException("is_deramped(image::T) must be implemented for all SingleLookComplex types. Type: $T"))
end

"""
get_burst_mid_times(image::T) where T <: SingleLookComplex

    Returns a vector of the mid burst times for the burst in the image. 
    Only bursts included in the image view are included
"""
function get_burst_mid_times(image::T) where T <: SingleLookComplex
    throw(ErrorException("get_burst_mid_times(image::T)   must be implemented for all SingleLookComplex types. Type: $T"))
end 


#abstract type ComplexBurst <: SARImage end


###############################################
##### MetaData #####

abstract type MetaData end

# Interface methods
function get_polarisation(meta_data::T) where T <: MetaData
    throw(ErrorException("get_polarisation(meta_data::T)must be implemented for all MetaData types. Type: $T"))
end

function get_range_sampling_rate(meta_data::T) where T <: MetaData
    throw(ErrorException("get_range_sampling_rate(meta_data::T)must be implemented for all MetaData types. Type: $T"))
end

function get_azimuth_frequency(meta_data::T) where T <: MetaData
    throw(ErrorException("get_azimuth_frequency(meta_data::T)must be implemented for all MetaData types. Type: $T"))
end

function get_slant_range_time_seconds(meta_data::T) where T <: MetaData
    throw(ErrorException("get_slant_range_time_seconds(meta_data::T)must be implemented for all MetaData types. Type: $T"))
end

function get_slant_range_time_seconds(meta_data::T) where T <: MetaData
    throw(ErrorException("get_slant_range_time_seconds(meta_data::T)must be implemented for all MetaData types. Type: $T"))
end

function get_time_range(meta_data::T) where T <: MetaData
    throw(ErrorException("get_time_range(image::T) must be implemented for all MetaData types. Type: $T"))
end

function get_reference_time(meta_data::T) where T <: MetaData
    throw(ErrorException("get_reference_time(image::T) must be implemented for all MetaData types. Type: $T"))
end

# Simple functions

get_range_pixel_spacing(meta_data::MetaData, c = LIGHT_SPEED) = c / ( 2.0*  get_range_sampling_rate(meta_data))

get_near_range(meta_data::MetaData, c = LIGHT_SPEED) = c *  get_slant_range_time_seconds(meta_data)/ 2.0



function get_image_duration_seconds(meta_data::MetaData)::Float64
    time_range = get_time_range(meta_data)
    return time_range[2]- time_range[1]
end


