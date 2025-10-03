module HighchartsPlugin

import JSON
import ..Plugin, ..to_html, ..css_deps, ..js_deps, ..init_script, ..css
using UUIDs

export Highcharts

struct Highcharts <: Plugin
    title::String
    config::Dict{String, Any}

    function Highcharts(title::String, config::Dict{String, Any})
        return new(title, config)
    end
end

function Highcharts(title::String, config::AbstractString)
    return Highcharts(title, JSON.parse(config))
end

function to_html(plugin::Highcharts)
    chart_id = "chart-$(uuid4())"
    config_json = JSON.json(plugin.config)

    return """
    <div>
        <h3 class="text-lg font-semibold mb-4">$(plugin.title)</h3>
        <div id="$chart_id" class="highcharts-chart" data-config='$config_json' style="height: 400px;"></div>
    </div>
    """
end

css_deps(::Type{Highcharts}) = String[]

js_deps(::Type{Highcharts}) = [
    "https://code.highcharts.com/12.4.0/highcharts.js",
]

init_script(::Type{Highcharts}) = """
    document.querySelectorAll('.highcharts-chart').forEach(container => {
        const config = JSON.parse(container.getAttribute('data-config'));
        Highcharts.chart(container.id, config);
    });
"""

css(::Type{Highcharts}) = ""

end
