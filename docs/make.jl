using Bombe
using Documenter

DocMeta.setdocmeta!(Bombe, :DocTestSetup, :(using Bombe); recursive=true)

makedocs(;
    modules=[Bombe],
    authors="Carlos Parada <paradac@carleton.edu>",
    repo="https://github.com/ParadaCarleton/Bombe.jl/blob/{commit}{path}#{line}",
    sitename="Bombe.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://ParadaCarleton.github.io/Bombe.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/ParadaCarleton/Bombe.jl",
)
