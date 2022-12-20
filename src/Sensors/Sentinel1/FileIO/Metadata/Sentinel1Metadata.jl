include("MetadataUtil.jl")

""""
Structures and constructors for the metadata. 
    MetaDataSentinel1
        - ::Sentinel1Header
        - ::Sentinel1ProductInformation
        - ::Sentinel1ImageInformation
        - ::Sentinel1SwathTiming
        - ::Vector{Sentinel1BurstInformation}
        - ::GeolocationGrid
"""
#currently, it is called "MetaDataSentinel1" to allow for a later abstract structures with MetaData for different satellites.



##################
### Structures
##################
##base.@kwdef not a part of stable julia. Probably will be future release(?)
"""
Sentinel1Header

returns structure of Sentinel1Header from metadata in .xml
"""
Base.@kwdef struct Sentinel1Header
    mission_id::String
    product_type::String
    polarisation::String
    mission_data_take_id::Int
    swath::Int
    mode::String
    start_time::DateTime
    stop_time::DateTime
    acquisition_time::Millisecond
    absolute_orbit_number::Int
    image_number::String
end


"""
Sentinel1ProductInformation

returns structure of product information 
"""
Base.@kwdef struct Sentinel1ProductInformation
    pass::String
    timeliness_category::String
    platform_heading::Float64
    projection::String
    range_sampling_rate::Float64
    radar_frequency::Float64
    azimuth_steering_rate::Float64
end



"""
Sentinel1ImageInformation

returns structure of Sentinel1ImageInformation from metadata in .xml
"""
Base.@kwdef struct Sentinel1ImageInformation
    range_pixel_spacing::Float64
    azimuth_frequency::Float64
    slant_range_time::Millisecond
    incidence_angle_mid_swath::Float64
    azimuth_pixel_spacing::Float64
    number_of_samples::Int
end

"""
Sentinel1SwathTiming

returns structure of Sentinel1SwathTiming from metadata in .xml
"""
Base.@kwdef struct Sentinel1SwathTiming
    lines_per_burst::Int64
    samples_per_burst::Int64
    burst_count::Int32
end




"""
Sentinel1DopplerCentroid

returns structure of Sentinel1DopplerCentroid from metadata in .xml
Sentinel1DopplerCentroid is calculated for each burst, and is therefore saved in each burst
"""
Base.@kwdef struct Sentinel1DopplerCentroid
    dataDcPolynomial::Vector{Float64}
    dcT0::Float64
end




"""
Sentinel1AzimuthFmRate

returns structure of Sentinel1AzimuthFmRate from metadata in .xml
Sentinel1AzimuthFmRate is calculated for each burst, and is therefore saved in each burst
"""
Base.@kwdef struct Sentinel1AzimuthFmRate
    azimuthFmRatePolynomial::Vector{Float64}
    azimuthFmRateT0::Float64
end




"""
Sentinel1BurstInformation

returns structure of Sentinel1BurstInformation from metadata in .xml
Sentinel1BurstInformation contain information from Sentinel1DopplerCentroid and Sentinel1AzimuthFmRate
"""
Base.@kwdef struct Sentinel1BurstInformation
    burstNumber::Int32
    azimuthTime::DateTime
    sensingTime::DateTime
    azimuthAnxTime::Millisecond
    byteOffset::Int64
    firstValidSample::Vector{Int64}
    lastValidSample::Vector{Int64}
    burstId::Int64
    absoluteBurstId::Int64
    azimuthFmRates::Sentinel1AzimuthFmRate
    dopplerCentroid::Sentinel1DopplerCentroid
end



"""
GeolocationGrid

returns structure of GeolocationGrid from metadata in .xml
"""
Base.@kwdef struct GeolocationGrid
    lines::Vector{Int64}
    samples::Vector{Int64}
    latitude::Vector{Float64}
    longitude::Vector{Float64}
    azimuthTime::Vector{DateTime}
    slant_range_time::Vector{Millisecond}
    elevation_angle::Vector{Float64}
    incidenceAngle::Vector{Float64}
    height::Vector{Float64}
end



