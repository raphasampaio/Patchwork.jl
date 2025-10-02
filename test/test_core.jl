module TestCore

using Test
using Patchwork

@testset "Core Types" begin
    @testset "Html" begin
        html = Patchwork.Html("<p>test</p>")
        @test html isa Item
        @test to_html(html) == "<p>test</p>"
        @test css_deps(Html) == String[]
        @test js_deps(Html) == String[]
        @test init_script(Html) == ""
        @test css(Html) == ""
    end

    @testset "Tab" begin
        tab = Patchwork.Tab("Test", [Patchwork.Html("<p>content</p>")])
        @test tab.label == "Test"
        @test length(tab.items) == 1
        @test tab.items[1] isa Html
    end

    @testset "Dashboard" begin
        tabs = [Patchwork.Tab("Tab1", [Patchwork.Html("<p>content</p>")])]
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
                Patchwork.Html("<h2>Raw HTML Example</h2>"),
                Patchwork.Html("<p>This demonstrates the Html content type with <strong>inline formatting</strong>.</p>"),
                Patchwork.Html("<ul><li>Item 1</li><li>Item 2</li><li>Item 3</li></ul>"),
            ],
        ),
        Patchwork.Tab(
            "Multiple Items",
            [
                Patchwork.Html("<div class='alert'>Alert message</div>"),
                Patchwork.Html("<p>Another paragraph</p>"),
                Patchwork.Html("<code>Code snippet: x = 42</code>"),
            ],
        ),
    ],
)

output_path = joinpath(@__DIR__, "output", "test_core.html")
save(dashboard, output_path)

end
