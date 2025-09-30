module TestTemplate

using Test
using Rhinestone

@testset "Template" begin
    @test Rhinestone.escape_html("plain text") == "plain text"
    @test Rhinestone.escape_html("<script>") == "&lt;script&gt;"
    @test Rhinestone.escape_json("\"quote\"") == "\\\"quote\\\""
    @test Rhinestone.json_string("text") == "\"text\""
    @test Rhinestone.json_string(42) == "42"
    @test Rhinestone.json_string([1, 2, 3]) == "[1,2,3]"
    @test Rhinestone.json_string(Dict("key" => "value")) == "{\"key\":\"value\"}"
end

@testset "Generate HTML" begin
    output_path = joinpath(@__DIR__, "output", "test_template.html")
    mkpath(dirname(output_path))

    chart = ChartPlaceholder("template-chart", "Template Test Chart",
        metadata = Dict{String, Any}(
            "type" => "pie",
            "data" => Dict(
                "labels" => ["Red", "Blue", "Yellow"],
                "datasets" => [Dict("data" => [300, 50, 100])],
            ),
        ))
    tab = Tab("Template Test", [chart])

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
        "Template Test Dashboard",
        [tab],
        chart_init_script = chart_script,
        cdn_urls = Dict(
            "chartjs" => "https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js",
        ),
    )

    generate_dashboard(config, output_path)
    @test isfile(output_path)
end

end
