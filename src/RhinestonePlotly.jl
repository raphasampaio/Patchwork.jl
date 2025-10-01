"""
# RhinestonePlotly

Plugin for Plotly.js support in Rhinestone dashboards.

This module provides support for creating interactive charts using Plotly.js.
"""
module RhinestonePlotly

import Rhinestone: ContentItem, ContentRenderer
import Rhinestone: render_to_dict, content_type, get_cdn_urls, register_renderer!

export PlotlyPlot

"""
    PlotlyPlot <: ContentItem

Represents a Plotly.js chart configuration.

# Fields
- `id::String`: Unique identifier for the chart container
- `title::String`: Chart title
- `data::Vector{Dict{String, Any}}`: Plotly.js data traces
- `layout::Dict{String, Any}`: Plotly.js layout configuration (optional)
- `config::Dict{String, Any}`: Plotly.js config options (optional)
- `height::String`: CSS height value (default: "24rem")

# Example
```julia
using Rhinestone.RhinestonePlotly

chart = PlotlyPlot(
    "scatter-chart",
    "Square Numbers",
    [
        Dict(
            "x" => [1, 2, 3, 4, 5],
            "y" => [1, 4, 9, 16, 25],
            "type" => "scatter",
            "mode" => "lines+markers",
            "name" => "Values"
        )
    ],
    layout = Dict(
        "xaxis" => Dict("title" => "Number"),
        "yaxis" => Dict("title" => "Square"),
        "margin" => Dict("l" => 50, "r" => 20, "t" => 20, "b" => 50)
    )
)
```
"""
struct PlotlyPlot <: ContentItem
    id::String
    title::String
    data::Vector{Dict{String, Any}}
    layout::Dict{String, Any}
    config::Dict{String, Any}
    height::String

    function PlotlyPlot(id::String, title::String, data::Vector{Dict{String, Any}};
                       layout::Dict{String, Any} = Dict{String, Any}(),
                       config::Dict{String, Any} = Dict{String, Any}(),
                       height::String = "24rem")
        new(id, title, data, layout, config, height)
    end
end

# Plotly Renderer
struct PlotlyRenderer <: ContentRenderer end

function render_to_dict(::PlotlyRenderer, item::PlotlyPlot)
    return Dict{String, Any}(
        "type" => "plotly",
        "id" => item.id,
        "title" => item.title,
        "height" => item.height,
        "data" => item.data,
        "layout" => item.layout,
        "config" => item.config
    )
end

content_type(::PlotlyRenderer) = "plotly"

function get_cdn_urls(::PlotlyRenderer)
    return Dict{String, String}(
        "plotly" => "https://cdn.plot.ly/plotly-2.27.0.min.js"
    )
end

function get_init_script(::PlotlyRenderer)
    return """
    // Plotly initialization
    if (metadata.type === 'plotly') {
        const defaultConfig = {
            displayModeBar: false
        };

        const defaultLayout = {
            autosize: true
        };

        const config = { ...defaultConfig, ...metadata.config };
        const layout = { ...defaultLayout, ...metadata.layout };

        Plotly.newPlot(container, metadata.data, layout, config);

        // Force resize after plot is created
        window.addEventListener('load', function() {
            Plotly.Plots.resize(container);
        });
    }
    """
end

# Auto-register when module is loaded
function __init__()
    register_renderer!(PlotlyPlot, PlotlyRenderer())
end

end # module
