include("Sentinel1Metadata.jl")
include("MetadataUtil.jl")

#folder with a safe products
#dataPath = "data"
# finding first .SAFE product... using that for testing.
#safeFolder = (joinpath(dataPath, searchDir(dataPath, "SAFE")[1]))
#getting annotation files in path
#annotationFiles = getAnnotationPaths(safeFolder) #return vector of annotation files
# taking first annotation file
#annotationFile = annotationFiles[1]

annotationFile = "test/testData/s1a-iw3-slc-vv-20220918t074921-20220918t074946-045056-056232-006.xml"

# or, if there is a direct path to an annotation file, use that.
metaDict = getDictofXml(annotationFile)


####### 
# can get the info individually:
swathtiming = SwathTiming(metaDict)
productinfo = ProductInformation(metaDict)
imageinfo = ImageInformation(metaDict)
header = Header(metaDict)
burstinfo = Burst(metaDict,
    swathtiming.linesPerBurst,
    imageinfo.azimuthFrequency,
    header.startTime)
geolocation = GeolocationGrid(metaDict)
#methods(Header)
# Returns -
#[1] Header(; missionId, productType, polarisation, missionDataTakeId, swath, mode, startTime, stopTime, aqusitionTime, absoluteOrbitNumber, imageNumber)

#######
# Can get the entire metadata as:
Metadata1 = MetaDataSentinel1(annotationFile)

# can acces, e.g., geolocation as:
#geolocation = Metadata1.geolocation

#get data for all images.
#for i in 1:length(annotationFiles)
#    Metadata = MetaDataSentinel1(annotationFiles[i])
#    println("swath: ", Metadata.header.swath)
#    println("polarization: ", Metadata.header.polarisation)
#    if Metadata.header.polarisation == "VV"
#        println("startTime: ", Metadata.header.startTime)
#        println("stopTime: ", Metadata.header.stopTime)
#    end
#end




