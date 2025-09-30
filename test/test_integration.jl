using Test
using Rhinestone

@testset "Integration Tests" begin
    # Create test output directory
    test_output_dir = joinpath(@__DIR__, "test_output")
    mkpath(test_output_dir)

    @testset "generate_dashboard creates file" begin
        output_path = joinpath(test_output_dir, "test_dashboard.html")

        chart = ChartPlaceholder("test-chart", "Test Chart",
            metadata=Dict{String,Any}("data" => [1, 2, 3]))
        tab = Tab("Test Tab", [chart])
        config = DashboardConfig("Test Dashboard", [tab])

        result = generate_dashboard(config, output_path)

        @test result == output_path
        @test isfile(output_path)

        # Read and verify content
        content = read(output_path, String)
        @test occursin("<!DOCTYPE html>", content)
        @test occursin("Test Dashboard", content)
        @test occursin("test-chart", content)
    end

    @testset "generate_dashboard with Chart.js example" begin
        output_path = joinpath(test_output_dir, "chartjs_dashboard.html")

        chart = ChartPlaceholder("cpu-chart", "CPU Usage",
            metadata=Dict{String,Any}(
                "type" => "line",
                "data" => Dict(
                    "labels" => ["00:00", "01:00", "02:00"],
                    "datasets" => [Dict("label" => "CPU %", "data" => [45, 52, 38])]
                )
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
            chart_init_script=chart_script,
            cdn_urls=Dict(
                "tailwind" => "https://cdn.tailwindcss.com/3.4.0",
                "vue" => "https://cdn.jsdelivr.net/npm/vue@3.3.4/dist/vue.global.js",
                "chartjs" => "https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"
            )
        )

        generate_dashboard(config, output_path)

        @test isfile(output_path)
        content = read(output_path, String)

        # Verify structure
        @test occursin("Performance Dashboard", content)
        @test occursin("cpu-chart", content)
        @test occursin("CPU Usage", content)

        # Verify Chart.js CDN
        @test occursin("chart.js", content)

        # Verify init script
        @test occursin("initializeChart", content)
        @test occursin("new Chart(canvas", content)

        # Verify metadata is embedded
        @test occursin("00:00", content)
        @test occursin("01:00", content)
        @test occursin("CPU %", content)
    end

    @testset "generate_dashboard with multiple tabs" begin
        output_path = joinpath(test_output_dir, "multi_tab_dashboard.html")

        tab1 = Tab("Performance", [
            ChartPlaceholder("cpu", "CPU Usage"),
            ChartPlaceholder("memory", "Memory Usage")
        ])

        tab2 = Tab("Network", [
            ChartPlaceholder("bandwidth", "Bandwidth")
        ])

        tab3 = Tab("Storage", [
            ChartPlaceholder("disk", "Disk Usage"),
            ChartPlaceholder("io", "I/O Operations")
        ])

        config = DashboardConfig("System Dashboard", [tab1, tab2, tab3])
        generate_dashboard(config, output_path)

        @test isfile(output_path)
        content = read(output_path, String)

        # Verify all tabs
        @test occursin("Performance", content)
        @test occursin("Network", content)
        @test occursin("Storage", content)

        # Verify all charts
        @test occursin("CPU Usage", content)
        @test occursin("Memory Usage", content)
        @test occursin("Bandwidth", content)
        @test occursin("Disk Usage", content)
        @test occursin("I/O Operations", content)

        # Verify chart IDs
        @test occursin("cpu", content)
        @test occursin("memory", content)
        @test occursin("bandwidth", content)
        @test occursin("disk", content)
        @test occursin("io", content)
    end

    @testset "generate_dashboard with custom styling" begin
        output_path = joinpath(test_output_dir, "styled_dashboard.html")

        chart = ChartPlaceholder("chart1", "Chart 1")
        tab = Tab("Tab", [chart])

        custom_css = """
        .chart-container {
            background: linear-gradient(to right, #667eea 0%, #764ba2 100%);
            border-radius: 12px;
        }
        """

        config = DashboardConfig(
            "Styled Dashboard",
            [tab],
            custom_css=custom_css
        )

        generate_dashboard(config, output_path)

        @test isfile(output_path)
        content = read(output_path, String)

        @test occursin("linear-gradient", content)
        @test occursin("#667eea", content)
        @test occursin("#764ba2", content)
    end

    @testset "generate_dashboard with complex metadata" begin
        output_path = joinpath(test_output_dir, "complex_dashboard.html")

        complex_metadata = Dict{String,Any}(
            "type" => "scatter",
            "config" => Dict(
                "responsive" => true,
                "plugins" => Dict(
                    "legend" => Dict("display" => true),
                    "tooltip" => Dict("enabled" => true)
                )
            ),
            "data" => [
                Dict("x" => 1, "y" => 2),
                Dict("x" => 2, "y" => 4),
                Dict("x" => 3, "y" => 6)
            ]
        )

        chart = ChartPlaceholder("scatter-plot", "Scatter Plot",
            metadata=complex_metadata)
        tab = Tab("Visualization", [chart])
        config = DashboardConfig("Complex Dashboard", [tab])

        generate_dashboard(config, output_path)

        @test isfile(output_path)
        content = read(output_path, String)

        # Verify complex metadata is embedded
        @test occursin("scatter", content)
        @test occursin("responsive", content)
        @test occursin("legend", content)
        @test occursin("tooltip", content)
    end

    @testset "generate_dashboard with empty tab" begin
        output_path = joinpath(test_output_dir, "empty_tab_dashboard.html")

        tab1 = Tab("With Charts", [ChartPlaceholder("c1", "Chart 1")])
        tab2 = Tab("Empty Tab", ChartPlaceholder[])

        config = DashboardConfig("Dashboard with Empty Tab", [tab1, tab2])
        generate_dashboard(config, output_path)

        @test isfile(output_path)
        content = read(output_path, String)

        @test occursin("With Charts", content)
        @test occursin("Empty Tab", content)
    end

    @testset "generate_dashboard file overwrite" begin
        output_path = joinpath(test_output_dir, "overwrite_test.html")

        # Generate first dashboard
        chart1 = ChartPlaceholder("chart1", "First Chart")
        tab1 = Tab("First Tab", [chart1])
        config1 = DashboardConfig("First Dashboard", [tab1])
        generate_dashboard(config1, output_path)

        first_content = read(output_path, String)
        @test occursin("First Dashboard", first_content)
        @test occursin("First Chart", first_content)

        # Overwrite with second dashboard
        chart2 = ChartPlaceholder("chart2", "Second Chart")
        tab2 = Tab("Second Tab", [chart2])
        config2 = DashboardConfig("Second Dashboard", [tab2])
        generate_dashboard(config2, output_path)

        second_content = read(output_path, String)
        @test occursin("Second Dashboard", second_content)
        @test occursin("Second Chart", second_content)
        @test !occursin("First Dashboard", second_content)
        @test !occursin("First Chart", second_content)
    end

    @testset "generate_dashboard with special characters in paths" begin
        # Create subdirectory with spaces
        subdir = joinpath(test_output_dir, "test directory")
        mkpath(subdir)
        output_path = joinpath(subdir, "dashboard with spaces.html")

        chart = ChartPlaceholder("test", "Test")
        tab = Tab("Tab", [chart])
        config = DashboardConfig("Dashboard", [tab])

        generate_dashboard(config, output_path)
        @test isfile(output_path)
    end

    @testset "generate_dashboard validates HTML structure" begin
        output_path = joinpath(test_output_dir, "validate.html")

        chart = ChartPlaceholder("test", "Test")
        tab = Tab("Tab", [chart])
        config = DashboardConfig("Dashboard", [tab])

        generate_dashboard(config, output_path)
        content = read(output_path, String)

        # Basic HTML structure validation
        @test occursin("<!DOCTYPE html>", content)
        @test occursin("<html lang=\"en\">", content)
        @test occursin("<head>", content)
        @test occursin("</head>", content)
        @test occursin("<body", content)
        @test occursin("</body>", content)
        @test occursin("</html>", content)

        # Required meta tags
        @test occursin("<meta charset=\"UTF-8\">", content)
        @test occursin("<meta name=\"viewport\"", content)

        # Vue app mount point
        @test occursin("id=\"app\"", content)
    end
end
