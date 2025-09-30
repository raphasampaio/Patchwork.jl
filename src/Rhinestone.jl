module Rhinestone

export DashboardConfig, Tab, ChartPlaceholder, generate_dashboard

"""
    ChartPlaceholder

Represents a chart placeholder with a unique ID and container specifications.
The actual chart rendering is handled by user-provided JavaScript.

# Fields

  - `id::String`: Unique identifier for the chart container
  - `title::String`: Chart title
  - `height::String`: CSS height value (default: "24rem")
  - `metadata::Dict{String,Any}`: Additional metadata for chart initialization
"""
struct ChartPlaceholder
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
    Tab

Represents a dashboard tab containing multiple chart placeholders.

# Fields

  - `label::String`: Tab display label
  - `charts::Vector{ChartPlaceholder}`: Charts in this tab
"""
struct Tab
    label::String
    charts::Vector{ChartPlaceholder}
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
        cdn_urls::Dict{String, String} = Dict(
            "tailwind" => "https://cdn.tailwindcss.com/3.4.0",
            "vue" => "https://cdn.jsdelivr.net/npm/vue@3.3.4/dist/vue.global.js",
        ))
        return new(title, tabs, custom_css, chart_init_script, cdn_urls)
    end
end

include("template.jl")

end
