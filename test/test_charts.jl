module TestCharts

using Test
using Rhinestone

@testset "Charts" begin
    output_path = joinpath(@__DIR__, "output", "test_charts.html")
    mkpath(dirname(output_path))

    # Chart.js line chart
    chartjs_chart = ChartPlaceholder("cpu-chart", "CPU Usage",
        metadata = Dict{String, Any}(
            "type" => "line",
            "data" => Dict(
                "labels" => ["00:00", "01:00", "02:00", "03:00", "04:00"],
                "datasets" => [Dict("label" => "CPU %", "data" => [45, 52, 38, 61, 42])],
            ),
        ))

    # Plotly scatter chart
    plotly_chart = ChartPlaceholder("square-chart", "Square Numbers",
        metadata = Dict{String, Any}(
            "data" => [
                Dict(
                    "x" => [1, 2, 3, 4, 5],
                    "y" => [1, 4, 9, 16, 25],
                    "type" => "scatter",
                    "mode" => "lines+markers",
                    "name" => "Values",
                ),
            ],
            "layout" => Dict(
                "xaxis" => Dict("title" => "Number"),
                "yaxis" => Dict("title" => "Square"),
            ),
        ))

    # Highcharts column chart
    highcharts_chart = ChartPlaceholder("sales-chart", "Monthly Sales",
        metadata = Dict{String, Any}(
            "chart" => Dict("type" => "column"),
            "xAxis" => Dict(
                "categories" => ["Jan", "Feb", "Mar", "Apr", "May", "Jun"],
            ),
            "yAxis" => Dict(
                "title" => Dict("text" => "Sales (USD)"),
            ),
            "series" => [
                Dict(
                    "name" => "Revenue",
                    "data" => [49.9, 71.5, 106.4, 129.2, 144.0, 176.0],
                ),
                Dict(
                    "name" => "Expenses",
                    "data" => [83.6, 78.8, 98.5, 93.4, 106.0, 84.5],
                ),
            ],
        ))

    tab = Tab("All Charts", [chartjs_chart, plotly_chart, highcharts_chart])

    chart_script = """
    function initializeChart(chartId, metadata) {
        const container = document.getElementById(chartId);

        // Chart.js
        if (metadata.type && (metadata.type === 'line' || metadata.type === 'bar' || metadata.type === 'pie')) {
            const canvas = document.createElement('canvas');
            container.appendChild(canvas);
            new Chart(canvas, {
                type: metadata.type,
                data: metadata.data,
                options: {
                    responsive: true,
                    maintainAspectRatio: false
                }
            });
        }
        // Plotly
        else if (metadata.data && Array.isArray(metadata.data) && metadata.data[0]?.type === 'scatter') {
            Plotly.newPlot(container, metadata.data, metadata.layout, {responsive: true});
        }
        // Highcharts
        else if (metadata.chart || metadata.series) {
            Highcharts.chart(container, metadata);
        }
    }
    """

    config = DashboardConfig(
        "Multi-Library Dashboard",
        [tab],
        chart_init_script = chart_script,
        cdn_urls = Dict(
            "chartjs" => "https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js",
            "plotly" => "https://cdn.plot.ly/plotly-2.27.0.min.js",
            "highcharts" => "https://code.highcharts.com/highcharts.js",
        ),
    )

    generate_dashboard(config, output_path)
    @test isfile(output_path)

    content = read(output_path, String)
    @test occursin("Multi-Library Dashboard", content)
    @test occursin("cpu-chart", content)
    @test occursin("square-chart", content)
    @test occursin("sales-chart", content)
    @test occursin("chart.js", content)
    @test occursin("plotly", content)
    @test occursin("highcharts", content)
end

end
