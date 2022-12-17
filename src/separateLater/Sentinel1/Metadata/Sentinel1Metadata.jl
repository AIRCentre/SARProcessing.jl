include("MetadataUtil.jl")

""""
Structures and constructures for the metadata. 
    MetaDataSentinel1
        - ::Header
        - ::ProductInformation
        - ::ImageInformation
        - ::SwathTiming
        - ::BurstsInfo
        - ::GeolocationGrid
"""
#currently, it is called "MetaDataSentinel1" to allow for a later abstract structures with MetaData for different satellites.



##################
### Structures
##################
##base.@kwdef not a part of stable julia. Probably will be future release(?)
"""
Header

returns structure of Header from metadata in .xml
"""
Base.@kwdef struct Header
    missionId::String
    productType::String
    polarisation::String
    missionDataTakeId::Int
    swath::Int
    mode::String
    startTime::DateTime
    stopTime::DateTime
    aqusitionTime::Millisecond
    absoluteOrbitNumber::Int
    imageNumber::String
end


"""
ProductInformation

returns structure of product information 
"""
Base.@kwdef struct ProductInformation
    pass::String
    timelinessCategory::String
    platformHeading::Float64
    projection::String
    rangeSamplingRate::Float64
    radarFrequency::Float64
    azimuthSteeringRate::Float64
end



"""
ImageInformation

returns structure of ImageInformation from metadata in .xml
"""
Base.@kwdef struct ImageInformation
    rangePixelSpacing::Float64
    azimuthFrequency::Float64
    slantRangeTime::Millisecond
    incidenceAngleMidSwath::Float64
    azimuthPixelSpacing::Float64
    numberOfSamples::Int
end

"""
SwathTiming

returns structure of SwathTiming from metadata in .xml
"""
Base.@kwdef struct SwathTiming
    linesPerBurst::Int64
    samplesPerBurst::Int64
    burstCount::Int32
end




"""
DopplerCentroid

returns structure of DopplerCentroid from metadata in .xml
DopplerCentroid is calculated for each burst, and is therefore saved in each burst
"""
Base.@kwdef struct DopplerCentroid
    numberOfDopplerCentroids::Int64
    burstTime::Millisecond
    burstMidTime::Millisecond
    dcTimeDifferences::Vector{Millisecond}
    bestDcIndex::Int64
    dataDcPolynomial::Vector{Float64}
    dcT0::Float64
    firstLineMosaic::Int64
end




"""
AzimuthFmRate

returns structure of AzimuthFmRate from metadata in .xml
AzimuthFmRate is calculated for each burst, and is therefore saved in each burst
"""
Base.@kwdef struct AzimuthFmRate
    fmTimesDiff::Vector{Millisecond}
    bestFmIndex::Int64
    azimuthFmRatePolynomial::Vector{Float64}
    azimuthFmRateT0::Float64
end




"""
Burst

returns structure of Burst from metadata in .xml
Burst contain information from DopplerCentroid and AzimuthFmRate
"""
Base.@kwdef struct Burst
    burstNumber::Int32
    azimuthTime::DateTime
    sensingTime::DateTime
    azimuthAnxTime::Millisecond
    byteOffset::Int64
    firstValidSample::Vector{Int64}
    lastValidSample::Vector{Int64}
    burstId::Int64
    absoluteBurstId::Int64
    azimuthFmRates::AzimuthFmRate
    dopplerCentroid::DopplerCentroid
end




"""
BurstsInfo

Returns a structure, BurstsInfo, containing info of each burst. For each bust, the following is saved in a Vector:
    - Burst: Structure of Burst.
"""
Base.@kwdef struct BurstsInfo
    numberOfBurst::Int32
    bursts::Vector{Burst}
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
    slantRangeTime::Vector{Millisecond}
    elevationAngle::Vector{Float64}
    incidenceAngle::Vector{Float64}
    height::Vector{Float64}
end



