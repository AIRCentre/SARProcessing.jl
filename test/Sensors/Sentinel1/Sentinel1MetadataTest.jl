"""
unit tests for the sentinel-1 metadata

    test
        1)Sentinel1MetaData
        2)loading data 
        3)the different sub structures.
    
"""


#############################################
########### test for Sentinel1MetaData ###########
#############################################

function metadata_sentinel1_test()
    slcMetadata = SARProcessing.Sentinel1MetaData(SENTINEL1_SLC_METADATA_TEST_FILE)
    checkStructures = isdefined(slcMetadata, :header) && isdefined(slcMetadata, :product) && isdefined(slcMetadata, :image) && isdefined(slcMetadata, :swath) && isdefined(slcMetadata, :bursts) && isdefined(slcMetadata, :geolocation)
    if !checkStructures
        println("Error in metadata_sentinel1_test")
    end
    return checkStructures
end


#############################################
########### test for loading data ###########
#############################################



function read_xml_test()
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
        meta_dict = SARProcessing.read_xml_as_dict(SENTINEL1_SLC_METADATA_TEST_FILE)
        ## Assert
        readXMLcheck = !isnothing(meta_dict )
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
### excluding the Sentinel1MetaData struct #######
#############################################



function header_test()
    meta_dict = SARProcessing.read_xml_as_dict(SENTINEL1_SLC_METADATA_TEST_FILE)
    reference_time = SARProcessing.get_reference_time(meta_dict)

    header = SARProcessing.Sentinel1Header(meta_dict,reference_time)
    #testing if data exists in header
    checkTimes = !isnothing(header.start_time)
    checkTypes = typeof(header.start_time) == Float64 && typeof(header.stop_time) == Float64
    check = checkTimes && checkTypes
    if !check
        println("Error in Sentinel1Header")
        println("Start time ", header.start_time)
        println("Stop time: ", header.stop_time)
    end
    return check
end


function productInformationTest()

    meta_dict = SARProcessing.read_xml_as_dict(SENTINEL1_SLC_METADATA_TEST_FILE)
    product = SARProcessing.Sentinel1ProductInformation(meta_dict)
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


function sentinel1_image_information_test()

    meta_dict = SARProcessing.read_xml_as_dict(SENTINEL1_SLC_METADATA_TEST_FILE)
    image_info = SARProcessing.Sentinel1ImageInformation(meta_dict)
    ## Assert
    check = round(Int,image_info.azimuth_frequency) == 486 #frequency should be around 486.4 Hz for the Sentinel-1 
    check &= image_info.number_of_samples == 24203 
    check &= round(Int,image_info.azimuth_pixel_spacing) ==14 

    if !check
        println("Error in Image data")
    end
    return check
end



function sentinel1_geolocation_grid_test()

    meta_dict = SARProcessing.read_xml_as_dict(SENTINEL1_SLC_METADATA_TEST_FILE)
    reference_time = SARProcessing.get_reference_time(meta_dict)
    geolocation = SARProcessing.Sentinel1GeolocationGrid(meta_dict,reference_time);
    ## Assert
 
    check = length(geolocation.lines)==210
    check &= minimum(geolocation.lines) > 0
    check &= round(Int,minimum(geolocation.longitude)) == -28
    check &= round(Int,maximum(geolocation.longitude)) == -27
    check &= round(Int,minimum(geolocation.latitude)) == 38
    
    check &= round(Int,minimum(geolocation.height)) == 0
    check &= round(Int,minimum(geolocation.elevation_angle)) == 37


    if !check
        println("Error in sentinel1_geolocation_grid_test")
        println(checkGeolocation1)
        println(checkGeolocation2)
        println(checkGeolocation3)
        println(checkGeolocation4)
        println(checkGeolocation5)        
    end
    return check
end


function sentinel1_burst_test()
    #Action
    meta_dict = SARProcessing.read_xml_as_dict(SENTINEL1_SLC_METADATA_TEST_FILE)
    reference_time = SARProcessing.get_reference_time(meta_dict)
    bursts = SARProcessing.get_sentinel1_burst_information(meta_dict,reference_time);

    ## Assert
    check = length(bursts) == 9
    check &= isapprox(bursts[1].doppler_centroid.t0,0.00534423320003329; atol = 0.000000001)
    check &= isapprox(bursts[8].doppler_centroid.t0,0.005342927742124565; atol = 0.000000001)
    check &= length(bursts[1].azimuth_fm_rate.polynomial) == 3
    sensing_time = reference_time + Millisecond(round(Int,bursts[3].sensing_time *1000))
    check &= sensing_time == DateTime(2022,09,18,07,49,28,166)   
    check &= isapprox(bursts[2].azimuth_fm_rate.t0 ,0.006018535512387027; atol = 0.000001) 
    check &= all([bursts[i].azimuth_time < bursts[i+1].azimuth_time for i in 1:length(bursts)-1])

    # add stuff later

    if !check
        println("Error in Sentinel1BurstInformation")
        println("sensing_time: ", sensing_time)
        println("bursts[3].sensing_time: ", bursts[3].sensing_time)
        println("reference_time ", reference_time)
    end
    return check
end

@testset "Sentinel1Metadata.jl" begin
    ####### actual tests ###############
    @test read_xml_test()
    @test metadata_sentinel1_test()
    @test header_test()
    @test sentinel1_geolocation_grid_test()
    @test sentinel1_image_information_test()
    @test productInformationTest()
    @test sentinel1_burst_test()
end