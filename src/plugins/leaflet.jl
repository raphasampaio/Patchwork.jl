module LeafletPlugin

import ..Plugin, ..to_html, ..css_deps, ..js_deps, ..init_script, ..css

using JSON
using UUIDs

export Leaflet

@doc """
    Leaflet(
        title::String,
        center::Tuple{Float64,Float64};
        zoom::Int = 13,
        markers::Vector{Dict{String,Any}} = Dict{String,Any}[],
        options::Dict{String,Any} = Dict{String,Any}()
    )

Interactive map plugin using Leaflet.

Creates interactive maps with markers and popups using the Leaflet library.
Uses OpenStreetMap tiles by default. Supports custom map options and multiple markers.

# Fields
- `title::String`: Map title displayed above the visualization
- `center::Tuple{Float64,Float64}`: Map center coordinates (latitude, longitude)
- `zoom::Int`: Initial zoom level (1-19, default: 13)
- `markers::Vector{Dict{String,Any}}`: Markers to display on the map
- `options::Dict{String,Any}`: Optional Leaflet map options

# Marker Format
Each marker should be a dictionary with:
- `"lat"::Float64` - Latitude
- `"lng"::Float64` - Longitude
- `"popup"::String` - Optional popup HTML content

# Example: Simple Map
```julia
Patchwork.Leaflet(
    "New York City",
    (40.7128, -74.0060),
    zoom = 12,
)
```

# Example: Map with Markers
```julia
Patchwork.Leaflet(
    "Major US Cities",
    (39.8283, -98.5795),
    zoom = 4,
    markers = [
        Dict{String,Any}(
            "lat" => 40.7128,
            "lng" => -74.0060,
            "popup" => "<b>New York</b><br>Population: 8.3M",
        ),
        Dict{String,Any}(
            "lat" => 34.0522,
            "lng" => -118.2437,
            "popup" => "<b>Los Angeles</b><br>Population: 4.0M",
        ),
    ],
)
```

# Example: Custom Options
```julia
Patchwork.Leaflet(
    "Map",
    (51.505, -0.09),
    zoom = 13,
    options = Dict{String,Any}(
        "scrollWheelZoom" => false,
    ),
)
```

See also: `Plotly`, `Plugin`
"""
struct Leaflet <: Plugin
    title::String
    center::Tuple{Float64, Float64}
    zoom::Int
    markers::Vector{Dict{String, Any}}
    options::Dict{String, Any}

    function Leaflet(
        title::String,
        center::Tuple{Float64, Float64};
        zoom::Int = 13,
        markers::Vector{Dict{String, Any}} = Dict{String, Any}[],
        options::Dict{String, Any} = Dict{String, Any}(),
    )
        return new(title, center, zoom, markers, options)
    end
end

function to_html(plugin::Leaflet)
    map_id = "map-$(uuid4())"

    map_data = Dict(
        "center" => [plugin.center[1], plugin.center[2]],
        "zoom" => plugin.zoom,
        "markers" => plugin.markers,
        "options" => plugin.options,
    )

    map_json = JSON.json(map_data)

    return """
    <div>
        <h3 class="text-lg font-semibold mb-4">$(plugin.title)</h3>
        <div id="$map_id" class="leaflet-map" data-config='$map_json' style="height: 500px; border-radius: 0.5rem; overflow: hidden;"></div>
    </div>
    """
end

css_deps(::Type{Leaflet}) = [
    "https://unpkg.com/leaflet@1.9.4/dist/leaflet.css",
]

js_deps(::Type{Leaflet}) = [
    "https://unpkg.com/leaflet@1.9.4/dist/leaflet.js",
]

init_script(::Type{Leaflet}) = """
    document.querySelectorAll('.leaflet-map').forEach(container => {
        const config = JSON.parse(container.getAttribute('data-config'));
        const map = L.map(container.id, config.options).setView(config.center, config.zoom);

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap contributors',
            maxZoom: 19
        }).addTo(map);

        config.markers.forEach(marker => {
            const m = L.marker([marker.lat, marker.lng]).addTo(map);
            if (marker.popup) {
                m.bindPopup(marker.popup);
            }
        });
    });
"""

css(::Type{Leaflet}) = ""

end
