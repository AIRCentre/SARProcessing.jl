using LinearAlgebra

function geodetic2ecef_longitude0_test(latitude,height, use_longitude180::Bool) 
    ## Arrange
    longitude = use_longitude180 ? pi : 0.0
    geodetic_coordinate = [latitude,longitude,height]
    
    a = SARProcessing.WGS84_SEMI_MAJOR_AXIS
    b = a * (1 - SARProcessing.WGS84_FLATTENING)

    ## Act
    ecef_coordinate = SARProcessing.geodetic2ecef(geodetic_coordinate)
    
    ## Assert
    x = ecef_coordinate[1]
    y = ecef_coordinate[2]
    z = ecef_coordinate[3]
    

    check_y = isapprox(y,0.0, atol=1)  ## points with zero longitude should have y=0

    check_x = false 

    check_z = false 
    check_distance = false


    if latitude ≈ 0.0
        check_z = isapprox(z,0.0, atol=1)
        check_x = use_longitude180 ? isapprox(x,-(a+height), atol=1)  : isapprox(x,(a+height), atol=1) 
        check_distance = true
    elseif abs(latitude) ≈ pi/2
        check_x = isapprox(x,0.0, atol=1)
        check_z =  latitude < 0.0 ? isapprox(z,-(b+height), atol=1)  : isapprox(z,(b+height), atol=1) 
        check_distance = true
    else
        check_x = use_longitude180 ? x < 0.0  : x > 0.0
        check_z = latitude < 0.0 ? z < 0.0  : z > 0.0

        distance = sqrt(x^2 + z^2 )
        check_distance = isapprox(distance, (a+height), rtol=0.01)
    end

    checks = [check_x, check_y, check_z, check_distance ]
    testOk = all(checks)
    
    ## Debug
    if !testOk
        println("Debug info: ", string(StackTraces.stacktrace()[1].func))
        println("checks: ", checks)
        println("ecef_coordinate: ", ecef_coordinate)
        println("geodetic_coordinate: ", geodetic_coordinate)

    end

    return testOk
end


function geodetic2ecef_latitude0_test(longitude,height) 
    ## Arrange
    geodetic_coordinate = [0.0,longitude,height]
    a = SARProcessing.WGS84_SEMI_MAJOR_AXIS

    ## Act
    ecef_coordinate = SARProcessing.geodetic2ecef(geodetic_coordinate)

    ## Assert
    x = ecef_coordinate[1]
    y = ecef_coordinate[2]
    z = ecef_coordinate[3]


    check_z = isapprox(z,0.0, atol=1)  ## points with zero latitude should have z = 0

    check_x = false 

    check_y = false 
    check_distance = false

    if longitude ≈ 0.0 || longitude ≈ pi
        check_y = isapprox(y,0.0, atol=1)
        check_x = pi/2 < longitude  ? isapprox(x,-(a+height), atol=1)  : isapprox(x,(a+height), atol=1) 
        check_distance = true
    elseif abs(longitude) ≈ pi/2
        check_x = isapprox(x,0.0, atol=1)
        check_y =  longitude < 0.0 ? isapprox(y,-(a+height), atol=1)  : isapprox(y,(a+height), atol=1) 
        check_distance = true
    else
        check_x = pi/2 < abs(longitude) ? x < 0.0  : x > 0.0
        check_y = longitude < 0 ? y < 0.0  : y > 0.0
        distance = sqrt(x^2 + y^2 )
        check_distance = isapprox(distance, (a+height), rtol=0.01)
    end
    
    checks = [check_x, check_y, check_z, check_distance ]
    testOk = all(checks)

    ## Debug
    if !testOk
        println("Debug info: ", string(StackTraces.stacktrace()[1].func))
        println("checks: ", checks)
        println("ecef_coordinate: ", ecef_coordinate)
        println("geodetic_coordinate: ", geodetic_coordinate)
    end

    return testOk
end


