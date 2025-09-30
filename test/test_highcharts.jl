module TestHighcharts

using Test
using Rhinestone

@testset "Highcharts" begin
    output_path = joinpath(@__DIR__, "output", "test_highcharts.html")
    mkpath(dirname(output_path))

    chart = ChartPlaceholder("highcharts-chart", "Monthly Sales",
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
    tab = Tab("Highcharts Test", [chart])

    chart_script = """
    function initializeChart(chartId, metadata) {
        const container = document.getElementById(chartId);
        Highcharts.chart(container, metadata);
    }
    """

    config = DashboardConfig(
        "Highcharts Test Dashboard",
        [tab],
        chart_init_script = chart_script,
        cdn_urls = Dict(
            "highcharts" => "https://code.highcharts.com/highcharts.js",
        ),
    )

    generate_dashboard(config, output_path)
    @test isfile(output_path)

    content = read(output_path, String)
    @test occursin("Highcharts Test Dashboard", content)
    @test occursin("highcharts-chart", content)
    @test occursin("Highcharts.chart", content)
    @test occursin("https://code.highcharts.com/highcharts.js", content)
    @test occursin("vue.global.js", content)
    @test occursin("tailwindcss.com", content)
end

end
