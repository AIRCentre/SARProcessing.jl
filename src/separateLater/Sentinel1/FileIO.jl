
import ArchGDAL


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

