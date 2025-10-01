module TestCharts

using Test
using Rhinestone
using JSON

@testset "Chart Plugins" begin
    @testset "ChartJs" begin
        chart = ChartJs(
            "Test Chart",
            "line",
            Dict{String,Any}("labels" => ["A", "B"], "datasets" => [Dict("data" => [1, 2])]),
        )
        @test chart isa Item
        @test chart.title == "Test Chart"
        @test chart.chart_type == "line"

        html_output = tohtml(chart)
        @test occursin("Test Chart", html_output)
        @test occursin("chartjs-chart", html_output)
        @test occursin("canvas", html_output)
        @test occursin("data-config", html_output)

        @test length(cdnurls(ChartJs)) > 0
        @test occursin("chart.js", cdnurls(ChartJs)[1])

        script = initscript(ChartJs)
        @test occursin("chartjs-chart", script)
        @test occursin("Chart", script)
    end

    @testset "ChartJs with options" begin
        chart = ChartJs(
            "Custom Chart",
            "bar",
            Dict{String,Any}("labels" => ["X"], "datasets" => [Dict("data" => [10])]),
            options = Dict{String,Any}("plugins" => Dict("legend" => Dict("display" => false))),
        )

        html_output = tohtml(chart)
        @test occursin("Custom Chart", html_output)
    end

    @testset "Highcharts" begin
        chart = Highcharts(
            "Analytics",
            Dict{String,Any}(
                "chart" => Dict("type" => "column"),
                "series" => [Dict("data" => [1, 2, 3])],
            ),
        )
        @test chart isa Item
        @test chart.title == "Analytics"

        html_output = tohtml(chart)
        @test occursin("Analytics", html_output)
        @test occursin("highcharts-chart", html_output)
        @test occursin("data-config", html_output)

        @test length(cdnurls(Highcharts)) > 0
        @test occursin("highcharts", cdnurls(Highcharts)[1])

        script = initscript(Highcharts)
        @test occursin("Highcharts", script)
    end

    @testset "Plotly" begin
        chart = Plotly(
            "Science Plot",
            [Dict("x" => [1, 2, 3], "y" => [4, 5, 6], "type" => "scatter")],
        )
        @test chart isa Item
        @test chart.title == "Science Plot"

        html_output = tohtml(chart)
        @test occursin("Science Plot", html_output)
        @test occursin("plotly-chart", html_output)
        @test occursin("data-data", html_output)

        @test length(cdnurls(Plotly)) > 0
        @test occursin("plotly", cdnurls(Plotly)[1])

        script = initscript(Plotly)
        @test occursin("Plotly", script)
    end

    @testset "Plotly with layout and config" begin
        chart = Plotly(
            "Custom Plot",
            [Dict{String,Any}("y" => [1, 2, 3])],
            layout = Dict{String,Any}("title" => "My Title"),
            config = Dict{String,Any}("displayModeBar" => false),
        )

        html_output = tohtml(chart)
        @test occursin("Custom Plot", html_output)
        @test occursin("data-layout", html_output)
        @test occursin("data-config", html_output)
    end
end

# Generate sample HTML output with all chart types
dashboard = Dashboard("Charts Demo", [
    Tab("Chart.js", [
        ChartJs(
            "Sales by Quarter",
            "bar",
            Dict{String,Any}(
                "labels" => ["Q1", "Q2", "Q3", "Q4"],
                "datasets" => [
                    Dict("label" => "2023", "data" => [120, 190, 130, 250], "backgroundColor" => "rgba(54, 162, 235, 0.5)"),
                    Dict("label" => "2024", "data" => [150, 220, 180, 290], "backgroundColor" => "rgba(255, 99, 132, 0.5)")
                ]
            )
        ),
        ChartJs(
            "Traffic Sources",
            "doughnut",
            Dict{String,Any}(
                "labels" => ["Direct", "Social", "Organic", "Referral"],
                "datasets" => [Dict(
                    "data" => [300, 150, 200, 100],
                    "backgroundColor" => ["#FF6384", "#36A2EB", "#FFCE56", "#4BC0C0"]
                )]
            )
        )
    ]),
    Tab("Highcharts", [
        Highcharts(
            "Monthly Performance",
            Dict{String,Any}(
                "chart" => Dict("type" => "line"),
                "title" => Dict("text" => ""),
                "xAxis" => Dict("categories" => ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]),
                "yAxis" => Dict("title" => Dict("text" => "Value")),
                "series" => [
                    Dict("name" => "Series A", "data" => [29, 71, 106, 129, 144, 176]),
                    Dict("name" => "Series B", "data" => [50, 80, 95, 110, 130, 150])
                ]
            )
        ),
        Highcharts(
            "Distribution",
            Dict{String,Any}(
                "chart" => Dict("type" => "column"),
                "xAxis" => Dict("categories" => ["Alpha", "Beta", "Gamma", "Delta"]),
                "series" => [Dict("name" => "Values", "data" => [5, 3, 4, 7])]
            )
        )
    ]),
    Tab("Plotly", [
        Plotly(
            "Scatter Analysis",
            [Dict{String,Any}(
                "x" => [1, 2, 3, 4, 5, 6],
                "y" => [1, 4, 9, 16, 25, 36],
                "mode" => "markers+lines",
                "type" => "scatter",
                "name" => "Quadratic"
            )],
            layout = Dict{String,Any}("xaxis" => Dict("title" => "X"), "yaxis" => Dict("title" => "Y²"))
        ),
        Plotly(
            "3D Surface",
            [Dict{String,Any}(
                "z" => [[1, 2, 3], [2, 3, 4], [3, 4, 5]],
                "type" => "surface"
            )],
            layout = Dict{String,Any}("title" => "3D Surface Plot")
        )
    ]),
    Tab("Mixed Charts", [
        Markdown("## Chart Comparison\n\nThis tab shows different chart libraries side by side."),
        ChartJs("Line Chart", "line", Dict{String,Any}("labels" => ["A", "B", "C"], "datasets" => [Dict("data" => [10, 20, 15])])),
        Highcharts("Area Chart", Dict{String,Any}("chart" => Dict("type" => "area"), "series" => [Dict("data" => [10, 20, 15])])),
        Plotly("Scatter Plot", [Dict{String,Any}("y" => [10, 20, 15], "type" => "scatter")])
    ])
])

output_path = joinpath(@__DIR__, "output", "test_charts.html")
render(dashboard, output_path)

end
