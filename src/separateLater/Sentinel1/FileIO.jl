



"""
readMetaDataSLC(filepath::String)
Returns: ::MetaDataSLC
"""
function readMetaDataSLC(filepath::String)
    error("Not implemented")
end


"""
readSwathSLC(filepath::String)
Returns: ::SwathSLC
"""
function readSwathSLC(filepath::String, window)
    error("Not implemented")
end


"""
readSLC(folder::String, window)
Returns: ::Array{SwathSLC,1}
"""
function readSLC(folder::String, window)
    error("Not implemented")
    ## use readMetaDataSLC(filepath::String) to read the MetaData
    ## use readSwathSLC(filepath::String, window) to read the swath

    ## create and return ::ComplexImage object
end

