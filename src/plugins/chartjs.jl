module ChartJsPlugin

import JSON
import ..Item, ..tohtml, ..cdnurls, ..initscript, ..customcss

export PatchworkChartJs

struct PatchworkChartJs <: Item
    title::String
    chart_type::String
    data::Dict{String, Any}
    options::Dict{String, Any}

    PatchworkChartJs(
        title::String,
        chart_type::String,
        data::Dict{String, Any};
        options::Dict{String, Any} = Dict{String, Any}(),
    ) =
        new(title, chart_type, data, options)
end

function tohtml(item::PatchworkChartJs)
    config = Dict(
        "type" => item.chart_type,
        "data" => item.data,
        "options" => merge(
            Dict("responsive" => true, "maintainAspectRatio" => false),
            item.options,
        ),
    )
    config_json = JSON.json(config)

    return """
    <div>
        <h3 class="text-lg font-semibold mb-4">$(item.title)</h3>
        <div style="height: 400px;">
            <canvas class="chartjs-chart" data-config='$config_json'></canvas>
        </div>
    </div>
    """
end

cdnurls(::Type{PatchworkChartJs}) = ["https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.js"]

initscript(::Type{PatchworkChartJs}) = """
    document.querySelectorAll('.chartjs-chart').forEach(canvas => {
        const config = JSON.parse(canvas.getAttribute('data-config'));
        new Chart(canvas, config);
    });
"""

customcss(::Type{PatchworkChartJs}) = ""

end
