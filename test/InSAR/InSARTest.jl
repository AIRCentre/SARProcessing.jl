"""
Checks the validity of the helper functions (polynomials) _doppler_fm_rate and _doppler_centroid_frequency
"""
function polynomial_test(f, x, param, x0)
    # Arrang
    # check if output is real
    output = f(x, param, x0);

    # Act
    output_type = eltype(output);
    check_real = output_type <: Real

    # check that the polynomial is not all zeros
    check_non_zero = sum(output .!= 0) != 0;

    # check if function is monotonically increasing/decreasing
    check_monotonically_increasing = [output[i+1] >= output[i] for i in eachindex(output[1:end-1])];
    check_monotonically_decreasing = [output[i+1] <= output[i] for i in eachindex(output[1:end-1])];
    check_monotonic = all(check_monotonically_increasing) | all(check_monotonically_decreasing);

    # Assert
    test_ok = all([check_real, check_non_zero, check_monotonic]);

    if !test_ok
        println("Debug info: ", string(StackTraces.stacktrace()[1].func))
        println("eltype(_doppler_fm_rate(x, param, x0)): ", output_type)
        println("Is monotonically increasing: ", all(check_monotonically_increasing))
        println("Is monotonically decreasing: ", all(check_monotonically_decreasing))
    end

    return test_ok
end

function _doppler_fm_rate_test()
    # Load
    image = load_test_slc_image();
    burst_number = SARProcessing.get_burst_numbers(image)[1]
    metadata = image.metadata;
    tau_0 = metadata.image.slant_range_time_seconds; 
    Delta_tau_s = 1/metadata.product.range_sampling_rate;
    columns = 1:metadata.image.number_of_samples;
    range_time = tau_0 .+ (collect(columns) .- 1) .* Delta_tau_s
    fm_meta = metadata.bursts[burst_number].azimuth_fm_rate;

    # Test
    return polynomial_test(SARProcessing._doppler_fm_rate, range_time, fm_meta.polynomial, fm_meta.t0)
end

function _doppler_centroid_frequency_test()
    # Load
    image = load_test_slc_image();
    burst_number = SARProcessing.get_burst_numbers(image)[1]
    metadata = image.metadata;
    tau_0 = metadata.image.slant_range_time_seconds; 
    Delta_tau_s = 1/metadata.product.range_sampling_rate;
    columns = 1:metadata.image.number_of_samples;
    range_time = tau_0 .+ (collect(columns) .- 1) .* Delta_tau_s
    dc_meta = metadata.bursts[burst_number].doppler_centroid;

    # Test
    return polynomial_test(SARProcessing._doppler_centroid_frequency, range_time, dc_meta.polynomial, dc_meta.t0)
end

function phase_ramp_grid_test()
    ## Arrange
    # load image
    image = load_test_slc_image();
    meta_data = image.metadata;
    burst_number = SARProcessing.get_burst_numbers(image)[1]

    # get range times from columns/samples
    orbit_states = SARProcessing.load_precise_orbit_sentinel1(PRECISE_ORBIT_TEST_FILE2)

    # ## Get mid burst time and speed
    interpolator = SARProcessing.orbit_state_interpolator(orbit_states, image)
    mid_burst_state = SARProcessing.get_burst_mid_states(image, interpolator)
    mid_burst_speed = SARProcessing.get_speed.(mid_burst_state)[1]

    # Create some matrices of row and column indices
    image_window = SARProcessing.get_window(image)
    columns = image_window[2][1]:image_window[2][2]
    rows = image_window[1][1]:image_window[1][2]

    ## Act
    ramp = SARProcessing.phase_ramp_grid(rows, columns, burst_number, mid_burst_speed, meta_data);

    ## Assert
    # check if output is real
    output_type = eltype(ramp);
    check_real = output_type <: Real

    #check size 
    check_size = size(ramp) == size(image.data)

    # check that the ramp is not all zeros
    check_non_zero = sum(ramp .!= 0) != 0;

    test_ok = all([check_real, check_non_zero, check_size])
    return test_ok
end

