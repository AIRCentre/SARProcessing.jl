"""
Utilities and get functions for the metadata..

# Functions
- get_sentinel1_annotation_paths(safe_path::string, satellite="s1")
- search_directory(path, key)
- read_xml_as_dict(annotationFile::string)
"""



"""
    get_sentinel1_annotation_paths(safe_path::string)

Getting the paths for the annotation files for a SLC image using its .SAFE folder path.

### Parameters
* `safe_path::String`: path of .SAFE folder for one image.

### Returns
* `annotationPaths::Vector`: Vector of paths for annotation files in .SAFE folder
"""
function get_sentinel1_annotation_paths(safe_path::String)::Vector{String}
    annotationFolder = joinpath(safe_path, "annotation")
    return [joinpath(annotationFolder, annotationFile) for annotationFile in search_directory(annotationFolder, ".xml")]
end


""""
    search_directory(path, key)

Searching a directory for files with extension.
"""
search_directory(path, key) = filter(x -> occursin(key, x), readdir(path))



function read_xml_as_dict(annotationFile::String)
    doc = open(f->read(f, String), annotationFile)
    return XMLDict.xml_dict(doc)
end
