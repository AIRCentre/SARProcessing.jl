period_to_float_seconds(nanoSeconds::Nanosecond) = Float64(nanoSeconds.value *10^-9)
period_to_float_seconds(milliseconds::Millisecond) = Float64(milliseconds.value *10^-3)
period_to_float_seconds(seconds::Second) = Float64(seconds.value)

float_seconds_to_period(seconds::Real) = Nanosecond(round(seconds*10^9))