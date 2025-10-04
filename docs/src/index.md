# Patchwork.jl

Create interactive, self-contained HTML dashboards with Julia. Patchwork generates single-page applications with Vue.js reactivity, Tailwind CSS styling, and a powerful plugin system for any JavaScript library.

## Features

- **Self-contained HTML files** - Share dashboards anywhere, no server required
- **Tabbed interface** with search and mobile support
- **Built-in plugins** - Markdown, Chart.js, Highcharts, Plotly, Leaflet, Mermaid
- **Plugin system** - Integrate any JavaScript library with five simple functions
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

## Core Concepts

### Dashboard

A `Dashboard` contains a title, tabs, and optional custom CSS:

```julia
Dashboard(title::String, tabs::Vector{Tab}; custom_css::String = "")
```

### Tab

A `Tab` contains a label and a vector of plugins:

```julia
Tab(label::String, plugins::Vector{Plugin})
```

### Plugin

All content types inherit from the abstract `Plugin` type. Built-in plugins include:
- `Markdown` - Rendered markdown with syntax highlighting
- `ChartJs` - Chart.js visualizations
- `Highcharts` - Highcharts visualizations
- `Plotly` - Plotly charts and maps
- `Leaflet` - Interactive maps
- `Mermaid` - Diagrams and flowcharts
- `HTML` - Raw HTML content

## Example: Multi-tab Dashboard

```julia
using Patchwork

dashboard = Patchwork.Dashboard(
    "Analytics Dashboard",
    [
        Patchwork.Tab(
            "Overview",
            [
                Patchwork.Markdown("# Executive Summary"),
                Patchwork.ChartJs(
                    "Revenue by Quarter",
                    "bar",
                    Dict{String,Any}(
                        "labels" => ["Q1", "Q2", "Q3", "Q4"],
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
        Patchwork.Tab(
            "Geographic",
            [
                Patchwork.Leaflet(
                    "Sales Locations",
                    (40.7128, -74.0060),
                    zoom = 10,
                    markers = [
                        Dict{String,Any}(
                            "lat" => 40.7128,
                            "lng" => -74.0060,
                            "popup" => "New York Office",
                        ),
                    ],
                ),
            ],
        ),
    ],
)

save(dashboard, "analytics.html")
```

## Next Steps

- [Built-in Plugins](plugins.md) - Explore all available plugins
- [Custom Plugins](custom_plugins.md) - Create your own plugins
- [API Reference](api.md) - Complete API documentation
