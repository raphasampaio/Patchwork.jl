module ELKJsPlugin

import ..Plugin, ..to_html, ..js_deps, ..init_script
using UUIDs
using JSON
export ELKJs

@doc """
    ELKJs(title::String, graph::Dict{String,Any})

Automatic graph layout using ELK.js (Eclipse Layout Kernel).

# Fields
- `title::String`: Graph title
- `graph::Dict{String,Any}`: ELK graph definition with nodes and edges

# Examples
```julia
using Patchwork

graph = Patchwork.ELKJs(
    "Flow Diagram",
    Dict{String,Any}(
        "id" => "root",
        "layoutOptions" => Dict("elk.algorithm" => "layered"),
        "children" => [
            Dict("id" => "n1", "width" => 80, "height" => 40),
            Dict("id" => "n2", "width" => 80, "height" => 40),
            Dict("id" => "n3", "width" => 80, "height" => 40),
        ],
        "edges" => [
            Dict("id" => "e1", "sources" => ["n1"], "targets" => ["n2"]),
            Dict("id" => "e2", "sources" => ["n2"], "targets" => ["n3"]),
        ],
    ),
)

dashboard = Patchwork.Dashboard("Dashboard", [Patchwork.Tab("Graph", [graph])])
save(dashboard, "output.html")
```
"""
struct ELKJs <: Plugin
    title::String
    graph::Dict{String,Any}
end

function to_html(plugin::ELKJs)
    id = string(uuid4())
    graph_json = JSON.json(plugin.graph)

    return """
    <div>
        <h3 class="text-lg font-semibold mb-4">$(plugin.title)</h3>
        <svg id="elk-$id" class="elkjs-graph" style="width:100%; height:600px; border:1px solid #e5e7eb;" data-graph='$graph_json'></svg>
    </div>
    """
end

js_deps(::Type{ELKJs}) = [
    "https://cdn.jsdelivr.net/npm/elkjs@0.11.0/lib/elk.bundled.js"
]

init_script(::Type{ELKJs}) = """
    const elk = new ELK();

    document.querySelectorAll('.elkjs-graph').forEach(async svg => {
        const graph = JSON.parse(svg.dataset.graph);

        try {
            const layout = await elk.layout(graph);

            // Clear SVG
            svg.innerHTML = '';

            // Create defs for arrowheads
            const defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs');
            const marker = document.createElementNS('http://www.w3.org/2000/svg', 'marker');
            marker.setAttribute('id', 'arrowhead-' + svg.id);
            marker.setAttribute('markerWidth', '10');
            marker.setAttribute('markerHeight', '10');
            marker.setAttribute('refX', '8');
            marker.setAttribute('refY', '3');
            marker.setAttribute('orient', 'auto');
            marker.setAttribute('markerUnits', 'strokeWidth');
            const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
            path.setAttribute('d', 'M0,0 L0,6 L9,3 z');
            path.setAttribute('fill', '#666');
            marker.appendChild(path);
            defs.appendChild(marker);
            svg.appendChild(defs);

            // Calculate viewBox
            const width = layout.width || 800;
            const height = layout.height || 600;
            svg.setAttribute('viewBox', \`0 0 \${width + 20} \${height + 20}\`);

            // Draw edges
            if (layout.edges) {
                layout.edges.forEach(edge => {
                    const sections = edge.sections || [];
                    sections.forEach(section => {
                        const pathData = [];
                        pathData.push(\`M \${section.startPoint.x} \${section.startPoint.y}\`);
                        if (section.bendPoints) {
                            section.bendPoints.forEach(bp => {
                                pathData.push(\`L \${bp.x} \${bp.y}\`);
                            });
                        }
                        pathData.push(\`L \${section.endPoint.x} \${section.endPoint.y}\`);

                        const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
                        path.setAttribute('d', pathData.join(' '));
                        path.setAttribute('stroke', '#666');
                        path.setAttribute('stroke-width', '2');
                        path.setAttribute('fill', 'none');
                        path.setAttribute('marker-end', 'url(#arrowhead-' + svg.id + ')');
                        svg.appendChild(path);
                    });
                });
            }

            // Draw nodes
            if (layout.children) {
                layout.children.forEach(node => {
                    const g = document.createElementNS('http://www.w3.org/2000/svg', 'g');

                    const rect = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
                    rect.setAttribute('x', node.x);
                    rect.setAttribute('y', node.y);
                    rect.setAttribute('width', node.width);
                    rect.setAttribute('height', node.height);
                    rect.setAttribute('fill', '#3b82f6');
                    rect.setAttribute('stroke', '#1d4ed8');
                    rect.setAttribute('stroke-width', '2');
                    rect.setAttribute('rx', '4');

                    const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
                    text.setAttribute('x', node.x + node.width / 2);
                    text.setAttribute('y', node.y + node.height / 2);
                    text.setAttribute('text-anchor', 'middle');
                    text.setAttribute('dominant-baseline', 'middle');
                    text.setAttribute('fill', 'white');
                    text.setAttribute('font-size', '14');
                    text.setAttribute('font-weight', 'bold');
                    text.textContent = node.id;

                    g.appendChild(rect);
                    g.appendChild(text);
                    svg.appendChild(g);
                });
            }
        } catch (error) {
            console.error('ELK layout error:', error);
        }
    });
"""

end
