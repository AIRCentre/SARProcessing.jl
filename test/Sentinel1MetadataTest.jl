"""
unitests for the sentinel-1 metadata

    test
        1)MetaDataSentinel1
        2)loading data 
        3)the different sub structures.
    
"""

include("../src/separateLater/Sentinel1/Metadata/exampleMetadata.jl")
include("../src/separateLater/Sentinel1/Metadata/Sentinel1Metadata.jl")

using Test
import Dates


#############################################
########### Getting the .xml file ###########
#############################################


#dataPath = "data"
# finding first .SAFE product... using that for testing.
#safeFolder = (joinpath(dataPath, searchDir(dataPath, "SAFE")[1]))
#getting annotation files in path
#xmlFiles = getAnnotationPaths(safeFolder) #return vector of annotation files
# taking first annotation file XML. 
#const xmlFile = xmlFiles[1]

const xmlFile = "test/testData/s1a-iw3-slc-vv-20220918t074921-20220918t074946-045056-056232-006.xml"




#############################################
########### test for MetaDataSentinel1 ###########
#############################################



function MetaDataSentinel1Test()
    slcMetadata = MetaDataSentinel1(xmlFile)
    checkStructures = isdefined(slcMetadata, :header) && isdefined(slcMetadata, :product) && isdefined(slcMetadata, :image) && isdefined(slcMetadata, :swath) && isdefined(slcMetadata, :burst) && isdefined(slcMetadata, :geolocation)
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
        metaDict = getDictofXml(xmlFile)
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

function XmlDataTest()
    #
    metaDict = getDictofXml(xmlFile)

    hasProduct = haskey(metaDict, "product")
    hasHeader = haskey(metaDict["product"], "adsHeader")
    hasQuality = haskey(metaDict["product"], "qualityInformation")
    hadGeneralInfo = haskey(metaDict["product"], "generalAnnotation")
    hasImageAnnotation = haskey(metaDict["product"], "imageAnnotation")
    hasDopplerCentroid = haskey(metaDict["product"], "dopplerCentroid")
    hasAnennaPattern = haskey(metaDict["product"], "antennaPattern")
    hasSwathTiming = haskey(metaDict["product"], "swathTiming")
    hasGeoLocatioj = haskey(metaDict["product"], "geolocationGrid")
    hasCoordinateConversion = haskey(metaDict["product"], "coordinateConversion")
    hasSwathMerg = haskey(metaDict["product"], "swathMerging")

    ElementsOk = hasProduct && hasHeader && hasQuality && hadGeneralInfo && hasImageAnnotation && hasDopplerCentroid && hasAnennaPattern && hasSwathTiming && hasGeoLocatioj && hasCoordinateConversion && hasSwathMerg

    if !ElementsOk
        println("Error in XML file.")
        println(metaDict)
    end
    return ElementsOk
end



#############################################
### test structures and constructurs #######
### excluding the MetaDataSentinel1 struct #######
#############################################



function HeaderTest()
    metaDict = getDictofXml(xmlFile)
    header = Header(metaDict)
    #testing if data exists in header
    checkTimes = header.startTime != nothing
    checkTypes = typeof(header.startTime) == Dates.DateTime && typeof(header.stopTime) == Dates.DateTime
    check = checkTimes && checkTypes
    if !check
        println("Error in Header")
        println("Start time ", header.startTime)
        println("Stop time: ", header.stopTime)
    end
    return check
end


function productInformationTest()

    metaDict = getDictofXml(xmlFile)
    product = ProductInformation(metaDict)
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

    metaDict = getDictofXml(xmlFile)
    imageinfo = ImageInformation(metaDict)
    ## Assert
    checkTypesImage2 = imageinfo.azimuthFrequency > 50 #frequency shoul be is 485 Hz ish
    if !checkTypesImage2
        println("Error in Image data")
    end
    return checkTypesImage2
end



function GeolocationGridTest()

    metaDict = getDictofXml(xmlFile)
    geolocation = GeolocationGrid(metaDict)
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
    metaDict = getDictofXml(xmlFile)

    swathtiming = SwathTiming(metaDict)
    imageinfo = ImageInformation(metaDict)
    header = Header(metaDict)
    burstinfo = Burst(metaDict,
        swathtiming.linesPerBurst,
        imageinfo.azimuthFrequency,
        header.startTime)


    ## Assert
    # checkTypes
    checkLength = length(burstinfo.azimuthTime) == length(burstinfo.lastValidSample) == length(burstinfo.data_dc_t0) == length(burstinfo.azimuth_fm_rate_t0) == length(burstinfo.firstLineMosaic) == length(burstinfo.absoluteBurstId) == length(burstinfo.burstId) == length(burstinfo.lastValidSample)
    if endswith(header.mode, "IW")
        checkLength2 = round(Int, length(burstinfo.data_dc_polynomial) / 3) == round(Int, length(burstinfo.azimuth_fm_rate_polynomial) / 3) == length(burstinfo.azimuthTime)
    end

    check = checkLength && checkLength2
    if !check
        println("Error in Burst")
    end
    return check
end





@testset "Sentinel1Metadata.jl" begin
    ####### actual tests ###############
    @test readXmlTest()
    @test MetaDataSentinel1Test()
    @test XmlDataTest()
    @test HeaderTest()
    @test GeolocationGridTest()
    @test ImageInformationTest()
    @test productInformationTest()
    @test BurstTest()
end