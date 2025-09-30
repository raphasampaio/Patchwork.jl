using Test
using Rhinestone

@testset "ChartPlaceholder" begin
    chart = ChartPlaceholder("test-chart", "Test Chart")
    @test chart.id == "test-chart"
    @test chart.title == "Test Chart"
    @test chart.height == "24rem"

    chart2 = ChartPlaceholder("chart2", "Chart 2", height = "32rem", metadata = Dict{String, Any}("type" => "line"))
    @test chart2.height == "32rem"
    @test chart2.metadata["type"] == "line"
end

@testset "Tab" begin
    tab = Tab("Test Tab", [ChartPlaceholder("c1", "Chart 1")])
    @test tab.label == "Test Tab"
    @test length(tab.charts) == 1

    empty_tab = Tab("Empty", ChartPlaceholder[])
    @test length(empty_tab.charts) == 0
end

@testset "DashboardConfig" begin
    tab = Tab("Tab", [ChartPlaceholder("test", "Test")])
    config = DashboardConfig("Dashboard", [tab])
    @test config.title == "Dashboard"
    @test length(config.tabs) == 1
    @test haskey(config.cdn_urls, "tailwind")
end

@testset "Generate HTML" begin
    output_path = joinpath(@__DIR__, "test_output", "test_types.html")
    mkpath(dirname(output_path))

    chart = ChartPlaceholder("test-chart", "Test Chart",
        metadata = Dict{String, Any}(
            "type" => "bar",
            "data" => Dict(
                "labels" => ["A", "B", "C"],
                "datasets" => [Dict("label" => "Dataset", "data" => [10, 20, 30])],
            ),
        ))
    tab = Tab("Types Test", [chart])

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
        "Types Test Dashboard",
        [tab],
        chart_init_script = chart_script,
        cdn_urls = Dict(
            "tailwind" => "https://cdn.tailwindcss.com/3.4.0",
            "vue" => "https://cdn.jsdelivr.net/npm/vue@3.3.4/dist/vue.global.js",
            "chartjs" => "https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js",
        ),
    )

    generate_dashboard(config, output_path)
    @test isfile(output_path)
end
