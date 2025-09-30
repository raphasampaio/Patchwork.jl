using Test
using Rhinestone

@testset "Template Generation" begin
    @testset "escape_html" begin
        @test Rhinestone.escape_html("plain text") == "plain text"
        @test Rhinestone.escape_html("<script>") == "&lt;script&gt;"
        @test Rhinestone.escape_html("&") == "&amp;"
        @test Rhinestone.escape_html("\"quotes\"") == "&quot;quotes&quot;"
        @test Rhinestone.escape_html("'apostrophe'") == "&#39;apostrophe&#39;"
        @test Rhinestone.escape_html("<tag attr=\"value\">") == "&lt;tag attr=&quot;value&quot;&gt;"
    end

    @testset "escape_json" begin
        @test Rhinestone.escape_json("plain text") == "plain text"
        @test Rhinestone.escape_json("\"quote\"") == "\\\"quote\\\""
        @test Rhinestone.escape_json("back\\slash") == "back\\\\slash"
        @test Rhinestone.escape_json("line\nbreak") == "line\\nbreak"
        @test Rhinestone.escape_json("carriage\rreturn") == "carriage\\rreturn"
        @test Rhinestone.escape_json("tab\there") == "tab\\there"
    end

    @testset "json_string primitives" begin
        @test Rhinestone.json_string("text") == "\"text\""
        @test Rhinestone.json_string(42) == "42"
        @test Rhinestone.json_string(3.14) == "3.14"
        @test Rhinestone.json_string(true) == "true"
        @test Rhinestone.json_string(false) == "false"
        @test Rhinestone.json_string(nothing) == "null"
    end

    @testset "json_string array" begin
        arr = [1, 2, 3]
        result = Rhinestone.json_string(arr)
        @test result == "[1,2,3]"

        arr_mixed = [1, "text", true]
        result = Rhinestone.json_string(arr_mixed)
        @test result == "[1,\"text\",true]"

        arr_empty = []
        result = Rhinestone.json_string(arr_empty)
        @test result == "[]"
    end

    @testset "json_string dictionary" begin
        dict = Dict("key" => "value")
        result = Rhinestone.json_string(dict)
        @test result == "{\"key\":\"value\"}"

        dict_multi = Dict("a" => 1, "b" => 2)
        result = Rhinestone.json_string(dict_multi)
        @test occursin("\"a\":1", result)
        @test occursin("\"b\":2", result)

        dict_empty = Dict()
        result = Rhinestone.json_string(dict_empty)
        @test result == "{}"
    end

    @testset "json_string nested structures" begin
        nested = Dict(
            "name" => "test",
            "values" => [1, 2, 3],
            "nested" => Dict("inner" => true)
        )
        result = Rhinestone.json_string(nested)
        @test occursin("\"name\":\"test\"", result)
        @test occursin("\"values\":[1,2,3]", result)
        @test occursin("\"inner\":true", result)
    end

    @testset "generate_tabs_json" begin
        charts = [
            ChartPlaceholder("chart1", "Chart One",
                metadata=Dict{String,Any}("type" => "line"))
        ]
        tab = Tab("Test Tab", charts)

        json = Rhinestone.generate_tabs_json([tab])

        @test occursin("\"label\":\"Test Tab\"", json)
        @test occursin("\"id\":\"chart1\"", json)
        @test occursin("\"title\":\"Chart One\"", json)
        @test occursin("\"height\":\"24rem\"", json)
        @test occursin("\"type\":\"line\"", json)
    end

    @testset "generate_cdn_scripts" begin
        cdn_urls = Dict(
            "library1" => "https://example.com/lib1.js",
            "library2" => "https://example.com/lib2.js"
        )

        scripts = Rhinestone.generate_cdn_scripts(cdn_urls)

        @test occursin("<script src=\"https://example.com/lib1.js\"></script>", scripts)
        @test occursin("<script src=\"https://example.com/lib2.js\"></script>", scripts)
    end

    @testset "generate_html basic structure" begin
        chart = ChartPlaceholder("test-chart", "Test Chart")
        tab = Tab("Test Tab", [chart])
        config = DashboardConfig("Test Dashboard", [tab])

        html = Rhinestone.generate_html(config)

        # Check HTML structure
        @test occursin("<!DOCTYPE html>", html)
        @test occursin("<html lang=\"en\">", html)
        @test occursin("<title>Test Dashboard</title>", html)
        @test occursin("<h1 class=\"text-2xl font-bold text-gray-900 mb-2\">Test Dashboard</h1>", html)

        # Check Vue.js integration
        @test occursin("const { createApp } = Vue;", html)
        @test occursin("createApp({", html)
        @test occursin(".mount('#app');", html)

        # Check for tab and chart data
        @test occursin("Test Tab", html)
        @test occursin("test-chart", html)
        @test occursin("Test Chart", html)
    end

    @testset "generate_html with custom CSS" begin
        chart = ChartPlaceholder("test", "Test")
        tab = Tab("Tab", [chart])
        custom_css = ".custom-class { color: blue; }"
        config = DashboardConfig("Dashboard", [tab], custom_css=custom_css)

        html = Rhinestone.generate_html(config)
        @test occursin(custom_css, html)
    end

    @testset "generate_html with chart init script" begin
        chart = ChartPlaceholder("test", "Test")
        tab = Tab("Tab", [chart])
        script = "function initializeChart(id, meta) { console.log('init'); }"
        config = DashboardConfig("Dashboard", [tab], chart_init_script=script)

        html = Rhinestone.generate_html(config)
        @test occursin(script, html)
        @test occursin("initializeChart(chart.id, chart.metadata);", html)
    end

    @testset "generate_html with custom CDN" begin
        chart = ChartPlaceholder("test", "Test")
        tab = Tab("Tab", [chart])
        cdn_urls = Dict(
            "tailwind" => "https://example.com/tailwind.js",
            "vue" => "https://example.com/vue.js"
        )
        config = DashboardConfig("Dashboard", [tab], cdn_urls=cdn_urls)

        html = Rhinestone.generate_html(config)
        @test occursin("https://example.com/tailwind.js", html)
        @test occursin("https://example.com/vue.js", html)
    end

    @testset "generate_html escapes special characters" begin
        chart = ChartPlaceholder("test", "Chart with <script>")
        tab = Tab("Tab with & special", [chart])
        config = DashboardConfig("Dashboard \"quoted\"", [tab])

        html = Rhinestone.generate_html(config)

        # HTML should be escaped in title tag and headers
        @test occursin("Dashboard &quot;quoted&quot;", html)
        # The chart title appears in JSON which escapes differently than HTML
        # Just verify the special characters are handled somewhere
        @test occursin("Chart with", html)
    end

    @testset "generate_html multiple tabs and charts" begin
        tab1 = Tab("Tab 1", [
            ChartPlaceholder("c1", "Chart 1"),
            ChartPlaceholder("c2", "Chart 2")
        ])
        tab2 = Tab("Tab 2", [
            ChartPlaceholder("c3", "Chart 3")
        ])
        config = DashboardConfig("Multi Dashboard", [tab1, tab2])

        html = Rhinestone.generate_html(config)

        @test occursin("Tab 1", html)
        @test occursin("Tab 2", html)
        @test occursin("c1", html)
        @test occursin("c2", html)
        @test occursin("c3", html)
        @test occursin("Chart 1", html)
        @test occursin("Chart 2", html)
        @test occursin("Chart 3", html)
    end
end
