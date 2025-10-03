module MermaidPlugin

import ..Plugin, ..to_html, ..css_deps, ..js_deps, ..init_script, ..css
using UUIDs

export Mermaid

struct Mermaid <: Plugin
    title::String
    diagram::String
    theme::String

    function Mermaid(
        title::String,
        diagram::String;
        theme::String = "default",
    )
        return new(title, diagram, theme)
    end
end

function to_html(plugin::Mermaid)
    diagram_id = "mermaid-$(uuid4())"

    return """
    <div>
        <h3 class="text-lg font-semibold mb-4">$(plugin.title)</h3>
        <div class="mermaid-diagram" data-theme="$(plugin.theme)" style="display: flex; justify-content: center; padding: 1rem; background: white; border-radius: 0.5rem;">
            <pre class="mermaid" id="$diagram_id">$(plugin.diagram)</pre>
        </div>
    </div>
    """
end

css_deps(::Type{Mermaid}) = String[]

js_deps(::Type{Mermaid}) = [
    "https://cdn.jsdelivr.net/npm/mermaid@11.4.1/dist/mermaid.min.js",
]

init_script(::Type{Mermaid}) = """
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

css(::Type{Mermaid}) = """
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
