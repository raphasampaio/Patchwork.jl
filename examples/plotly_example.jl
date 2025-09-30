using Rhinestone

# Example: Dashboard with Plotly.js

# Define chart placeholders with metadata for Plotly
tabs = [
    Tab(
        "Data Visualization",
        [
            ChartPlaceholder("scatter-chart", "Scatter Plot Example",
                metadata = Dict{String, Any}(
                    "data" => [
                        Dict(
                            "x" => [1, 2, 3, 4, 5],
                            "y" => [1, 4, 9, 16, 25],
                            "mode" => "markers",
                            "type" => "scatter",
                            "name" => "Quadratic",
                        ),
                    ],
                    "layout" => Dict(
                        "title" => "",
                        "xaxis" => Dict("title" => "X Axis"),
                        "yaxis" => Dict("title" => "Y Axis"),
                    ),
                ),
            ),
            ChartPlaceholder("bar-chart", "Bar Chart Example",
                metadata = Dict{String, Any}(
                    "data" => [
                        Dict(
                            "x" => ["Q1", "Q2", "Q3", "Q4"],
                            "y" => [120, 150, 170, 190],
                            "type" => "bar",
                            "name" => "Sales",
                        ),
                    ],
                    "layout" => Dict(
                        "title" => "",
                        "yaxis" => Dict("title" => "Revenue (\$K)"),
                    ),
                ),
            ),
        ],
    ),
    Tab(
        "3D Charts",
        [
            ChartPlaceholder("surface-chart", "3D Surface Plot",
                metadata = Dict{String, Any}(
                    "data" => [
                        Dict(
                            "z" => [
                                [8.83, 8.89, 8.81, 8.87, 8.9, 8.87],
                                [8.89, 8.94, 8.85, 8.94, 8.96, 8.92],
                                [8.84, 8.9, 8.82, 8.92, 8.93, 8.91],
                                [8.79, 8.85, 8.79, 8.9, 8.94, 8.92],
                            ],
                            "type" => "surface",
                            "colorscale" => "Viridis",
                        ),
                    ],
                    "layout" => Dict(
                        "title" => "",
                        "scene" => Dict(
                            "xaxis" => Dict("title" => "X"),
                            "yaxis" => Dict("title" => "Y"),
                            "zaxis" => Dict("title" => "Z"),
                        ),
                    ),
                ),
            ),
        ],
    ),
]

# Plotly.js initialization script
chart_init_script = """
// Plotly.js must be loaded via CDN
function initializeChart(chartId, metadata) {
    const container = document.getElementById(chartId);

    // Plotly expects data and layout separately
    const data = metadata.data || [];
    const layout = metadata.layout || {};

    // Set responsive sizing
    const config = {
        responsive: true
    };

    Plotly.newPlot(container, data, layout, config);
}
"""

# Create dashboard configuration
config = DashboardConfig(
    "Plotly Dashboard",
    tabs,
    chart_init_script = chart_init_script,
    cdn_urls = Dict(
        "tailwind" => "https://cdn.tailwindcss.com/3.4.0",
        "vue" => "https://cdn.jsdelivr.net/npm/vue@3.3.4/dist/vue.global.js",
        "plotly" => "https://cdn.plot.ly/plotly-2.18.0.min.js",
    ),
)

# Generate the dashboard
output_file = "dashboard_plotly.html"
generate_dashboard(config, output_file)

println("Dashboard generated: \$output_file")
