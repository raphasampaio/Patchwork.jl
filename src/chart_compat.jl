"""
Backward compatibility layer for ChartPlaceholder.

This provides a ChartPlaceholder type that works with the plugin system.
In the future, chart types should be provided by external packages like RhinestoneCharts.jl.
"""

"""
    ChartPlaceholder <: ContentItem

A generic chart placeholder for embedding charts with custom JavaScript initialization.
This type is provided for backward compatibility and simple use cases.

For production use, consider using dedicated chart packages that implement
specific renderers (e.g., RhinestoneHighcharts.jl, RhinestonePlotly.jl).

# Fields
- `id::String`: Unique identifier for the chart container
- `title::String`: Chart title
- `height::String`: CSS height value (default: "24rem")
- `metadata::Dict{String,Any}`: Chart configuration passed to JavaScript
"""
struct ChartPlaceholder <: ContentItem
    id::String
    title::String
    height::String
    metadata::Dict{String, Any}

    function ChartPlaceholder(id::String, title::String;
        height::String = "24rem",
        metadata::Dict{String, Any} = Dict{String, Any}())
        return new(id, title, height, metadata)
    end
end

# Chart renderer
struct ChartRenderer <: ContentRenderer end

function render_to_dict(::ChartRenderer, item::ChartPlaceholder)
    return Dict{String, Any}(
        "type" => "chart",
        "id" => item.id,
        "title" => item.title,
        "height" => item.height,
        "metadata" => item.metadata
    )
end

content_type(::ChartRenderer) = "chart"

# Register the chart renderer
register_renderer!(ChartPlaceholder, ChartRenderer())

# Export for backward compatibility
export ChartPlaceholder
