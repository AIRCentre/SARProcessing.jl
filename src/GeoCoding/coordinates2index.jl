

"""
geodetic2SAR_index(geodetic_coordinate::Array{T,1}, interpolator, metadata::MetaData) where T <: Real

Convert geodetic-coordinates [latitude(radians),longitude(radians),height] 
to SAR_index (row_from_first_burst, image_column) 
"""
function geodetic2SAR_index(geodetic_coordinate::Array{T,1}, interpolator, metadata::MetaData) where T <: Real
    
    range_pixel_spacing = get_range_pixel_spacing(metadata)
    azimuth_frequency = get_azimuth_frequency(metadata)
    near_range = get_near_range(metadata)
    time_range = get_time_range(metadata)

    return geodetic2SAR_index(
        geodetic_coordinate,
        interpolator,
        range_pixel_spacing,
        azimuth_frequency,
        near_range,
        time_range
        ) 
end


function geodetic2SAR_index(
    geodetic_coordinate::Array{T,1},
    interpolator,
    range_pixel_spacing::Real,
    azimuth_frequency::Real,
    near_range::Real,
    time_range
    ) where T <: Real

    ecef_coordinate = geodetic2ecef(geodetic_coordinate)

    return ecef2SAR_index(
        ecef_coordinate,
        interpolator,
        range_pixel_spacing,
        azimuth_frequency,
        near_range,
        time_range
        )
end


"""
ecef2SAR_index(
    ecef_coordinate::Array{T,1},
    interpolator,
    range_pixel_spacing::Real,
    azimuth_frequency::Real,
    near_range::Real,
    image_duration_seconds::Real
    ) where T <: Real

Convert ECEF-coordinates [X,Y,Z] 
to SAR_index (row_from_first_burst, image_column) 
"""
function ecef2SAR_index(
    ecef_coordinate::Array{T,1},
    interpolator,
    range_pixel_spacing::Real,
    azimuth_frequency::Real,
    near_range::Real,
    time_range
    ) where T <: Real

    delta_time = find_zero_doppler_time(ecef_coordinate, time_range , interpolator)
    range = LinearAlgebra.norm(ecef_coordinate .- interpolator(delta_time).position)

    row_from_first_burst = azimuth_time2row(delta_time,azimuth_frequency,time_range[1])
    image_column = range2column(range,range_pixel_spacing,near_range)

    return row_from_first_burst, image_column
end



#TODO A faster way would probably be to project the line of sight component in the v direction (dx_v)
# and then change the time with dx_v/v until the time steps gets small enough, 
function find_zero_doppler_time(ecef_coordinate::Array{T,1}, time_range , interpolator;
    tolerance_in_seconds::Real = 1e-6) where T <: Real

    # Use float seconds for sub millisecond accuracy
    search_interval_start = time_range[1]
    search_interval_end = time_range[2]

    # The search interval is half every step 
    number_of_steps = log2((search_interval_end-search_interval_start)/tolerance_in_seconds)

    is_in_image = _is_coordinate_in_time_range(ecef_coordinate, time_range , interpolator)
    @assert is_in_image "ecef_coordinate is not in image"

    local time_i::Float64

    for _ = 1:number_of_steps
        time_i = (search_interval_end + search_interval_start) / 2

        sin_squint_angle = _get_sin_squint_angle(ecef_coordinate, time_i , interpolator)

        if (sin_squint_angle < 0) # The satellite has already passed the point at time_i
            search_interval_end = time_i  
        else # The satellite has not yet passed the point at time_i
            search_interval_start = time_i 
        end
    end
    
    return time_i
end

function _get_sin_squint_angle(ecef_coordinate::Array{T,1}, t_0::Real, interpolator) where T <: Real
    state_vector = interpolator(t_0)
    line_of_sight = ecef_coordinate .- state_vector.position

    # Compute the squint angle
    trial_sat_velocity = state_vector.velocity
    sin_squint_angle = line_of_sight' * trial_sat_velocity
    return sin_squint_angle
end


function _is_coordinate_in_time_range(ecef_coordinate::Array{T,1},time_range  , interpolator) where T <: Real
    sin_squint_angle_start = _get_sin_squint_angle(ecef_coordinate, time_range[1] , interpolator)
    sin_squint_angle_end = _get_sin_squint_angle(ecef_coordinate, time_range[2], interpolator)
    return (sin_squint_angle_start > 0) && (sin_squint_angle_end < 0)
end