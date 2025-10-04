module ChartJsPlugin

import ..Plugin, ..to_html, ..css_deps, ..js_deps, ..init_script, ..css

using JSON

export ChartJs

@doc """
    ChartJs(
        title::String,
        chart_type::String,
        data::Dict{String,Any};
        options::Dict{String,Any} = Dict{String,Any}()
    )

Chart.js visualization plugin.

Creates interactive charts using Chart.js library. Supports multiple chart types with
customizable options. Always use `Dict{String,Any}` for type parameters to avoid
type inference issues.

# Fields
- `title::String`: Chart title displayed above the visualization
- `chart_type::String`: Type of chart (line, bar, radar, doughnut, pie, polarArea, bubble, scatter)
- `data::Dict{String,Any}`: Chart data configuration (labels and datasets)
- `options::Dict{String,Any}`: Optional chart configuration options

# Example: Bar Chart
```julia
Patchwork.ChartJs(
    "Sales by Quarter",
    "bar",
    Dict{String,Any}(
        "labels" => ["Q1", "Q2", "Q3", "Q4"],
        "datasets" => [
            Dict{String,Any}(
                "label" => "2024",
                "data" => [12, 19, 8, 15],
                "backgroundColor" => "rgba(54, 162, 235, 0.5)",
            ),
        ],
    ),
)
```

# Example: Doughnut Chart
```julia
Patchwork.ChartJs(
    "Traffic Sources",
    "doughnut",
    Dict{String,Any}(
        "labels" => ["Direct", "Social", "Organic"],
        "datasets" => [
            Dict{String,Any}(
                "data" => [300, 150, 200],
                "backgroundColor" => ["#FF6384", "#36A2EB", "#FFCE56"],
            ),
        ],
    ),
)
```

# Example: With Custom Options
```julia
Patchwork.ChartJs(
    "Time Series",
    "line",
    Dict{String,Any}(...),
    options = Dict{String,Any}(
        "plugins" => Dict(
            "legend" => Dict("position" => "top"),
        ),
    ),
)
```

See also: `Highcharts`, `Plotly`, `Plugin`
"""
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
