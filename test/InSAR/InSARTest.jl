"""
Checks the validity of the helper functions (polynomials) _doppler_fm_rate and _doppler_centroid_frequency
"""
function polynomial_test(f, x, param, x0)
    # check if output is real
    output = f(x, param, x0);
    output_type = eltype(output);
    check_real = output_type <: Real

    # check non zero polynomial
    check_non_zero = all(output .!= 0);

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

function test_phase_ramp(lines, samples, burst_number, meta_data, orbit_states)
    # check if output is real
    output = SARProcessing.get_phase_ramp(lines, samples, burst_number, meta_data, orbit_states);
    output_type = eltype(output);
    check_real = output_type <: Real

    # check non zero polynomial
    check_non_zero = all(output .!= 0);

    # maybe some check for periodicity?

    test_ok = all([check_real, check_non_zero])
    return test_ok
end


@testset "InSARTest.jl" begin
    image = load_test_slc_image();
    metadata = image.metadata;
    index_start = image.index_start;
    samples = 1:metadata.image.number_of_samples;
    tau_0 = metadata.image.slant_range_time.value; 
    Delta_tau_s = 1/metadata.product.range_sampling_rate;

    # get range times from samples
    range_time = tau_0 .+ (collect(samples) .- 1) .* Delta_tau_s
    orbit_states = SARProcessing.load_precise_orbit_sentinel1(PRECISE_ORBIT_TEST_FILE)

    # test all bursts
    for i in 1:length(metadata.bursts)
        fm_meta = metadata.bursts[i].azimuth_fm_rate;
        @test polynomial_test(SARProcessing._doppler_fm_rate, range_time, fm_meta.polynomial, fm_meta.t0)

        dc_meta = metadata.bursts[i].doppler_centroid;
        @test polynomial_test(SARProcessing._doppler_centroid_frequency, range_time, dc_meta.polynomial, dc_meta.t0)

        burst_sample_start = findall(metadata.bursts[i].first_valid_sample .> 0)[1]
        burst_sample_end = findall(metadata.bursts[i].first_valid_sample .> 0)[end]
        samples = collect(burst_sample_start:burst_sample_end)
        lines = collect(1:metadata.bursts[i].lines_per_burst)
        # v = collect(1:1000);
        n_samples = length(samples)
        samples = repeat(samples', length(lines))
        lines = transpose(repeat(lines', n_samples))

        @test test_phase_ramp(lines, samples, i, metadata, orbit_states)

    end
    


end