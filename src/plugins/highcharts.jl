module HighchartsPlugin

import ..Plugin, ..to_html, ..css_deps, ..js_deps, ..init_script, ..css

using JSON
using UUIDs

export Highcharts

@doc """
    Highcharts(title::String, config::Dict{String,Any})
    Highcharts(title::String, config::AbstractString)

Highcharts visualization plugin.

Creates interactive charts using the Highcharts library. Supports the full Highcharts
configuration API. Accepts configuration as either a dictionary or JSON string.

# Fields
- `title::String`: Chart title displayed above the visualization
- `config::Dict{String,Any}`: Highcharts configuration object

# Constructors
- `Highcharts(title::String, config::Dict{String,Any})` - From dictionary
- `Highcharts(title::String, config::AbstractString)` - From JSON string

# Example: Line Chart
```julia
Patchwork.Highcharts(
    "Monthly Performance",
    Dict{String,Any}(
        "chart" => Dict("type" => "line"),
        "xAxis" => Dict("categories" => ["Jan", "Feb", "Mar"]),
        "yAxis" => Dict("title" => Dict("text" => "Value")),
        "series" => [
            Dict("name" => "Series A", "data" => [29, 71, 106]),
            Dict("name" => "Series B", "data" => [50, 80, 95]),
        ],
    ),
)
```

# Example: Column Chart
```julia
Patchwork.Highcharts(
    "Distribution",
    Dict{String,Any}(
        "chart" => Dict("type" => "column"),
        "xAxis" => Dict("categories" => ["Alpha", "Beta", "Gamma"]),
        "series" => [Dict("name" => "Values", "data" => [5, 3, 4])],
    ),
)
```

# Example: From JSON
```julia
config_json = \"\"\"
{
    "chart": {"type": "area"},
    "series": [{"data": [1, 2, 3, 4]}]
}
\"\"\"
Patchwork.Highcharts("Area Chart", config_json)
```

See also: `ChartJs`, `Plotly`, `Plugin`
"""
struct Highcharts <: Plugin
    title::String
    config::Dict{String, Any}

    function Highcharts(title::String, config::Dict{String, Any})
        return new(title, config)
    end
end

function Highcharts(title::String, config::AbstractString)
    return Highcharts(title, JSON.parse(config; dicttype = Dict{String, Any}))
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
    "https://code.highcharts.com/12.4.0/highcharts-more.js",
    "https://code.highcharts.com/12.4.0/modules/exporting.js",
]

init_script(::Type{Highcharts}) = """
    document.querySelectorAll('.highcharts-chart').forEach(container => {
        const config = JSON.parse(container.getAttribute('data-config'));

        config.navigation = { buttonOptions: { align: 'left' } };

        config.exporting = {
            enabled: true,
            buttons: {
                contextButton: {
                    menuItems: [
                        'downloadPNG',
                        {
                            text: 'Show All Series',
                            onclick: function() {
                                this.series.forEach(series => {
                                    if (!series.visible) {
                                        series.setVisible(true, false);
                                    }
                                });
                                this.redraw();
                            }
                        },
                        {
                            text: 'Hide All Series',
                            onclick: function() {
                                this.series.forEach(series => {
                                    if (series.visible) {
                                        series.setVisible(false, false);
                                    }
                                });
                                this.redraw();
                            }
                        }                        
                    ]
                }
            }
        };
        
        Highcharts.chart(container.id, config);
    });
"""

css(::Type{Highcharts}) = ""

end
