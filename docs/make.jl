using Documenter
using Patchwork

DocMeta.setdocmeta!(Patchwork, :DocTestSetup, :(using Patchwork); recursive = true)

Documenter.makedocs(
    sitename = "Patchwork",
    modules = [Patchwork],
    authors = "Raphael Araujo Sampaio",
    repo = "https://github.com/raphasampaio/Patchwork.jl/blob/{commit}{path}#{line}",
    doctest = true,
    clean = true,
    checkdocs = :none,
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://raphasampaio.github.io/Patchwork.jl",
        edit_link = "main",
        assets = [
            "assets/favicon.ico",
        ],
    ),
    pages = [
        "Home" => "index.md",
        "Core" => [
            "dashboard.md",
            "tab.md",
        ],
        "Plugins" => [
            "plugins.md",
            "plugins/html.md",
            "plugins/markdown.md",
            "plugins/chartjs.md",
            "plugins/highcharts.md",
            "plugins/plotly.md",
            "plugins/leaflet.md",
            "plugins/mermaid.md",
        ],
    ],
)

deploydocs(
    repo = "github.com/raphasampaio/Patchwork.jl.git",
    devbranch = "main",
    push_preview = true,
)
