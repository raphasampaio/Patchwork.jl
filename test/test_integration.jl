using Test
using Rhinestone

@testset "Integration Tests" begin
    output_path = joinpath(@__DIR__, "test_output", "test_integration.html")
    mkpath(dirname(output_path))

    chart = ChartPlaceholder("cpu-chart", "CPU Usage",
        metadata = Dict{String, Any}(
            "type" => "line",
            "data" => Dict(
                "labels" => ["00:00", "01:00", "02:00"],
                "datasets" => [Dict("label" => "CPU %", "data" => [45, 52, 38])],
            ),
        ))

    tab = Tab("Performance", [chart])

    chart_script = """
    function initializeChart(chartId, metadata) {
        const container = document.getElementById(chartId);
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
    """

    config = DashboardConfig(
        "Performance Dashboard",
        [tab],
        chart_init_script = chart_script,
        cdn_urls = Dict(
            "chartjs" => "https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js",
        ),
    )

    generate_dashboard(config, output_path)

    @test isfile(output_path)
    content = read(output_path, String)
    @test occursin("Performance Dashboard", content)
    @test occursin("cpu-chart", content)
    @test occursin("new Chart(canvas", content)
end
