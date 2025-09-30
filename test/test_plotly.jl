module TestPlotly

using Test
using Rhinestone

@testset "Plotly" begin
    output_path = joinpath(@__DIR__, "output", "test_plotly.html")
    mkpath(dirname(output_path))

    chart = ChartPlaceholder("plotly-chart", "Plotly Test Chart",
        metadata = Dict{String, Any}(
            "data" => [
                Dict(
                    "x" => [1, 2, 3, 4, 5],
                    "y" => [1, 4, 9, 16, 25],
                    "type" => "scatter",
                    "mode" => "lines+markers",
                    "name" => "Square Numbers",
                ),
            ],
            "layout" => Dict(
                "title" => "Square Numbers",
                "xaxis" => Dict("title" => "Number"),
                "yaxis" => Dict("title" => "Square"),
            ),
        ))
    tab = Tab("Plotly Test", [chart])

    chart_script = """
    function initializeChart(chartId, metadata) {
        const container = document.getElementById(chartId);
        Plotly.newPlot(container, metadata.data, metadata.layout, {responsive: true});
    }
    """

    config = DashboardConfig(
        "Plotly Test Dashboard",
        [tab],
        chart_init_script = chart_script,
        cdn_urls = Dict(
            "plotly" => "https://cdn.plot.ly/plotly-2.27.0.min.js",
        ),
    )

    generate_dashboard(config, output_path)
    @test isfile(output_path)

    content = read(output_path, String)
    @test occursin("Plotly Test Dashboard", content)
    @test occursin("plotly-chart", content)
    @test occursin("Plotly.newPlot", content)
    @test occursin("https://cdn.plot.ly/plotly-2.27.0.min.js", content)
    @test occursin("vue.global.js", content)
    @test occursin("tailwindcss.com", content)
end

end
