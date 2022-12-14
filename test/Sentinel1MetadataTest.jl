"""
unitests for the sentinel-1 metadata

    test
        1)MetaDataSentinel1
        2)loading data 
        3)the different sub structures.
    
"""


#include("../src/separateLater/Sentinel1/Metadata/Sentinel1Metadata.jl")
#import .Sentinel1Metadata



#############################################
########### test for MetaDataSentinel1 ###########
#############################################

function MetaDataSentinel1Test()
    slcMetadata = Sentinel1.MetaDataSentinel1(xmlFile)
    checkStructures = isdefined(slcMetadata, :header) && isdefined(slcMetadata, :product) && isdefined(slcMetadata, :image) && isdefined(slcMetadata, :swath) && isdefined(slcMetadata, :burstsInfo) && isdefined(slcMetadata, :geolocation)
    if !checkStructures
        println("Error in MetaDataSentinel1Test")
    end
    return checkStructures
end


#############################################
########### test for loading data ###########
#############################################



function readXmlTest()
    ## Assert
    isXML = endswith(xmlFile, ".xml")
    ## Debug
    if !isXML
        println("Input is not .xml format")
        println(isXML)
    end


    # can the file be read
    if isXML == true
        ## Act
        metaDict = Sentinel1.getDictofXml(xmlFile)
        ## Assert
        readXMLcheck = metaDict != nothing
        ## Debug
        if !readXMLcheck
            println("Can't load XML file. Error in getDictofXml() ")
            println(readXMLcheck)
        end
        return isXML && readXMLcheck
    else
        return isXML
    end
end





#############################################
### test structures and constructurs #######
### excluding the MetaDataSentinel1 struct #######
#############################################



function HeaderTest()
    metaDict = Sentinel1.getDictofXml(xmlFile)
    header = Sentinel1.Header(metaDict)
    #testing if data exists in header
    checkTimes = header.startTime != nothing
    checkTypes = typeof(header.startTime) == DateTime && typeof(header.stopTime) == DateTime
    check = checkTimes && checkTypes
    if !check
        println("Error in Header")
        println("Start time ", header.startTime)
        println("Stop time: ", header.stopTime)
    end
    return check
end


function productInformationTest()

    metaDict = Sentinel1.getDictofXml(xmlFile)
    product = Sentinel1.ProductInformation(metaDict)
    ## Assert
    checkTypes = typeof(product.rangeSamplingRate) == Float64
    checkrangeSamplingRate = product.rangeSamplingRate > 0
    checkTypesProduct2 = product.radarFrequency > 5 #frq should be 5.4 Ghz ish


    check = checkrangeSamplingRate && checkTypes && checkTypesProduct2
    if !check 
        println("Error in Product data")
        println("Samplig rate", product.rangeSamplingRate, "of type ", typeof(product.rangeSamplingRate))
    end
    return check
end


function ImageInformationTest()

    metaDict = Sentinel1.getDictofXml(xmlFile)
    imageinfo = Sentinel1.ImageInformation(metaDict)
    ## Assert
    checkTypesImage2 = imageinfo.azimuthFrequency > 50 #frequency shoul be is 485 Hz ish
    if !checkTypesImage2
        println("Error in Image data")
    end
    return checkTypesImage2
end



function GeolocationGridTest()

    metaDict = Sentinel1.getDictofXml(xmlFile)
    geolocation = Sentinel1.GeolocationGrid(metaDict)
    ## Assert


    checkGeolocation1 = minimum(geolocation.lines) > 0
    checkGeolocation2 = minimum(geolocation.longitude) > -181
    checkGeolocation3 = minimum(geolocation.latitude) > -181
    checkGeolocation4 = minimum(geolocation.height) > 0
    checkGeolocation5 = minimum(geolocation.elevationAngle) > 0


    check = checkGeolocation1 && checkGeolocation2 && checkGeolocation3 && checkGeolocation4 && checkGeolocation5
    if !check
        println("Error in GeolocationGridTest")
        println(checkGeolocation1)
        println(checkGeolocation2)
        println(checkGeolocation3)
        println(checkGeolocation4)
        println(checkGeolocation5)
    end
    return check
end


function BurstTest()
    #Action
    metaDict = Sentinel1.getDictofXml(xmlFile)
    burstinfo = Sentinel1.BurstsInfo(metaDict)

    azimuthTime = [burst.azimuthTime for burst in burstinfo.bursts]
    lastValidSample = [burst.lastValidSample for burst in burstinfo.bursts]

    ## Assert
    # checkTypes
    checkLength = length(azimuthTime) == length(lastValidSample) 
    

    check = checkLength 
    if !check
        println("Error in Burst")
    end
    return check
end

@testset "Sentinel1Metadata.jl" begin
    ####### actual tests ###############
    @test readXmlTest()
    @test MetaDataSentinel1Test()
    @test HeaderTest()
    @test GeolocationGridTest()
    @test ImageInformationTest()
    @test productInformationTest()
    @test BurstTest()
end