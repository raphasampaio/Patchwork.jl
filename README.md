# Rhinestone.jl

A chart-agnostic static site generator for creating self-contained, single-page HTML dashboards with TailwindCSS and Vue.js.

## Features

- **Chart Agnostic**: Works with any JavaScript charting library (Chart.js, Plotly, D3.js, or custom implementations)
- **Self-Contained**: Generates a single HTML file with all dependencies loaded via CDN
- **Responsive Design**: Built with TailwindCSS for mobile-friendly layouts
- **Interactive**: Vue.js-powered sidebar navigation and search functionality
- **Flexible**: Customizable CSS and chart initialization scripts

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/yourusername/Rhinestone.jl")
```

## Quick Start

```julia
using Rhinestone

# Define your dashboard structure
tabs = [
    Tab("Performance", [
        ChartPlaceholder("cpu-chart", "CPU Usage",
            metadata=Dict{String,Any}(
                "data" => [45, 52, 38, 61, 42]
            )
        )
    ])
]

# Provide chart initialization script
chart_init_script = """
function initializeChart(chartId, metadata) {
    const container = document.getElementById(chartId);
    // Your chart rendering code here
}
"""

# Create configuration
config = DashboardConfig(
    "My Dashboard",
    tabs,
    chart_init_script=chart_init_script
)

# Generate HTML file
generate_dashboard(config, "dashboard.html")
```

## Architecture

The package separates concerns:

1. **Structure** (`ChartPlaceholder`, `Tab`): Define layout and containers
2. **Template** (`DashboardConfig`, `generate_dashboard`): Generate HTML skeleton
3. **Rendering** (user-provided `chart_init_script`): Handle chart-specific visualization

This design allows you to use any charting library without modifying the package code.

## Examples

See the `examples/` directory:

- `chartjs_example.jl`: Dashboard using Chart.js
- `plotly_example.jl`: Dashboard using Plotly.js
- `custom_example.jl`: Dashboard with custom HTML rendering (no external library)

## API Reference

### Types

#### `ChartPlaceholder`

Represents a chart container.

**Constructor:**
```julia
ChartPlaceholder(
    id::String,
    title::String;
    height::String="24rem",
    metadata::Dict{String,Any}=Dict{String,Any}()
)
```

**Fields:**
- `id`: Unique identifier for the DOM element
- `title`: Chart title displayed above the container
- `height`: CSS height value for the container
- `metadata`: Arbitrary data passed to `initializeChart()`

#### `Tab`

Represents a dashboard tab.

**Constructor:**
```julia
Tab(label::String, charts::Vector{ChartPlaceholder})
```

**Fields:**
- `label`: Tab name shown in sidebar
- `charts`: List of charts in this tab

#### `DashboardConfig`

Dashboard configuration.

**Constructor:**
```julia
DashboardConfig(
    title::String,
    tabs::Vector{Tab};
    custom_css::String="",
    chart_init_script::String="",
    cdn_urls::Dict{String,String}=Dict(
        "tailwind" => "https://cdn.tailwindcss.com/3.4.0",
        "vue" => "https://cdn.jsdelivr.net/npm/vue@3.3.4/dist/vue.global.js"
    )
)
```

**Fields:**
- `title`: Dashboard title
- `tabs`: List of tabs
- `custom_css`: Additional CSS styles
- `chart_init_script`: JavaScript function for chart rendering
- `cdn_urls`: External dependencies to load

### Functions

#### `generate_dashboard`

```julia
generate_dashboard(config::DashboardConfig, output_path::String)
```

Generates a self-contained HTML file.

**Arguments:**
- `config`: Dashboard configuration
- `output_path`: Output file path

**Returns:** The output file path

## Chart Initialization Contract

Your `chart_init_script` must define a function:

```javascript
function initializeChart(chartId, metadata) {
    // chartId: String - DOM element ID for the container
    // metadata: Object - The metadata dict from ChartPlaceholder

    const container = document.getElementById(chartId);
    // Render your chart in this container
}
```

This function is called once for each chart after the page loads.

## Customization

### Custom Styling

```julia
config = DashboardConfig(
    "Dashboard",
    tabs,
    custom_css="""
    .chart-container {
        background: linear-gradient(to bottom, #f0f0f0, #ffffff);
    }
    """
)
```

### Additional CDN Libraries

```julia
config = DashboardConfig(
    "Dashboard",
    tabs,
    cdn_urls=Dict(
        "tailwind" => "https://cdn.tailwindcss.com/3.4.0",
        "vue" => "https://cdn.jsdelivr.net/npm/vue@3.3.4/dist/vue.global.js",
        "chartjs" => "https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js",
        "d3" => "https://d3js.org/d3.v7.min.js"
    )
)
```

## License

MIT License