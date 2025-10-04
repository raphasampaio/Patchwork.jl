<div align="center"><img src="/docs/src/assets/logo.svg" width=150px alt="Patchwork.jl"></img></div>

# Patchwork.jl

[![Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://raphasampaio.github.io/Patchwork.jl/stable)
[![CI](https://github.com/raphasampaio/Patchwork.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/raphasampaio/Patchwork.jl/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/raphasampaio/Patchwork.jl/graph/badge.svg?token=Qkg4DKh6HJ)](https://codecov.io/gh/raphasampaio/Patchwork.jl)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

## Introduction

Patchwork.jl is a lightweight Julia package for creating interactive, self-contained HTML dashboards. With Patchwork you can:

- **Generate single-page dashboards** with Vue.js reactivity and Tailwind CSS styling
- **Extend with any JavaScript library** through a simple plugin system
- **Create self-contained HTML files** that work anywhere, no server required
- **Use built-in plugins** for Markdown, Chart.js, Highcharts, Plotly, Leaflet maps, and Mermaid diagrams

## Getting Started

### Installation

```julia
pkg> add Patchwork
```

### Example: Simple markdown dashboard

```julia
using Patchwork

dashboard = Patchwork.Dashboard(
    "My Dashboard",
    [
        Patchwork.Tab(
            "Overview",
            [
                Patchwork.Markdown(
                    "# Welcome to Patchwork.jl\n" *
                    "This is a **simple** dashboard with:\n" *
                    "- Interactive tabs\n" *
                    "- Search functionality\n" *
                    "- Beautiful styling",
                ),
            ],
        ),
    ],
)

save(dashboard, "dashboard.html")
```

### Example: Dashboard with charts

```julia
using Patchwork

dashboard = Patchwork.Dashboard(
    "Sales Analytics",
    [
        Patchwork.Tab(
            "Monthly Revenue",
            [
                Patchwork.ChartJs(
                    "Revenue by Month",
                    "bar",
                    Dict{String,Any}(
                        "labels" => ["Jan", "Feb", "Mar", "Apr"],
                        "datasets" => [
                            Dict{String,Any}(
                                "label" => "2024",
                                "data" => [12, 19, 8, 15],
                                "backgroundColor" => "rgba(54, 162, 235, 0.5)",
                            ),
                        ],
                    ),
                ),
            ],
        ),
    ],
)

save(dashboard, "sales.html")
```

## Plugin System

Create custom plugins by implementing five functions for any JavaScript library:

```julia
struct MyPlugin <: Plugin
    content::String
end

to_html(plugin::MyPlugin) = "<div>$(plugin.content)</div>"
css_deps(::Type{MyPlugin}) = ["https://cdn.example.com/lib.css"]
js_deps(::Type{MyPlugin}) = ["https://cdn.example.com/lib.js"]
init_script(::Type{MyPlugin}) = "// initialization code"
css(::Type{MyPlugin}) = "/* custom styles */"
```

## Contributing

Contributions, bug reports, and feature requests are welcome! Feel free to open an issue or submit a pull request.
