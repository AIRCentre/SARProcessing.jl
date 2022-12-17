"""
unitests for the sentinel-1 metadata

    test
        1)MetaDataSentinel1
        2)loading data 
        3)the different sub structures.
    
"""


#############################################
########### test for MetaDataSentinel1 ###########
#############################################

function MetaDataSentinel1Test()
    slcMetadata = Sentinel1.MetaDataSentinel1(SENTINEL1_SLC_METADATA_TEST_FILE)
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
    isXML = endswith(SENTINEL1_SLC_METADATA_TEST_FILE, ".xml")
    ## Debug
    if !isXML
        println("Input is not .xml format")
        println(isXML)
    end


    # can the file be read
    if isXML == true
        ## Act
        metaDict = Sentinel1.getDictofXml(SENTINEL1_SLC_METADATA_TEST_FILE)
        ## Assert
        readXMLcheck = metaDict != nothing
        ## Debug
        if !readXMLcheck
            println("Can't load XML file. Error in getDictofXml() ")
            println(readXMLcheck)
        end
        return isXML && readXMLcheck
    else
        return false
    end
end





#############################################
### test structures and constructurs #######
### excluding the MetaDataSentinel1 struct #######
#############################################



function HeaderTest()
    metaDict = Sentinel1.getDictofXml(SENTINEL1_SLC_METADATA_TEST_FILE)
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

    metaDict = Sentinel1.getDictofXml(SENTINEL1_SLC_METADATA_TEST_FILE)
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

    metaDict = Sentinel1.getDictofXml(SENTINEL1_SLC_METADATA_TEST_FILE)
    imageinfo = Sentinel1.ImageInformation(metaDict)
    ## Assert
    check = round(Int,imageinfo.azimuthFrequency) == 486 #frequency should be around 486.4 Hz for the Sentinel-1 
    check &= imageinfo.numberOfSamples == 24203 
    check &= round(Int,imageinfo.azimuthPixelSpacing) ==14 

    if !check
        println("Error in Image data")
    end
    return check
end



function GeolocationGridTest()

    metaDict = Sentinel1.getDictofXml(SENTINEL1_SLC_METADATA_TEST_FILE)
    geolocation = Sentinel1.GeolocationGrid(metaDict);
    ## Assert
 
    check = length(geolocation.lines)==210
    check &= minimum(geolocation.lines) > 0
    check &= round(Int,minimum(geolocation.longitude)) == -28
    check &= round(Int,maximum(geolocation.longitude)) == -27
    check &= round(Int,minimum(geolocation.latitude)) == 38
    
    check &= round(Int,minimum(geolocation.height)) == 0
    check &= round(Int,minimum(geolocation.elevationAngle)) == 37


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
    metaDict = Sentinel1.getDictofXml(SENTINEL1_SLC_METADATA_TEST_FILE)
    burstinfo = Sentinel1.BurstsInfo(metaDict);

    ## Assert
    check = burstinfo.numberOfBurst == 9
    check &= length(burstinfo.bursts) == 9
    check &= isapprox(burstinfo.bursts[1].dopplerCentroid.dcT0,0.00534423320003329; atol = 0.000000001)
    check &= isapprox(burstinfo.bursts[8].dopplerCentroid.dcT0,0.005342927742124565; atol = 0.000000001)
    check &= length(burstinfo.bursts[1].azimuthFmRates.azimuthFmRatePolynomial) == 3
    check &= burstinfo.bursts[5].dopplerCentroid.burstMidTime == Millisecond(12588)
    check &= burstinfo.bursts[3].sensingTime == DateTime(2022,09,18,07,49,28,166)   
    check &= isapprox(burstinfo.bursts[2].azimuthFmRates.azimuthFmRateT0 ,0.006018535512387027; atol = 0.000001) 

    # add stuff later

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