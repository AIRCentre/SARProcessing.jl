import Dates
import EzXML
import XMLDict


include("MetadataUtil.jl")

""""
Structures and constructures for the metadata. 
    MetaDataSentinel1
        - ::Header
        - ::productInformation
        - ::imageInformation
        - ::swathTiming
        - ::burst
        - ::geolocationGrid

"""
#currently, it is called "MetaDataSentinel1" to allow for a later abstract structures with MetaData for different satellites.

##################
### Structures
##################


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
##base.@kwdef not a part of stable julia. Probably will be future release(?)


"""
ImageInformation

returns structure of ImageInformation from metadata in .xml


"""
Base.@kwdef struct ImageInformation
    rangePixelSpacing::Float64
    azimuthFrequency::Float64
    slantRangeTime::Float64
    incidenceAngleMidSwath::Float64
    azimuthPixelSpacing::Float64
    numberOfSamples::Int
end

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
    startTime::Dates.DateTime
    stopTime::Dates.DateTime
    aqusitionTime::Float64
    absoluteOrbitNumber::Int
    imageNumber::String
end

"""
SwathTiming

returns structure of SwathTiming from metadata in .xml


"""
Base.@kwdef struct SwathTiming
    linesPerBurst
    samplesPerBurst
    burstCount::Int
end


"""
Burst

returns structure of Burst from metadata in .xml


"""
Base.@kwdef struct Burst
    azimuthTime::Vector{Dates.DateTime}
    sensingTime::Vector{Dates.DateTime}
    azimuthAnxTime::Vector{Float64}
    byteOffset::Vector{Int64}
    firstValidSample::Vector{Vector{Int64}}
    lastValidSample::Vector{Vector{Int64}}
    burstId::Vector{Int64}
    absoluteBurstId::Vector{Int64}
    firstLineMosaic::Vector{Int64}
    azimuth_fm_rate_polynomial::Matrix{Float64}
    azimuth_fm_rate_t0::Vector{Float64}
    data_dc_polynomial::Matrix{Float64}
    data_dc_t0::Vector{Float64}
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
    azimuthTime::Vector{Dates.DateTime}
    slantRangeTime::Vector{Float64}
    elevationAngle::Vector{Float64}
    incidenceAngle::Vector{Float64}
    height::Vector{Float64}
end


"""
MetaDataSentinel1:
    Metadata structure for the Sentinel-1 satellite

    
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
    burst::Burst
    geolocation::GeolocationGrid
end




##################
### Constructors
##################

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
    

"""
function MetaDataSentinel1(xmlFile::String)::MetaDataSentinel1

    metaDict = getDictofXml(xmlFile)


    swathtiming = SwathTiming(metaDict)
    imageinfo = ImageInformation(metaDict)
    header = Header(metaDict)
    burstinfo = Burst(metaDict,
        swathtiming.linesPerBurst,
        imageinfo.azimuthFrequency,
        header.startTime)

    metadata = MetaDataSentinel1(header,
        ProductInformation(metaDict),
        imageinfo,
        swathtiming,
        burstinfo,
        GeolocationGrid(metaDict))

    return metadata
end





""""
Header

    Constucture for the Header structure. 

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the Header as a structure. Input in the header file:
        missionId,
        productType,
        polarisation,
        missionDataTakeId,
        swath,
        mode,
        startTime,
        stopTime,
        aqusitionTime,
        absoluteOrbitNumber,
        imageNumber

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


    stopTime = Dates.DateTime(stopTime[1:23])

    missionDataTakeId = parse(Int, missionDataTakeId)
    swath = parse(Int, swath[end])
    startTime = Dates.DateTime(startTime[1:23])
    absoluteOrbitNumber = parse(Int, absoluteOrbitNumber)
    aqusitionTime = getTimeDifference(startTime, stopTime)


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

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the ProductInformation as a structure. Input in the ProductInformation file:
        pass,
        timelinessCategory,
        platformHeading,
        projection,
        rangeSamplingRate,
        radarFrequency,
        azimuthSteeringRate

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
        rangePixelSpacing,
        azimuthFrequency,
        slantRangeTime,
        incidenceAngleMidSwath,
        azimuthPixelSpacing,
        numberOfSamples

    Input:
        metaDict[dict]: a dictionary of the metadata.

    output:
        ImageInformation[structure of ImageInformation]
    
"""
function ImageInformation(metaDict)::ImageInformation
    imageinformations = metaDict["product"]["imageAnnotation"]["imageInformation"]
    rangePixelSpacing = parse(Float64, imageinformations["rangePixelSpacing"])
    azimuthFrequency = parse(Float64, imageinformations["azimuthFrequency"])
    slantRangeTime = parse(Float64, imageinformations["slantRangeTime"])
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

    It takes a dictionary containing the full sentinel-1 swath metadata and extracts the SwathTiming as a structure. Input in the SwathTiming file:
        lines,
        samples,
        latitude,
        longitude,
        azimuthTime,
        slantRangeTime,
        elevationAngle,
        incidenceAngle,
        height

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
        lines,
        samples,
        latitude,
        longitude,
        azimuthTime,
        slantRangeTime,
        elevationAngle,
        incidenceAngle,
        height

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
    azimuthTime = [Dates.DateTime(elem["azimuthTime"][1:23]) for elem in geolocation]
    slantRangeTime = [parse(Float64, elem["slantRangeTime"]) for elem in geolocation]
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
Burst:
    For Sentinel-1
    Getting Burst data for a swath/polarization.
    
