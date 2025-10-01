module TestLeaflet

using Test
using Patchwork

@testset "Leaflet Plugin" begin
    @testset "PatchworkLeaflet constructor" begin
        map = PatchworkLeaflet("Test Map", (40.7128, -74.0060))
        @test map.title == "Test Map"
        @test map.center == (40.7128, -74.0060)
        @test map.zoom == 13
        @test map.markers == Dict{String, Any}[]
        @test map.options == Dict{String, Any}()

        map_with_zoom = PatchworkLeaflet("Custom Zoom", (51.505, -0.09), zoom = 10)
        @test map_with_zoom.zoom == 10
    end

    @testset "PatchworkLeaflet with markers" begin
        markers = [
            Dict{String, Any}("lat" => 40.7128, "lng" => -74.0060, "popup" => "New York"),
            Dict{String, Any}("lat" => 34.0522, "lng" => -118.2437, "popup" => "Los Angeles"),
        ]
        map = PatchworkLeaflet("US Cities", (37.0, -95.0), markers = markers)
        @test length(map.markers) == 2
        @test map.markers[1]["popup"] == "New York"
    end

    @testset "PatchworkLeaflet rendering" begin
        map = PatchworkLeaflet("Test Map", (40.7128, -74.0060))
        html = to_html(map)
        @test occursin("Test Map", html)
        @test occursin("leaflet-map", html)
        @test occursin("40.7128", html)
        @test occursin("-74.006", html)
    end

    @testset "PatchworkLeaflet plugin interface" begin
        @test css_deps(PatchworkLeaflet) == ["https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"]
        @test js_deps(PatchworkLeaflet) == ["https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"]
        @test occursin("L.map", init_script(PatchworkLeaflet))
        @test occursin("L.tileLayer", init_script(PatchworkLeaflet))
        @test css(PatchworkLeaflet) == ""
    end
end

# Generate sample HTML output
dashboard = Dashboard(
    "Leaflet Maps Demo",
    [
        Tab(
            "Single Map",
            [
                PatchworkLeaflet(
                    "New York City",
                    (40.7128, -74.0060),
                    zoom = 12,
                ),
            ],
        ),
        Tab(
            "Map with Markers",
            [
                PatchworkLeaflet(
                    "Major US Cities",
                    (39.8283, -98.5795),
                    zoom = 4,
                    markers = [
                        Dict{String, Any}(
                            "lat" => 40.7128,
                            "lng" => -74.0060,
                            "popup" => "<b>New York</b><br>Population: 8.3M",
                        ),
                        Dict{String, Any}(
                            "lat" => 34.0522,
                            "lng" => -118.2437,
                            "popup" => "<b>Los Angeles</b><br>Population: 4.0M",
                        ),
                        Dict{String, Any}(
                            "lat" => 41.8781,
                            "lng" => -87.6298,
                            "popup" => "<b>Chicago</b><br>Population: 2.7M",
                        ),
                        Dict{String, Any}(
                            "lat" => 29.7604,
                            "lng" => -95.3698,
                            "popup" => "<b>Houston</b><br>Population: 2.3M",
                        ),
                    ],
                ),
            ],
        ),
    ],
)

output_path = joinpath(@__DIR__, "output", "test_leaflet.html")
render(dashboard, output_path)

end