"""
MetaDataSentinel1:
    Metadata structure for the Sentinel-1 satellite for each burst in the swath.

    General metadata info is kept in the following structures:
        - Sentinel1Header
        - Sentinel1ProductInformation
        - Sentinel1ImageInformation
        - Sentinel1SwathTiming
        - GeolocationGrid
    Sentinel1BurstInformation specific Info is kept in 
        - Vector{Sentinel1BurstInformation}
   
Example:
    slcMetadata = MetaDataSentinel1(meta_dict)

    Input:
        meta_dict: xml file.

    can be accesed as, e.g., 
    slcMetadata.product.radar_frequency --> 5.40500045433435e9::Float64
    slcMetadata.header.swath --> 1::Int
    slcMetadata.header.mode --> "IW"::String
    slcMetadata.header.polarisation --> "VH"::String
"""
Base.@kwdef struct MetaDataSentinel1
    header::Sentinel1Header
    product::Sentinel1ProductInformation
    image::Sentinel1ImageInformation
    swath::Sentinel1SwathTiming
    bursts::Vector{Sentinel1BurstInformation}
    geolocation::GeolocationGrid
end



######################################################
##################### Constructors  ##################
######## Constructures for all the structures ########
######################################################


""""
Sentinel1Header

    Constucture for the Sentinel1Header structure. 

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1Header as a structure. Input in the header file:
        missionId: Mission identifier for this data set.
        productType: Product type for this data set.
        polarisation: Polarisation for this data set.
        missionDataTakeId: Mission data take identifier.
        swath: Swath identifier for this data set. This element identifies the swath that applies to all data contained within this data set. The swath identifier "EW" is used for products in which the 5 EW swaths have been merged. Likewise, "IW" is used for products in which the 3 IW swaths have been merged.
        mode: Sensor mode for this data set.
        start_time: Zero Doppler start time of the output image [UTC].
        stop_time: Zero Doppler stop time of the output image [UTC].
        aqusitionTime,
        absoluteOrbitNumber: Absolute orbit number at data set start time.
        imageNumber: Image number. For WV products the image number is used to distinguish between vignettes. For SM, IW and EW modes the image number is still used but refers instead to each swath and polarisation combination (known as the 'channel') of the data.

    Input:
        meta_dict[dict]: a dictionary of the metadata.

    output:
        Sentinel1Header[structure of Sentinel1Header]
    
"""
function Sentinel1Header(meta_dict)::Sentinel1Header
    missionId = meta_dict["product"]["adsHeader"]["missionId"]
    productType = meta_dict["product"]["adsHeader"]["productType"]
    polarisation = meta_dict["product"]["adsHeader"]["polarisation"]
    missionDataTakeId = meta_dict["product"]["adsHeader"]["missionDataTakeId"]
    swath = meta_dict["product"]["adsHeader"]["swath"]
    mode = meta_dict["product"]["adsHeader"]["mode"]
    start_time = meta_dict["product"]["adsHeader"]["startTime"]
    stop_time = meta_dict["product"]["adsHeader"]["stopTime"]
    absoluteOrbitNumber = meta_dict["product"]["adsHeader"]["absoluteOrbitNumber"]
    imageNumber = meta_dict["product"]["adsHeader"]["imageNumber"]


    stop_time = DateTime(stop_time[1:23])
    missionDataTakeId = parse(Int, missionDataTakeId)
    swath = parse(Int, swath[end])
    start_time = DateTime(start_time[1:23])
    absoluteOrbitNumber = parse(Int, absoluteOrbitNumber)

    acquisition_time = stop_time - start_time

    header = Sentinel1Header(missionId,
        productType,
        polarisation,
        missionDataTakeId,
        swath,
        mode,
        start_time,
        stop_time,
        acquisition_time,
        absoluteOrbitNumber,
        imageNumber)
    return header
end


""""
Sentinel1ProductInformation

    Constucture for the Sentinel1ProductInformation structure. 

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

    productinformation = Sentinel1ProductInformation(pass,
        timeliness_category,
        platform_heading,
        projection,
        range_sampling_rate,
        radar_frequency,
        azimuth_steering_rate)
    return productinformation
end




""""
Sentinel1ImageInformation

    Constucture for the Sentinel1ImageInformation structure. 

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1ImageInformation as a structure. Input in the Sentinel1ImageInformation file:
        range_pixel_spacing: Pixel spacing between range samples [m].
        azimuth_frequency: Azimuth line frequency of the output image [Hz]. This is the inverse of the azimuthTimeInterval.
        slant_range_time: Two-way slant range time to first sample [milli sec].
        incidence_angle_mid_swath: Incidence angle at mid swath [degrees].
        azimuth_pixel_spacing: Nominal pixel spacing between range lines [m].
        number_of_samples: Total number of samples in the output image (image width).

    Input:
        meta_dict[dict]: a dictionary of the metadata.

    output:
        Sentinel1ImageInformation[structure of Sentinel1ImageInformation]
    
