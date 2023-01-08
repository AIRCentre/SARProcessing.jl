
using SARProcessing, SciPy, Images, Statistics




orbit_file_b = "test/testData/largeFiles/EO_workshop_full/S1B_OPER_AUX_POEORB_OPOD_20210330T202915_V20190627T225942_20190629T005942.EOF"
safefolderB = "test/testData/largeFiles/EO_workshop_full/S1B_IW_SLC__1SDV_20190628T014958_20190628T015025_016890_01FC87_FC0D.SAFE"


polarisation = SARProcessing.VV
swath = 2

metadata_path = SARProcessing.get_annotation_path_sentinel1(safefolderB, polarisation, swath);

metadataB = SARProcessing.Sentinel1MetaData(metadata_path);


phase_error_whole_burst = 2*pi*8

delta_t_s = metadataB.image.azimuth_time_interval;
lines_per_burst = metadataB.swath.lines_per_burst;

burst_duration = lines_per_burst * delta_t_s 
k_t = 1484

## We are 1.7 ms off( corresponds to approximate 13.2 meters) 
error_t = phase_error_whole_burst/(2*pi*k_t*burst_duration)

## we are 0.8454 pixels of, (could be one pixel of)
error_t/delta_t_s  



interpolator_b = SARProcessing.orbit_state_interpolator(
    SARProcessing.load_precise_orbit_sentinel1(orbit_file_b)
    ,metadataB);

burst_mid_time =   SARProcessing.get_burst_mid_times(metadataB)[4]
mid_burst_speed_b = SARProcessing.get_speed(interpolator_b(burst_mid_time))[1]

phase_ramp_b = SARProcessing.phase_ramp(
    collect( 6200:6210), 
    collect( 4000:4015), 
4, mid_burst_speed_b, metadataB);
    