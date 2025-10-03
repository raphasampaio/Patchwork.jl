module PlotlyPlugin

import JSON
import ..Plugin, ..to_html, ..css_deps, ..js_deps, ..init_script, ..css
using UUIDs

export Plotly

struct Plotly <: Plugin
    title::String
    data::Vector{Dict{String, Any}}
    layout::Dict{String, Any}
    config::Dict{String, Any}

    function Plotly(
        title::String,
        data::Vector{Dict{String, Any}};
        layout::Dict{String, Any} = Dict{String, Any}(),
        config::Dict{String, Any} = Dict{String, Any}(),
    )
        return new(title, data, layout, config)
    end
end

function to_html(plugin::Plotly)
    chart_id = "chart-$(uuid4())"
    data_json = JSON.json(plugin.data)
    layout = merge(Dict("autosize" => true), plugin.layout)
    layout_json = JSON.json(layout)
    config = merge(Dict("responsive" => true), plugin.config)
    config_json = JSON.json(config)

    return """
    <div>
        <h3 class="text-lg font-semibold mb-4">$(plugin.title)</h3>
        <div id="$chart_id" class="plotly-chart" data-data='$data_json' data-layout='$layout_json' data-config='$config_json' style="height: 400px;"></div>
    </div>
    """
end

css_deps(::Type{Plotly}) = String[]

js_deps(::Type{Plotly}) = [
    "https://cdn.plot.ly/plotly-2.27.0.min.js",
]

init_script(::Type{Plotly}) = """
    const initPlotlyCharts = () => {
        document.querySelectorAll('.plotly-chart').forEach(container => {
            if (container.offsetParent !== null && !container.classList.contains('plotly-initialized')) {
                const data = JSON.parse(container.getAttribute('data-data'));
                const layout = JSON.parse(container.getAttribute('data-layout'));
                const config = JSON.parse(container.getAttribute('data-config'));

                if (layout.height) {
                    container.style.height = layout.height + 'px';
                } else {
                    layout.height = parseInt(getComputedStyle(container).height);
                }

                Plotly.newPlot(container.id, data, layout, config);
                container.classList.add('plotly-initialized');
            }
        });
    };

    initPlotlyCharts();

    // Check for newly visible charts periodically
    setInterval(initPlotlyCharts, 100);
"""

css(::Type{Plotly}) = """
.plotly-chart {
    min-height: 400px;
}
.plotly-chart .plot-container {
    height: 100% !important;
}
.plotly-chart .gl-container {
    height: 100% !important;
}
.plotly-chart .mapboxgl-map {
    top: 0 !important;
    left: 0 !important;
    width: 100% !important;
    height: 100% !important;
}
"""

end