"""
function Sentinel1ImageInformation(meta_dict)::Sentinel1ImageInformation
    imageinformations = meta_dict["product"]["imageAnnotation"]["imageInformation"]

    range_pixel_spacing = parse(Float64, imageinformations["rangePixelSpacing"])
    azimuth_frequency = parse(Float64, imageinformations["azimuthFrequency"])
    slant_range_time = Millisecond(round(Int,parse(Float64, imageinformations["slantRangeTime"])*1000))
    incidence_angle_mid_swath = parse(Float64, imageinformations["incidenceAngleMidSwath"])
    azimuth_pixel_spacing = parse(Float64, imageinformations["azimuthPixelSpacing"])
    number_of_samples = parse(Int, imageinformations["numberOfSamples"])

    imageinformations = Sentinel1ImageInformation(range_pixel_spacing,
        azimuth_frequency,
        slant_range_time,
        incidence_angle_mid_swath,
        azimuth_pixel_spacing,
        number_of_samples)
    return imageinformations
end


""""
Sentinel1SwathTiming

    Constucture for the Sentinel1SwathTiming structure. 

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1SwathTiming as a structure. 

    Input:
        meta_dict[dict]: a dictionary of the metadata.

    output:
        Sentinel1SwathTiming[structure of Sentinel1SwathTiming]
    
"""
function Sentinel1SwathTiming(meta_dict)::Sentinel1SwathTiming
    swathtiming = meta_dict["product"]["swathTiming"]

    lines_per_burst = parse(Int, swathtiming["linesPerBurst"])
    samples_per_burst = parse(Int, swathtiming["samplesPerBurst"])
    burst_count = parse(Int, swathtiming["burstList"][:count])

    swathtiming = Sentinel1SwathTiming(lines_per_burst,
        samples_per_burst,
        burst_count)
    return swathtiming
end


""""
GeolocationGrid

    Constucture for the GeolocationGrid structure. 

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the GeolocationGrid as a structure. Input in the GeolocationGrid file:
        lines: Reference image MDS line to which this geolocation grid point applies.
        samples,
        latitude: Geodetic latitude of grid point [degrees].
        longitude: Geodetic longitude of grid point [degrees].
        azimuthTime: Zero Doppler azimuth time to which grid point applies [UTC].
        slant_range_time: Two-way slant range time to grid point [milli sec].
        elevation_angle: Elevation angle to grid point [degrees].
        incidenceAngle: Incidence angle to grid point [degrees].
        height: Height of the grid point above sea level [m].

    Example:
        # accesing the geolocation data from the full metadata.
        xmlPath = "s1a-iw1-slc-vh-20220220t144146-20220220t144211-041998-050092-001.xml"
        Metadata1 = MetaDataSentinel1(xmlPath)
        geolocation = Metadata1.geolocation

        # accessing the geolocation directly from the xml.
        meta_dict = read_xml_as_dict(xmlPath)
        geolocation = GeolocationGrid(meta_dict)
        

    Input:
        meta_dict[dict]: a dictionary of the metadata.

    output:
        GeolocationGrid[structure of GeolocationGrid]
    
