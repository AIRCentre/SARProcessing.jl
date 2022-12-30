include("MetadataUtil.jl")


######################################################
##################### Constructors  ##################
######## Constructors for all the structures ########
######################################################
function get_reference_time(meta_dict)::DateTime
    start_time = meta_dict["product"]["adsHeader"]["startTime"]
    reference_time = DateTime(start_time[1:19])
    return reference_time
end

function parse_delta_time(time_string::String,reference_time::DateTime)
    milliseconds = Dates.value( DateTime(time_string[1:23]) - reference_time) 
    microseconds = parse(Int, time_string[24:26])
    return milliseconds /1000.0 + microseconds*  10^-6
end

""""
Sentinel1Header

    Constructors for the Sentinel1Header structure. 

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1Header as a structure. Input in the header file:
        missionId: Mission identifier for this data set.
        productType: Product type for this data set.
        polarisation: Polarisation for this data set.
        mission_data_take_id: Mission data take identifier.
        swath: Swath identifier for this data set. This element identifies the swath that applies to all data contained within this data set. The swath identifier "EW" is used for products in which the 5 EW swaths have been merged. Likewise, "IW" is used for products in which the 3 IW swaths have been merged.
        mode: Sensor mode for this data set.
        start_time: Zero Doppler start time of the output image [UTC].
        stop_time: Zero Doppler stop time of the output image [UTC].
        absolute_orbit_number: Absolute orbit number at data set start time.
        image_number: Image number. For WV products the image number is used to distinguish between vignettes. For SM, IW and EW modes the image number is still used but refers instead to each swath and polarisation combination (known as the 'channel') of the data.

    Input:
        meta_dict[dict]: a dictionary of the metadata.

    output:
        Sentinel1Header[structure of Sentinel1Header]
    
"""
function Sentinel1Header(meta_dict, reference_time::DateTime)::Sentinel1Header
    missionId = meta_dict["product"]["adsHeader"]["missionId"]
    productType = meta_dict["product"]["adsHeader"]["productType"]
    polarisation = meta_dict["product"]["adsHeader"]["polarisation"]
    mission_data_take_id = meta_dict["product"]["adsHeader"]["missionDataTakeId"]
    swath = meta_dict["product"]["adsHeader"]["swath"]
    mode = meta_dict["product"]["adsHeader"]["mode"]
    start_time = meta_dict["product"]["adsHeader"]["startTime"]
    stop_time = meta_dict["product"]["adsHeader"]["stopTime"]
    absolute_orbit_number = meta_dict["product"]["adsHeader"]["absoluteOrbitNumber"]
    image_number = meta_dict["product"]["adsHeader"]["imageNumber"]

    polarisation = parse(Polarisation,polarisation)
    stop_time = parse_delta_time(stop_time,reference_time)
    mission_data_take_id = parse(Int, mission_data_take_id)
    swath = parse(Int, swath[end])
    start_time = parse_delta_time(start_time,reference_time)
    absolute_orbit_number = parse(Int, absolute_orbit_number)


    header = Sentinel1Header(missionId,
        productType,
        polarisation,
        mission_data_take_id,
        swath,
        mode,
        start_time,
        stop_time,
        absolute_orbit_number,
        image_number)
    return header
end


""""
Sentinel1ProductInformation

    Constructors for the Sentinel1ProductInformation structure. 

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1ProductInformation as a structure. Sentinel1ProductInformation file:
        pass: Direction of the orbit (ascending, descending)
        timeliness_category: Timeliness category under which the product was produced, i.e. time frame from the data acquisition
        platform_heading: Platform heading relative to North [degrees].
        projection: Projection of the image, either slant range or ground range.
        range_sampling_rate: Range sample rate [Hz]
        radar_frequency: Radar (carrier) frequency [Hz]
        azimuth_steering_rate: Azimuth steering rate for IW and EW modes [degrees/s].

    Input:
        meta_dict[dict]: a dictionary of the metadata.

    output:
        Sentinel1ProductInformation[structure of Sentinel1ProductInformation]
    
"""
function Sentinel1ProductInformation(meta_dict)::Sentinel1ProductInformation
    pass = meta_dict["product"]["generalAnnotation"]["productInformation"]["pass"]
    timeliness_category = meta_dict["product"]["generalAnnotation"]["productInformation"]["timelinessCategory"]
    platform_heading = meta_dict["product"]["generalAnnotation"]["productInformation"]["platformHeading"]
    projection = meta_dict["product"]["generalAnnotation"]["productInformation"]["projection"]
    range_sampling_rate = meta_dict["product"]["generalAnnotation"]["productInformation"]["rangeSamplingRate"]
    radar_frequency = meta_dict["product"]["generalAnnotation"]["productInformation"]["radarFrequency"]
    azimuth_steering_rate = meta_dict["product"]["generalAnnotation"]["productInformation"]["azimuthSteeringRate"]

    platform_heading = parse(Float64,platform_heading)
    range_sampling_rate = parse(Float64, range_sampling_rate)
    radar_frequency = parse(Float64, radar_frequency)
    azimuth_steering_rate = parse(Float64, azimuth_steering_rate)

    return Sentinel1ProductInformation(pass,
        timeliness_category,
        platform_heading,
        projection,
        range_sampling_rate,
        radar_frequency,
        azimuth_steering_rate)
