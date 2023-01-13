const WGS84_SEMI_MAJOR_AXIS = 6378137.0
const WGS84_FLATTENING = 1/298.257223563



"""
    geodetic2ecef(geodetic_coordinate::Array{Real,1}; semi_major_axis::Real=WGS84_SEMI_MAJOR_AXIS,
        flattening::Real=WGS84_FLATTENING)

Convert geodetic-coordinates `[latitude(radians),longitude(radians),height]` (WGS-84) to ECEF-coordinates `[X,Y,Z]`
"""
function geodetic2ecef(geodetic_coordinate::Array{T,1}; semi_major_axis::Real=WGS84_SEMI_MAJOR_AXIS,
    flattening::Real=WGS84_FLATTENING) where T <: Real

    latitude = geodetic_coordinate[1]
    longitude = geodetic_coordinate[2]
    height = geodetic_coordinate[3]

    @assert abs(latitude) <= pi/2
    @assert abs(longitude) <= pi

    e2 = flattening * (2 - flattening)
    local_radius = semi_major_axis/sqrt(1- e2*sin(latitude)*sin(latitude))

    x=(local_radius+height)*cos(latitude)*cos(longitude)
    y=(local_radius+height)*cos(latitude)*sin(longitude)
    z=(local_radius*(1-e2)+height)*sin(latitude)

    return [x, y, z]
end



"""
    ecef2geodetic(ecef_coordinate::Array{Real,1};
                        semi_major_axis=6378137., flattening=1/298.257223563,
                        tolerance_latitude = 1.e-12, tolerance_height = 1.e-5)

Convert ECEF-coordinates `[X,Y,Z]` to geodetic-coordinates `[latitude(radians),longitude(radians),height]` (WGS-84) radians

(Based on B.R. Bowring, "The accuracy of geodetic latitude and height equations",
Survey Review, v28 #218, October 1985 pp.202-206).
"""
function ecef2geodetic(ecef_coordinate::Array{T,1};
                        semi_major_axis::Real=WGS84_SEMI_MAJOR_AXIS,flattening::Real=WGS84_FLATTENING,
                        tolerance_latitude::Real = 1.e-12, tolerance_height::Real = 1.e-5, max_iterations=1000) where T <: Real


    x = ecef_coordinate[1]
    y = ecef_coordinate[2]
    z = ecef_coordinate[3]


    ### get latitude and hight

    e2 = flattening*(2-flattening)
    height = 0
    delta_height = 1
    delta_latitude = 1

    xy_squared_radius = sqrt(x^2+y^2)
    latitude = atan(z,xy_squared_radius./(1-e2))

    iteration = 0

    while (delta_latitude>tolerance_latitude) | (delta_height>tolerance_height)
        latitude0   = latitude
        height0     = height

        local_radius = semi_major_axis/sqrt(1-e2*sin(latitude)*sin(latitude))
        height = xy_squared_radius*cos(latitude)+z*sin(latitude)-(semi_major_axis^2)/local_radius  # Bowring formula
        latitude = atan(z, xy_squared_radius*(1-e2*local_radius/(local_radius+height)))

        delta_latitude  = abs(latitude-latitude0)
        delta_height    = abs(height-height0)

        iteration += 1
        if iteration >max_iterations
            throw(ErrorException("ecef2geodetic did not converge for  $ecef_coordinate"))
        end
    end

    # Get longitude
    longitude = atan(y,x)

    return [latitude, longitude, height]
end




"""
    ellipsoid_intersect(x_sat::Array{Real,1},normalised_line_of_sight::Array{Real,1};
                                semi_major_axis::Real=6378137.,flattening::Real=1/298.257223563)

Computes the intersection between the satellite line of sight and the earth ellipsoid in ECEF-coordinates
# Arguments
- `x_sat::Array{Real,1}`: [X,Y,Z] position of the satellite in ECEF-coordinates.
- `normalised_line_of_sight::Array{Real,1}`: Normalised Line of sight
# Output
- `x_0::Array{Real,1}`: intersection between line and ellipsoid in ECEF-coordinates.
# Note:
Equations follows I. Cumming and F. Wong (2005) p. 558-559
"""
function ellipsoid_intersect(x_sat::Array{T,1},normalised_line_of_sight::Array{S,1};
                                semi_major_axis::Real=WGS84_SEMI_MAJOR_AXIS,flattening::Real=WGS84_FLATTENING) where T <: Real where S <: Real

    semi_minor_axis = semi_major_axis*(1 - flattening)
    epsilon = (semi_major_axis/semi_minor_axis)^2  - 1 # second eccentricity squared

    # Expressing the intersection between line of sight and ellipsoid as quadratic equation
    F    = (x_sat'*normalised_line_of_sight + epsilon*x_sat[3]*normalised_line_of_sight[3]) / (1 + epsilon*normalised_line_of_sight[3]^2)
    G    = (x_sat'*x_sat - semi_major_axis^2 + epsilon*x_sat[3]^2) / (1 + epsilon*normalised_line_of_sight[3]^2)


    D = F^2 - G
    if D < 0.0
        # no intersection
        return nothing
    end

    # Smallest solution is the intersection. Largest is on the other side of the Earth
    distance    = -F - sqrt(D)

    return x_sat + distance.* normalised_line_of_sight;
end
