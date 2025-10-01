module HighchartsPlugin

import JSON
import ..Item, ..tohtml, ..cdnurls, ..initscript, ..customcss
using UUIDs

export PatchworkHighcharts

struct PatchworkHighcharts <: Item
    title::String
    config::Dict{String, Any}

    PatchworkHighcharts(title::String, config::Dict{String, Any}) = new(title, config)
end

function tohtml(item::PatchworkHighcharts)
    chart_id = "chart-$(uuid4())"
    config_json = JSON.json(item.config)

    return """
    <div>
        <h3 class="text-lg font-semibold mb-4">$(item.title)</h3>
        <div id="$chart_id" class="highcharts-chart" data-config='$config_json' style="height: 400px;"></div>
    </div>
    """
end

cdnurls(::Type{PatchworkHighcharts}) = ["https://code.highcharts.com/highcharts.js"]

initscript(::Type{PatchworkHighcharts}) = """
    document.querySelectorAll('.highcharts-chart').forEach(container => {
        const config = JSON.parse(container.getAttribute('data-config'));
        Highcharts.chart(container.id, config);
    });
"""

customcss(::Type{PatchworkHighcharts}) = ""

end
