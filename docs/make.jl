using SARProcessing
using Documenter

DocMeta.setdocmeta!(SARProcessing, :DocTestSetup, :(using SARProcessing); recursive=true)

makedocs(;
    modules=[SARProcessing],
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
    ],
)

deploydocs(;
    repo="github.com/AIRCentre/SARProcessing.jl",
    devbranch="main",
)
