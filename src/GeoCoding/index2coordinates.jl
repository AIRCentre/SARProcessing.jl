

"""

"""
function sar_index2geodetic(row_in_burst,
     image_column, 
     height, 
     interpolator,
     t_start,
     theta_0, #sign_angle*abs(meta["incidence_angle_mid"]*pi/180)
     range_pixel_spacing,
     azimuth_frequency,
     near_range::Real)

    # create function to get time, range. Also inverse function in other 
    time =  t_start + (row_in_burst-1)/azimuth_frequency
    range = near_range + (image_column - 1)*range_pixel_spacing

    orbit_state = interpolator(time)
    
    approximate_intersect = approx_point(orbit_state,theta_0)
    
    x_ecef = solve_radar(range,height,approximate_intersect,orbit_state)
    x_geodetic =  ecef2geodetic(x_ecef)

    return x_geodetic
end




"""
    solve_radar(range,height,x_init,x_sat,v_sat)
    Find the point that is range away from the satelite, orthogonal on the flight directions
    and "height" above the elipsiod using Newton_rhapsody method.
   
"""
function solve_radar(range::Real,height::Real,position_guess::Vector{T},orbit_state::OrbitState;
        scale_factor = 1e-03,MAX_ITER = 150,tolerance = 1e-6,
         semi_major_axis=WGS84_SEMI_MAJOR_AXIS,flattening=WGS84_FLATTENING)


        semi_minor_axis = semi_major_axis*(1 - flattening)

        # inits
        last_position_i = [0.;0.;0.];
        position_i = position_guess;
        iteration  = 1;
        line_of_sight = [0.;0.;0.];

        # scale
        velocity_satellite = orbit_state.velocity.* scale_factor;
        position_i = position_i .*scale_factor;
        position_satellite = x_sat.*scale_factor;
        range = range .*scale_factor;
        a_plus_h = (semi_major_axis + height) .*scale_factor;
        b_plus_h = (semi_minor_axis + height) .*scale_factor;




        while (iteration < MAX_ITER)

            line_of_sight = position_i - position_satellite

            # Design matrix evaluated at previous solution
            fx_i = [velocity_satellite'* line_of_sight,
                line_of_sight' *line_of_sight - range^2,
                ((position_i[1]^2 + position_i[2]^2) / a_plus_h^2 +(position_i[3] / b_plus_h)^2 - 1)];


            # Matrix of partial derivatives
            dfx_i = vcat(velocity_satellite',
                    2*line_of_sight',
                    [2*position_i[1]/a_plus_h^2, 2*position_i[2]/a_plus_h^2,2*position_i[3]/b_plus_h^2]');

            # Solve linear system
            dx = dfx_i\(-fx_i)
            # Update
            last_position_i = position_i;
            position_i += dx;
            iteration += 1;

            step_size = LinearAlgebra.norm(dx)

            if step_size < tolerance
                break
            end

        end

        if iteration == MAX_ITER
            println("Warning Covergens not reached")
            return nothing
        end

        return position_i./scale_factor
end



approx_point(orbit_state::OrbitState,theta_0::Real) = ellipsoid_intersect(
                                                        orbit_state.position, 
                                                        approx_line_of_sight(orbit_state,theta_0))

"""
approx_line_of_sight(orbit_state::OrbitState,theta_0::Real)
    # Output
    - `line_of_sight::Array{float}(3)`: Line of sight to mid swath

#TODO, interpolate geolocationGridPoint from metadata instead?
"""
function approx_line_of_sight(orbit_state::OrbitState,theta_0::Real)

    #Satellite fixed coordinates
    x_hat_satellite=  LinearAlgebra.normalize(orbit_state.position)  # away from the earth center
    z_hat_satellite =  LinearAlgebra.normalize(orbit_state.velocity)  # flight direction
    y_hat_satellite = cross(z_hat_satellite, x_hat_satellite) # Right handed coordinate system

    line_of_sight_satellite_coordinates = [-cos(theta_0), sin(theta_0), 0]

    # Basis change matrix from satellite basis to ECEF coordinates
    m = hcat(x_hat_satellite, y_hat_satellite,z_hat_satellite)

    # Line of sight in ECEF coordinates
    line_of_sight = m*line_of_sight_satellite_coordinates;

    return line_of_sight
end