"""
MetaDataSentinel1:
    Metadata structure for the Sentinel-1 satellite for each burst in the swath.

    General metadata info is kept in the following structures:
        - Header
        - ProductInformation
        - ImageInformation
        - SwathTiming
        - GeolocationGrid
    Burst specific Info is kept in 
        - BurstsInfo
    Where BurstsInfo is a structure:
        numberOfBurst::Int64
        bursts::Vector{Burst}
        
Example:
    slcMetadata = MetaDataSentinel1(metaDict)

    Input:
        metaDict: xml file.

    can be accesed as, e.g., 
    slcMetadata.product.radarFrequency --> 5.40500045433435e9::Float64
    slcMetadata.header.swath --> 1::Int
    slcMetadata.header.mode --> "IW"::String
    slcMetadata.header.polarisation --> "VH"::String
"""
Base.@kwdef struct MetaDataSentinel1
    header::Header
    product::ProductInformation
    image::ImageInformation
    swath::SwathTiming
    burstsInfo::BurstsInfo
    geolocation::GeolocationGrid
end



######################################################
##################### Constructors  ##################
######## Constructures for all the structures ########
######################################################


""""
Header

    Constucture for the Header structure. 

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the Header as a structure. Input in the header file:
        missionId: Mission identifier for this data set.
        productType: Product type for this data set.
        polarisation: Polarisation for this data set.
        missionDataTakeId: Mission data take identifier.
        swath: Swath identifier for this data set. This element identifies the swath that applies to all data contained within this data set. The swath identifier "EW" is used for products in which the 5 EW swaths have been merged. Likewise, "IW" is used for products in which the 3 IW swaths have been merged.
        mode: Sensor mode for this data set.
        startTime: Zero Doppler start time of the output image [UTC].
        stopTime: Zero Doppler stop time of the output image [UTC].
        aqusitionTime,
        absoluteOrbitNumber: Absolute orbit number at data set start time.
        imageNumber: Image number. For WV products the image number is used to distinguish between vignettes. For SM, IW and EW modes the image number is still used but refers instead to each swath and polarisation combination (known as the 'channel') of the data.

    Input:
        metaDict[dict]: a dictionary of the metadata.

    output:
        Header[structure of Header]
    
"""
function Header(metaDict)::Header
    missionId = metaDict["product"]["adsHeader"]["missionId"]
    productType = metaDict["product"]["adsHeader"]["productType"]
    polarisation = metaDict["product"]["adsHeader"]["polarisation"]
    missionDataTakeId = metaDict["product"]["adsHeader"]["missionDataTakeId"]
    swath = metaDict["product"]["adsHeader"]["swath"]
    mode = metaDict["product"]["adsHeader"]["mode"]
    startTime = metaDict["product"]["adsHeader"]["startTime"]
    stopTime = metaDict["product"]["adsHeader"]["stopTime"]
    absoluteOrbitNumber = metaDict["product"]["adsHeader"]["absoluteOrbitNumber"]
    imageNumber = metaDict["product"]["adsHeader"]["imageNumber"]


    stopTime = DateTime(stopTime[1:23])
    missionDataTakeId = parse(Int, missionDataTakeId)
    swath = parse(Int, swath[end])
    startTime = DateTime(startTime[1:23])
    absoluteOrbitNumber = parse(Int, absoluteOrbitNumber)

    aqusitionTime = stopTime - startTime

    header = Header(missionId,
        productType,
        polarisation,
        missionDataTakeId,
        swath,
        mode,
        startTime,
        stopTime,
        aqusitionTime,
        absoluteOrbitNumber,
        imageNumber)
    return header
end


