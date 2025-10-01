module Patchwork

using UUIDs
import JSON

export Item, Tab, Dashboard, Html
export render, to_html, cdn_urls, init_script, css

abstract type Item end

struct Html <: Item
    content::String
end

struct Tab
    label::String
    items::Vector{Item}
end

struct Dashboard
    title::String
    tabs::Vector{Tab}
    custom_css::String

    Dashboard(title::String, tabs::Vector{Tab}; custom_css::String = "") =
        new(title, tabs, custom_css)
end

to_html(item::Html) = item.content
cdn_urls(::Type{Html}) = String[]
init_script(::Type{Html}) = ""
css(::Type{Html}) = ""

include("html.jl")

include("plugins/markdown.jl")
include("plugins/chartjs.jl")
include("plugins/highcharts.jl")
include("plugins/plotly.jl")

using .MarkdownPlugin
using .ChartJsPlugin
using .HighchartsPlugin
using .PlotlyPlugin

export PatchworkMarkdown, PatchworkChartJs, PatchworkHighcharts, PatchworkPlotly

end
