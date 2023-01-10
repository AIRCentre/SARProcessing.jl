
struct OrbitState
    time::Dates.DateTime
    position::Array{Float64,1}
    velocity::Array{Float64,1}
end


get_speed(state::OrbitState) = LinearAlgebra.norm(state.velocity)


function get_burst_mid_states(image::SingleLookComplex, interpolator)
    return  [interpolator.(t) for t in get_burst_mid_times(image)]
end

"""
    orbit_state_interpolator(orbit_states::Vector{OrbitState}, image::SARImage,
        polynomial_degree::Integer=4, margin::Integer = 3 )

Create a polynomial interpolation function for orbit states valid in the time span
from image start time to image end time.

# Returns
Anonymous interpolation function. (Input: seconds_from_t_start::Float64, Output: state::OrbitState)
"""
function orbit_state_interpolator(orbit_states::Vector{OrbitState}, image::SARImage;
    polynomial_degree::Integer=4, margin::Integer = 3 )

    orbit_state_interpolator(orbit_states, get_metadata(image);
    polynomial_degree=polynomial_degree, margin = margin )
end

function orbit_state_interpolator(orbit_states::Vector{OrbitState}, metadata::MetaData;
    polynomial_degree::Integer=4, margin::Integer = 3 )

    time_range = get_time_range(metadata)
    reference_time = get_reference_time(metadata)

    orbit_sate_start =  Dates.value(orbit_states[1].time-reference_time)/1000.0
    orbit_sate_end = Dates.value(orbit_states[end].time-reference_time)/1000.0
    # check that the orbit states cover the image
    @assert (orbit_sate_start < time_range[1]) &&
            (time_range[2] < orbit_sate_end)

    orbit_state_interpolator(orbit_states, time_range, reference_time ;
    polynomial_degree=polynomial_degree, margin = margin )
end

function orbit_state_interpolator(orbit_states::Vector{OrbitState}, time_range, reference_time::DateTime;
    polynomial_degree::Integer=4, margin::Integer = 3 )


    #select orbit states
    datetime_range =reference_time .+ Millisecond.(round.(Int,time_range .* 1000))
    selected_orbit_states = _select_orbit_states(orbit_states, datetime_range, margin)
    @assert length(selected_orbit_states) > polynomial_degree "Expected polynomial degree to be smaller than length of selected orbit states"

    # Get times
    selected_times = [element.time for element in selected_orbit_states];

    seconds = Float64.(Dates.value.(selected_times .- reference_time)) / 1000

    # normalise data
    position = [ state.position[i] for i=1:3, state in selected_orbit_states ];
    normalised_position, mean_position, std_position  = _normalise_dim2(position)
    velocity = [ state.velocity[i] for i=1:3, state in selected_orbit_states ];
    normalised_velocity, mean_velocity, std_velocity  = _normalise_dim2(velocity)

    # fit polynomial
    position_polynomial = [Polynomials.fit(seconds, normalised_position[i,:], polynomial_degree) for i =1:3]
    velocity_polynomial = [Polynomials.fit(seconds, normalised_velocity[i,:], polynomial_degree) for i =1:3]

    ## create interpolation function
    interpolator = t_seconds ->
    begin
        @assert ((time_range[1]) <= t_seconds) && (t_seconds <= (time_range[2]))  "t is outside time_range"

        interpolated_position= _interpolate_3d_vector(t_seconds, position_polynomial,
            mean_position, std_position)

        interpolated_velocity= _interpolate_3d_vector(t_seconds, velocity_polynomial,
            mean_velocity, std_velocity)

        t = reference_time + Millisecond(round(Int,t_seconds*1000))
        interpolated_orbit_state = OrbitState(t,interpolated_position, interpolated_velocity)
        return interpolated_orbit_state
    end

    return interpolator
end

function _interpolate_3d_vector(x, polynomials, mean_values, std_values)
    interpolated_vector =  [poly(x) for poly in polynomials];
    interpolated_vector = interpolated_vector .* std_values .+mean_values
    return interpolated_vector
end


function _select_orbit_states(orbit_states::Vector{OrbitState}, time_range::Tuple{DateTime,DateTime}, margin::Integer = 3 )

    times = [element.time for element in orbit_states];

    start_index = findfirst(times .> time_range[1])
    start_index = max(1, start_index - margin)

    end_index = findlast(times .< time_range[2])
    end_index = min(length(orbit_states), end_index + margin)

    return orbit_states[start_index:end_index]
end

function _normalise_dim2(values::Matrix)
    mean_values = dropdims(mean(values, dims=2),dims=2)
    std_values = dropdims(std(values, dims=2),dims=2)
    normalised_values= (values .- mean_values) ./std_values;
    return normalised_values, mean_values, std_values
end
