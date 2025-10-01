module TestCharts

using Test
using Rhinestone
using Rhinestone.RhinestoneChartJs
using Rhinestone.RhinestonePlotly
using Rhinestone.RhinestoneHighcharts

@testset "Charts" begin
    output_path = joinpath(@__DIR__, "output", "test_charts.html")
    mkpath(dirname(output_path))

    # Chart.js line chart
    chartjs_chart = ChartJsPlot(
        "cpu-chart",
        "CPU Usage",
        "line",
        Dict{String, Any}(
            "labels" => ["00:00", "01:00", "02:00", "03:00", "04:00"],
            "datasets" => [Dict("label" => "CPU %", "data" => [45, 52, 38, 61, 42])]
        )
    )

    # Plotly scatter chart
    plotly_chart = PlotlyPlot(
        "square-chart",
        "Square Numbers",
        [
            Dict(
                "x" => [1, 2, 3, 4, 5],
                "y" => [1, 4, 9, 16, 25],
                "type" => "scatter",
                "mode" => "lines+markers",
                "name" => "Values"
            )
        ],
        layout = Dict(
            "xaxis" => Dict("title" => "Number"),
            "yaxis" => Dict("title" => "Square"),
            "margin" => Dict("l" => 50, "r" => 20, "t" => 20, "b" => 50)
        )
    )

    # Highcharts column chart
    highcharts_chart = HighchartsPlot(
        "sales-chart",
        "Monthly Sales",
        Dict(
            "chart" => Dict("type" => "column"),
            "xAxis" => Dict(
                "categories" => ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
            ),
            "yAxis" => Dict(
                "title" => Dict("text" => "Sales (USD)")
            ),
            "series" => [
                Dict(
                    "name" => "Revenue",
                    "data" => [49.9, 71.5, 106.4, 129.2, 144.0, 176.0]
                ),
                Dict(
                    "name" => "Expenses",
                    "data" => [83.6, 78.8, 98.5, 93.4, 106.0, 84.5]
                )
            ]
        )
    )

    tab = Tab("All Charts", [chartjs_chart, plotly_chart, highcharts_chart])

    # No need to manually provide CDN URLs or init scripts - plugins handle it!
    config = DashboardConfig("Multi-Library Dashboard", [tab])

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
