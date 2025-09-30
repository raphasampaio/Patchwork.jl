using Test
using Rhinestone

@testset "ChartPlaceholder" begin
    @testset "Basic constructor" begin
        chart = ChartPlaceholder("test-id", "Test Chart")
        @test chart.id == "test-id"
        @test chart.title == "Test Chart"
        @test chart.height == "24rem"
        @test chart.metadata == Dict{String,Any}()
    end

    @testset "Constructor with custom height" begin
        chart = ChartPlaceholder("test-id", "Test Chart", height="32rem")
        @test chart.height == "32rem"
    end

    @testset "Constructor with metadata" begin
        metadata = Dict{String,Any}(
            "type" => "line",
            "data" => [1, 2, 3, 4, 5]
        )
        chart = ChartPlaceholder("test-id", "Test Chart", metadata=metadata)
        @test chart.metadata == metadata
        @test chart.metadata["type"] == "line"
        @test chart.metadata["data"] == [1, 2, 3, 4, 5]
    end

    @testset "Constructor with all parameters" begin
        metadata = Dict{String,Any}("key" => "value")
        chart = ChartPlaceholder(
            "custom-id",
            "Custom Chart",
            height="16rem",
            metadata=metadata
        )
        @test chart.id == "custom-id"
        @test chart.title == "Custom Chart"
        @test chart.height == "16rem"
        @test chart.metadata == metadata
    end
end

@testset "Tab" begin
    @testset "Empty tab" begin
        tab = Tab("Empty Tab", ChartPlaceholder[])
        @test tab.label == "Empty Tab"
        @test length(tab.charts) == 0
    end

    @testset "Tab with single chart" begin
        chart = ChartPlaceholder("chart1", "Chart 1")
        tab = Tab("Single Tab", [chart])
        @test tab.label == "Single Tab"
        @test length(tab.charts) == 1
        @test tab.charts[1].id == "chart1"
    end

    @testset "Tab with multiple charts" begin
        charts = [
            ChartPlaceholder("chart1", "Chart 1"),
            ChartPlaceholder("chart2", "Chart 2"),
            ChartPlaceholder("chart3", "Chart 3")
        ]
        tab = Tab("Multi Tab", charts)
        @test length(tab.charts) == 3
        @test tab.charts[2].title == "Chart 2"
    end
end

@testset "DashboardConfig" begin
    @testset "Basic configuration" begin
        tab = Tab("Test Tab", [ChartPlaceholder("test", "Test")])
        config = DashboardConfig("Test Dashboard", [tab])

        @test config.title == "Test Dashboard"
        @test length(config.tabs) == 1
        @test config.custom_css == ""
        @test config.chart_init_script == ""
        @test haskey(config.cdn_urls, "tailwind")
        @test haskey(config.cdn_urls, "vue")
    end

    @testset "Configuration with custom CSS" begin
        tab = Tab("Test Tab", [ChartPlaceholder("test", "Test")])
        custom_css = ".custom { color: red; }"
        config = DashboardConfig(
            "Test Dashboard",
            [tab],
            custom_css=custom_css
        )
        @test config.custom_css == custom_css
    end

    @testset "Configuration with chart init script" begin
        tab = Tab("Test Tab", [ChartPlaceholder("test", "Test")])
        script = "function initializeChart(id, meta) { console.log(id); }"
        config = DashboardConfig(
            "Test Dashboard",
            [tab],
            chart_init_script=script
        )
        @test config.chart_init_script == script
    end

    @testset "Configuration with custom CDN URLs" begin
        tab = Tab("Test Tab", [ChartPlaceholder("test", "Test")])
        cdn_urls = Dict(
            "tailwind" => "https://example.com/tailwind.js",
            "vue" => "https://example.com/vue.js",
            "custom" => "https://example.com/custom.js"
        )
        config = DashboardConfig(
            "Test Dashboard",
            [tab],
            cdn_urls=cdn_urls
        )
        @test config.cdn_urls["tailwind"] == "https://example.com/tailwind.js"
        @test config.cdn_urls["custom"] == "https://example.com/custom.js"
    end

    @testset "Configuration with multiple tabs" begin
        tabs = [
            Tab("Tab 1", [ChartPlaceholder("c1", "Chart 1")]),
            Tab("Tab 2", [ChartPlaceholder("c2", "Chart 2")]),
            Tab("Tab 3", [ChartPlaceholder("c3", "Chart 3")])
        ]
        config = DashboardConfig("Multi-Tab Dashboard", tabs)
        @test length(config.tabs) == 3
        @test config.tabs[2].label == "Tab 2"
    end
end
