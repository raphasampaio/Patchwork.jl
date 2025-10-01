"""
# RhinestoneHighcharts

Plugin for Highcharts.js support in Rhinestone dashboards.

This module provides support for creating interactive charts using Highcharts.
"""
module RhinestoneHighcharts

import Rhinestone: ContentItem, ContentRenderer
import Rhinestone: render_to_dict, content_type, get_cdn_urls, register_renderer!

export HighchartsPlot

"""
    HighchartsPlot <: ContentItem

Represents a Highcharts chart configuration.

# Fields
- `id::String`: Unique identifier for the chart container
- `title::String`: Chart title
- `config::Dict{String, Any}`: Highcharts configuration object
- `height::String`: CSS height value (default: "24rem")

# Example
```julia
using Rhinestone.RhinestoneHighcharts

chart = HighchartsPlot(
    "sales-chart",
    "Monthly Sales",
    Dict(
        "chart" => Dict("type" => "column"),
        "xAxis" => Dict("categories" => ["Jan", "Feb", "Mar"]),
        "series" => [
            Dict("name" => "Revenue", "data" => [100, 150, 120])
        ]
    )
)
```
"""
struct HighchartsPlot <: ContentItem
    id::String
    title::String
    config::Dict{String, Any}
    height::String

    function HighchartsPlot(id::String, title::String, config::Dict{String, Any};
                           height::String = "24rem")
        new(id, title, config, height)
    end
end

# Highcharts Renderer
struct HighchartsRenderer <: ContentRenderer end

function render_to_dict(::HighchartsRenderer, item::HighchartsPlot)
    return Dict{String, Any}(
        "type" => "highcharts",
        "id" => item.id,
        "title" => item.title,
        "height" => item.height,
        "config" => item.config
    )
end

content_type(::HighchartsRenderer) = "highcharts"

function get_cdn_urls(::HighchartsRenderer)
    return Dict{String, String}(
        "highcharts" => "https://code.highcharts.com/highcharts.js"
    )
end

function get_init_script(::HighchartsRenderer)
    return """
    // Highcharts initialization
    if (metadata.type === 'highcharts' || metadata.chart || metadata.series) {
        Highcharts.chart(container, metadata.config);
    }
    """
end

# Auto-register when module is loaded
function __init__()
    register_renderer!(HighchartsPlot, HighchartsRenderer())
end

end # module
