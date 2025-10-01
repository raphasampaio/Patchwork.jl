module LeafletPlugin

import JSON
import ..Item, ..to_html, ..css_deps, ..js_deps, ..init_script, ..css
using UUIDs

export PatchworkLeaflet

struct PatchworkLeaflet <: Item
    title::String
    center::Tuple{Float64, Float64}
    zoom::Int
    markers::Vector{Dict{String, Any}}
    options::Dict{String, Any}

    function PatchworkLeaflet(
        title::String,
        center::Tuple{Float64, Float64};
        zoom::Int = 13,
        markers::Vector{Dict{String, Any}} = Dict{String, Any}[],
        options::Dict{String, Any} = Dict{String, Any}(),
    )
        return new(title, center, zoom, markers, options)
    end
end

function to_html(item::PatchworkLeaflet)
    map_id = "map-$(uuid4())"

    map_data = Dict(
        "center" => [item.center[1], item.center[2]],
        "zoom" => item.zoom,
        "markers" => item.markers,
        "options" => item.options,
    )

    map_json = JSON.json(map_data)

    return """
    <div>
        <h3 class="text-lg font-semibold mb-4">$(item.title)</h3>
        <div id="$map_id" class="leaflet-map" data-config='$map_json' style="height: 500px; border-radius: 0.5rem; overflow: hidden;"></div>
    </div>
    """
end

css_deps(::Type{PatchworkLeaflet}) = [
    "https://unpkg.com/leaflet@1.9.4/dist/leaflet.css",
]

js_deps(::Type{PatchworkLeaflet}) = [
    "https://unpkg.com/leaflet@1.9.4/dist/leaflet.js",
]

init_script(::Type{PatchworkLeaflet}) = """
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

css(::Type{PatchworkLeaflet}) = ""

end
