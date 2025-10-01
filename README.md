# Patchwork.jl

Simple, extensible dashboards with Vue.js and Tailwind CSS.

## Features

- **Clean & Simple** - Minimal API, no complexity
- **Extensible** - Plugin system for markdown, charts, and custom content
- **Single File Output** - Self-contained HTML with CDN dependencies
- **Responsive** - Mobile-friendly design with Tailwind CSS
- **Interactive** - Vue.js powered sidebar and search

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/yourusername/Patchwork.jl")
```

## Quick Start

```julia
using Patchwork

# Create a simple dashboard
dashboard = Dashboard("My Dashboard", [
    Tab("Overview", [
        PatchworkMarkdown("""
        # Welcome
        This is a simple dashboard.
        """),
        Html("<p>Custom HTML content</p>")
    ])
])

# Generate HTML file
render(dashboard, "dashboard.html")
```

## Using Charts

### Chart.js

```julia
using Patchwork

dashboard = Dashboard("Charts", [
    Tab("Sales", [
        PatchworkChartJs(
            "Monthly Revenue",
            "bar",
            Dict(
                "labels" => ["Jan", "Feb", "Mar"],
                "datasets" => [Dict(
                    "label" => "Revenue",
                    "data" => [100, 150, 120]
                )]
            )
        )
    ])
])

render(dashboard, "sales.html")
```

### PatchworkHighcharts

```julia
using Patchwork

dashboard = Dashboard("Analytics", [
    Tab("Performance", [
        PatchworkHighcharts(
            "CPU Usage",
            Dict(
                "chart" => Dict("type" => "line"),
                "xAxis" => Dict("categories" => ["00:00", "01:00", "02:00"]),
                "series" => [Dict("name" => "CPU", "data" => [45, 52, 38])]
            )
        )
    ])
])

render(dashboard, "analytics.html")
```

### PatchworkPlotly

```julia
using Patchwork

dashboard = Dashboard("Science", [
    Tab("Data", [
        PatchworkPlotly(
            "Scatter Plot",
            [Dict(
                "x" => [1, 2, 3, 4],
                "y" => [10, 15, 13, 17],
                "type" => "scatter",
                "mode" => "lines+markers"
            )]
        )
    ])
])

render(dashboard, "science.html")
```

## API Reference

### Core Types

**`Dashboard(title, tabs; custom_css="")`**
- `title::String` - Dashboard title
- `tabs::Vector{Tab}` - Dashboard tabs
- `custom_css::String` - Optional custom CSS

**`Tab(label, items)`**
- `label::String` - Tab name
- `items::Vector{Item}` - Content items

**`render(dashboard, path)`**
- Generate HTML file from dashboard

### Built-in Items

**`Html(content)`**
- Raw HTML content

**`PatchworkMarkdown(content)`**
- PatchworkMarkdown content (auto-converted to HTML)

**`PatchworkChartJs(title, type, data; options=Dict())`**
- Chart.js chart
- `type`: "line", "bar", "pie", "doughnut", etc.

**`PatchworkHighcharts(title, config)`**
- PatchworkHighcharts chart
- `config`: PatchworkHighcharts configuration object

**`PatchworkPlotly(title, data; layout=Dict(), config=Dict())`**
- PatchworkPlotly chart
- `data`: Vector of trace objects

## Custom CSS

```julia
dashboard = Dashboard("Styled", tabs,
    custom_css="""
    .bg-white {
        background: linear-gradient(to bottom, #f8f9fa, #ffffff);
    }
    """
)
```

## Creating Custom Plugins

Extend Patchwork by implementing the plugin interface:

```julia
module MyPlugin

import Patchwork: Item, tohtml, cdnurls, initscript

struct MyItem <: Item
    content::String
end

tohtml(item::MyItem) = "<div class='my-item'>$(item.content)</div>"

cdnurls(::Type{MyItem}) = ["https://cdn.example.com/mylib.js"]

initscript(::Type{MyItem}) = """
    document.querySelectorAll('.my-item').forEach(el => {
        // Initialize your component
    });
"""

end
```

## License

MIT
