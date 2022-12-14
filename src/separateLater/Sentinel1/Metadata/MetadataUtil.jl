"""
Utilities and get functions for the metadata..




Functions 

- getAnnotationPaths(safePath::string, satellite="s1")
- searchDir(path, key)
- getDictofXml(annotationFile::string)

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
    doc = open(f->read(f, String), annotationFile)
    return XMLDict.xml_dict(doc)
end



