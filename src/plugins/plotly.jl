module PlotlyPlugin

import JSON
import ..Item, ..tohtml, ..cdnurls, ..initscript
using UUIDs

export Plotly

struct Plotly <: Item
    title::String
    data::Vector{Dict{String, Any}}
    layout::Dict{String, Any}
    config::Dict{String, Any}

    Plotly(
        title::String,
        data::Vector{Dict{String, Any}};
        layout::Dict{String, Any} = Dict{String, Any}(),
        config::Dict{String, Any} = Dict{String, Any}(),
    ) =
        new(title, data, layout, config)
end

function tohtml(item::Plotly)
    chart_id = "chart-$(uuid4())"
    data_json = JSON.json(item.data)
    layout = merge(Dict("autosize" => true), item.layout)
    layout_json = JSON.json(layout)
    config = merge(Dict("responsive" => true), item.config)
    config_json = JSON.json(config)

    return """
    <div>
        <h3 class="text-lg font-semibold mb-4">$(item.title)</h3>
        <div id="$chart_id" class="plotly-chart" data-data='$data_json' data-layout='$layout_json' data-config='$config_json' style="height: 400px;"></div>
    </div>
    """
end

cdnurls(::Type{Plotly}) = ["https://cdn.plot.ly/plotly-2.27.0.min.js"]

initscript(::Type{Plotly}) = """
    document.querySelectorAll('.plotly-chart').forEach(container => {
        const data = JSON.parse(container.getAttribute('data-data'));
        const layout = JSON.parse(container.getAttribute('data-layout'));
        const config = JSON.parse(container.getAttribute('data-config'));
        Plotly.newPlot(container.id, data, layout, config);
    });
"""

end