"""
function GeolocationGrid(meta_dict)::GeolocationGrid
    geolocation = meta_dict["product"]["geolocationGrid"]["geolocationGridPointList"]["geolocationGridPoint"]

    lines = [parse(Int, elem["line"]) for elem in geolocation] .+ 1
    samples = [parse(Int, elem["pixel"]) for elem in geolocation] .+ 1
    latitude = [parse(Float64, elem["latitude"]) for elem in geolocation]
    longitude = [parse(Float64, elem["longitude"]) for elem in geolocation]
    azimuthTime = [DateTime(elem["azimuthTime"][1:23]) for elem in geolocation]
    slant_range_time = [Millisecond(round(Int,parse(Float64, elem["slantRangeTime"])*1000)) for elem in geolocation]
    elevation_angle = [parse(Float64, elem["elevationAngle"]) for elem in geolocation]
    incidenceAngle = [parse(Float64, elem["incidenceAngle"]) for elem in geolocation]
    height = [parse(Float64, elem["height"]) for elem in geolocation]

    geolocationgrid = GeolocationGrid(lines,
        samples,
        latitude,
        longitude,
        azimuthTime,
        slant_range_time,
        elevation_angle,
        incidenceAngle,
        height)
    return geolocationgrid
end



""""
Sentinel1BurstInformation

    Constucture for the Sentinel1BurstInformation structure. 

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1BurstInformation specific data for a single burst as a structure. 
    The Sentinel1BurstInformation structure returns the following:
        burstNumber::Int64
        azimuthTime::DateTime : Zero Doppler azimuth time of the first line of this burst [UTC]. 
        sensingTime::DateTime : Sensing time of the first input line of this burst [UTC].
        azimuthAnxTime::Float64 : Zero Doppler azimuth time of the first line of this burst relative to the Ascending Node Crossing (ANX) time. [milli sec].
        byteOffset::Int64.:  Byte offset of this burst within the image MDS.
        firstValidSample::Vector{Int64}: An array of integers indicating the offset of the first valid image sample within each range line. This array contains count attribute integers, equal to the lines_per_burst field (i.e. one value per range line within the burst), separated by spaces. If a range line does not contain any valid image samples, the integer is set to -1.
        lastValidSample::Vector{Int64}: An array of integers indicating the offset of the last valid image sample within each range line. This array contains count attribute integers, equal to the lines_per_burst (i.e. one value per range line within the burst), separated by spaces. If a range line does not contain any valid image samples, the integer is set to -1.
        burstId::Int64
        absoluteBurstId::Int64
        fmTimesDiff::Vector{Millisecond}
        bestFmIndex::Int64
        azimuthFmRatePolynomial::Vector{Float64}
        azimuthFmRateT0::Float64
        numberOfDopplerCentroids::Int64
        burstTime::Millisecond
        burstMidTime::Millisecond
        dcTimeDifferences::Vector{Millisecond}
        bestDcIndex::Int64
        dataDcPolynomial::Vector{Float64}
        dcT0::Float64
        firstLineMosaic::Int64
    
    Input:
        meta_dict[dict]: a dictionary of the metadata.
        burstNumber[Int]: Integer value of burst number.


    output:
        Sentinel1BurstInformation[structure of Sentinel1BurstInformation]
    
"""
function Sentinel1BurstInformation(meta_dict,burstNumber::Int=1)::Sentinel1BurstInformation
    burst = meta_dict["product"]["swathTiming"]["burstList"]["burst"][burstNumber]

    azimuthTime = DateTime(burst["azimuthTime"][1:23])
    sensingTime = DateTime(burst["sensingTime"][1:23])
    azimuthAnxTime = Millisecond(round(Int,parse(Float64, burst["azimuthAnxTime"])*1000))
    byteOffset = parse.(Int,burst["byteOffset"])
    firstValidSample = parse.(Int,split(burst["firstValidSample"][""]))
    lastValidSample = parse.(Int,split(burst["lastValidSample"][""]))
    burstId = parse.(Int64,split(burst["burstId"][""]))[1]
    absoluteBurstId = parse.(Int,split(burst["burstId"][:absolute]))[1]

    #Sentinel1DopplerCentroid  for burst 
    lines_per_burst  = Sentinel1SwathTiming(meta_dict).lines_per_burst
    azimuth_frequency = Sentinel1ImageInformation(meta_dict).azimuth_frequency

    half_burst_period = Millisecond(floor(Int,lines_per_burst / (2 * (azimuth_frequency*0.001) )))
    burst_mid_time = half_burst_period + azimuthTime


    dopplerCentroid = Sentinel1DopplerCentroid(meta_dict,burst_mid_time)

    #Sentinel1AzimuthFmRate for burst 
   
    azimuthFmRates = Sentinel1AzimuthFmRate(meta_dict,burst_mid_time)



    burst = Sentinel1BurstInformation(burstNumber, 
                        azimuthTime,
                        sensingTime,
                        azimuthAnxTime,
                        byteOffset,
                        firstValidSample,
                        lastValidSample,
                        burstId,
                        absoluteBurstId,
                        azimuthFmRates,
                        dopplerCentroid
                        )
    return burst
end




""""
Sentinel1DopplerCentroid

    Constucture for the Sentinel1DopplerCentroid structure. 

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1DopplerCentroid data for a single burst as a structure. 
    The Sentinel1DopplerCentroid structure returns the following:
        dataDcPolynomial::Vector{Float64}
        dcT0::Float64
    
    Input:
        meta_dict[dict]: a dictionary of the metadata.
        burst.azimuthTime
        header.start_time
        swathtiming.lines_per_burst
        imageInformation.azimuth_frequency


    output:
        Sentinel1DopplerCentroid[structure of Sentinel1DopplerCentroid]

    Note:
        [ ] Perhaps change input vars from strutures to the specific values. -- Does the current implementaion use extra time?
        [ ] What is needed? Maybe, e.g., dataDcPolynomial is redudant in the later processing. Could be deleted.