""""
ProductInformation

    Constucture for the ProductInformation structure. 

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the ProductInformation as a structure. ProductInformation file:
        pass: Direction of the orbit (ascending, descending)
        timelinessCategory: Timeliness category under which the product was produced, i.e. time frame from the data acquisition
        platformHeading: Platform heading relative to North [degrees].
        projection: Projection of the image, either slant range or ground range.
        rangeSamplingRate: Range sample rate [Hz]
        radarFrequency: Radar (carrier) frequency [Hz]
        azimuthSteeringRate: Azimuth steering rate for IW and EW modes [degrees/s].

    Input:
        metaDict[dict]: a dictionary of the metadata.

    output:
        ProductInformation[structure of ProductInformation]
    
"""
function ProductInformation(metaDict)::ProductInformation
    pass = metaDict["product"]["generalAnnotation"]["productInformation"]["pass"]
    timelinessCategory = metaDict["product"]["generalAnnotation"]["productInformation"]["timelinessCategory"]
    platformHeading = metaDict["product"]["generalAnnotation"]["productInformation"]["platformHeading"]
    projection = metaDict["product"]["generalAnnotation"]["productInformation"]["projection"]
    rangeSamplingRate = metaDict["product"]["generalAnnotation"]["productInformation"]["rangeSamplingRate"]
    radarFrequency = metaDict["product"]["generalAnnotation"]["productInformation"]["radarFrequency"]
    azimuthSteeringRate = metaDict["product"]["generalAnnotation"]["productInformation"]["azimuthSteeringRate"]

    platformHeading = parse(Float64, platformHeading)
    rangeSamplingRate = parse(Float64, rangeSamplingRate)
    radarFrequency = parse(Float64, radarFrequency)
    azimuthSteeringRate = parse(Float64, azimuthSteeringRate)

    productinformation = ProductInformation(pass,
        timelinessCategory,
        platformHeading,
        projection,
        rangeSamplingRate,
        radarFrequency,
        azimuthSteeringRate)
    return productinformation
end




""""
ImageInformation

    Constucture for the ImageInformation structure. 

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the ImageInformation as a structure. Input in the ImageInformation file:
        rangePixelSpacing: Pixel spacing between range samples [m].
        azimuthFrequency: Azimuth line frequency of the output image [Hz]. This is the inverse of the azimuthTimeInterval.
        slantRangeTime: Two-way slant range time to first sample [milli sec].
        incidenceAngleMidSwath: Incidence angle at mid swath [degrees].
        azimuthPixelSpacing: Nominal pixel spacing between range lines [m].
        numberOfSamples: Total number of samples in the output image (image width).

    Input:
        metaDict[dict]: a dictionary of the metadata.

    output:
        ImageInformation[structure of ImageInformation]
    
"""
function ImageInformation(metaDict)::ImageInformation
    imageinformations = metaDict["product"]["imageAnnotation"]["imageInformation"]

    rangePixelSpacing = parse(Float64, imageinformations["rangePixelSpacing"])
    azimuthFrequency = parse(Float64, imageinformations["azimuthFrequency"])
    slantRangeTime = Millisecond(round(Int,parse(Float64, imageinformations["slantRangeTime"])*1000))
    incidenceAngleMidSwath = parse(Float64, imageinformations["incidenceAngleMidSwath"])
    azimuthPixelSpacing = parse(Float64, imageinformations["azimuthPixelSpacing"])
    numberOfSamples = parse(Int, imageinformations["numberOfSamples"])

    imageinformations = ImageInformation(rangePixelSpacing,
        azimuthFrequency,
        slantRangeTime,
        incidenceAngleMidSwath,
        azimuthPixelSpacing,
        numberOfSamples)
    return imageinformations
end


