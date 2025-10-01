"""
Example Plugin: Custom Map Renderer

This file demonstrates how to create a custom content renderer plugin for Rhinestone.
External packages like RhinestoneLeaflet.jl would follow this pattern.
"""

using Rhinestone

# 1. Define your custom content type
struct MapContent <: Rhinestone.ContentItem
    id::String
    title::String
    latitude::Float64
    longitude::Float64
    zoom::Int
end

# 2. Define your custom renderer
struct MapRenderer <: Rhinestone.ContentRenderer end

# 3. Implement the required interface methods

"""
Convert the map content to a dictionary that will be embedded in the HTML.
"""
function Rhinestone.render_to_dict(::MapRenderer, item::MapContent)
    return Dict{String, Any}(
        "type" => "map",
        "id" => item.id,
        "title" => item.title,
        "lat" => item.latitude,
        "lon" => item.longitude,
        "zoom" => item.zoom
    )
end

"""
Return the content type identifier.
"""
Rhinestone.content_type(::MapRenderer) = "map"

"""
Return CDN URLs needed for rendering maps.
"""
function Rhinestone.get_cdn_urls(::MapRenderer)
    return Dict{String, String}(
        "leaflet_css" => "https://unpkg.com/leaflet@1.9.4/dist/leaflet.css",
        "leaflet_js" => "https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
    )
end

"""
Return JavaScript code for initializing map content.
This function will be called for each map in the dashboard.
"""
function Rhinestone.get_init_script(::MapRenderer)
    return """
    function initializeMap(mapId, data) {
        const map = L.map(mapId).setView([data.lat, data.lon], data.zoom);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap contributors'
        }).addTo(map);
        L.marker([data.lat, data.lon]).addTo(map);
    }
    """
end

# 4. Register your renderer
Rhinestone.register_renderer!(MapContent, MapRenderer())

# Example usage
function create_example_dashboard()
    # Create some map content
    map1 = MapContent("map-paris", "Paris", 48.8566, 2.3522, 12)
    map2 = MapContent("map-tokyo", "Tokyo", 35.6762, 139.6503, 11)

    # Create a markdown explanation
    markdown = Rhinestone.RhinestoneMarkdown.MarkdownContent(
        "map-info",
        """
        # Interactive Maps

        This dashboard demonstrates custom map rendering using the Rhinestone plugin system.

        - Maps are powered by Leaflet.js
        - Each map can have custom coordinates and zoom levels
        - External packages can implement their own renderers
        """
    )

    tab = Rhinestone.Tab("Maps", [markdown, map1, map2])

    # Note: We need to manually add the map initialization to chart_init_script
    # In a real plugin package, this would be handled automatically
    map_init = """
    function initializeChart(chartId, metadata) {
        const container = document.getElementById(chartId);

        // Handle map type
        if (metadata.type === 'map') {
            container.style.height = '400px';
            const map = L.map(chartId).setView([metadata.lat, metadata.lon], metadata.zoom);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '© OpenStreetMap contributors',
                maxZoom: 19
            }).addTo(map);
            L.marker([metadata.lat, metadata.lon])
                .addTo(map)
                .bindPopup(metadata.title)
                .openPopup();
        }
    }
    """

    renderer = Rhinestone.get_renderer(map1)
    cdn_urls = Rhinestone.get_cdn_urls(renderer)

    config = Rhinestone.DashboardConfig(
        "Map Plugin Example",
        [tab],
        chart_init_script=map_init,
        cdn_urls=cdn_urls
    )

    output_path = joinpath(@__DIR__, "map_example.html")
    Rhinestone.generate_dashboard(config, output_path)
    println("Dashboard created at: ", output_path)

    return output_path
end

# Uncomment to run:
# create_example_dashboard()
