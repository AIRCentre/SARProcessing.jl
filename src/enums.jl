@enum Polarisation begin
    VV
    VH
    HV
    HH
end

function Base.parse(::Type{Polarisation}, polarisation::AbstractString)
    
    polarisation = uppercase(polarisation)
    
    if polarisation == "VV"
        return VV
    elseif polarisation == "VH"
        return VH
    elseif polarisation == "HV"
        return HV
    elseif polarisation == "HH"
        return HH
    else
        throw(ErrorException("$polarisation is not a valid polarisation"))
    end
    
end