""""
SwathTiming

    Constucture for the SwathTiming structure. 

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the SwathTiming as a structure. 

    Input:
        metaDict[dict]: a dictionary of the metadata.

    output:
        SwathTiming[structure of SwathTiming]
    
"""
function SwathTiming(metaDict)::SwathTiming
    swathtiming = metaDict["product"]["swathTiming"]

    linesPerBurst = parse(Int, swathtiming["linesPerBurst"])
    samplesPerBurst = parse(Int, swathtiming["samplesPerBurst"])
    burstCount = parse(Int, swathtiming["burstList"][:count])

    swathtiming = SwathTiming(linesPerBurst,
        samplesPerBurst,
        burstCount)
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
        slantRangeTime: Two-way slant range time to grid point [milli sec].
        elevationAngle: Elevation angle to grid point [degrees].
        incidenceAngle: Incidence angle to grid point [degrees].
        height: Height of the grid point above sea level [m].

    Example:
        # accesing the geolocation data from the full metadata.
        xmlPath = "s1a-iw1-slc-vh-20220220t144146-20220220t144211-041998-050092-001.xml"
        Metadata1 = MetaDataSentinel1(xmlPath)
        geolocation = Metadata1.geolocation

        # accessing the geolocation directly from the xml.
        metaDict = getDictofXml(xmlPath)
        geolocation = GeolocationGrid(metaDict)
        

    Input:
        metaDict[dict]: a dictionary of the metadata.

    output:
        GeolocationGrid[structure of GeolocationGrid]
    
"""
function GeolocationGrid(metaDict)::GeolocationGrid
    geolocation = metaDict["product"]["geolocationGrid"]["geolocationGridPointList"]["geolocationGridPoint"]

    lines = [parse(Int, elem["line"]) for elem in geolocation] .+ 1
    samples = [parse(Int, elem["pixel"]) for elem in geolocation] .+ 1
    latitude = [parse(Float64, elem["latitude"]) for elem in geolocation]
    longitude = [parse(Float64, elem["longitude"]) for elem in geolocation]
    azimuthTime = [DateTime(elem["azimuthTime"][1:23]) for elem in geolocation]
    slantRangeTime = [Millisecond(round(Int,parse(Float64, elem["slantRangeTime"])*1000)) for elem in geolocation]
    elevationAngle = [parse(Float64, elem["elevationAngle"]) for elem in geolocation]
    incidenceAngle = [parse(Float64, elem["incidenceAngle"]) for elem in geolocation]
    height = [parse(Float64, elem["height"]) for elem in geolocation]

    geolocationgrid = GeolocationGrid(lines,
        samples,
        latitude,
        longitude,
        azimuthTime,
        slantRangeTime,
        elevationAngle,
        incidenceAngle,
        height)
    return geolocationgrid
end



""""
Burst

    Constucture for the Burst structure. 

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the Burst specific data for a single burst as a structure. 
    The Burst structure returns the following:
        burstNumber::Int64
        azimuthTime::DateTime : Zero Doppler azimuth time of the first line of this burst [UTC]. 
        sensingTime::DateTime : Sensing time of the first input line of this burst [UTC].
        azimuthAnxTime::Float64 : Zero Doppler azimuth time of the first line of this burst relative to the Ascending Node Crossing (ANX) time. [milli sec].
        byteOffset::Int64.:  Byte offset of this burst within the image MDS.
        firstValidSample::Vector{Int64}: An array of integers indicating the offset of the first valid image sample within each range line. This array contains count attribute integers, equal to the linesPerBurst field (i.e. one value per range line within the burst), separated by spaces. If a range line does not contain any valid image samples, the integer is set to -1.
        lastValidSample::Vector{Int64}: An array of integers indicating the offset of the last valid image sample within each range line. This array contains count attribute integers, equal to the linesPerBurst (i.e. one value per range line within the burst), separated by spaces. If a range line does not contain any valid image samples, the integer is set to -1.
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
        metaDict[dict]: a dictionary of the metadata.
        burstNumber[Int]: Integer value of burst number.


    output:
        Burst[structure of Burst]
    
