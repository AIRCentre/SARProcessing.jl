
""""
Helper functions
Used, e.g., in filter comparisions.
"""

function variance_to_mean_ratio(image_window)
    return (Statistics.var(image_window) / (Statistics.mean(image_window)^2 + eps()))
end



function equivalent_number_of_looks_intensity(image_window)
    return Statistics.mean(image_window)^2  / (Statistics.var(image_window)+ eps())
end



function equivalent_number_of_looks_amplitude(image_window)
    #where 0.5227 is the value of the O"v of a 1-look amplitude SAR image. This def­ inition is consistent with the multi-look processing using amplitude averaging of individual looks.
    return (0.5227/(speckle_index_ratio(image_window)+eps()))^2
end


"""
In the homogeneous areas, the ratio of the standard deviation to the mean is a good measure of speckle strength.
For the filtered SAR images, this ratio is also frequently used to measure the amount of speckle reduction.
"""
function speckle_index_ratio(image_window)
    return sqrt(Statistics.std(image_window)^2)/Statistics.mean(image_window)
end