function phase_ramp_test()
    ## Arrange
    # load image
    image = load_test_slc_image();
    meta_data = image.metadata;
    burst_number = SARProcessing.get_burst_numbers(image)[1]

    # get range times from columns/samples
    orbit_states = SARProcessing.load_precise_orbit_sentinel1(PRECISE_ORBIT_TEST_FILE2)

    # ## Get mid burst time and speed
    interpolator = SARProcessing.orbit_state_interpolator(orbit_states, image)
    mid_burst_state = SARProcessing.get_burst_mid_states(image, interpolator)
    mid_burst_speed = SARProcessing.get_speed.(mid_burst_state)[1]

    # Create some matrices of row and column indices
    columns = collect(11:15)
    rows = collect(10:-2:1)

    ## Act
    ramp = SARProcessing.phase_ramp(rows, columns, burst_number, mid_burst_speed, meta_data);

    ## Assert
    # check if output is real
    output_type = eltype(ramp);
    check_real = output_type <: Real

    # check size
    check_size = length(ramp) == 5

    # check that the ramp is not all zeros
    check_non_zero = sum(ramp .!= 0) != 0;

    test_ok = all([check_real, check_non_zero, check_size])
    return test_ok
end

function deramp_test()
    ## Arrange
    # load image
    image = load_test_slc_image();
    meta_data = image.metadata;
    burst_number = SARProcessing.get_burst_numbers(image)[1]

    # get range times from columns/samples
    orbit_states = SARProcessing.load_precise_orbit_sentinel1(PRECISE_ORBIT_TEST_FILE2)

    # ## Get mid burst time and speed
    interpolator = SARProcessing.orbit_state_interpolator(orbit_states, image)
    mid_burst_state = SARProcessing.get_burst_mid_states(image,interpolator)
    mid_burst_speed = SARProcessing.get_speed.(mid_burst_state)[1]

    # Create some matrices of row and colomn indeces
    image_window = SARProcessing.get_window(image)
    columns = image_window[2][1]:image_window[2][2]
    rows = image_window[1][1]:image_window[1][2]

    ## Act 
    ramp = SARProcessing.phase_ramp_grid(rows, columns, burst_number[1], mid_burst_speed, meta_data);
    deramped_image = SARProcessing.deramp(image, ramp)

    ## Assert
    output_type = eltype(deramped_image);
    check_real = output_type <: Complex

    # check that not all elements are zero
    check_non_zero = sum(deramped_image .!= 0) != 0;

    test_ok = all([check_real, check_non_zero])
    return test_ok
end

function reramp_test()
    ## Arrange
    # load image
    image = load_test_slc_image();
    meta_data = image.metadata;
    burst_number = SARProcessing.get_burst_numbers(image)[1]

    # get range times from columns/samples
    orbit_states = SARProcessing.load_precise_orbit_sentinel1(PRECISE_ORBIT_TEST_FILE2)

    # ## Get mid burst time and speed
    interpolator = SARProcessing.orbit_state_interpolator(orbit_states, image)
    mid_burst_state = SARProcessing.get_burst_mid_states(image,interpolator)
    mid_burst_speed = SARProcessing.get_speed.(mid_burst_state)[1]

    # Create some matrices of row and column indices
    image_window = SARProcessing.get_window(image)
    columns = image_window[2][1]:image_window[2][2]
    rows = image_window[1][1]:image_window[1][2]

    ramp = SARProcessing.phase_ramp_grid(rows, columns, burst_number[1], mid_burst_speed, meta_data);

    ## Act
    reramped_image = SARProcessing.reramp(image, ramp)

    ## Assert
    output_type = eltype(reramped_image);
    check_real = output_type <: Complex

    # check that not all elements are zero
    check_non_zero = sum(reramped_image .!= 0) != 0;

    test_ok = all([check_real, check_non_zero])
    return test_ok
end

@testset "InSARTest.jl" begin
    @test _doppler_centroid_frequency_test()
    @test _doppler_fm_rate_test()
    @test phase_ramp_grid_test()
    @test phase_ramp_test()
    @test deramp_test()
    @test reramp_test()
    #TODO: Add more phase ramp tests
end