"""
function Burst(metadict,burstNumber::Int=1)::Burst
    burst = metadict["product"]["swathTiming"]["burstList"]["burst"][burstNumber]

    azimuthTime = DateTime(burst["azimuthTime"][1:23])
    sensingTime = DateTime(burst["sensingTime"][1:23])
    azimuthAnxTime = Millisecond(round(Int,parse(Float64, burst["azimuthAnxTime"])*1000))
    byteOffset = parse.(Int,burst["byteOffset"])
    firstValidSample = parse.(Int,split(burst["firstValidSample"][""]))
    lastValidSample = parse.(Int,split(burst["lastValidSample"][""]))
    burstId = parse.(Int64,split(burst["burstId"][""]))[1]
    absoluteBurstId = parse.(Int,split(burst["burstId"][:absolute]))[1]

    #DopplerCentroid  for burst 
    startTime = Header(metadict).startTime
    linesPerBurst  = SwathTiming(metadict).linesPerBurst
    azimuthFrequency = ImageInformation(metadict).azimuthFrequency
    dopplerCentroid = DopplerCentroid(metadict,azimuthTime,startTime,linesPerBurst,azimuthFrequency)

    #AzimuthFmRate for burst 
    burstMidTime = dopplerCentroid.burstMidTime
    azimuthFmRates = AzimuthFmRate(metadict,startTime,burstMidTime)



    burst = Burst(burstNumber, 
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
DopplerCentroid

    Constucture for the DopplerCentroid structure. 

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the DopplerCentroid data for a single burst as a structure. 
    The DopplerCentroid structure returns the following:
        numberOfDopplerCentroids::Int64
        burstTime::Millisecond
        burstMidTime::Millisecond
        dcTimeDifferences::Vector{Millisecond}
        bestDcIndex::Int64
        dataDcPolynomial::Vector{Float64}
        dcT0::Float64
        firstLineMosaic::Int64
    
    Input:
        metaDict[dict]: a dictionary of the metadata.
        burst.azimuthTime
        header.startTime
        swathtiming.linesPerBurst
        imageInformation.azimuthFrequency


    output:
        DopplerCentroid[structure of DopplerCentroid]

    Note:
        [ ] Perhaps change input vars from strutures to the specific values. -- Does the current implementaion use extra time?
        [ ] What is needed? Maybe, e.g., dataDcPolynomial is redudant in the later processing. Could be deleted.
"""
function DopplerCentroid(metaDict,
                        azimuthTime::Dates.DateTime,
                        startTime::Dates.DateTime,
                        linesPerBurst::Int64,
                        azimuthFrequency::Float64)::DopplerCentroid
    dopplerCentroids = metaDict["product"]["dopplerCentroid"]["dcEstimateList"]["dcEstimate"]
    numberOfDopplerCentroids = length(dopplerCentroids)

    burstTimes = (azimuthTime-startTime)

    burstMidTimes = burstTimes.value + linesPerBurst / (2 * (azimuthFrequency*0.001) ) #burst mid time in milliseconds. frq in Hz.
    burstMidTimes = Millisecond(floor(Int,round(burstMidTimes)))
    dcTimeDifferences = [(abs.((DateTime(centroid["azimuthTime"][1:23]) - startTime) - burstMidTimes)) for centroid in dopplerCentroids]
    bestDcIndex = argmin(dcTimeDifferences)
    dataDcPolynomial = [parse(Float64, param) for param in split(dopplerCentroids[bestDcIndex]["dataDcPolynomial"][""])] 
    dcT0 = parse(Float64, dopplerCentroids[bestDcIndex]["t0"])
    firstLineMosaic = round(Int64,1 + burstTimes.value * azimuthFrequency*0.001)

    dopplerCentroid = DopplerCentroid(numberOfDopplerCentroids,
                                        burstTimes,
                                        burstMidTimes,
                                        dcTimeDifferences,
                                        bestDcIndex,
                                        dataDcPolynomial,
                                        dcT0,
                                        firstLineMosaic)
    return dopplerCentroid
end


