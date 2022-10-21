
import ArchGDAL


"""
readMetaDataSLC(filepath::String)
Returns: ::MetaDataSLC
"""
function readMetaDataSLC(filepath::String)
    error("Not implemented")
end


"""
    readSwathSLC(filepath::String, window=nothing)

    Read a Sentinel 1 Single Look Complex (SLC) swath from a tiff file.
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
function readSwathSLC(filepath::String, window=nothing)

    dataset = ArchGDAL.readraster(filepath)

    if window[1][2] > ArchGDAL.width(dataset)
        @warn "The window exceeds the dataset width $(ArchGDAL.width(dataset))."
    end
    if window[2][2] > ArchGDAL.height(dataset)
        @warn "The window exceeds the dataset height $(ArchGDAL.height(dataset))."
    end

    if !isnothing(window)
        dataset = dataset[window[1][1]:window[1][2],window[2][1]:window[2][2],1]
    end

    ## The sentinel 1 images are Complex{Int64} this conversion multiplies the data with 4 but is need for future computations.
    return convert.(Complex{Float64}, dataset)
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

