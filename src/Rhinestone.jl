"""
# Rhinestone.jl

A flexible, plugin-based framework for creating interactive HTML dashboards.

Rhinestone provides a core framework for building dashboards with tabs and content items.
Content rendering is handled through a plugin system, allowing external packages to implement
custom renderers for different content types (charts, maps, visualizations, etc.).

## Plugin Architecture

External packages can create renderers by:
1. Defining a content type that extends `ContentItem`
2. Implementing a renderer that extends `ContentRenderer`
3. Registering the renderer with `register_renderer!`

## Example

```julia
# In an external package like RhinestoneHighcharts.jl
struct HighchartsPlot <: Rhinestone.ContentItem
    id::String
    title::String
    config::Dict{String, Any}
end

struct HighchartsRenderer <: Rhinestone.ContentRenderer end

Rhinestone.render_to_dict(::HighchartsRenderer, item::HighchartsPlot) =
    Dict("type" => "highcharts", "id" => item.id, "title" => item.title,
         "config" => item.config)

Rhinestone.content_type(::HighchartsRenderer) = "highcharts"
Rhinestone.get_cdn_urls(::HighchartsRenderer) =
    Dict("highcharts" => "https://code.highcharts.com/highcharts.js")

# Register the renderer
Rhinestone.register_renderer!(HighchartsPlot, HighchartsRenderer())
```
"""
module Rhinestone

using Markdown
using JSON

export DashboardConfig, Tab, ContentItem, generate_dashboard
export ContentRenderer, register_renderer!, get_renderer, has_renderer, clear_registry!
export render_to_dict, get_cdn_urls, get_init_script, content_type
export HtmlContent

"""
Abstract type for dashboard content items.

All content types must extend this type. External packages can define their own
content types by extending ContentItem and implementing a corresponding renderer.
"""
abstract type ContentItem end

"""
    HtmlContent <: ContentItem

Represents raw HTML content.

# Fields
- `id::String`: Unique identifier for the content block
- `html::String`: Raw HTML content
"""
struct HtmlContent <: ContentItem
    id::String
    html::String
end


"""
    Tab

Represents a dashboard tab containing multiple content items (charts, markdown, etc.).

# Fields

  - `label::String`: Tab display label
  - `items::Vector{ContentItem}`: Content items in this tab
"""
struct Tab
    label::String
    items::Vector{ContentItem}
end

"""
    DashboardConfig

Configuration for generating a dashboard HTML file.

# Fields

  - `title::String`: Dashboard title
  - `tabs::Vector{Tab}`: Dashboard tabs
  - `custom_css::String`: Additional CSS styles
  - `chart_init_script::String`: JavaScript function to initialize charts
  - `cdn_urls::Dict{String,String}`: CDN URLs for external libraries
"""
struct DashboardConfig
    title::String
    tabs::Vector{Tab}
    custom_css::String
    chart_init_script::String
    cdn_urls::Dict{String, String}

    function DashboardConfig(title::String, tabs::Vector{Tab};
        custom_css::String = "",
        chart_init_script::String = "",
        cdn_urls::Dict{String, String} = Dict{String, String}())
        # Always include Vue, Tailwind, and highlight.js as base dependencies
        # Using highlight.js common bundle which includes popular languages
        default_urls = Dict(
            "vue" => "https://cdn.jsdelivr.net/npm/vue@3.3.4/dist/vue.global.js",
            "tailwind" => "https://cdn.tailwindcss.com/3.4.0",
            "highlightjs" => "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js",
            "highlightcss" => "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github-dark.min.css",
        )
        # Merge user-provided URLs with defaults (user URLs take precedence)
        merged_urls = merge(default_urls, cdn_urls)
        return new(title, tabs, custom_css, chart_init_script, merged_urls)
    end
end

include("renderers.jl")
include("validation.jl")
include("builtin_renderers.jl")
include("RhinestoneMarkdown.jl")
include("RhinestoneHighcharts.jl")
include("RhinestoneChartJs.jl")
include("RhinestonePlotly.jl")
include("chart_compat.jl")
include("template.jl")

# Re-export plugin submodules
using .RhinestoneMarkdown
using .RhinestoneHighcharts
using .RhinestoneChartJs
using .RhinestonePlotly

export RhinestoneMarkdown, RhinestoneHighcharts, RhinestoneChartJs, RhinestonePlotly

end
