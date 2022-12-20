using Base.Cartesian
using Statistics

include("../separateLater/Sentinel1/Sentinel1.jl")
include("../SARProcessing.jl")
include("../separateLater/VisualiseSAR/VisualiseSAR.jl")

include("../speckle_filters/helper_functions.jl")
include("simple.jl")






slcSubsetPath = "test/testData/s1a-iw3-slc-vv_subset_hight9800_10400_width11000_11000.tiff";
complex_image = Sentinel1.readTiff(slcSubsetPath)
abseloute_image = abs.(complex_image)




descpe = speckle_mean_filter(abseloute_image,[3,3])



mean_image = speckle_mean_filter(abseloute_image,[5,5])
mean_image_squarred = speckle_mean_filter(abseloute_image.^2,[5,5] )
image_mean_varince = mean_image_squarred - mean_image.^2
image_variance = var(abseloute_image)
image_weights = image_variance./(image_variance.+image_mean_varince)
mean_image.+ image_weights
mean_image.+ image_weights.*(abseloute_image - mean_image)


lee = speckle_lee_filter(abseloute_image,[13,13])

img = VisualiseSAR.sar2grayimage(abseloute_image, p_quantile = 0.85)
img = VisualiseSAR.sar2grayimage(lee, p_quantile = 0.85)
img = VisualiseSAR.sar2grayimage(descpe, p_quantile = 0.85)

using Plots


histogram(vcat(abseloute_image...),bins=50)
histogram!(vcat(descpe...),bins=50)
histogram!(vcat(lee...),bins=50)