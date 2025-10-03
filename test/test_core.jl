module TestCore

using Test
using Patchwork

@testset "Core Types" begin
    @testset "HTML" begin
        html = Patchwork.HTML("<p>test</p>")
        @test html isa Patchwork.Plugin
        @test to_html(html) == "<p>test</p>"
        @test css_deps(Patchwork.HTML) == String[]
        @test js_deps(Patchwork.HTML) == String[]
        @test init_script(Patchwork.HTML) == ""
        @test css(Patchwork.HTML) == ""
    end

    @testset "Tab" begin
        tab = Patchwork.Tab("Test", [Patchwork.HTML("<p>content</p>")])
        @test tab.label == "Test"
        @test length(tab.plugins) == 1
        @test tab.plugins[1] isa Patchwork.HTML
    end

    @testset "Dashboard" begin
        tabs = [Patchwork.Tab("Tab1", [Patchwork.HTML("<p>content</p>")])]
        dashboard = Patchwork.Dashboard("Test Dashboard", tabs)
        @test dashboard.title == "Test Dashboard"
        @test length(dashboard.tabs) == 1
        @test dashboard.custom_css == ""

        dashboard_with_css = Patchwork.Dashboard("Styled", tabs, custom_css = ".custom { color: red; }")
        @test dashboard_with_css.custom_css == ".custom { color: red; }"
    end
end

@testset "HTML Utilities" begin
    @test Patchwork.escape_html("&") == "&amp;"
    @test Patchwork.escape_html("<") == "&lt;"
    @test Patchwork.escape_html(">") == "&gt;"
    @test Patchwork.escape_html("\"") == "&quot;"
    @test Patchwork.escape_html("<div>&test</div>") == "&lt;div&gt;&amp;test&lt;/div&gt;"
end

# Generate sample HTML output
dashboard = Patchwork.Dashboard(
    "Core Types Demo",
    [
        Patchwork.Tab(
            "HTML Content",
            [
                Patchwork.HTML("<h2>Raw HTML Example</h2>"),
                Patchwork.HTML(
                    "<p>This demonstrates the HTML content type with <strong>inline formatting</strong>.</p>",
                ),
                Patchwork.HTML("<ul><li>Plugin 1</li><li>Plugin 2</li><li>Plugin 3</li></ul>"),
            ],
        ),
        Patchwork.Tab(
            "Multiple Items",
            [
                Patchwork.HTML("<div class='alert'>Alert message</div>"),
                Patchwork.HTML("<p>Another paragraph</p>"),
                Patchwork.HTML("<code>Code snippet: x = 42</code>"),
            ],
        ),
    ],
)

output_path = joinpath(@__DIR__, "output", "test_core.html")
save(dashboard, output_path)

end
