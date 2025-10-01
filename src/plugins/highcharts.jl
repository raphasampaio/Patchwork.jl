module HighchartsPlugin

import JSON
import ..Item, ..to_html, ..cdn_urls, ..init_script, ..css
using UUIDs

export PatchworkHighcharts

struct PatchworkHighcharts <: Item
    title::String
    config::Dict{String, Any}

    PatchworkHighcharts(title::String, config::Dict{String, Any}) = new(title, config)
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

cdn_urls(::Type{PatchworkHighcharts}) = ["https://code.highcharts.com/highcharts.js"]

init_script(::Type{PatchworkHighcharts}) = """
    document.querySelectorAll('.highcharts-chart').forEach(container => {
        const config = JSON.parse(container.getAttribute('data-config'));
        Highcharts.chart(container.id, config);
    });
"""

css(::Type{PatchworkHighcharts}) = ""

end
