"""
Checks the validity of the helper functions (polynomials) _doppler_fm_rate and _doppler_centroid_frequency
"""
function polynomial_test(f, x, param, x0)
    # check if output is real
    output = f(x, param, x0);
    output_type = eltype(output);
    check_real = output_type <: Real

    # check that the polynomial is not all zeros
    check_non_zero = sum(output .!= 0) != 0;

    # check if function is monotonically increasing/decreasing
    check_monotonically_increasing = [output[i+1] >= output[i] for i in eachindex(output[1:end-1])];
    check_monotonically_decreasing = [output[i+1] <= output[i] for i in eachindex(output[1:end-1])];
    check_monotonic = all(check_monotonically_increasing) | all(check_monotonically_decreasing);

    test_ok = all([check_real, check_non_zero, check_monotonic]);

    if !test_ok
        println([check_real, check_non_zero, check_monotonic])
        println("Debug info: ", string(StackTraces.stacktrace()[1].func))
        println("eltype(_doppler_fm_rate(x, param, x0)): ", output_type)
        if !all(check_monotonically_increasing)
            println("Index for breaking monotonic increase: ", findall(check_monotonically_increasing))
        elseif !all(check_monotonically_decreasing)
            println("Index for breaking monotonic decrease: ", findall(check_monotonically_decreasing))
        else
            println("Function is monotonic")
        end
    end

    return test_ok
end

function test_phase_ramp(rows, columns, burst_number, mid_burst_speed, meta_data, orbit_states)
    # check if output is real
    ramp = SARProcessing.phase_ramp(rows, columns, burst_number, mid_burst_speed, meta_data, orbit_states);
    output_type = eltype(ramp);
    check_real = output_type <: Real

    # check that the ramp is not all zeros
    check_non_zero = sum(ramp .!= 0) != 0;

    # check that length of each element is 1 for reramp * deramp
    check_ramp_cancellation_length = all(length.(exp.(-ramp .* im) .* exp.(ramp .* im)) .== 1)

    test_ok = all([check_real, check_non_zero, check_ramp_cancellation_length])
    return test_ok
end

function test_deramp(image, rows, columns, burst_number, mid_burst_speed, meta_data, orbit_states)
    ramp = SARProcessing.phase_ramp(rows, columns, burst_number, mid_burst_speed, meta_data, orbit_states);
    deramped_image = SARProcessing.deramp(image, ramp)

    output_type = eltype(deramped_image);
    check_real = output_type <: Complex

    # check that not all elements are zero
    check_non_zero = sum(deramped_image .!= 0) != 0;

    test_ok = all([check_real, check_non_zero])
    return test_ok
end

function test_reramp(image, rows, columns, burst_number, mid_burst_speed, meta_data, orbit_states)
    ramp = SARProcessing.phase_ramp(rows, columns, burst_number, mid_burst_speed, meta_data, orbit_states);
    reramped_image = SARProcessing.reramp(image, ramp)
    output_type = eltype(reramped_image);
    check_real = output_type <: Complex

    # check that not all elements are zero
    check_non_zero = sum(reramped_image .!= 0) != 0;

    test_ok = all([check_real, check_non_zero])
    return test_ok
end

@testset "InSARTest.jl" begin
    image = load_test_slc_image();
    metadata = image.metadata;
    index_start = image.index_start;
    columns = 1:metadata.image.number_of_samples;
    tau_0 = metadata.image.slant_range_time.value; 
    Delta_tau_s = 1/metadata.product.range_sampling_rate;

    # get range times from columns/samples
    range_time = tau_0 .+ (collect(columns) .- 1) .* Delta_tau_s
    orbit_states = SARProcessing.load_precise_orbit_sentinel1(PRECISE_ORBIT_TEST_FILE2)

    # ## Get mid burst time and speed
    interpolator = SARProcessing.orbit_state_interpolator(orbit_states, image)
    mid_burst_state = SARProcessing.get_burst_mid_states(image,interpolator)
    mid_burst_speed = SARProcessing.get_speed.(mid_burst_state)

    # test all bursts
    for (i, burst_number) in enumerate(SARProcessing.get_burst_numbers(image))
        fm_meta = metadata.bursts[burst_number].azimuth_fm_rate;
        @test polynomial_test(SARProcessing._doppler_fm_rate, range_time, fm_meta.polynomial, fm_meta.t0)

        dc_meta = metadata.bursts[burst_number].doppler_centroid;
        @test polynomial_test(SARProcessing._doppler_centroid_frequency, range_time, dc_meta.polynomial, dc_meta.t0)

        # Create some matrices of row and colomn indeces
        image_window = SARProcessing.get_window(image)
        columns = collect(image_window[2][1]:image_window[2][2])
        rows = collect(image_window[1][1]:image_window[1][2])

        n_columns = length(columns)
        columns = repeat(columns', length(rows))
        rows = Matrix(transpose(repeat(rows', n_columns)))

        @test test_phase_ramp(rows, columns, burst_number, mid_burst_speed[i], metadata, orbit_states)

        @test test_deramp(image, rows, columns, burst_number, mid_burst_speed[i], metadata, orbit_states)
        @test test_reramp(image, rows, columns, burst_number, mid_burst_speed[i], metadata, orbit_states)

        #TODO: Add more phase ramp tests
    end
end