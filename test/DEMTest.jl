


function tandemxDEM_test()
    ## Arrange
    heights = Array{Union{Missing,Float32},2}(missing, 5,5)
    heights[2:3,3:5] .= 2.3
    coordinateOffset = (30.5,20.5) ## lat lon
    coordinateSpacing = (-0.1,0.2) ## lat lon

    ## Act
    testdem = SARProcessing.TandemxDEM(heights, coordinateOffset, coordinateSpacing)
    
    ## Assert
    testOk = size(testdem.heights) == (5,5)

     
     ## Debug
     if !testOk
         println("Debug info: ", string(StackTraces.stacktrace()[1].func))
         println("testdem: ", testdem)
     end
 
     return testOk

end

function coordinate_index_test()
    ## Arrange
    heights = Array{Union{Missing,Float32},2}(missing, 5,5)
    heights[2:3,3:5] .= 2.3
    coordinateOffset = (30.5,20.5) ## lat lon
    coordinateSpacing = (-0.1,0.2) ## lat lon
    testdem = SARProcessing.TandemxDEM(heights, coordinateOffset, coordinateSpacing)

    ## Act
    coordinate_1 = SARProcessing.getCoordinate(testdem,(1,1))
    coordinate_101 = SARProcessing.getCoordinate(testdem,(101,101))
    index_101 = round.(Int,SARProcessing.getIndex(testdem,coordinate_101))
    
    ## Assert
    testOk = coordinate_1 == coordinateOffset 
    testOk &= coordinate_101 == (20.5,40.5)
    testOk &= index_101 == (101,101)

    ## Debug
    if !testOk
        println("Debug info: ", string(StackTraces.stacktrace()[1].func))
        println("coordinate_1: ", coordinate_1)
        println("coordinate_101: ", coordinate_101)
        println("index_101: ", index_101)
    end

    return testOk

end


# Requires a TandemxDEM which can not be put on github due to licence.
# The test is commented out.
function loadTandemxDEM_test() 
    ## Arrange
    testPath = "testData/largeFiles/TDM1_DEM__30_N38W028_V01_C/DEM/TDM1_DEM__30_N38W028_DEM.tif"

    ## Act
    testdem = SARProcessing.loadTandemxDEM(testPath)
    
    ## Assert
    index_island = round.(Int,SARProcessing.getIndex(testdem,(38.7011104,-27.2354222))) ## coordinates on island
    index_ocean =  round.(Int,SARProcessing.getIndex(testdem,(38.3592399,-27.3606715))) ## coordinates middle of ocean

    testOk = !ismissing(testdem.heights[index_island...]) && ismissing(testdem.heights[index_ocean...])
    
    ## Debug
    if !testOk
        println("Debug info: ", string(StackTraces.stacktrace()[1].func))
        println("testdem.heights[index_island]: ", testdem.heights[index_island...])
        println("testdem.heights[index_ocean]: ", testdem.heights[index_ocean...])
    end

    return testOk
end


@testset "DEM.jl" begin
    @test tandemxDEM_test()
    @test coordinate_index_test()
    #@test loadTandemxDEM_test() # Requires a TandemxDEM which can not be put on github
end