Inputs:
    - metaDict, linesPerBurst, azimuthFrequency, startSensingTime


    Note to self:
        This should be cleaned up greatly.
"""

function Burst(metaDict, linesPerBurst::Int64, azimuthFrequency::Float64, startSensingTime::Dates.DateTime)::Burst
    #dict with burst info
    burst = metaDict["product"]["swathTiming"]["burstList"]["burst"]
    #dict with dopplercentroid estiamted
    dopplerCentroid = metaDict["product"]["dopplerCentroid"]["dcEstimateList"]["dcEstimate"]
    # number of burst.
    burstCount = parse(Int, metaDict["product"]["swathTiming"]["burstList"][:count])


    #data from the dict
    azimuthTime = [Dates.DateTime(elem["azimuthTime"][1:23]) for elem in burst]
    azimuthAnxTime = [parse(Float64, elem["azimuthAnxTime"]) for elem in burst]
    sensingTime = [Dates.DateTime(elem["sensingTime"][1:23]) for elem in burst]
    byteOffset = [parse(Int64, elem["byteOffset"]) for elem in burst]
    firstValidSample = [parse.(Int, split(elem["firstValidSample"][""])) for elem in burst]
    lastValidSample = [parse.(Int, split(elem["lastValidSample"][""])) for elem in burst]
    burstId = [parse.(Int64, split(elem["burstId"][""])[1]) for elem in burst]

    absoluteBurstId = [parse.(Int64, split(elem["burstId"][:absolute])[1]) for elem in burst]
    #   burst times are calculte as time differece between sensing start

    burstTimes = getTimeDifference.(startSensingTime, azimuthTime)
    burstMidTimes = burstTimes .+ linesPerBurst / (2 * azimuthFrequency)



    #select the polynomials and t0's closest to mid burst time
    data_dc_polynomial = Array{Float64,2}(undef, burstCount, 3)
    data_dc_t0 = Array{Float64,1}(undef, burstCount)

    dcTimeDifference = Array{Float64,1}(undef, length(dopplerCentroid))


    for i in 1:burstCount
        for j in 1:length(dopplerCentroid)
            dcTime = getTimeDifference(startSensingTime, Dates.DateTime(dopplerCentroid[j]["azimuthTime"][1:23]))
            dcTimeDifference[j] = abs.(dcTime - burstMidTimes[i])
        end
        best_dc_index = argmin(dcTimeDifference)
        data_dc_polynomial[i, :] = [parse(Float64, param) for param in split(dopplerCentroid[best_dc_index]["dataDcPolynomial"][""])]
        data_dc_t0[i] = parse(Float64, dopplerCentroid[best_dc_index]["t0"])
    end
    # A ordered dictionary of all the azimuth fm rate polynomials
    azimuth_fm_rate_list = metaDict["product"]["generalAnnotation"]["azimuthFmRateList"]["azimuthFmRate"]

    # select the polynomials and t0's closest to mid burst time
    azimuth_fm_rate_polynomial = Array{Float64,2}(undef, burstCount, 3)
    azimuth_fm_rate_t0 = Array{Float64,1}(undef, burstCount)
    fm_time_diff = Array{Float64,1}(undef, length(azimuth_fm_rate_list))


    for i in 1:burstCount
        for j in 1:length(azimuth_fm_rate_list)
            fm_time = getTimeDifference(startSensingTime, Dates.DateTime(azimuth_fm_rate_list[j]["azimuthTime"][1:23]))
            fm_time_diff[i] = abs(fm_time - burstMidTimes[i])
        end

        best_dc_index = argmin(fm_time_diff)

        azimuth_fm_rate_polynomial[i, :] = [parse(Float64, param) for param in split(azimuth_fm_rate_list[best_dc_index]["azimuthFmRatePolynomial"][""])]
        azimuth_fm_rate_t0[i] = parse(Float64, azimuth_fm_rate_list[best_dc_index]["t0"])
    end
    firstLineMosaic = 1 .+ (burstTimes) .* azimuthFrequency
    firstLineMosaic = round.(Int64, firstLineMosaic)

    burstdata = Burst(azimuthTime=azimuthTime,
        sensingTime=sensingTime,
        azimuthAnxTime=azimuthAnxTime,
        byteOffset=byteOffset,
        firstValidSample=firstValidSample,
        lastValidSample=lastValidSample,
        burstId=burstId,
        absoluteBurstId=absoluteBurstId,
        firstLineMosaic=firstLineMosaic,
        azimuth_fm_rate_polynomial=azimuth_fm_rate_polynomial,
        azimuth_fm_rate_t0=azimuth_fm_rate_t0,
        data_dc_polynomial=data_dc_polynomial,
        data_dc_t0=data_dc_t0)
    return burstdata

end