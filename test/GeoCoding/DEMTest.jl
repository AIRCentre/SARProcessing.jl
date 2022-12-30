
const TEST_DEM = "testData/largeFiles/TDM1_DEM__30_N38W028_V01_C/DEM/TDM1_DEM__30_N38W028_DEM.tif"

function tandemxDEM_test()
    ## Arrange
    heights = fill(NaN32, 5,5)
    heights[2:3,3:5] .= 2.3
    coordinate_offset = (30.5,20.5) ## lat lon
    coordinate_spacing = (-0.1,0.2) ## lat lon

    ## Act
    test_dem = SARProcessing.TandemxDEM(heights, coordinate_offset, coordinate_spacing)
    
    ## Assert
    test_ok = size(test_dem.heights) == (5,5)

     
     ## Debug
     if !test_ok
         println("Debug info: ", string(StackTraces.stacktrace()[1].func))
         println("test_dem: ", test_dem)
     end
 
     return test_ok

end

function coordinate_index_test()
    ## Arrange
    heights = fill(NaN32, 5,5)
    heights[2:3,3:5] .= 2.3
    coordinate_offset = (30.5,20.5) ## lat lon
    coordinate_spacing = (-0.1,0.2) ## lat lon
    test_dem = SARProcessing.TandemxDEM(heights, coordinate_offset, coordinate_spacing)

    ## Act
    coordinate_1 = SARProcessing.get_coordinate(test_dem,(1,1))
    coordinate_101 = SARProcessing.get_coordinate(test_dem,(101,101))
    index_101 = round.(Int,SARProcessing.get_index(test_dem,coordinate_101))
    
    ## Assert
    test_ok = coordinate_1 == coordinate_offset 
    test_ok &= coordinate_101 == (20.5,40.5)
    test_ok &= index_101 == (101,101)

    ## Debug
    if !test_ok
        println("Debug info: ", string(StackTraces.stacktrace()[1].func))
        println("coordinate_1: ", coordinate_1)
        println("coordinate_101: ", coordinate_101)
        println("index_101: ", index_101)
    end

    return test_ok

end


# Requires a TandemxDEM which can not be put on github due to licence.
function load_tandemx_dem_test() 
    ## Arrange

    ## Act
    test_dem = SARProcessing.load_tandemx_dem(TEST_DEM)
    
    ## Assert
    index_island = round.(Int,SARProcessing.get_index(test_dem,(38.7011104,-27.2354222))) ## coordinates on island
    index_ocean =  round.(Int,SARProcessing.get_index(test_dem,(38.3592399,-27.3606715))) ## coordinates middle of ocean

    test_ok = !isnan(test_dem.heights[index_island...]) && isnan(test_dem.heights[index_ocean...])
    
    ## Debug
    if !test_ok
        println("Debug info: ", string(StackTraces.stacktrace()[1].func))
        println("test_dem.heights[index_island]: ", test_dem.heights[index_island...])
        println("test_dem.heights[index_ocean]: ", test_dem.heights[index_ocean...])
    end

    return test_ok
end


@testset "DEM.jl" begin
    @test tandemxDEM_test()
    @test coordinate_index_test()
    if ispath(TEST_DEM)
        @test load_tandemx_dem_test() # Requires a TandemxDEM which can not be put on github
    end
end