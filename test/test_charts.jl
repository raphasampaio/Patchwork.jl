module TestCharts

using Test
using Rhinestone
using JSON

@testset "Chart Plugins" begin
    @testset "ChartJs" begin
        chart = ChartJs(
            "Test Chart",
            "line",
            Dict("labels" => ["A", "B"], "datasets" => [Dict("data" => [1, 2])]),
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
            Dict("labels" => ["X"], "datasets" => [Dict("data" => [10])]),
            options = Dict("plugins" => Dict("legend" => Dict("display" => false))),
        )

        html_output = tohtml(chart)
        @test occursin("Custom Chart", html_output)
    end

    @testset "Highcharts" begin
        chart = Highcharts(
            "Analytics",
            Dict(
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
            [Dict("y" => [1, 2, 3])],
            layout = Dict("title" => "My Title"),
            config = Dict("displayModeBar" => false),
        )

        html_output = tohtml(chart)
        @test occursin("Custom Plot", html_output)
        @test occursin("data-layout", html_output)
        @test occursin("data-config", html_output)
    end
end

end
