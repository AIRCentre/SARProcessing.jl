var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = SARProcessing","category":"page"},{"location":"#SARProcessing","page":"Home","title":"SARProcessing","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for SARProcessing.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [SARProcessing]","category":"page"},{"location":"#SARProcessing.Sentinel1AzimuthFmRate","page":"Home","title":"SARProcessing.Sentinel1AzimuthFmRate","text":"Sentinel1AzimuthFmRate\n\nreturns structure of Sentinel1AzimuthFmRate from metadata in .xml Sentinel1AzimuthFmRate is calculated for each burst, and is therefore saved in each burst\n\n\n\n\n\n","category":"type"},{"location":"#SARProcessing.Sentinel1AzimuthFmRate-Tuple{Any, Float64, Dates.DateTime}","page":"Home","title":"SARProcessing.Sentinel1AzimuthFmRate","text":"\" Sentinel1AzimuthFmRate\n\nConstructors for the Sentinel1AzimuthFmRate structure. \n\nIt takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1AzimuthFmRate data for a single burst as a structure. \n\nNote:\n    [ ] Perhaps change input vars from strutures to the specific values. -- Does the current implementaion use extra time?\n    [ ] What is needed? Maybe, e.g., polynomial is redudant in the later processing. Could then be deleted.\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.Sentinel1BurstInformation","page":"Home","title":"SARProcessing.Sentinel1BurstInformation","text":"Sentinel1BurstInformation\n\nreturns structure of Sentinel1BurstInformation from metadata in .xml Sentinel1BurstInformation contain information from Sentinel1DopplerCentroid and Sentinel1AzimuthFmRate\n\n\n\n\n\n","category":"type"},{"location":"#SARProcessing.Sentinel1BurstInformation-Tuple{Any, Int64, Dates.DateTime}","page":"Home","title":"SARProcessing.Sentinel1BurstInformation","text":"\" Sentinel1BurstInformation\n\nConstructors for the Sentinel1BurstInformation structure. \n\nIt takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1BurstInformation specific data for a single burst as a structure. \n\nInput:\n    meta_dict[dict]: a dictionary of the metadata.burst_number\n\n[Int]: Integer value of burst number.\n\noutput:\n    Sentinel1BurstInformation[structure of Sentinel1BurstInformation]\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.Sentinel1DopplerCentroid","page":"Home","title":"SARProcessing.Sentinel1DopplerCentroid","text":"Sentinel1DopplerCentroid\n\nreturns structure of Sentinel1DopplerCentroid from metadata in .xml Sentinel1DopplerCentroid is calculated for each burst, and is therefore saved in each burst\n\n\n\n\n\n","category":"type"},{"location":"#SARProcessing.Sentinel1DopplerCentroid-Tuple{Any, Float64, Dates.DateTime}","page":"Home","title":"SARProcessing.Sentinel1DopplerCentroid","text":"\" Sentinel1DopplerCentroid\n\nConstructors for the Sentinel1DopplerCentroid structure. \n\nIt takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1DopplerCentroid data for a single burst as a structure. \n\nNote:\n    [ ] Perhaps change input vars from strutures to the specific values. -- Does the current implementaion use extra time?\n    [ ] What is needed? Maybe, e.g., polynomial is redudant in the later processing. Could be deleted.\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.Sentinel1GeolocationGrid","page":"Home","title":"SARProcessing.Sentinel1GeolocationGrid","text":"Sentinel1GeolocationGrid\n\nreturns structure of Sentinel1GeolocationGrid from metadata in .xml\n\n\n\n\n\n","category":"type"},{"location":"#SARProcessing.Sentinel1GeolocationGrid-Tuple{Any, Dates.DateTime}","page":"Home","title":"SARProcessing.Sentinel1GeolocationGrid","text":"\" Sentinel1GeolocationGrid\n\nConstructors for the Sentinel1GeolocationGrid structure. \n\nIt takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1GeolocationGrid as a structure. Input in the Sentinel1GeolocationGrid file:\n    lines: Reference image MDS line to which this geolocation grid point applies.\n    samples,\n    latitude: Geodetic latitude of grid point [degrees].\n    longitude: Geodetic longitude of grid point [degrees].\n    azimuth_time: Zero Doppler azimuth time to which grid point applies [UTC].\n    slant_range_time_seconds: Two-way slant range time to grid point.\n    elevation_angle: Elevation angle to grid point [degrees].\n    incidence_angle: Incidence angle to grid point [degrees].\n    height: Height of the grid point above sea level [m].\n\nExample:\n    # accesing the geolocation data from the full metadata.\n    xmlPath = \"s1a-iw1-slc-vh-20220220t144146-20220220t144211-041998-050092-001.xml\"\n    Metadata1 = Sentinel1MetaData(xmlPath)\n    geolocation = Metadata1.geolocation\n\n    # accessing the geolocation directly from the xml.\n    meta_dict = read_xml_as_dict(xmlPath)\n    geolocation = Sentinel1GeolocationGrid(meta_dict)\n    \n\nInput:\n    meta_dict[dict]: a dictionary of the metadata.\n\noutput:\n    Sentinel1GeolocationGrid[structure of Sentinel1GeolocationGrid]\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.Sentinel1Header","page":"Home","title":"SARProcessing.Sentinel1Header","text":"Sentinel1Header\n\nreturns structure of Sentinel1Header from metadata in .xml\n\n\n\n\n\n","category":"type"},{"location":"#SARProcessing.Sentinel1Header-Tuple{Any, Dates.DateTime}","page":"Home","title":"SARProcessing.Sentinel1Header","text":"\" Sentinel1Header\n\nConstructors for the Sentinel1Header structure. \n\nIt takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1Header as a structure. Input in the header file:\n    missionId: Mission identifier for this data set.\n    productType: Product type for this data set.\n    polarisation: Polarisation for this data set.\n    mission_data_take_id: Mission data take identifier.\n    swath: Swath identifier for this data set. This element identifies the swath that applies to all data contained within this data set. The swath identifier \"EW\" is used for products in which the 5 EW swaths have been merged. Likewise, \"IW\" is used for products in which the 3 IW swaths have been merged.\n    mode: Sensor mode for this data set.\n    start_time: Zero Doppler start time of the output image [UTC].\n    stop_time: Zero Doppler stop time of the output image [UTC].\n    absolute_orbit_number: Absolute orbit number at data set start time.\n    image_number: Image number. For WV products the image number is used to distinguish between vignettes. For SM, IW and EW modes the image number is still used but refers instead to each swath and polarisation combination (known as the 'channel') of the data.\n\nInput:\n    meta_dict[dict]: a dictionary of the metadata.\n\noutput:\n    Sentinel1Header[structure of Sentinel1Header]\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.Sentinel1ImageInformation","page":"Home","title":"SARProcessing.Sentinel1ImageInformation","text":"Sentinel1ImageInformation\n\nreturns structure of Sentinel1ImageInformation from metadata in .xml\n\n\n\n\n\n","category":"type"},{"location":"#SARProcessing.Sentinel1ImageInformation-Tuple{Any}","page":"Home","title":"SARProcessing.Sentinel1ImageInformation","text":"\" Sentinel1ImageInformation\n\nConstructor for the Sentinel1ImageInformation structure. \n\nIt takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1ImageInformation as a structure. Input in the Sentinel1ImageInformation file:\n    range_pixel_spacing: Pixel spacing between range samples [m].\n    azimuth_frequency: Azimuth line frequency of the output image [Hz]. This is the inverse of the azimuth_timeInterval.\n    slant_range_time_seconds: Two-way slant range time to first sample.\n    incidence_angle_mid_swath: Incidence angle at mid swath [degrees].\n    azimuth_pixel_spacing: Nominal pixel spacing between range lines [m].\n    number_of_samples: Total number of samples in the output image (image width).\n\nInput:\n    meta_dict[dict]: a dictionary of the metadata.\n\noutput:\n    Sentinel1ImageInformation[structure of Sentinel1ImageInformation]\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.Sentinel1MetaData","page":"Home","title":"SARProcessing.Sentinel1MetaData","text":"Sentinel1MetaData:     Metadata structure for the Sentinel-1 satellite for each burst in the swath.\n\nGeneral metadata info is kept in the following structures:\n    - Sentinel1Header\n    - Sentinel1ProductInformation\n    - Sentinel1ImageInformation\n    - Sentinel1SwathTiming\n    - Sentinel1GeolocationGrid\nSentinel1BurstInformation specific Info is kept in \n    - Vector{Sentinel1BurstInformation}\n\nExample:     slcMetadata = Sentinel1MetaData(meta_dict)\n\nInput:\n    meta_dict: xml file.\n\ncan be accessed as, e.g., \nslcMetadata.product.radar_frequency --> 5.40500045433435e9::Float64\nslcMetadata.header.swath --> 1::Int\nslcMetadata.header.mode --> \"IW\"::String\nslcMetadata.header.polarisation --> \"VH\"::String\n\n\n\n\n\n","category":"type"},{"location":"#SARProcessing.Sentinel1MetaData-Tuple{String}","page":"Home","title":"SARProcessing.Sentinel1MetaData","text":"\" Sentinel1MetaData\n\nConstructors for the Sentinel1MetaData structure. \nIt takes a Sentinel-1 single swath metafile in .xml format and constructs the metadata structure using the individual sub-structures in the metadata.\nThe individual sub-structures in the metadata are:\n- Sentinel1Header\n- Sentinel1ProductInformation\n- Sentinel1ImageInformation\n- Sentinel1SwathTiming\n- Sentinel1BurstInformation\n- Sentinel1GeolocationGrid\n\nInput:\n    xmlFile[string]: path of swath specific metadata in xml.format.\n\noutput:\n    Sentinel1MetaData[structure of Sentinel1MetaData]: Structure with all Sentinel-1 metadata for a swath.\n\n\nExample:\n\nGetting the t0 for the 5th burst:\n    metadata = Sentinel1MetaData(annotation.xml)\n    metadata.bursts.azimuthFmRate[5].t0\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.Sentinel1ProductInformation","page":"Home","title":"SARProcessing.Sentinel1ProductInformation","text":"Sentinel1ProductInformation\n\nreturns structure of product information \n\n\n\n\n\n","category":"type"},{"location":"#SARProcessing.Sentinel1ProductInformation-Tuple{Any}","page":"Home","title":"SARProcessing.Sentinel1ProductInformation","text":"\" Sentinel1ProductInformation\n\nConstructors for the Sentinel1ProductInformation structure. \n\nIt takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1ProductInformation as a structure. Sentinel1ProductInformation file:\n    pass: Direction of the orbit (ascending, descending)\n    timeliness_category: Timeliness category under which the product was produced, i.e. time frame from the data acquisition\n    platform_heading: Platform heading relative to North [degrees].\n    projection: Projection of the image, either slant range or ground range.\n    range_sampling_rate: Range sample rate [Hz]\n    radar_frequency: Radar (carrier) frequency [Hz]\n    azimuth_steering_rate: Azimuth steering rate for IW and EW modes [degrees/s].\n\nInput:\n    meta_dict[dict]: a dictionary of the metadata.\n\noutput:\n    Sentinel1ProductInformation[structure of Sentinel1ProductInformation]\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.Sentinel1SwathTiming","page":"Home","title":"SARProcessing.Sentinel1SwathTiming","text":"Sentinel1SwathTiming\n\nreturns structure of Sentinel1SwathTiming from metadata in .xml\n\n\n\n\n\n","category":"type"},{"location":"#SARProcessing.Sentinel1SwathTiming-Tuple{Any}","page":"Home","title":"SARProcessing.Sentinel1SwathTiming","text":"\" Sentinel1SwathTiming\n\nConstructors for the Sentinel1SwathTiming structure. \n\nIt takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1SwathTiming as a structure. \n\nInput:\n    meta_dict[dict]: a dictionary of the metadata.\n\noutput:\n    Sentinel1SwathTiming[structure of Sentinel1SwathTiming]\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.TandemxDEM","page":"Home","title":"SARProcessing.TandemxDEM","text":"TandemxDEM <: DEM\n\nA DEM implementation for Tandem-X DEM data.\n\n\n\n\n\n","category":"type"},{"location":"#SARProcessing._cell_averaging_constant_false_alarm_rate_pixel-Union{Tuple{Matrix{T}}, Tuple{T}, Tuple{Matrix{T}, Integer}, Tuple{Matrix{T}, Integer, Integer}, Tuple{Matrix{T}, Integer, Integer, Real}} where T<:Real","page":"Home","title":"SARProcessing._cell_averaging_constant_false_alarm_rate_pixel","text":"\n\n\n\n","category":"method"},{"location":"#SARProcessing._doppler_centroid_frequency-Tuple{Any, Any, Any}","page":"Home","title":"SARProcessing._doppler_centroid_frequency","text":"Computes Doppler centroid frequency (fetac), as given by equation 13 in the document \"Definition of the TOPS SLC deramping function  for products generated by the S-1 IPF\" by Miranda (2014): https://sentinel.esa.int/documents/247904/1653442/sentinel-1-tops-slcderamping\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing._doppler_fm_rate-Tuple{Any, Any, Any}","page":"Home","title":"SARProcessing._doppler_fm_rate","text":"Computes Doppler FM rate (ka), as given by equation 11 in the document \"Definition of the TOPS SLC deramping function  for products generated by the S-1 IPF\" by Miranda (2014): https://sentinel.esa.int/documents/247904/1653442/sentinel-1-tops-slcderamping\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing._speckle_lee_filter_pixel-Union{Tuple{T}, Tuple{Matrix{T}, T}} where T<:Real","page":"Home","title":"SARProcessing._speckle_lee_filter_pixel","text":"\" despeckled pixel value\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing._speckle_lee_weighting-Union{Tuple{T}, Tuple{Matrix{T}, T}} where T<:Real","page":"Home","title":"SARProcessing._speckle_lee_weighting","text":"Weighting coefficient for lee filter\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing._two_parameter_constant_false_alarm_rate_pixel-Union{Tuple{Matrix{T}}, Tuple{T}, Tuple{Matrix{T}, Integer}, Tuple{Matrix{T}, Integer, Real}} where T<:Real","page":"Home","title":"SARProcessing._two_parameter_constant_false_alarm_rate_pixel","text":"\n\n\n\n","category":"method"},{"location":"#SARProcessing.add_padding","page":"Home","title":"SARProcessing.add_padding","text":"Add padding to array\n\nQ for simon:\n\n\n\n\n\n","category":"function"},{"location":"#SARProcessing.approx_line_of_sight-Tuple{SARProcessing.OrbitState, Real}","page":"Home","title":"SARProcessing.approx_line_of_sight","text":"approxlineofsight(orbitstate::OrbitState,incidenceanglemid::Real)     # Output     - line_of_sight::Array{float}(3): Line of sight to mid swath\n\n#TODO, interpolate geolocationGridPoint from metadata instead?\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.azimuth_time2row-Tuple{Real, SARProcessing.MetaData}","page":"Home","title":"SARProcessing.azimuth_time2row","text":"azimuthtime2row(azimuthtime::Real,metadata::MetaData)\n\nReturns the row corresponding to a specific azimuth time.\n\nNote: That the burst overlap is not considered in this function. \nThe actual image row will thus differ.\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.binarize_array-Union{Tuple{Matrix{T}}, Tuple{T}, Tuple{Matrix{T}, Real}} where T<:Real","page":"Home","title":"SARProcessing.binarize_array","text":"binarize_array(image::Matrix{T}, threshold::Real= 0.0001) where T<:Real\nMaking a mask with boolean values of image\n\nExamples:\n\n    bool_array = binarize_array(rand(10,10), threshold= 0.0001)\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.cell_averaging_constant_false_alarm_rate-Union{Tuple{Matrix{T}}, Tuple{T}, Tuple{Matrix{T}, Integer}, Tuple{Matrix{T}, Integer, Integer}, Tuple{Matrix{T}, Integer, Integer, Integer}, Tuple{Matrix{T}, Integer, Integer, Integer, Real}} where T<:Real","page":"Home","title":"SARProcessing.cell_averaging_constant_false_alarm_rate","text":"The two paramter (TP)-CFAR object detection method described in The State-of-the-Art in Ship Detection in Synthetic Aperture Radar imagery, D.J. Crips, 2004, in section 5.2 Adaptive threshold algorithms\n\nFinding CFAR for all pixels in an image.\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.column2range-Tuple{Real, SARProcessing.MetaData}","page":"Home","title":"SARProcessing.column2range","text":"column2range(column::Real,metadata::MetaData)\n\nReturns the range corresponding to the image column\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.constant_false_alarm_rate_with_convolution_and_pooling-Union{Tuple{Matrix{T}}, Tuple{T}, Tuple{Matrix{T}, Integer}, Tuple{Matrix{T}, Integer, Integer}, Tuple{Matrix{T}, Integer, Integer, Real}} where T<:Real","page":"Home","title":"SARProcessing.constant_false_alarm_rate_with_convolution_and_pooling","text":"\" The The constant false alarm rate with convolution and pooling (CP-CFAR) object detection method described in: Z. Cui, H. Quan, Z. Cao, S. Xu, C. Ding and J. Wu, \"SAR Target CFAR Detection Via GPU Parallel Operation,\"  in IEEE Journal of Selected Topics in Applied Earth Observations and Remote Sensing,  vol. 11, no. 12, pp. 4884-4894, Dec. 2018, doi: 10.1109/JSTARS.2018.2879082.\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.conv2d","page":"Home","title":"SARProcessing.conv2d","text":"Convolution function copied from Yosi Pramajaya. Credits goes to him. In his blogpost, he showed this implementation was faster than many others..\nSee https://towardsdatascience.com/understanding-convolution-by-implementing-in-julia-3ed744e2e933\n\ndont want to have too many packages. I therefore wont use Convolution pkg.\n\nInput:\n    input::Matrix{Float64}. The input image,\n    filter::Matrix{Float64}. The  filter/kernel to convolve\n    stride::Int64 = 1. Stride of the convolution.\n    padding::String = \"valid\". If padding is used [\"valid\" or \"same\"]\n\nOutput:\n    result::Matrix{Float64}. convolved image.\n\n# Example:\n    #define a filter.\n    average_pool_filter = filters.meanFilter([2,2])\n    #perform convolution.\n    image = operations.conv2d(image, average_pool_filter,2, \"same\")\n\n\n\n\n\n","category":"function"},{"location":"#SARProcessing.ecef2SAR_index-Union{Tuple{T}, Tuple{Vector{T}, Any, Real, Real, Real, Any}} where T<:Real","page":"Home","title":"SARProcessing.ecef2SAR_index","text":"ecef2SARindex(     ecefcoordinate::Array{T,1},     interpolator,     rangepixelspacing::Real,     azimuthfrequency::Real,     nearrange::Real,     imagedurationseconds::Real     ) where T <: Real\n\nConvert ECEF-coordinates [X,Y,Z]  to SARindex (rowfromfirstburst, image_column) \n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.ecef2geodetic-Union{Tuple{Vector{T}}, Tuple{T}} where T<:Real","page":"Home","title":"SARProcessing.ecef2geodetic","text":"ecef2geodetic(ecefcoordinate::Array{Real,1};                         semimajoraxis=6378137., flattening=1/298.257223563,                         tolerancelatitude = 1.e-12, tolerance_height = 1.e-5)\n\nConvert ECEF-coordinates [X,Y,Z] to geodetic-coordinates [latitude(radians),longitude(radians),height] (WGS-84) radians\n\n(Based on B.R. Bowring, \"The accuracy of geodetic latitude and height equations\",\nSurvey Review, v28 #218, October 1985 pp.202-206).\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.ellipsoid_intersect-Union{Tuple{T}, Tuple{S}, Tuple{Vector{T}, Vector{S}}} where {S<:Real, T<:Real}","page":"Home","title":"SARProcessing.ellipsoid_intersect","text":"ellipsoidintersect(xsat::Array{Real,1},normalisedlineofsight::Array{Real,1};                                 semimajor_axis::Real=6378137.,flattening::Real=1/298.257223563)\n\nComputes the intersection between the satellite line of sight and the earth ellipsoid in ECEF-coordinates\n# Arguments\n- `x_sat::Array{Real,1}`: [X,Y,Z] position of the satellite in ECEF-coordinates.\n- `normalised_line_of_sight::Array{Real,1}`: Normalised Line of sight\n# Output\n- `x_0::Array{Real,1}`: intersection between line and ellipsoid in ECEF-coordinates.\n# Note:\nEquations follows I. Cumming and F. Wong (2005) p. 558-559\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.geodetic2SAR_index-Union{Tuple{T}, Tuple{Vector{T}, Any, SARProcessing.MetaData}} where T<:Real","page":"Home","title":"SARProcessing.geodetic2SAR_index","text":"geodetic2SARindex(geodeticcoordinate::Array{T,1}, interpolator, metadata::MetaData) where T <: Real\n\nConvert geodetic-coordinates [latitude(radians),longitude(radians),height]  to SARindex (rowfromfirstburst, image_column) \n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.geodetic2ecef-Union{Tuple{Vector{T}}, Tuple{T}} where T<:Real","page":"Home","title":"SARProcessing.geodetic2ecef","text":"geodetic2ecef(geodeticcoordinate::Array{Real,1}; semimajoraxis::Real=WGS84SEMIMAJORAXIS,     flattening::Real=WGS84_FLATTENING)\n\nConvert geodetic-coordinates [latitude(radians),longitude(radians),height] (WGS-84) to ECEF-coordinates [X,Y,Z]\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.get_burst_mid_times-Tuple{T} where T<:SARProcessing.SingleLookComplex","page":"Home","title":"SARProcessing.get_burst_mid_times","text":"getburstmid_times(image::T) where T <: SingleLookComplex\n\nReturns a vector of the mid burst times for the burst in the image. \nOnly bursts included in the image view are included\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.get_burst_numbers-Tuple{SARProcessing.Sentinel1SLC}","page":"Home","title":"SARProcessing.get_burst_numbers","text":"getburstnumbers(image::Sentinel1SLC)\n\nReturns list of burst included in the image subset\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.get_coordinate-Union{Tuple{T}, Tuple{T, Tuple{Integer, Integer}}} where T<:SARProcessing.DEM","page":"Home","title":"SARProcessing.get_coordinate","text":"get_coordinate(dem::T,index::Tuple{Integer,Integer}) where T <: DEM\n\nGet the coordinate for a certain index in the DEM. \n(All the DEM's are stored as a matrix of heights)\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.get_image_rows-Tuple{SARProcessing.Sentinel1MetaData, Any}","page":"Home","title":"SARProcessing.get_image_rows","text":"getimagerows(metadata::Sentinel1MetaData, rowfromfirstburst)\n\nConverts the row number representing a unique azimuth time, rowfromfirst_burst,  to the number in the full image. Note that two results are returned when the row appears in two bursts\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.get_index-Union{Tuple{T}, Tuple{T, Tuple{Real, Real}}} where T<:SARProcessing.DEM","page":"Home","title":"SARProcessing.get_index","text":"get_index(dem::T,coordinate::Tuple{Real,Real}) where T <: DEM\n\nGet the index of the DEM corresponding to the coordinate. \n(All the DEM's are stored as a matrix of heights)\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.get_sentinel1_annotation_paths-Tuple{String}","page":"Home","title":"SARProcessing.get_sentinel1_annotation_paths","text":"getsentinel1annotationpaths(safepath::string)\n\nGetting the paths for the annotation files for a SLC image using its .SAFE folder path.\n\nParameters\n\n* safe_path::String: path of .SAFE folder for one image.\n\nReturns\n\n* annotationPaths::Vector: Vector of paths for annotation files in .SAFE folder\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.get_subset-Union{Tuple{P}, Tuple{Matrix{T} where T<:Real, Vector{P}}, Tuple{Matrix{T} where T<:Real, Vector{P}, Vector{P}}} where P<:Integer","page":"Home","title":"SARProcessing.get_subset","text":"Extracting a subset from an image. The subset will be extraxted from the image row/column defined by coordinate and size subset_size.\n\nInput:\n    image: The image array\n    coordinate::Vector{Int64}. Center coordinate of subset, in image geometry.\n    subset_size::Vector{Int64}=[75,75]. Size of the subset. \n\nOutput:\n    subset::Array{Float64, 3}. The three dimensional subset [rows,columns,dimensions.] with dimension=1 for an input 2D array.\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.get_window-Tuple{SARProcessing.Sentinel1SLC}","page":"Home","title":"SARProcessing.get_window","text":"get_window(image::Sentinel1SLC)\n\nReturns the window of the complete Sentinel image covered the \"image\"\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.load_precise_orbit_sentinel1-Tuple{Any}","page":"Home","title":"SARProcessing.load_precise_orbit_sentinel1","text":"loadpreciseorbit_sentinel1(path)\n\nLoads a Sentinel 1 orbit file\n\nReturns\n\nVector{OrbitState}\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.load_tandemx_dem-Tuple{String}","page":"Home","title":"SARProcessing.load_tandemx_dem","text":"load_tandemx_dem(tiffPath::String) -> TandemxDEM\n\nLoad a Tandem-X DEM tiff. The Tandem-X DEM's can be downloaded from https://download.geoservice.dlr.de/TDM90/.\nNote: Invalid values are replaced with missing\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.load_tiff","page":"Home","title":"SARProcessing.load_tiff","text":"load_tiff(filepath::String, window=nothing; convertToDouble = true,flip = true)\n\nRead a Sentinel 1 tiff file.\n# Examples:\n```jldoctest\njulia> filepath = \"s1a-iw3-slc-vv-20220918t074921-20220918t074946-045056-056232-006.tiff\"\njulia> data = readSwathSLC(filePath, [(501,600),(501,650)]);\njulia> typeof(data)\nMatrix{ComplexF64}\njulia> size(data)\n(100,150)\n```\n\n\n\n\n\n","category":"function"},{"location":"#SARProcessing.mask_array_nan-Union{Tuple{Matrix{T}}, Tuple{T}, Tuple{Matrix{T}, Real}} where T<:Real","page":"Home","title":"SARProcessing.mask_array_nan","text":"Making a mask with 1/NaN values of image\n\nExamples:\n\n    array_with_nan = mask_array_nan(rand(10,10), 0.5)\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.mean_filter","page":"Home","title":"SARProcessing.mean_filter","text":"\" meanFilter     Creates a mean filter for a iamge\n\nexamples:         filter = meanFilter([3,3])         or          filter = meanFilter([3]) \n\n\n\n\n\n","category":"function"},{"location":"#SARProcessing.object_locations-Union{Tuple{Matrix{T}}, Tuple{T}} where T<:Real","page":"Home","title":"SARProcessing.object_locations","text":"\"\n\nFind center locations of objects in a binary image.\n\n# Example:\n    object_centers = object_locations(binary_array)\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.orbit_state_interpolator-Tuple{Vector{SARProcessing.OrbitState}, SARProcessing.SARImage}","page":"Home","title":"SARProcessing.orbit_state_interpolator","text":"orbitstateinterpolator(orbitstates::Vector{OrbitState}, image::SARImage,      polynomialdegree::Integer=4, margin::Integer = 3 )\n\nCreate a polynomial interpolation function for orbit states valid in the time span\nfrom image start time to image end time.\n\n#Returns\nAnonymous interpolation function. (Input: seconds_from_t_start::Float64, Output: state::OrbitState)\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.phase_ramp-Union{Tuple{T}, Tuple{Vector{T}, Vector{T}, Int64, Float64, Float64, Vector{Float64}, Float64, Vector{Float64}, Float64, Float64, Int64, Int64, Float64, Float64, Number}, Tuple{Vector{T}, Vector{T}, Int64, Float64, Float64, Vector{Float64}, Float64, Vector{Float64}, Float64, Float64, Int64, Int64, Float64, Float64, Number, Any}} where T<:Integer","page":"Home","title":"SARProcessing.phase_ramp","text":"phaseramp(rows::Vector{T}, columns::Vector{T}, burstnumber::Int64, vs::Float64,             kpsi::Float64, dccoefficient::Vector{Float64},              dctau0::Float64, fmcoefficient::Vector{Float64},              fmtau0::Float64, fc::Float64, linesperburst::Int64,              numberofsamples::Int64, deltats::Float64,              deltataus::Float64, tau0::Number, c=LIGHT_SPEED::Real) where T <: Integer\n\nComputes the phase ramp (phi) for the given burst number for input rows (lines) and columns (samples).\n\nNOTES\n\nreference: Equation numbers refer to the document \"Definition of the TOPS SLC deramping function  for products generated by the S-1 IPF\" by Miranda (2014):      https://sentinel.esa.int/documents/247904/1653442/sentinel-1-tops-slc_deramping\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.phase_ramp-Union{Tuple{T}, Tuple{Vector{T}, Vector{T}, Int64, Float64, SARProcessing.Sentinel1MetaData}} where T<:Integer","page":"Home","title":"SARProcessing.phase_ramp","text":"phaseramp(rows::Vector{T}, columns::Vector{T},              burstnumber::Int64, midburstspeed::Float64, meta_data::Sentinel1MetaData) where T <: Integer\n\nExtracts relevant parameters from metadata and calls phaseramp().\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.range2column-Tuple{Real, SARProcessing.MetaData}","page":"Home","title":"SARProcessing.range2column","text":"range2column(range::Real,metadata::MetaData)\n\nReturns the image column corresponding to the range\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.row2azimuth_time-Tuple{Real, SARProcessing.MetaData}","page":"Home","title":"SARProcessing.row2azimuth_time","text":"row2azimuthtime(rowfromfirstburst::Real,metadata::MetaData)\n\nReturns the azimuth_time corresponding to a specific row (as counted from first burst ignoring burst overlap)\n\nNote: That the burst overlap is not considered in this function.\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.sar2gray-Union{Tuple{AbstractArray{T}}, Tuple{T}} where T<:Real","page":"Home","title":"SARProcessing.sar2gray","text":"sar2gray(data::AbstractArray; p_quantile = 0.85)\n\nMaps the data to values between 0 and 1 and convert into a gray scaled image.  The minimum data value is mapped to 0 and all values above the p_quantile is mapped to 1\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.sar_index2geodetic-Tuple{Real, Real, Real, Any, SARProcessing.MetaData}","page":"Home","title":"SARProcessing.sar_index2geodetic","text":"sarindex2geodetic(rowfromfirstburst,     image_column,      height,      interpolator,     metadata::MetaData)\n\nConvert SAR_index (row_from_first_burst, image_column) to geodetic coordinates [latitude(radians),longitude(radians),height]\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.search_directory-Tuple{Any, Any}","page":"Home","title":"SARProcessing.search_directory","text":"\"\n\nsearch dir\n\nSearching a directory for files with extension.\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.sobel_filter","page":"Home","title":"SARProcessing.sobel_filter","text":"\" sobelFilter(input::Matrix{Float64},stride::Int64 = 1,padding::String=\"same\")::Matrix{Float64}     Creates a sobelFilter for a image using edgeVertical() and edgeHorizontal()\n\nexamples:         sobel_image = filters.sobelFilter(image)\n\n\n\n\n\n","category":"function"},{"location":"#SARProcessing.solve_radar-Union{Tuple{T}, Tuple{Real, Real, Vector{T}, SARProcessing.OrbitState}} where T<:Real","page":"Home","title":"SARProcessing.solve_radar","text":"solve_radar\nFind the point that is range away from the satellite, orthogonal on the flight directions\nand \"height\" above the elipsiod using Newton_rhapsody method.\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.speckle_index_ratio-Tuple{Any}","page":"Home","title":"SARProcessing.speckle_index_ratio","text":"in the homogeneous areas, the ratio of the standard deviation to the mean is a good measure of speckle strength.  For the filtered SAR images, this ratio is also frequently used to measure the amount of speckle reduction.\n\n\n\n\n\n","category":"method"},{"location":"#SARProcessing.speckle_lee_filter","page":"Home","title":"SARProcessing.speckle_lee_filter","text":"original speckle lee filter for SAR images, see 'Refined Filtering of Image Noise Using Local Statistics' (1980)\nThe Lee filter is an adaptive filter in the sence that it used the local statistics to determine the amount of speckle filtering.\nIn homogenous region, it will resemble a mean filter. In inhomogenous region, i.e., near cities or edges, it will do less filtering.\n\nInputs\n\nimage::Matrix, Speckled input iamge. 2D matrix.\n\nfilter_size::[integer,integer]. Filter size of speckle filter\n\nOutputs\n\ndespeckled_image::Matrix, despeckled image\n\nexamples\n\ndescpeckled_image = SARProcessing.speckle_lee_filter(speckle_image,[9,9]);\n\ndescpeckled_image = SARProcessing.speckle_lee_filter(speckle_image,[3,3]);\n\n\n\n\n\n","category":"function"},{"location":"#SARProcessing.speckle_mean_filter","page":"Home","title":"SARProcessing.speckle_mean_filter","text":"mean filter\n\nAlso called BoxFilter for SAR speckle reduction. Sometimes even Average filter.\n\nexamples\n\ndescpekmean3 = specklemeanfilter(abseloute_image,[3,3])\n\ndescpekmean3 = specklemeanfilter(abseloute_image,[9,9])\n\n\n\n\n\n","category":"function"},{"location":"#SARProcessing.speckle_median_filter","page":"Home","title":"SARProcessing.speckle_median_filter","text":"median filter\n\n\n\n\n\n","category":"function"},{"location":"#SARProcessing.two_parameter_constant_false_alarm_rate-Union{Tuple{Matrix{T}}, Tuple{T}, Tuple{Matrix{T}, Integer}, Tuple{Matrix{T}, Integer, Integer}, Tuple{Matrix{T}, Integer, Integer, Real}} where T<:Real","page":"Home","title":"SARProcessing.two_parameter_constant_false_alarm_rate","text":"The two paramter (TP)-CFAR object detection method described in The State-of-the-Art in Ship Detection in Synthetic Aperture Radar imagery, D.J. Crips, 2004, in section 5.2 Adaptive threshold algorithms\n\nFinding CFAR for all pixels in an image.\n\n\n\n\n\n","category":"method"}]
}
