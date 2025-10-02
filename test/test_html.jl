module TestHTML

using Test
using Patchwork

@testset "HTML Generation" begin
    @testset "render creates file" begin
        mktempdir() do dir
            path = joinpath(dir, "test.html")

            dashboard = Dashboard("Test", [
                Tab("Tab1", [Html("<p>content</p>")]),
            ])

            result = save(dashboard, path)

            @test result == path
            @test isfile(path)

            content = read(path, String)
            @test occursin("<!DOCTYPE html>", content)
            @test occursin("<html", content)
            @test occursin("Test", content)
        end
    end

    @testset "HTML contains Vue and Tailwind" begin
        dashboard = Dashboard("App", [Tab("T", [Html("<p>x</p>")])])
        html = Patchwork.generate_html(dashboard)

        @test occursin("vue", html)
        @test occursin("tailwindcss", html)
    end

    @testset "HTML contains dashboard title" begin
        dashboard = Dashboard("My Dashboard", [Tab("T", [Html("<p>x</p>")])])
        html = Patchwork.generate_html(dashboard)

        @test occursin("My Dashboard", html)
    end

    @testset "HTML escapes title properly" begin
        dashboard = Dashboard("<script>alert()</script>", [Tab("T", [Html("<p>x</p>")])])
        html = Patchwork.generate_html(dashboard)

        @test occursin("&lt;script&gt;", html)
        @test occursin("&lt;/script&gt;", html)
    end

    @testset "HTML includes custom CSS" begin
        dashboard = Dashboard("App", [Tab("T", [Html("<p>x</p>")])],
            custom_css = ".custom { color: red; }")
        html = Patchwork.generate_html(dashboard)

        @test occursin(".custom { color: red; }", html)
    end

    @testset "HTML includes CDN URLs from plugins" begin
        dashboard = Dashboard(
            "Charts",
            [
                Tab(
                    "T",
                    [
                        ChartJs("Chart", "line", Dict{String, Any}("labels" => [], "datasets" => [])),
                    ],
                ),
            ],
        )
        html = Patchwork.generate_html(dashboard)

        @test occursin("chart.js", html)
    end

    @testset "HTML includes init scripts from plugins" begin
        dashboard = Dashboard(
            "Charts",
            [
                Tab(
                    "T",
                    [
                        ChartJs("Chart", "bar", Dict{String, Any}("labels" => [], "datasets" => [])),
                    ],
                ),
            ],
        )
        html = Patchwork.generate_html(dashboard)

        @test occursin("chartjs-chart", html)
    end

    @testset "HTML contains multiple tabs" begin
        dashboard = Dashboard(
            "Multi",
            [
                Tab("Tab1", [Html("<p>one</p>")]),
                Tab("Tab2", [Html("<p>two</p>")]),
                Tab("Tab3", [Html("<p>three</p>")]),
            ],
        )
        html = Patchwork.generate_html(dashboard)

        @test occursin("Tab1", html)
        @test occursin("Tab2", html)
        @test occursin("Tab3", html)
        @test occursin("one", html)
        @test occursin("two", html)
        @test occursin("three", html)
    end

    @testset "HTML contains multiple items per tab" begin
        dashboard = Dashboard(
            "Multi",
            [
                Tab(
                    "Tab",
                    [
                        Html("<p>first</p>"),
                        Html("<p>second</p>"),
                        Markdown("# Third"),
                    ],
                ),
            ],
        )
        html = Patchwork.generate_html(dashboard)

        @test occursin("first", html)
        @test occursin("second", html)
        @test occursin("Third", html)
    end

    @testset "Mixed content types" begin
        dashboard = Dashboard(
            "Mixed",
            [
                Tab(
                    "All",
                    [
                        Html("<div>HTML</div>"),
                        Markdown("**Markdown**"),
                        ChartJs(
                            "Chart",
                            "pie",
                            Dict{String, Any}("labels" => ["A"], "datasets" => [Dict("data" => [1])]),
                        ),
                    ],
                ),
            ],
        )
        html = Patchwork.generate_html(dashboard)

        @test occursin("HTML", html)
        @test occursin("Markdown", html)
        @test occursin("Chart", html)
        @test occursin("chart.js", html)
    end
end

# Generate comprehensive HTML demo
dashboard = Dashboard(
    "HTML Generation Demo",
    [
        Tab(
            "Overview",
            [
                Markdown("""
                # Patchwork Dashboard Generator

                This demo showcases the HTML generation capabilities.

                ## Features Demonstrated

                - **Multi-tab layout** with Vue.js navigation
                - **Responsive design** using Tailwind CSS
                - **Search functionality** across all content
                - **Mixed content types** (HTML, Markdown, Charts)
                """),
                Html(
                    "<div class='bg-blue-50 border border-blue-200 rounded p-4 my-4'><strong>Info:</strong> This is custom HTML content with Tailwind classes.</div>",
                ),
            ],
        ),
        Tab(
            "Components",
            [
                Markdown("## Available Components\n\n### 1. HTML Items"),
                Html("<p>Direct HTML injection for maximum flexibility.</p>"),
                Markdown("### 2. Markdown Items"),
                Markdown("Support for *all* **standard** markdown features."),
                Markdown("### 3. Chart Items"),
                ChartJs(
                    "Sample Chart",
                    "line",
                    Dict{String, Any}(
                        "labels" => ["Mon", "Tue", "Wed", "Thu", "Fri"],
                        "datasets" => [Dict("label" => "Data", "data" => [12, 19, 3, 5, 2])],
                    ),
                ),
            ],
        ),
        Tab(
            "Custom Styling",
            [
                Markdown("## Custom CSS Support\n\nDashboards can include custom CSS for styling."),
                Html(
                    """
               <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 2rem; border-radius: 0.5rem; text-align: center;">
                   <h3 style="margin: 0; font-size: 1.5rem;">Gradient Box</h3>
                   <p style="margin-top: 0.5rem;">With inline styles</p>
               </div>
               """,
                ),
                Html(
                    "<div style='margin-top: 1rem; padding: 1rem; background: #f9fafb; border-radius: 0.5rem;'><code>Custom CSS can be added via the dashboard config</code></div>",
                ),
            ],
        ),
        Tab(
            "Interactive Features",
            [
                Markdown("""
                ## Search

                Try searching for keywords in the top search bar.

                ## Tab Navigation

                Click tabs in the sidebar to switch views.

                ## Responsive Layout

                Resize your browser to see the mobile-friendly layout.
                """),
                Html(
                    "<div class='grid grid-cols-2 gap-4 my-4'><div class='bg-gray-100 p-4 rounded'>Box 1</div><div class='bg-gray-100 p-4 rounded'>Box 2</div></div>",
                ),
            ],
        ),
    ],
    custom_css = """
    .bg-blue-50 { background-color: #eff6ff; }
    .border-blue-200 { border-color: #bfdbfe; }
    """,
)

output_path = joinpath(@__DIR__, "output", "test_html.html")
save(dashboard, output_path)

end
