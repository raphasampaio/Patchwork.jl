module HighchartsPlugin

import JSON
import ..Item, ..tohtml, ..cdnurls, ..initscript
using UUIDs

export Highcharts

struct Highcharts <: Item
    title::String
    config::Dict{String,Any}

    Highcharts(title::String, config::Dict{String,Any}) = new(title, config)
end

function tohtml(item::Highcharts)
    chart_id = "chart-$(uuid4())"
    config_json = JSON.json(item.config)

    return """
    <div>
        <h3 class="text-lg font-semibold mb-4">$(item.title)</h3>
        <div id="$chart_id" class="highcharts-chart" data-config='$config_json' style="height: 400px;"></div>
    </div>
    """
end

cdnurls(::Type{Highcharts}) = ["https://code.highcharts.com/highcharts.js"]

initscript(::Type{Highcharts}) = """
    document.querySelectorAll('.highcharts-chart').forEach(container => {
        const config = JSON.parse(container.getAttribute('data-config'));
        Highcharts.chart(container.id, config);
    });
"""

end
