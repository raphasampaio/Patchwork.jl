module Patchwork

using UUIDs
import JSON

export Item, Tab, Dashboard, Html
export render, tohtml, cdnurls, initscript

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

tohtml(item::Html) = item.content
cdnurls(::Type{Html}) = String[]
initscript(::Type{Html}) = ""

include("html.jl")

include("plugins/markdown.jl")
include("plugins/chartjs.jl")
include("plugins/highcharts.jl")
include("plugins/plotly.jl")

using .MarkdownPlugin
using .ChartJsPlugin
using .HighchartsPlugin
using .PlotlyPlugin

export Markdown, ChartJs, Highcharts, Plotly

end
