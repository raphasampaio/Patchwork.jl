module ChartJsPlugin

import JSON
import ..Plugin, ..to_html, ..css_deps, ..js_deps, ..init_script, ..css

export ChartJs

struct ChartJs <: Plugin
    title::String
    chart_type::String
    data::Dict{String, Any}
    options::Dict{String, Any}

    function ChartJs(
        title::String,
        chart_type::String,
        data::Dict{String, Any};
        options::Dict{String, Any} = Dict{String, Any}(),
    )
        return new(title, chart_type, data, options)
    end
end

function to_html(plugin::ChartJs)
    config = Dict(
        "type" => plugin.chart_type,
        "data" => plugin.data,
        "options" => merge(
            Dict("responsive" => true, "maintainAspectRatio" => false),
            plugin.options,
        ),
    )
    config_json = JSON.json(config)

    return """
    <div>
        <h3 class="text-lg font-semibold mb-4">$(plugin.title)</h3>
        <div style="height: 400px;">
            <canvas class="chartjs-chart" data-config='$config_json'></canvas>
        </div>
    </div>
    """
end

css_deps(::Type{ChartJs}) = String[]

js_deps(::Type{ChartJs}) = [
    "https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.js",
]

init_script(::Type{ChartJs}) = """
    document.querySelectorAll('.chartjs-chart').forEach(canvas => {
        const config = JSON.parse(canvas.getAttribute('data-config'));
        new Chart(canvas, config);
    });
"""

css(::Type{ChartJs}) = ""

end
