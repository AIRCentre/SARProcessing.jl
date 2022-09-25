module SARProcessing
export greet, Sentinel1

include("Sentinel1.jl");

function greet(a)
    print("Hello World! $a");
    return "Hello World! $a" ;
end

end # module SARProcessing
