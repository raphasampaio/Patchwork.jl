"""
# RhinestoneChartJs

Plugin for Chart.js support in Rhinestone dashboards.

This module provides support for creating interactive charts using Chart.js.
"""
module RhinestoneChartJs

import Rhinestone: ContentItem, ContentRenderer
import Rhinestone: render_to_dict, content_type, get_cdn_urls, register_renderer!

export ChartJsPlot

"""
    ChartJsPlot <: ContentItem

Represents a Chart.js chart configuration.

# Fields
- `id::String`: Unique identifier for the chart container
- `title::String`: Chart title
- `chart_type::String`: Chart.js chart type (e.g., "line", "bar", "pie", "doughnut", "radar")
- `data::Dict{String, Any}`: Chart.js data configuration
- `options::Dict{String, Any}`: Chart.js options configuration (optional)
- `height::String`: CSS height value (default: "24rem")

# Example
```julia
using Rhinestone.RhinestoneChartJs

chart = ChartJsPlot(
    "cpu-chart",
    "CPU Usage",
    "line",
    Dict(
        "labels" => ["00:00", "01:00", "02:00", "03:00"],
        "datasets" => [
            Dict("label" => "CPU %", "data" => [45, 52, 38, 61])
        ]
    )
)
```
"""
struct ChartJsPlot <: ContentItem
    id::String
    title::String
    chart_type::String
    data::Dict{String, Any}
    options::Dict{String, Any}
    height::String

    function ChartJsPlot(id::String, title::String, chart_type::String,
                        data::Dict{String, Any};
                        options::Dict{String, Any} = Dict{String, Any}(),
                        height::String = "24rem")
        new(id, title, chart_type, data, options, height)
    end
end

# Chart.js Renderer
struct ChartJsRenderer <: ContentRenderer end

function render_to_dict(::ChartJsRenderer, item::ChartJsPlot)
    return Dict{String, Any}(
        "type" => "chartjs",
        "id" => item.id,
        "title" => item.title,
        "height" => item.height,
        "chartType" => item.chart_type,
        "data" => item.data,
        "options" => item.options
    )
end

content_type(::ChartJsRenderer) = "chartjs"

function get_cdn_urls(::ChartJsRenderer)
    return Dict{String, String}(
        "chartjs" => "https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"
    )
end

function get_init_script(::ChartJsRenderer)
    return """
    // Chart.js initialization
    if (metadata.type === 'chartjs') {
        const canvas = document.createElement('canvas');
        container.appendChild(canvas);

        const defaultOptions = {
            responsive: true,
            maintainAspectRatio: false
        };

        const chartOptions = metadata.options || {};
        const mergedOptions = { ...defaultOptions, ...chartOptions };

        new Chart(canvas, {
            type: metadata.chartType,
            data: metadata.data,
            options: mergedOptions
        });
    }
    """
end

# Auto-register when module is loaded
function __init__()
    register_renderer!(ChartJsPlot, ChartJsRenderer())
end

end # module
