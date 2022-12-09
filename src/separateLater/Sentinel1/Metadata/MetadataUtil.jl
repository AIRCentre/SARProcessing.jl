import Dates


"""
Utilities and get functions for the metadata..




Functions 

- getAnnotationPaths(safePath::string, satellite="s1")
- searchDir(path, key)
- getTimeDifference(startTime::Dates.DateTime,stopTime::Dates.DateTime)

"""



"""
getAnnotationPaths(safePath::string)

Getting the paths for the annotation files for a SLC image using its .SAFE folder path.

### Parameters
    * safePath::String: path of .SAFE folder for one image.
    
### Returns
    * annotationPaths::Vector: Vector of paths for annotation files in .SAFE folder
"""
function getAnnotationPaths(safePath::String)::Vector{String}
    annotationFolder = joinpath(safePath, "annotation")
    return [joinpath(annotationFolder, annotationFile) for annotationFile in searchDir(annotationFolder, ".xml")]
end


""""

search dir

Searching a directory for files with extention.

"""
searchDir(path, key) = filter(x -> occursin(key, x), readdir(path))


function getDictofXml(annotationFile::String)
    doc = EzXML.readxml(annotationFile)
    return XMLDict.xml_dict(doc)
end



""""
getTimeDifference(startTime::Dates.DateTime,stopTime::Dates.DateTime)

Getting time difference in seconds between to DateTimes.
time difference is calcualted as stopTime - startTime. 
Will return a negative value if stopTime is before startTime.

### Parameters
    * startTime::Dates.DateTime: Start time
    * stopTime::Dates.DateTime: End time. 

    
### Returns
    * timedifference in seconds

"""
function getTimeDifference(startTime::Dates.DateTime,stopTime::Dates.DateTime)::Float64
    return (stopTime-startTime).value/1000
end


"""
vecToDataframeRows(vec::Vector{Pair{String, String}})::NamedTuple

    turns a vector of two strings, e.g.,  "missionId" => "S1A", into a row for a DataFrame

    ### Parameters
    vec::Vector{Pair{String, String}}: 
    
    ### return 
    row for df
"""
function vecToDataframeRows(vec)::NamedTuple
    try
        return (Data=vec[1], Value=vec[2])
    catch
        return nothing
    end
end

