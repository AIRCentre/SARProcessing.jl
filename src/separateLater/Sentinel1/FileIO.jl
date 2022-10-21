
import ArchGDAL


"""
readMetaDataSLC(filepath::String)
Returns: ::MetaDataSLC
"""
function readMetaDataSLC(filepath::String)
    error("Not implemented")
end


"""
    readTiff(filepath::String, window=nothing, convertToDouble = true)

    Read a Sentinel 1 tiff file.
    # Examples:
    ```jldoctest
    julia> filepath = "s1a-iw3-slc-vv-20220918t074921-20220918t074946-045056-056232-006.tiff"
    julia> data = readSwathSLC(filePath, [(501,600),(501,650)]);
    julia> typeof(data)
    Matrix{ComplexF64}
    julia> size(data)
    (100,150)
    ```
"""
function readTiff(filepath::String, window=nothing, convertToDouble = true)

    dataset = ArchGDAL.readraster(filepath)

    if window[1][2] > ArchGDAL.width(dataset)
        @warn "The window exceeds the dataset width $(ArchGDAL.width(dataset))."
    end
    if window[2][2] > ArchGDAL.height(dataset)
        @warn "The window exceeds the dataset height $(ArchGDAL.height(dataset))."
    end

    if !isnothing(window)
        dataset = dataset[window[1][1]:window[1][2],window[2][1]:window[2][2],1]
    else
        dataset = dataset[:,:,1]
    end

    ## Make sure that the data type is float for future computations.
    if convertToDouble
        if eltype(dataset) <: Complex
            dataset = convert.(Complex{Float64}, dataset)
        else
            dataset = convert.(Float64, dataset)
        end
    end

    return dataset
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

