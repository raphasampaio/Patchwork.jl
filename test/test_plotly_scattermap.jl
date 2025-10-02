module TestPlotlyScattermap

using Test
using Patchwork

@testset "Plotly Scattermap" begin
    @testset "Basic scattermapbox" begin
        chart = Plotly(
            "Location Map",
            [Dict{String, Any}(
                "type" => "scattermapbox",
                "lat" => [45.5, 43.6],
                "lon" => [-73.6, -79.4],
                "mode" => "markers",
                "marker" => Dict("size" => 14),
                "text" => ["Montreal", "Toronto"],
            )],
            layout = Dict{String, Any}(
                "mapbox" => Dict(
                    "style" => "open-street-map",
                    "center" => Dict("lat" => 44.5, "lon" => -76.5),
                    "zoom" => 4,
                ),
            ),
        )
        @test chart isa Item
        @test chart.title == "Location Map"

        html_output = to_html(chart)
        @test occursin("Location Map", html_output)
        @test occursin("plotly-chart", html_output)
    end

    @testset "Scattermapbox with custom styling" begin
        chart = Plotly(
            "City Population",
            [Dict{String, Any}(
                "type" => "scattermapbox",
                "lat" => [40.7, 34.0, 41.9],
                "lon" => [-74.0, -118.2, -87.6],
                "mode" => "markers",
                "marker" => Dict(
                    "size" => [20, 30, 25],
                    "color" => ["red", "blue", "green"],
                ),
                "text" => ["New York", "Los Angeles", "Chicago"],
            )],
            layout = Dict{String, Any}(
                "mapbox" => Dict(
                    "style" => "open-street-map",
                    "center" => Dict("lat" => 39, "lon" => -98),
                    "zoom" => 3,
                ),
                "height" => 600,
            ),
        )

        html_output = to_html(chart)
        @test occursin("City Population", html_output)
        @test occursin("data-layout", html_output)
    end

    @testset "Multiple scattermapbox traces" begin
        chart = Plotly(
            "Multi-layer Map",
            [
                Dict{String, Any}(
                    "type" => "scattermapbox",
                    "lat" => [51.5],
                    "lon" => [-0.1],
                    "mode" => "markers",
                    "marker" => Dict("size" => 15, "color" => "red"),
                    "text" => ["London"],
                    "name" => "Europe",
                ),
                Dict{String, Any}(
                    "type" => "scattermapbox",
                    "lat" => [35.7],
                    "lon" => [139.7],
                    "mode" => "markers",
                    "marker" => Dict("size" => 15, "color" => "blue"),
                    "text" => ["Tokyo"],
                    "name" => "Asia",
                ),
            ],
            layout = Dict{String, Any}(
                "mapbox" => Dict(
                    "style" => "open-street-map",
                    "center" => Dict("lat" => 40, "lon" => 50),
                    "zoom" => 1,
                ),
            ),
        )

        @test length(chart.data) == 2
    end
end

# Generate demo HTML
dashboard = Dashboard(
    "Plotly Scattermap Demo",
    [
        Tab(
            "US Cities",
            [
                Markdown("""
                ## Major US Cities Map

                This map shows the locations of major US cities using Plotly's scattermapbox.
                """),
                Plotly(
                    "Population Centers",
                    [Dict{String, Any}(
                        "type" => "scattermapbox",
                        "lat" => [40.7128, 34.0522, 41.8781, 29.7604, 33.4484, 39.7392],
                        "lon" => [-74.0060, -118.2437, -87.6298, -95.3698, -112.0740, -104.9903],
                        "mode" => "markers",
                        "marker" => Dict(
                            "size" => [25, 30, 22, 20, 18, 15],
                            "color" => ["#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A", "#98D8C8", "#F7DC6F"],
                        ),
                        "text" => ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix", "Denver"],
                    )],
                    layout = Dict{String, Any}(
                        "mapbox" => Dict(
                            "style" => "open-street-map",
                            "center" => Dict("lat" => 39.8283, "lon" => -98.5795),
                            "zoom" => 3,
                        ),
                        "height" => 500,
                    ),
                ),
            ],
        ),
        Tab(
            "World Capitals",
            [
                Markdown("""
                ## World Capital Cities

                Interactive map showing capital cities across different continents.
                """),
                Plotly(
                    "Global Capitals",
                    [
                        Dict{String, Any}(
                            "type" => "scattermapbox",
                            "lat" => [51.5074, 48.8566, 52.5200],
                            "lon" => [-0.1278, 2.3522, 13.4050],
                            "mode" => "markers",
                            "marker" => Dict("size" => 15, "color" => "#3498db"),
                            "text" => ["London", "Paris", "Berlin"],
                            "name" => "Europe",
                        ),
                        Dict{String, Any}(
                            "type" => "scattermapbox",
                            "lat" => [35.6762, -33.8688, 28.6139],
                            "lon" => [139.6503, 151.2093, 77.2090],
                            "mode" => "markers",
                            "marker" => Dict("size" => 15, "color" => "#e74c3c"),
                            "text" => ["Tokyo", "Sydney", "New Delhi"],
                            "name" => "Asia-Pacific",
                        ),
                        Dict{String, Any}(
                            "type" => "scattermapbox",
                            "lat" => [40.7128, -23.5505, 19.4326],
                            "lon" => [-74.0060, -46.6333, -99.1332],
                            "mode" => "markers",
                            "marker" => Dict("size" => 15, "color" => "#2ecc71"),
                            "text" => ["Washington DC", "São Paulo", "Mexico City"],
                            "name" => "Americas",
                        ),
                    ],
                    layout = Dict{String, Any}(
                        "mapbox" => Dict(
                            "style" => "open-street-map",
                            "center" => Dict("lat" => 20, "lon" => 0),
                            "zoom" => 1,
                        ),
                        "height" => 600,
                    ),
                ),
            ],
        ),
        Tab(
            "Route Visualization",
            [
                Markdown("""
                ## Flight Path Example

                Showing a flight route with markers and lines.
                """),
                Plotly(
                    "Flight Route: NYC to London",
                    [
                        Dict{String, Any}(
                            "type" => "scattermapbox",
                            "lat" => [40.7128, 51.5074],
                            "lon" => [-74.0060, -0.1278],
                            "mode" => "markers+lines",
                            "marker" => Dict("size" => 20, "color" => "red"),
                            "line" => Dict("width" => 2, "color" => "blue"),
                            "text" => ["New York (JFK)", "London (LHR)"],
                        ),
                    ],
                    layout = Dict{String, Any}(
                        "mapbox" => Dict(
                            "style" => "open-street-map",
                            "center" => Dict("lat" => 45, "lon" => -37),
                            "zoom" => 2,
                        ),
                        "height" => 500,
                    ),
                ),
            ],
        ),
    ],
)

output_path = joinpath(@__DIR__, "output", "test_plotly_scattermap.html")
save(dashboard, output_path)

end