end




""""
Sentinel1ImageInformation

    Constructor for the Sentinel1ImageInformation structure. 

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1ImageInformation as a structure. Input in the Sentinel1ImageInformation file:
        range_pixel_spacing: Pixel spacing between range samples [m].
        azimuth_frequency: Azimuth line frequency of the output image [Hz]. This is the inverse of the azimuth_timeInterval.
        slant_range_time_seconds: Two-way slant range time to first sample [sec].
        incidence_angle_mid_swath: Incidence angle at mid swath [degrees].
        azimuth_pixel_spacing: Nominal pixel spacing between range lines [m].
        number_of_samples: Total number of samples in the output image (image width).

    Input:
        meta_dict[dict]: a dictionary of the metadata.

    output:
        Sentinel1ImageInformation[structure of Sentinel1ImageInformation]
    
"""
function Sentinel1ImageInformation(meta_dict)::Sentinel1ImageInformation
    image_informations = meta_dict["product"]["imageAnnotation"]["imageInformation"]

    range_pixel_spacing = parse(Float64, image_informations["rangePixelSpacing"])
    azimuth_frequency = parse(Float64, image_informations["azimuthFrequency"])
    slant_range_time_seconds = parse(Float64, image_informations["slantRangeTime"])
    incidence_angle_mid_swath = parse(Float64, image_informations["incidenceAngleMidSwath"])
    azimuth_pixel_spacing = parse(Float64, image_informations["azimuthPixelSpacing"])
    number_of_samples = parse(Int, image_informations["numberOfSamples"])

    image_informations = Sentinel1ImageInformation(range_pixel_spacing,
        azimuth_frequency,
        slant_range_time_seconds,
        incidence_angle_mid_swath,
        azimuth_pixel_spacing,
        number_of_samples)
    return image_informations
end


""""
Sentinel1SwathTiming

    Constructors for the Sentinel1SwathTiming structure. 

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1SwathTiming as a structure. 

    Input:
        meta_dict[dict]: a dictionary of the metadata.

    output:
        Sentinel1SwathTiming[structure of Sentinel1SwathTiming]
    
"""
function Sentinel1SwathTiming(meta_dict)::Sentinel1SwathTiming
    swath_timing = meta_dict["product"]["swathTiming"]

    lines_per_burst = parse(Int, swath_timing["linesPerBurst"])
    samples_per_burst = parse(Int, swath_timing["samplesPerBurst"])
    burst_count = parse(Int, swath_timing["burstList"][:count])

    swath_timing = Sentinel1SwathTiming(lines_per_burst,
        samples_per_burst,
        burst_count)
    return swath_timing
end


