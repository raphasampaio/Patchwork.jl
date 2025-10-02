module Patchwork

using UUIDs
import JSON

export save, to_html, css_deps, js_deps, init_script, css

include("string.jl")
include("item.jl")
include("html.jl")
include("tab.jl")
include("dashboard.jl")

include("plugins/markdown.jl")
include("plugins/chartjs.jl")
include("plugins/highcharts.jl")
include("plugins/plotly.jl")
include("plugins/leaflet.jl")
include("plugins/mermaid.jl")

using .MarkdownPlugin
using .ChartJsPlugin
using .HighchartsPlugin
using .PlotlyPlugin
using .LeafletPlugin
using .MermaidPlugin

export
    Markdown,
    ChartJs,
    Highcharts,
    Plotly,
    Leaflet,
    Mermaid

end
