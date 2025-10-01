module HighchartsPlugin

import JSON
import ..Item, ..to_html, ..css_deps, ..js_deps, ..init_script, ..css
using UUIDs

export PatchworkHighcharts

struct PatchworkHighcharts <: Item
    title::String
    config::Dict{String, Any}

    function PatchworkHighcharts(title::String, config::Dict{String, Any})
        return new(title, config)
    end
end

function PatchworkHighcharts(title::String, config::AbstractString)
    return PatchworkHighcharts(title, JSON.parse(config))
end

function to_html(item::PatchworkHighcharts)
    chart_id = "chart-$(uuid4())"
    config_json = JSON.json(item.config)

    return """
    <div>
        <h3 class="text-lg font-semibold mb-4">$(item.title)</h3>
        <div id="$chart_id" class="highcharts-chart" data-config='$config_json' style="height: 400px;"></div>
    </div>
    """
end

css_deps(::Type{PatchworkHighcharts}) = String[]

js_deps(::Type{PatchworkHighcharts}) = [
    "https://code.highcharts.com/12.4.0/highcharts.js",
]

init_script(::Type{PatchworkHighcharts}) = """
    document.querySelectorAll('.highcharts-chart').forEach(container => {
        const config = JSON.parse(container.getAttribute('data-config'));
        Highcharts.chart(container.id, config);
    });
"""

css(::Type{PatchworkHighcharts}) = ""

end
