module Patchwork

using UUIDs
import JSON

export Item, Tab, Dashboard, Html
export render, to_html, cdn_urls, init_script, css

include("string.jl")
include("item.jl")
include("html.jl")
include("tab.jl")
include("dashboard.jl")

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
