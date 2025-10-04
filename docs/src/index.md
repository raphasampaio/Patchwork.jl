# Patchwork.jl

Create interactive, self-contained HTML dashboards with Julia.

## Features

- **Self-contained HTML files** - Share dashboards anywhere, no server required
- **Tabbed interface** with search and mobile support
- **Built-in plugins** - Markdown, Chart.js, Highcharts, Plotly, Leaflet, Mermaid
- **Plugin system** - Integrate any JavaScript library
- **Zero configuration** - Works out of the box

## Installation

```julia
using Pkg
Pkg.add("Patchwork")
```

## Quick Start

```julia
using Patchwork

dashboard = Patchwork.Dashboard(
    "My Dashboard",
    [
        Patchwork.Tab(
            "Overview",
            [
                Patchwork.Markdown("""
                # Welcome to Patchwork.jl

                Create beautiful dashboards with:
                - Interactive charts
                - Maps
                - Diagrams
                - Custom content
                """),
            ],
        ),
    ],
)

save(dashboard, "dashboard.html")
```

## Documentation

- [Built-in Plugins](plugins.md) - Explore all available plugins
- [Custom Plugins](custom_plugins.md) - Create your own plugins
- [API Reference](api.md) - Complete API documentation