""""
Sentinel1GeolocationGrid

    Constructors for the Sentinel1GeolocationGrid structure. 

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1GeolocationGrid as a structure. Input in the Sentinel1GeolocationGrid file:
        lines: Reference image MDS line to which this geolocation grid point applies.
        samples,
        latitude: Geodetic latitude of grid point [degrees].
        longitude: Geodetic longitude of grid point [degrees].
        azimuth_time: Zero Doppler azimuth time to which grid point applies [UTC].
        slant_range_time_seconds: Two-way slant range time to grid point [milli sec].
        elevation_angle: Elevation angle to grid point [degrees].
        incidence_angle: Incidence angle to grid point [degrees].
        height: Height of the grid point above sea level [m].

    Example:
        # accesing the geolocation data from the full metadata.
        xmlPath = "s1a-iw1-slc-vh-20220220t144146-20220220t144211-041998-050092-001.xml"
        Metadata1 = Sentinel1MetaData(xmlPath)
        geolocation = Metadata1.geolocation

        # accessing the geolocation directly from the xml.
        meta_dict = read_xml_as_dict(xmlPath)
        geolocation = Sentinel1GeolocationGrid(meta_dict)
        

    Input:
        meta_dict[dict]: a dictionary of the metadata.

    output:
        Sentinel1GeolocationGrid[structure of Sentinel1GeolocationGrid]
    
"""
function Sentinel1GeolocationGrid(meta_dict,reference_time::DateTime )::Sentinel1GeolocationGrid
    geolocation = meta_dict["product"]["geolocationGrid"]["geolocationGridPointList"]["geolocationGridPoint"]

    lines = [parse(Int, elem["line"]) for elem in geolocation] .+ 1
    samples = [parse(Int, elem["pixel"]) for elem in geolocation] .+ 1
    latitude = [parse(Float64, elem["latitude"]) for elem in geolocation]
    longitude = [parse(Float64, elem["longitude"]) for elem in geolocation]
    azimuth_time = [parse_delta_time(elem["azimuthTime"],reference_time) for elem in geolocation]
    slant_range_time_seconds = [parse(Float64, elem["slantRangeTime"]) for elem in geolocation]
    elevation_angle = [parse(Float64, elem["elevationAngle"]) for elem in geolocation]
    incidence_angle = [parse(Float64, elem["incidenceAngle"]) for elem in geolocation]
    height = [parse(Float64, elem["height"]) for elem in geolocation]

    geolocation_grid = Sentinel1GeolocationGrid(lines,
        samples,
        latitude,
        longitude,
        azimuth_time,
        slant_range_time_seconds,
        elevation_angle,
        incidence_angle,
        height)
    return geolocation_grid
end



""""
Sentinel1BurstInformation

    Constructors for the Sentinel1BurstInformation structure. 

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1BurstInformation specific data for a single burst as a structure. 
    
    Input:
        meta_dict[dict]: a dictionary of the metadata.burst_number
[Int]: Integer value of burst number.


    output:
        Sentinel1BurstInformation[structure of Sentinel1BurstInformation]
    
"""
function Sentinel1BurstInformation(meta_dict,burst_number::Int, reference_time::DateTime)::Sentinel1BurstInformation
    burst = meta_dict["product"]["swathTiming"]["burstList"]["burst"][burst_number]

    azimuth_time = parse_delta_time(burst["azimuthTime"],reference_time)
    sensing_time = parse_delta_time(burst["sensingTime"],reference_time)
    azimuth_anx_time = Millisecond(round(Int,parse(Float64, burst["azimuthAnxTime"])*1000))
    byte_offset = parse.(Int,burst["byteOffset"])
    first_valid_sample = parse.(Int,split(burst["firstValidSample"][""]))
    last_valid_sample = parse.(Int,split(burst["lastValidSample"][""]))
    burst_id = parse.(Int64,split(burst["burstId"][""]))[1]
    absolute_burst_id = parse.(Int,split(burst["burstId"][:absolute]))[1]

    #Sentinel1DopplerCentroid  for burst 
    lines_per_burst  = Sentinel1SwathTiming(meta_dict).lines_per_burst
    azimuth_frequency = Sentinel1ImageInformation(meta_dict).azimuth_frequency

    half_burst_period = lines_per_burst / (2 * azimuth_frequency )
    burst_mid_time = half_burst_period + azimuth_time


    doppler_centroid = Sentinel1DopplerCentroid(meta_dict,burst_mid_time,reference_time)

    #Sentinel1AzimuthFmRate for burst 
   
    azimuth_fm_rate = Sentinel1AzimuthFmRate(meta_dict,burst_mid_time,reference_time)



    burst = Sentinel1BurstInformation(burst_number, 
                        azimuth_time,
                        sensing_time,
                        azimuth_anx_time,
                        byte_offset,
                        first_valid_sample,
                        last_valid_sample,
                        burst_id,
                        absolute_burst_id,
                        azimuth_fm_rate,
                        doppler_centroid
                        )
    return burst
end




