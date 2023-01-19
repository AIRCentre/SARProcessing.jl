# SARProcessing.jl

[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://aircentre.github.io/SARProcessing.jl/dev/)
[![CI](https://github.com/AIRCentre/SARProcessing.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/AIRCentre/SARProcessing.jl/actions/workflows/CI.yml)
[![Codecov](https://codecov.io/gh/AIRCentre/SARProcessing.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/AIRCentre/SARProcessing.jl)

<p align="center">
<img src="/Users/igaszczesniak/JuliaEO/notebooks/hands_on_sessions/Working_with_SAR_and_InSAR_Data/SARProcessing/figures/detect_ship.png" height="200"><br>

SARProcessing.jl is a flexible package for the processing of SAR data written in Julia. Its current features include loading [Single-Look-Complex](https://sentinels.copernicus.eu/web/sentinel/technical-guides/sentinel-1-sar/products-algorithms/level-1-algorithms/single-look-complex) (SLC) and [Ground-Range-Detected](https://sentinels.copernicus.eu/web/sentinel/technical-guides/sentinel-1-sar/products-algorithms/level-1-algorithms/ground-range-detected) (GRD) images, speckle reduction, object detection in SAR image, interferometry, and more. With a low barrier to entry and a large ecosystem of tools and libraries that allow quick prototyping, Julia has great potential for geospatial development. SARProcessing.jl is a much open-source project with the aim of making SAR data processing easy and fast for everyone. 

## Installation

SARProcessing.jl package is not registered yet. To install an unregistered package, use `Pkg.add(url = "URL")`, where URL is a git URL of the package

```julia
julia> using Pkg; Pkg.add(url = "https://github.com/AIRCentre/SARProcessing.jl")
```

Start using the package

```julia
using SARProcessing
```

## Quick start


The following examples are supposed to be self-explanatory. For further information check out documentation and [the example notebooks](https://github.com/AIRCentre/JuliaEO/tree/main/notebooks/hands_on_sessions/Working_with_SAR_and_InSAR_Data).

### Load and Show image

The primary step when working with any data is loading and displaying. TIFF images can be loaded using the `load_tiff` function in the SARProcessing module

```julia
#test images for the folder
slcSubsetPath = "../data/s1a-iw3-slc-vv_subset_hight9800_10400_width11000_11000.tiff"; 
slc_image = SARProcessing.load_tiff(slcSubsetPath);
grd_image_hom = SARProcessing.load_tiff("../data/grd_image_hom.tiff"); 
slc_image[1:4,1:4:end] 
```
and displayed by using the `sar2gray` function

```julia
slc_image = abs.(slc_image);
SARProcessing.sar2gray(slc_image, p_quantile = 0.95)
```

### Speckle Reduction

A common SAR processing step is speckle reduction. The objective of it is to reduce the variance of the pixels such that a better estimate of the intensity is found. The trade-off is a poorer spatial resolution. There are many speckle filters that all try to reduce the black-white granularity. The `speckle_mean_filter` function introduces the mean filter

```julia
descpek_mean_9 = SARProcessing.speckle_mean_filter(slc_image,[11,11]);
SARProcessing.sar2gray(descpek_mean_9, p_quantile = 0.95)
```

The mean filter is a simple filter that assign the mean value of a region to a center pixel.

### Object Detection

Object detection is used in many fiels of Earth Observation in both the land and maritime enviroment. For the maritime enviroment, it is used in great extent for, e.g., iceberg detection or ship detection. Often, object detection is used as a priliminary analysis whereafter the detected objects are classified as belonging to different classes.

We use CA-CFAR and CP-CFAR object detectors to find objects in an image. First, the size of both the guard and background (clutter) windows must be defined

```julia
background_window = 12; 
guard_window = 7;
probability_for_alarms = 10^(-12);
target_window=3;
```

Using the CA-CFAR to find objects in the image

```julia
image_cp_cfar = SARProcessing.constant_false_alarm_rate_with_convolution_and_pooling(slc_image.^2,background_window,guard_window,probability_for_alarms);
SARProcessing.sar2gray(image_cp_cfar, p_quantile = 0.9)
```

Using the CP-CFAR

```julia
image_cp_cfar = SARProcessing.constant_false_alarm_rate_with_convolution_and_pooling(slc_image.^2,background_window,guard_window,probability_for_alarms);
SARProcessing.sar2gray(image_cp_cfar, p_quantile = 0.95)
```

Getting location of objects and subset are further described in the [tutorial] (https://github.com/AIRCentre/JuliaEO/blob/main/notebooks/hands_on_sessions/Working_with_SAR_and_InSAR_Data/SARProcessing/3_Object_detection.ipynb).

### InSAR



## Project Status

The package is under development and the first version 0.1 will be released soon. Breaking changes are expected and some core missing features will be added. Upon that package version, 1.0 will be released and registered as an official Julia package.

As with all open-source software, please try it out and report your experience. We will be happy to gather any users' feedback to improve.

The package is tested on the current Julia version (1.8), and the current master on macOS.

## Contributing and Questions

Contributions are very welcome, as are feature requests and suggestions. Please open an
[issue](https://github.com/AIRCentre/SARProcessing.jl/issues) if you encounter any problems or would just like to ask a question.