function geodetic_ecef_consistency_test(geodetic_coordinate) 
    ## Arrange
    ecef_coordinate = SARProcessing.geodetic2ecef(geodetic_coordinate)

    ## Act
    geodetic_coordinate_computed = SARProcessing.ecef2geodetic(ecef_coordinate)

    ## Assert
    checks  = [isapprox(geodetic_coordinate[i], geodetic_coordinate_computed[i], rtol=0.001, atol=0.0001) for i=1:3]
    testOk = all(checks)

    ## Debug
    if !testOk
        println("Debug info: ", string(StackTraces.stacktrace()[1].func))
        println("checks: ", checks)
        println("geodetic_coordinate_computed: ", geodetic_coordinate_computed)
        println("geodetic_coordinate: ", geodetic_coordinate)
    end

    return testOk
end


function ellipsoid_intersect_straight_down_test(geodetic_coordinate) 
    
    ## Arrange
    position = SARProcessing.geodetic2ecef(geodetic_coordinate)
    line_of_sight = - position ./ norm(position)

    ## Act
    intersection = SARProcessing.ellipsoid_intersect(position,line_of_sight)

    ## Assert
    intersection_geo = SARProcessing.ecef2geodetic(intersection)

    check_height    =     isapprox(intersection_geo[3],0, atol=1)
    check_latitude  =   isapprox(intersection_geo[1],geodetic_coordinate[1], atol=0.01)
    check_longitude =   isapprox(intersection_geo[2],geodetic_coordinate[2], atol=0.01)

    checks  = [check_height, check_latitude, check_longitude]
    testOk = all(checks)
    
    ## Debug
    if !testOk
        println("Debug info: ", string(StackTraces.stacktrace()[1].func))
        println("intersection_geo: ", intersection_geo)
    end

    return testOk
end


@testset "geometryUtils.jl" begin
    ####### actual tests ###############
    @test geodetic2ecef_longitude0_test(0.0,503000, true) 
    @test geodetic2ecef_longitude0_test(pi/4,-3400, true) 
    @test geodetic2ecef_longitude0_test(-pi/4,4, true) 
    @test geodetic2ecef_longitude0_test(pi/2,32040, true) 
    @test geodetic2ecef_longitude0_test(-pi/2,12334, true) 
    @test geodetic2ecef_longitude0_test(0.0,1300023, false) 
    @test geodetic2ecef_longitude0_test(pi/4,1243434, false) 
    @test geodetic2ecef_longitude0_test(-pi/4,313332, false) 
    @test geodetic2ecef_longitude0_test(pi/2,-394343, false) 
    @test geodetic2ecef_longitude0_test(-pi/2,123233, false) 

    @test geodetic2ecef_latitude0_test(0.0,0.0)
    @test geodetic2ecef_latitude0_test(pi/4,1232)
    @test geodetic2ecef_latitude0_test(pi/2,34333)
    @test geodetic2ecef_latitude0_test(3*pi/4,-1232)
    @test geodetic2ecef_latitude0_test(pi,23424)
    @test geodetic2ecef_latitude0_test(-pi/4,21231)
    @test geodetic2ecef_latitude0_test(-pi/2,76666)
    @test geodetic2ecef_latitude0_test(-3*pi/4,-3033)
    @test geodetic2ecef_latitude0_test(-pi,-19934)

    @test geodetic_ecef_consistency_test([0.0, 0.0, 3545333])
    @test geodetic_ecef_consistency_test([-pi/23, pi/8, 54333])
    @test geodetic_ecef_consistency_test([-pi/9, -pi/6, 0.0])
    @test geodetic_ecef_consistency_test([pi/9,  -pi/6, -23242.0])
    @test geodetic_ecef_consistency_test([pi/3,  pi/6, 43242])
    @test geodetic_ecef_consistency_test([pi/3,  3*pi/4, 29954])
    @test geodetic_ecef_consistency_test([-pi/3,  -3*pi/4, -5])


    @test ellipsoid_intersect_straight_down_test([0.0, 0.0, 3545333])
    @test ellipsoid_intersect_straight_down_test([-pi/23, pi/8, 54333])
    @test ellipsoid_intersect_straight_down_test([-pi/9, -pi/6, 340.0])
    @test ellipsoid_intersect_straight_down_test([pi/9,  -pi/6, 23242.0])
    @test ellipsoid_intersect_straight_down_test([pi/3,  pi/6, 43242])
    @test ellipsoid_intersect_straight_down_test([pi/3,  3*pi/4, 29954])
    @test ellipsoid_intersect_straight_down_test([-pi/3,  -3*pi/4, 435])
end