""""
Sentinel1DopplerCentroid

    Constructors for the Sentinel1DopplerCentroid structure. 

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1DopplerCentroid data for a single burst as a structure. 

    Note:
        [ ] Perhaps change input vars from strutures to the specific values. -- Does the current implementaion use extra time?
        [ ] What is needed? Maybe, e.g., polynomial is redudant in the later processing. Could be deleted.
"""
function Sentinel1DopplerCentroid(meta_dict,
                        burst_mid_time::Float64, reference_time::DateTime)::Sentinel1DopplerCentroid
    doppler_centroids = meta_dict["product"]["dopplerCentroid"]["dcEstimateList"]["dcEstimate"]

    
    dc_time_differences = [ abs.(parse_delta_time(centroid["azimuthTime"],reference_time) -burst_mid_time ) for centroid in doppler_centroids]
    best_index = argmin(dc_time_differences)
    
    polynomial = [parse(Float64, param) for param in split(doppler_centroids[best_index]["dataDcPolynomial"][""])] 
    t0 = parse(Float64, doppler_centroids[best_index]["t0"])

    doppler_centroid = Sentinel1DopplerCentroid(
                                        polynomial,
                                        t0)
    return doppler_centroid
end


""""
Sentinel1AzimuthFmRate

    Constructors for the Sentinel1AzimuthFmRate structure. 

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1AzimuthFmRate data for a single burst as a structure. 

    Note:
        [ ] Perhaps change input vars from strutures to the specific values. -- Does the current implementaion use extra time?
        [ ] What is needed? Maybe, e.g., polynomial is redudant in the later processing. Could then be deleted.
    
"""
function Sentinel1AzimuthFmRate(meta_dict,
        burst_mid_time::Float64, reference_time::DateTime)::Sentinel1AzimuthFmRate
    azimuthFmRateList = meta_dict["product"]["generalAnnotation"]["azimuthFmRateList"]["azimuthFmRate"]

    fm_times_diff = [abs.(parse_delta_time(azimuthFmRate["azimuthTime"],reference_time)-burst_mid_time) for azimuthFmRate in azimuthFmRateList]
    best_index = argmin(fm_times_diff)

    polynomial = [parse(Float64, param) for param in split(azimuthFmRateList[best_index]["azimuthFmRatePolynomial"][""])]
    t0 = parse(Float64, azimuthFmRateList[best_index]["t0"])

    azimuth_fm_rate = Sentinel1AzimuthFmRate(
                                polynomial,
                                t0,
                                )
    return azimuth_fm_rate
end




function get_sentinel1_burst_information(meta_dict, reference_time::DateTime)
    number_of_burst = size(meta_dict["product"]["swathTiming"]["burstList"]["burst"])[1]
    return [Sentinel1BurstInformation(meta_dict,number,reference_time) for number in 1:1:number_of_burst ]
end


""""
Sentinel1MetaData

    Constructors for the Sentinel1MetaData structure. 
    It takes a Sentinel-1 single swath metafile in .xml format and constructs the metadata structure using the individual sub-structures in the metadata.
    The individual sub-structures in the metadata are:
    - Sentinel1Header
    - Sentinel1ProductInformation
    - Sentinel1ImageInformation
    - Sentinel1SwathTiming
    - Sentinel1BurstInformation
    - Sentinel1GeolocationGrid

    Input:
        xmlFile[string]: path of swath specific metadata in xml.format.

    output:
        Sentinel1MetaData[structure of Sentinel1MetaData]: Structure with all Sentinel-1 metadata for a swath.
    

    Example:

    Getting the t0 for the 5th burst:
        metadata = Sentinel1MetaData(annotation.xml)
        metadata.bursts.azimuthFmRate[5].t0
        

"""
function Sentinel1MetaData(xmlFile::String)::Sentinel1MetaData

    meta_dict = read_xml_as_dict(xmlFile)

    reference_time = get_reference_time(meta_dict)

    metadata = Sentinel1MetaData(reference_time,
                        Sentinel1Header(meta_dict,reference_time),
                        Sentinel1ProductInformation(meta_dict),
                        Sentinel1ImageInformation(meta_dict),
                        Sentinel1SwathTiming(meta_dict),
                        get_sentinel1_burst_information(meta_dict,reference_time),
                        Sentinel1GeolocationGrid(meta_dict,reference_time)
                        )

    return metadata
end




