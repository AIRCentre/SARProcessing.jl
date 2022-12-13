using SARProcessing
using Documenter
include("../src/separateLater/Sentinel1/Sentinel1.jl")
include("../src/separateLater/VisualiseSAR/VisualiseSAR.jl")
using .VisualiseSAR, .Sentinel1


DocMeta.setdocmeta!(VisualiseSAR, :DocTestSetup, :(using .VisualiseSAR ); recursive=true)
DocMeta.setdocmeta!(Sentinel1, :DocTestSetup, :(using .Sentinel1); recursive=true)
DocMeta.setdocmeta!(SARProcessing, :DocTestSetup, :(using SARProcessing ); recursive=true)

makedocs(;
    modules=[SARProcessing,VisualiseSAR,Sentinel1],
    authors="AIRCentre and contributors",
    repo="https://github.com/AIRCentre/SARProcessing.jl/blob/{commit}{path}#{line}",
    sitename="SARProcessing.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://AIRCentre.github.io/SARProcessing.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Sentinel1" => "Sentinel1.md",
        "VisualiseSAR" => "VisualiseSAR.md",
    ],
)

deploydocs(;
    repo="github.com/AIRCentre/SARProcessing.jl",
    devbranch="main",
)
