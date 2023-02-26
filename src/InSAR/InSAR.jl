"""
Computes Doppler FM rate (k_a), as given by equation 11 in the document "Definition of the TOPS SLC deramping function
for products generated by the S-1 IPF" by Miranda (2014): https://sentinel.esa.int/documents/247904/1653442/sentinel-1-tops-slc_deramping
"""
_doppler_fm_rate(x, fm_param, x0) = fm_param[1] .+ fm_param[2].*(x .- x0) .+ fm_param[3].*(x .- x0).^2

"""
Computes Doppler centroid frequency (f_etac), as given by equation 13 in the document "Definition of the TOPS SLC deramping function
for products generated by the S-1 IPF" by Miranda (2014): https://sentinel.esa.int/documents/247904/1653442/sentinel-1-tops-slc_deramping
"""
_doppler_centroid_frequency(x, dc_param, x0) = dc_param[1] .+ dc_param[2].*(x .- x0) .+ dc_param[3].*(x .- x0).^2;

"""
    phase_ramp(rows::Vector{T}, columns::Vector{T}, burst_number::Int64, v_s::Float64,
            k_psi::Float64, dc_coefficient::Vector{Float64},
            dc_tau_0::Float64, fm_coefficient::Vector{Float64},
            fm_tau_0::Float64, f_c::Float64, lines_per_burst::Int64,
            number_of_samples::Int64, delta_t_s::Float64,
            delta_tau_s::Float64, tau_0::Number, c=LIGHT_SPEED::Real) where T <: Number

Computes the phase ramp (phi) for the given burst number for input rows (lines) and columns (samples).

# NOTES
reference: Equation numbers refer to the document "Definition of the TOPS SLC deramping function
for products generated by the S-1 IPF" by Miranda (2014):
    https://sentinel.esa.int/documents/247904/1653442/sentinel-1-tops-slc_deramping
"""
function phase_ramp(rows::Vector{T}, columns::Vector{T}, burst_number::Int64, v_s::Float64,
                    k_psi::Float64, dc_coefficient::Vector{Float64},
                    dc_tau_0::Float64, fm_coefficient::Vector{Float64},
                    fm_tau_0::Float64, f_c::Float64, lines_per_burst::Int64,
                    number_of_samples::Int64, delta_t_s::Float64,
                    delta_tau_s::Float64, tau_0::Number, c=LIGHT_SPEED::Real) where T <: Number

    if length(rows) != length(columns)
        throw(ArgumentError("Length of rows must match columns. Consider using phase_ramp_grid() for grids"))
    end

    tau = tau_0 .+ (columns .- 1) .* delta_tau_s # Slant range time of ith sample, Eqn. 12

    # Doppler rate equations
    k_s = 2 * v_s/c * f_c * k_psi; # Doppler rate from antenna scanning, Eqn. 4
    alpha = 1 .- k_s ./ _doppler_fm_rate(tau, fm_coefficient, fm_tau_0); # conversion factor, Eqn. 3
    k_t = k_s ./ alpha; # Doppler Centroid Rate, Eqn. 2

    # Doppler azimuth time equations
    eta_c = - _doppler_centroid_frequency(tau, dc_coefficient, dc_tau_0) ./ _doppler_fm_rate(tau, fm_coefficient, fm_tau_0); # Beam centre crossing time, Eqn. 7
    tau_mid = tau_0 + number_of_samples/2 * delta_tau_s

    eta_ref = eta_c .- (- _doppler_centroid_frequency(tau_mid, dc_coefficient, dc_tau_0) / _doppler_fm_rate(tau_mid, fm_coefficient, fm_tau_0)); # Reference time, Eqn. 6
    line_in_burst = rows .- lines_per_burst * (burst_number - 1)
    eta = -lines_per_burst / 2 * delta_t_s .+ (line_in_burst .- 1/2 ) .* delta_t_s

    # the modulation term
    doppler =  _doppler_centroid_frequency(tau, dc_coefficient, dc_tau_0)

    # Compute the phase ramp added with the modulation term
    ramp = pi .* k_t .* (eta .- eta_ref) .^2 .+ 2 .* pi .* doppler .* (eta .- eta_ref)
    return ramp
end

"""
    phase_ramp(rows::Vector{T}, columns::Vector{T},
            burst_number::Int64, mid_burst_speed::Float64, meta_data::Sentinel1MetaData) where T <: Integer

Extracts relevant parameters from meta_data and calls phase_ramp().
"""
function phase_ramp(rows::Vector{T}, columns::Vector{T},
                        burst_number::Int64, mid_burst_speed::Float64, meta_data::Sentinel1MetaData) where T <: Number


    if length(rows) != length(columns)
        throw(ArgumentError("Length of rows must match columns. Consider using phase_ramp_grid() for grids"))
    end

    k_psi = meta_data.product.azimuth_steering_rate * pi/180 ;
    dc_coefficient = meta_data.bursts[burst_number].doppler_centroid.polynomial;
    dc_tau_0 = meta_data.bursts[burst_number].doppler_centroid.t0;
    fm_coefficient = meta_data.bursts[burst_number].azimuth_fm_rate.polynomial;
    fm_tau_0 = meta_data.bursts[burst_number].azimuth_fm_rate.t0;
    f_c = meta_data.product.radar_frequency;
    lines_per_burst = meta_data.swath.lines_per_burst;
    number_of_samples = meta_data.image.number_of_samples;
    delta_t_s = meta_data.image.azimuth_time_interval;
    delta_tau_s = 1/meta_data.product.range_sampling_rate
    tau_0 = meta_data.image.slant_range_time_seconds; # in seconds

    ramp = phase_ramp(rows, columns, burst_number, mid_burst_speed, k_psi, dc_coefficient,
                      dc_tau_0, fm_coefficient, fm_tau_0, f_c, lines_per_burst,
                      number_of_samples, delta_t_s, delta_tau_s, tau_0);
    return ramp
end


"""
phase_ramp_grid(rows::AbstractRange, columns::AbstractRange, 
                        burst_number::Int64, mid_burst_speed::Float64, meta_data::Sentinel1MetaData)

Computes the phase ramp (phi) for the given burst number over the grid defined by 
rows::AbstractRange and columns::AbstractRange 
"""
function phase_ramp_grid(rows::AbstractRange, columns::AbstractRange, 
                        burst_number::Int64, mid_burst_speed::Float64, meta_data::Sentinel1MetaData)
    rows = collect(rows)
    columns = collect(columns)

    rows_grid = reshape(ones(length(columns))' .* rows,:)
	columns_grid = reshape(columns' .* ones(length(rows)),:);

    ramp = phase_ramp(rows_grid, columns_grid, burst_number, mid_burst_speed, meta_data);
    return reshape(ramp,(length(rows),length(columns)))
end

function deramp(image::Sentinel1SLC, ramp::Matrix{Float64})
    image = image.data .* reshape(exp.(-ramp .* im), size(image.data));
end

function reramp(image::Sentinel1SLC, ramp::Matrix{Float64})
    image = image.data .* reshape(exp.(ramp .* im), size(image.data));
end
