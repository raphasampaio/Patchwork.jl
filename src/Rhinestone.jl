module Rhinestone

using Markdown
using JSON

export DashboardConfig, Tab, ChartPlaceholder, MarkdownContent, ContentItem, generate_dashboard

"""
Abstract type for dashboard content items (charts, markdown, etc.)
"""
abstract type ContentItem end

"""
    ChartPlaceholder <: ContentItem

Represents a chart placeholder with a unique ID and container specifications.
The actual chart rendering is handled by user-provided JavaScript.

# Fields

  - `id::String`: Unique identifier for the chart container
  - `title::String`: Chart title
  - `height::String`: CSS height value (default: "24rem")
  - `metadata::Dict{String,Any}`: Additional metadata for chart initialization
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

"""
    MarkdownContent <: ContentItem

Represents a markdown content block.

# Fields

  - `id::String`: Unique identifier for the content block
  - `content::String`: Markdown content
"""
struct MarkdownContent <: ContentItem
    id::String
    content::String
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

include("validation.jl")
include("template.jl")

end
