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
    slcMetadata = SARProcessing.MetaDataSentinel1(SENTINEL1_SLC_METADATA_TEST_FILE)
    checkStructures = isdefined(slcMetadata, :header) && isdefined(slcMetadata, :product) && isdefined(slcMetadata, :image) && isdefined(slcMetadata, :swath) && isdefined(slcMetadata, :bursts) && isdefined(slcMetadata, :geolocation)
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
        metaDict = SARProcessing.read_xml_as_dict(SENTINEL1_SLC_METADATA_TEST_FILE)
        ## Assert
        readXMLcheck = !isnothing(metaDict )
        ## Debug
        if !readXMLcheck
            println("Can't load XML file. Error in read_xml_as_dict() ")
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
    metaDict = SARProcessing.read_xml_as_dict(SENTINEL1_SLC_METADATA_TEST_FILE)
    header = SARProcessing.Sentinel1Header(metaDict)
    #testing if data exists in header
    checkTimes = !isnothing(header.start_time)
    checkTypes = typeof(header.start_time) == DateTime && typeof(header.stop_time) == DateTime
    check = checkTimes && checkTypes
    if !check
        println("Error in Sentinel1Header")
        println("Start time ", header.start_time)
        println("Stop time: ", header.stop_time)
    end
    return check
end


function productInformationTest()

    metaDict = SARProcessing.read_xml_as_dict(SENTINEL1_SLC_METADATA_TEST_FILE)
    product = SARProcessing.Sentinel1ProductInformation(metaDict)
    ## Assert
    checkTypes = typeof(product.range_sampling_rate) == Float64
    checkrange_sampling_rate = product.range_sampling_rate > 0
    checkTypesProduct2 = product.radar_frequency > 5 #frq should be 5.4 Ghz ish


    check = checkrange_sampling_rate && checkTypes && checkTypesProduct2
    if !check 
        println("Error in Product data")
        println("Samplig rate", product.range_sampling_rate, "of type ", typeof(product.range_sampling_rate))
    end
    return check
end


function ImageInformationTest()

    metaDict = SARProcessing.read_xml_as_dict(SENTINEL1_SLC_METADATA_TEST_FILE)
    imageinfo = SARProcessing.Sentinel1ImageInformation(metaDict)
    ## Assert
    check = round(Int,imageinfo.azimuth_frequency) == 486 #frequency should be around 486.4 Hz for the Sentinel-1 
    check &= imageinfo.number_of_samples == 24203 
    check &= round(Int,imageinfo.azimuth_pixel_spacing) ==14 

    if !check
        println("Error in Image data")
    end
    return check
end



function Sentinel1GeolocationGridTest()

    metaDict = SARProcessing.read_xml_as_dict(SENTINEL1_SLC_METADATA_TEST_FILE)
    geolocation = SARProcessing.Sentinel1GeolocationGrid(metaDict);
    ## Assert
 
    check = length(geolocation.lines)==210
    check &= minimum(geolocation.lines) > 0
    check &= round(Int,minimum(geolocation.longitude)) == -28
    check &= round(Int,maximum(geolocation.longitude)) == -27
    check &= round(Int,minimum(geolocation.latitude)) == 38
    
    check &= round(Int,minimum(geolocation.height)) == 0
    check &= round(Int,minimum(geolocation.elevation_angle)) == 37


    if !check
        println("Error in Sentinel1GeolocationGridTest")
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
    metaDict = SARProcessing.read_xml_as_dict(SENTINEL1_SLC_METADATA_TEST_FILE)
    bursts = SARProcessing.get_sentinel1_burst_information(metaDict);

    ## Assert
    check = length(bursts) == 9
    check &= isapprox(bursts[1].doppler_centroid.t0,0.00534423320003329; atol = 0.000000001)
    check &= isapprox(bursts[8].doppler_centroid.t0,0.005342927742124565; atol = 0.000000001)
    check &= length(bursts[1].azimuth_fm_rate.polynomial) == 3
    check &= bursts[3].sensing_time == DateTime(2022,09,18,07,49,28,166)   
    check &= isapprox(bursts[2].azimuth_fm_rate.t0 ,0.006018535512387027; atol = 0.000001) 

    # add stuff later

    if !check
        println("Error in Sentinel1BurstInformation")
    end
    return check
end

@testset "Sentinel1Metadata.jl" begin
    ####### actual tests ###############
    @test readXmlTest()
    @test MetaDataSentinel1Test()
    @test HeaderTest()
    @test Sentinel1GeolocationGridTest()
    @test ImageInformationTest()
    @test productInformationTest()
    @test BurstTest()
end