""""
AzimuthFmRate

    Constucture for the AzimuthFmRate structure. 

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the AzimuthFmRate data for a single burst as a structure. 
    The AzimuthFmRate structure returns the following:
            burstNumber::Int64
            fmTimesDiff::Vector{Millisecond}
            bestFmIndex::Int64
            azimuthFmRatePolynomial::Vector{Float64}
            azimuthFmRateT0::Float64

    The burstNumber can be used as a key to other burst specific strucutres, e.g., the Burst data.

    
    Input:
        metaDict[dict]: a dictionary of the metadata.
        dopplerCentroid[DopplerCentroid]: DopplerCentroid Structure


    output:
        azimuthFmRate[structure of AzimuthFmRate]

    Note:
        [ ] Perhaps change input vars from strutures to the specific values. -- Does the current implementaion use extra time?
        [ ] What is needed? Maybe, e.g., azimuthFmRatePolynomial is redudant in the later processing. Could then be deleted.
    
"""
function AzimuthFmRate(metadict,
                        startTime::Dates.DateTime,
                        burstMidTime::Dates.Millisecond)::AzimuthFmRate
    azimuthFmRateList = metadict["product"]["generalAnnotation"]["azimuthFmRateList"]["azimuthFmRate"]

    fmTimesDiff = abs.([(DateTime(azimuthFmRate["azimuthTime"][1:23])-startTime) for azimuthFmRate in azimuthFmRateList].-burstMidTime)
    bestFmIndex = argmin(fmTimesDiff)
    azimuthFmRatePolynomial = [parse(Float64, param) for param in split(azimuthFmRateList[bestFmIndex]["azimuthFmRatePolynomial"][""])]
    azimuthFmRateT0 = parse(Float64, azimuthFmRateList[bestFmIndex]["t0"])

    azimuthfmrate = AzimuthFmRate(
                                fmTimesDiff,
                                bestFmIndex,
                                azimuthFmRatePolynomial,
                                azimuthFmRateT0,
                                )
    return azimuthfmrate
end



""""
BurstsInfo

    Constucture for the BurstsInfo structure. 

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the BurstsInfo data for a all bursts as a structure. 
    The burst info has the info and derived data for each bursts.

    
    Input:
        metaDict[dict]: a dictionary of the metadata.

    output:
    burstinfo[structure of BurstsInfo]

    Note:
        Instead of vector{strucutre} consider another type???
        
    
"""
function BurstsInfo(metadict)::BurstsInfo
    #number of bursts.
    numberOfBurst = floor(Int, size(metadict["product"]["swathTiming"]["burstList"]["burst"])[1])
    #Getting data for each burst.
    burstRange = 1.0:1.0:numberOfBurst 
    bursts = [Burst(metadict,floor(Int, number)) for number in burstRange]
    burstinfo = BurstsInfo(numberOfBurst,
                            bursts)
    return burstinfo
end


""""
MetaDataSentinel1

    Constucture for the MetaDataSentinel1 structure. 
    It takes a Sentinel-1 single swath metafile in .xml format and constructs the metadata structure using the individual sub-structures in the metadata.
    The individual sub-structures in the metadata are:
    - Header
    - ProductInformation
    - ImageInformation
    - SwathTiming
    - Burst
    - GeolocationGrid

    Input:
        xmlFile[string]: path of swath specific metadata in xml.format.

    output:
        MetaDataSentinel1[structure of MetaDataSentinel1]: Strucutre with all Sentinel-1 metadata for a swath.
    

    Example:

    Getting the azimuthFmRateT0 for the 5th burst:
        metadata = MetaDataSentinel1(annotation.xml)
        metadata.burstsInfo.azimuthFmRate[5].azimuthFmRateT0
        

"""
function MetaDataSentinel1(xmlFile::String)::MetaDataSentinel1

    metaDict = getDictofXml(xmlFile)
    metadata = MetaDataSentinel1(Header(metaDict),
                        ProductInformation(metaDict),
                        ImageInformation(metaDict),
                        SwathTiming(metaDict),
                        BurstsInfo(metaDict),
                        GeolocationGrid(metaDict)
                        )

    return metadata
end




