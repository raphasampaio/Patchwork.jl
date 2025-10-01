module MermaidPlugin

import ..Item, ..to_html, ..css_deps, ..js_deps, ..init_script, ..css
using UUIDs

export PatchworkMermaid

struct PatchworkMermaid <: Item
    title::String
    diagram::String
    theme::String

    function PatchworkMermaid(
        title::String,
        diagram::String;
        theme::String = "default",
    )
        return new(title, diagram, theme)
    end
end

function to_html(item::PatchworkMermaid)
    diagram_id = "mermaid-$(uuid4())"

    return """
    <div>
        <h3 class="text-lg font-semibold mb-4">$(item.title)</h3>
        <div class="mermaid-diagram" data-theme="$(item.theme)" style="display: flex; justify-content: center; padding: 1rem; background: white; border-radius: 0.5rem;">
            <pre class="mermaid" id="$diagram_id">$(item.diagram)</pre>
        </div>
    </div>
    """
end

css_deps(::Type{PatchworkMermaid}) = String[]

js_deps(::Type{PatchworkMermaid}) = [
    "https://cdn.jsdelivr.net/npm/mermaid@11.4.1/dist/mermaid.min.js",
]

init_script(::Type{PatchworkMermaid}) = """
    const diagramThemes = {};
    document.querySelectorAll('.mermaid-diagram').forEach(container => {
        const theme = container.getAttribute('data-theme') || 'default';
        const pre = container.querySelector('pre.mermaid');
        if (pre && pre.id) {
            diagramThemes[pre.id] = theme;
        }
    });

    mermaid.initialize({
        startOnLoad: true,
        theme: 'default',
        securityLevel: 'loose',
        fontFamily: 'inherit'
    });
"""

css(::Type{PatchworkMermaid}) = """
.mermaid-diagram {
    overflow-x: auto;
}

.mermaid-diagram pre {
    background: transparent;
    border: none;
    margin: 0;
}
"""

end