"""
function Sentinel1DopplerCentroid(meta_dict,
                        burst_mid_time::Dates.DateTime)::Sentinel1DopplerCentroid
    dopplerCentroids = meta_dict["product"]["dopplerCentroid"]["dcEstimateList"]["dcEstimate"]

    
    dcTimeDifferences = [ abs.(DateTime(centroid["azimuthTime"][1:23]) -burst_mid_time ) for centroid in dopplerCentroids]
    bestDcIndex = argmin(dcTimeDifferences)
    
    dataDcPolynomial = [parse(Float64, param) for param in split(dopplerCentroids[bestDcIndex]["dataDcPolynomial"][""])] 
    dcT0 = parse(Float64, dopplerCentroids[bestDcIndex]["t0"])

    dopplerCentroid = Sentinel1DopplerCentroid(
                                        dataDcPolynomial,
                                        dcT0)
    return dopplerCentroid
end


""""
Sentinel1AzimuthFmRate

    Constucture for the Sentinel1AzimuthFmRate structure. 

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1AzimuthFmRate data for a single burst as a structure. 
    The Sentinel1AzimuthFmRate structure returns the following:
            burstNumber::Int64
            fmTimesDiff::Vector{Millisecond}
            bestFmIndex::Int64
            azimuthFmRatePolynomial::Vector{Float64}
            azimuthFmRateT0::Float64

    The burstNumber can be used as a key to other burst specific strucutres, e.g., the Sentinel1BurstInformation data.

    
    Input:
        meta_dict[dict]: a dictionary of the metadata.
        dopplerCentroid[Sentinel1DopplerCentroid]: Sentinel1DopplerCentroid Structure


    output:
        azimuthFmRate[structure of Sentinel1AzimuthFmRate]

    Note:
        [ ] Perhaps change input vars from strutures to the specific values. -- Does the current implementaion use extra time?
        [ ] What is needed? Maybe, e.g., azimuthFmRatePolynomial is redudant in the later processing. Could then be deleted.
    
"""
function Sentinel1AzimuthFmRate(meta_dict,
                        burst_mid_time::Dates.DateTime)::Sentinel1AzimuthFmRate
    azimuthFmRateList = meta_dict["product"]["generalAnnotation"]["azimuthFmRateList"]["azimuthFmRate"]

    fmTimesDiff = [abs.(DateTime(azimuthFmRate["azimuthTime"][1:23])-burst_mid_time) for azimuthFmRate in azimuthFmRateList]
    bestFmIndex = argmin(fmTimesDiff)

    azimuthFmRatePolynomial = [parse(Float64, param) for param in split(azimuthFmRateList[bestFmIndex]["azimuthFmRatePolynomial"][""])]
    azimuthFmRateT0 = parse(Float64, azimuthFmRateList[bestFmIndex]["t0"])

    azimuthfmrate = Sentinel1AzimuthFmRate(
                                azimuthFmRatePolynomial,
                                azimuthFmRateT0,
                                )
    return azimuthfmrate
end




function get_sentinel1_burst_information(meta_dict)
    numberOfBurst = size(meta_dict["product"]["swathTiming"]["burstList"]["burst"])[1]
    return [Sentinel1BurstInformation(meta_dict,number) for number in 1:1:numberOfBurst ]
end


""""
MetaDataSentinel1

    Constucture for the MetaDataSentinel1 structure. 
    It takes a Sentinel-1 single swath metafile in .xml format and constructs the metadata structure using the individual sub-structures in the metadata.
    The individual sub-structures in the metadata are:
    - Sentinel1Header
    - Sentinel1ProductInformation
    - Sentinel1ImageInformation
    - Sentinel1SwathTiming
    - Sentinel1BurstInformation
    - GeolocationGrid

    Input:
        xmlFile[string]: path of swath specific metadata in xml.format.

    output:
        MetaDataSentinel1[structure of MetaDataSentinel1]: Strucutre with all Sentinel-1 metadata for a swath.
    

    Example:

    Getting the azimuthFmRateT0 for the 5th burst:
        metadata = MetaDataSentinel1(annotation.xml)
        metadata.bursts.azimuthFmRate[5].azimuthFmRateT0
        

"""
function MetaDataSentinel1(xmlFile::String)::MetaDataSentinel1

    meta_dict = read_xml_as_dict(xmlFile)
    metadata = MetaDataSentinel1(Sentinel1Header(meta_dict),
                        Sentinel1ProductInformation(meta_dict),
                        Sentinel1ImageInformation(meta_dict),
                        Sentinel1SwathTiming(meta_dict),
                        get_sentinel1_burst_information(meta_dict),
                        GeolocationGrid(meta_dict)
                        )

    return metadata
end




