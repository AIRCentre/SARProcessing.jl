
"""
sar_index2geodetic(row_from_first_burst,
    image_column, 
    height, 
    interpolator,
    metadata::MetaData)

    Convert SAR_index (row_from_first_burst, image_column) to geodetic coordinates [latitude(radians),longitude(radians),height] 
"""
function sar_index2geodetic(row_in_burst::Real,
    image_column::Real, 
    height::Real, 
    interpolator,
    metadata::MetaData,
    burst_number::Integer)

    range_pixel_spacing = get_range_pixel_spacing(metadata)
    azimuth_frequency = get_azimuth_frequency(metadata)
    near_range = get_near_range(metadata)
    incidence_angle_mid = get_incidence_angle_mid_degrees(metadata) * pi/180
    burst_start_time = get_burst_start_times(metadata)[burst_number]

    return  sar_index2geodetic(row_in_burst,
        image_column, 
        height, 
        interpolator,
        incidence_angle_mid, 
        range_pixel_spacing,
        azimuth_frequency,
        near_range,
        burst_start_time)
end


function sar_index2geodetic(row_in_burst::Real,
     image_column::Real, 
     height::Real, 
     interpolator,
     incidence_angle_mid::Real, 
     range_pixel_spacing::Real,
     azimuth_frequency::Real,
     near_range::Real,
     burst_start_time::Real)

    time = row_in_burst2azimuth_time(row_in_burst,azimuth_frequency,burst_start_time)
    range = column2range(image_column,range_pixel_spacing,near_range)

    orbit_state = interpolator(time)
    
    approximate_intersect = approx_point(orbit_state,incidence_angle_mid)

    x_ecef = solve_radar(range,height,approximate_intersect,orbit_state)
    x_geodetic =  ecef2geodetic(x_ecef)

    return x_geodetic
end




"""
    solve_radar
    Find the point that is range away from the satellite, orthogonal on the flight directions
    and "height" above the elipsiod using Newton_rhapsody method.
   
"""
function solve_radar(range::Real,height::Real,point_guess::Vector{T},orbit_state::OrbitState;
        scale_factor = 1e-03,MAX_ITER = 150,tolerance = 1e-7,
         semi_major_axis=WGS84_SEMI_MAJOR_AXIS,flattening=WGS84_FLATTENING) where T <: Real


        semi_minor_axis = semi_major_axis*(1 - flattening)

        # inits
        last_point = [0.;0.;0.];
        point_i = point_guess;
        iteration  = 1;
        line_of_sight = [0.;0.;0.];

        # scale
        velocity_satellite = orbit_state.velocity.* scale_factor;
        point_i = point_i .*scale_factor;
        position_satellite =  orbit_state.position.*scale_factor;
        range = range .*scale_factor;
        a_plus_h = (semi_major_axis + height) .*scale_factor;
        b_plus_h = (semi_minor_axis + height) .*scale_factor;




        while (iteration < MAX_ITER)

            line_of_sight = point_i - position_satellite

            # Design matrix evaluated at previous solution
            fx_i = [velocity_satellite'* line_of_sight, # Line of sight is orthogonal with the velocity
                line_of_sight' *line_of_sight - range^2, # The point is at range distance
                ((point_i[1]^2 + point_i[2]^2) / a_plus_h^2 +(point_i[3] / b_plus_h)^2 - 1)] # point is at correct height;


            # Matrix of partial derivatives
            dfx_i = vcat(velocity_satellite',
                    2*line_of_sight',
                    [2*point_i[1]/a_plus_h^2, 2*point_i[2]/a_plus_h^2,2*point_i[3]/b_plus_h^2]');

            # Solve linear system
            dx = dfx_i\(-fx_i)
            # Update
            last_point = point_i;
            point_i += dx;
            iteration += 1;

            step_size = LinearAlgebra.norm(dx)

            if step_size < tolerance
                break
            end

        end

        if iteration == MAX_ITER
            println("Warning Convergence not reached")
            return nothing
        end

        return point_i./scale_factor
end



approx_point(orbit_state::OrbitState,incidence_angle_mid::Real) = ellipsoid_intersect(
                                                        orbit_state.position, 
                                                        approx_line_of_sight(orbit_state,incidence_angle_mid))

"""
approx_line_of_sight(orbit_state::OrbitState,incidence_angle_mid::Real)
    # Output
    - `line_of_sight::Array{float}(3)`: Line of sight to mid swath

#TODO, interpolate geolocationGridPoint from metadata instead?
"""
function approx_line_of_sight(orbit_state::OrbitState,incidence_angle_mid::Real)

    #Satellite fixed coordinates
    x_hat_satellite=  LinearAlgebra.normalize(orbit_state.position)  # away from the earth center
    z_hat_satellite =  LinearAlgebra.normalize(orbit_state.velocity)  # flight direction
    y_hat_satellite = LinearAlgebra.cross(z_hat_satellite, x_hat_satellite) # Right handed coordinate system

    line_of_sight_satellite_coordinates = [-cos(incidence_angle_mid), sin(incidence_angle_mid), 0]

    # Basis change matrix from satellite basis to ECEF coordinates
    m = hcat(x_hat_satellite, y_hat_satellite,z_hat_satellite)

    # Line of sight in ECEF coordinates
    line_of_sight = m*line_of_sight_satellite_coordinates;

    return line_of_sight
end