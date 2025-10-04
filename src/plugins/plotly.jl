module PlotlyPlugin

import ..Plugin, ..to_html, ..css_deps, ..js_deps, ..init_script, ..css

using JSON
using UUIDs

export Plotly

@doc """
    Plotly(
        title::String,
        data::Vector{Dict{String,Any}};
        layout::Dict{String,Any} = Dict{String,Any}(),
        config::Dict{String,Any} = Dict{String,Any}()
    )

Plotly visualization plugin.

Creates interactive charts and visualizations using Plotly.js. Supports 2D/3D plots,
scientific charts, maps, and statistical visualizations. Provides full access to
Plotly's data, layout, and config options.

# Fields
- `title::String`: Chart title displayed above the visualization
- `data::Vector{Dict{String,Any}}`: Vector of Plotly data traces
- `layout::Dict{String,Any}`: Layout configuration (axes, title, etc.)
- `config::Dict{String,Any}`: Plotly config options (responsive, displayModeBar, etc.)

# Example: Scatter Plot
```julia
Patchwork.Plotly(
    "Scatter Analysis",
    [
        Dict{String,Any}(
            "x" => [1, 2, 3, 4, 5],
            "y" => [1, 4, 9, 16, 25],
            "mode" => "markers+lines",
            "type" => "scatter",
            "name" => "Quadratic",
        ),
    ],
    layout = Dict{String,Any}(
        "xaxis" => Dict("title" => "X"),
        "yaxis" => Dict("title" => "Y²"),
    ),
)
```

# Example: 3D Surface
```julia
Patchwork.Plotly(
    "3D Surface",
    [
        Dict{String,Any}(
            "z" => [[1, 2, 3], [2, 3, 4], [3, 4, 5]],
            "type" => "surface",
        ),
    ],
    layout = Dict{String,Any}("title" => "Surface Plot"),
)
```

# Example: Scattermap
```julia
Patchwork.Plotly(
    "US Cities",
    [
        Dict{String,Any}(
            "type" => "scattermapbox",
            "lat" => [40.7128, 34.0522],
            "lon" => [-74.0060, -118.2437],
            "mode" => "markers",
            "text" => ["NYC", "LA"],
        ),
    ],
    layout = Dict{String,Any}(
        "mapbox" => Dict(
            "style" => "open-street-map",
            "center" => Dict("lat" => 37, "lon" => -95),
            "zoom" => 3,
        ),
    ),
)
```

See also: `ChartJs`, `Highcharts`, `Leaflet`, `Plugin`
"""
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
