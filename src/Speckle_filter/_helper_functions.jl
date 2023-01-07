
""""
Helper functions
Used, e.g., in filter comparisions.
"""

function variance_to_mean_ratio(image_window)
    # ϵ added for numerical stability. #Simon, is this an issue in julia?
    ϵ = 0.00000001
    return (std(image_window) / (mean(image_window)^2 + ϵ))
end



function equivalent_number_of_looks_intensity(image_window)
    # ϵ added for numerical stability. #Simon, is this an issue in julia?
    ϵ = 0.00000001
    return mean(image_window)^2  / (std(image_window+ ϵ))
end



function equivalent_number_of_looks_amplitude(image_window)
    # ϵ added for numerical stability. #Simon, is this an issue in julia?
    ϵ = 0.00000001
    #where 0.5227 is the value of the O"v of a 1-look amplitude SAR image. This def­ inition is consistent with the multi-look processing using amplitude averaging of individual looks.
    return (0.5227/speckle_index_ratio(image_window))^2
end


@doc """

in the homogeneous areas, the ratio of the standard deviation to the mean is a good measure of speckle strength. 
For the filtered SAR images, this ratio is also frequently used to measure the amount of speckle reduction.

"""
function speckle_index_ratio(image_window)
    # ϵ added for numerical stability.
    ϵ = 0.00000001
    return sqrt(std(image_window)^2)/mean(image_window)
end



