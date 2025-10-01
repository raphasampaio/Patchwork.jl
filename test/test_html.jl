module TestHTML

using Test
using Rhinestone

@testset "HTML Generation" begin
    @testset "render creates file" begin
        mktempdir() do dir
            path = joinpath(dir, "test.html")

            dashboard = Dashboard("Test", [
                Tab("Tab1", [Html("<p>content</p>")])
            ])

            result = render(dashboard, path)

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
        html = Rhinestone.generate_html(dashboard)

        @test occursin("vue", html)
        @test occursin("tailwindcss", html)
    end

    @testset "HTML contains dashboard title" begin
        dashboard = Dashboard("My Dashboard", [Tab("T", [Html("<p>x</p>")])])
        html = Rhinestone.generate_html(dashboard)

        @test occursin("My Dashboard", html)
    end

    @testset "HTML escapes title properly" begin
        dashboard = Dashboard("<script>alert()</script>", [Tab("T", [Html("<p>x</p>")])])
        html = Rhinestone.generate_html(dashboard)

        @test occursin("&lt;script&gt;", html)
        @test occursin("&lt;/script&gt;", html)
    end

    @testset "HTML includes custom CSS" begin
        dashboard = Dashboard("App", [Tab("T", [Html("<p>x</p>")])],
            custom_css=".custom { color: red; }")
        html = Rhinestone.generate_html(dashboard)

        @test occursin(".custom { color: red; }", html)
    end

    @testset "HTML includes CDN URLs from plugins" begin
        dashboard = Dashboard("Charts", [
            Tab("T", [
                ChartJs("Chart", "line", Dict("labels" => [], "datasets" => []))
            ])
        ])
        html = Rhinestone.generate_html(dashboard)

        @test occursin("chart.js", html)
    end

    @testset "HTML includes init scripts from plugins" begin
        dashboard = Dashboard("Charts", [
            Tab("T", [
                ChartJs("Chart", "bar", Dict("labels" => [], "datasets" => []))
            ])
        ])
        html = Rhinestone.generate_html(dashboard)

        @test occursin("chartjs-chart", html)
    end

    @testset "HTML contains multiple tabs" begin
        dashboard = Dashboard("Multi", [
            Tab("Tab1", [Html("<p>one</p>")]),
            Tab("Tab2", [Html("<p>two</p>")]),
            Tab("Tab3", [Html("<p>three</p>")])
        ])
        html = Rhinestone.generate_html(dashboard)

        @test occursin("Tab1", html)
        @test occursin("Tab2", html)
        @test occursin("Tab3", html)
        @test occursin("one", html)
        @test occursin("two", html)
        @test occursin("three", html)
    end

    @testset "HTML contains multiple items per tab" begin
        dashboard = Dashboard("Multi", [
            Tab("Tab", [
                Html("<p>first</p>"),
                Html("<p>second</p>"),
                Markdown("# Third")
            ])
        ])
        html = Rhinestone.generate_html(dashboard)

        @test occursin("first", html)
        @test occursin("second", html)
        @test occursin("Third", html)
    end

    @testset "Mixed content types" begin
        dashboard = Dashboard("Mixed", [
            Tab("All", [
                Html("<div>HTML</div>"),
                Markdown("**Markdown**"),
                ChartJs("Chart", "pie", Dict("labels" => ["A"], "datasets" => [Dict("data" => [1])]))
            ])
        ])
        html = Rhinestone.generate_html(dashboard)

        @test occursin("HTML", html)
        @test occursin("Markdown", html)
        @test occursin("Chart", html)
        @test occursin("chart.js", html)
    end
end

end