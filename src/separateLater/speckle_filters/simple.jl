
function mean_filter(size =[3,3])

end
function speckle_mean_filter(img::Matrix{T},filter_size::Vector{Integer} = [5,5]) where T<: Real
    


end



slcSubsetPath = "test/testData/s1a-iw3-slc-vv_subset_hight9800_10400_width11000_11000.tiff";
complex_image = Sentinel1.readTiff(slcSubsetPath)
abseloute_image = abs.(complex_image)

