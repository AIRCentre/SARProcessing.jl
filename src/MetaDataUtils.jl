get_range_pixel_spacing(meta_data::MetaData, c = LIGHT_SPEED) = c / ( 2.0*  get_range_sampling_rate(meta_data))

get_near_range(meta_data::MetaData, c = LIGHT_SPEED) = c *  get_slant_range_time_seconds(meta_data)/ 2.0



function get_image_duration_seconds(meta_data::MetaData)::Float64
    time_range = get_time_range(meta_data)
    return time_range[2]- time_range[1]
end


azimuth_time2row(azimuth_time::Real,azimuth_frequency,start_time) =  1 + (azimuth_time-start_time) * azimuth_frequency

row2azimuth_time(row_from_first_burst::Real,azimuth_frequency,start_time) = start_time + (row_from_first_burst-1)/azimuth_frequency 

"""
azimuth_time2row(azimuth_time::Real,metadata::MetaData)

    Returns the row corresponding to a specific azimuth time.

    Note: That the burst overlap is not considered in this function. 
    The actual image row will thus differ.
"""
function azimuth_time2row(azimuth_time::Real,metadata::MetaData)
    azimuth_frequency = get_azimuth_frequency(metadata)
    time_range = get_time_range(metadata)
    return azimuth_time2row(azimuth_time::Real,azimuth_frequency,time_range[1])
end


"""
row2azimuth_time(row_from_first_burst::Real,metadata::MetaData)

    Returns the azimuth_time corresponding to a specific row (as counted from first burst ignoring burst overlap)

    Note: That the burst overlap is not considered in this function. 
"""
function row2azimuth_time(row_from_first_burst::Real,metadata::MetaData)
    azimuth_frequency = get_azimuth_frequency(metadata)
    time_range = get_time_range(metadata)
    return row2azimuth_time(row_from_first_burst::Real,azimuth_frequency,time_range[1])
end

range2column(range::Real,range_pixel_spacing,near_range) =  1 + (range - near_range) / range_pixel_spacing

column2range(column::Real,range_pixel_spacing,near_range) = near_range + (column-1)*range_pixel_spacing

"""
range2column(range::Real,metadata::MetaData)

    Returns the image column corresponding to the range
"""
function range2column(range::Real,metadata::MetaData)
    range_pixel_spacing = get_range_pixel_spacing(metadata)
    near_range = get_near_range(metadata)
    return range2column(range,range_pixel_spacing,near_range) 
end

"""
column2range(column::Real,metadata::MetaData)

    Returns the range corresponding to the image column
"""
function column2range(column::Real,metadata::MetaData)
    range_pixel_spacing = get_range_pixel_spacing(metadata)
    near_range = get_near_range(metadata)
    return column2range(column,range_pixel_spacing,near_range) 
end