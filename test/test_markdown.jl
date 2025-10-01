module TestMarkdown

using Test
using Rhinestone
using Rhinestone.RhinestoneMarkdown

@testset "Markdown" begin
    output_path = joinpath(@__DIR__, "output", "test_markdown.html")
    mkpath(dirname(output_path))

    markdown_content = RhinestoneMarkdown.MarkdownContent(
        "intro",
        """
# Dashboard Overview

This dashboard demonstrates **markdown support** alongside charts.

## Features

- Mix markdown and charts freely
- Full markdown syntax support
- Search across both content types

```julia
# Example code block
function hello()
    println("Hello, World!")
end
```
""",
    )

    chart = ChartPlaceholder("sample-chart", "Sample Chart",
        metadata = Dict{String, Any}(
            "type" => "bar",
            "data" => Dict(
                "labels" => ["A", "B", "C"],
                "datasets" => [Dict("label" => "Values", "data" => [10, 20, 15])],
            ),
        ))

    tab = Tab("Mixed Content", [markdown_content, chart])

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
        "Markdown Test Dashboard",
        [tab],
        chart_init_script = chart_script,
        cdn_urls = Dict(
            "chartjs" => "https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js",
        ),
    )

    generate_dashboard(config, output_path)
    @test isfile(output_path)

    content = read(output_path, String)
    @test occursin("Markdown Test Dashboard", content)
    @test occursin("Dashboard Overview", content)
    @test occursin("markdown", content)
    @test occursin(".prose", content)  # Check for prose CSS styling
end

end
