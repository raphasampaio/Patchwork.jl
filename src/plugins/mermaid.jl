module MermaidPlugin

import ..Plugin, ..to_html, ..css_deps, ..js_deps, ..init_script, ..css
using UUIDs

export Mermaid

@doc """
    Mermaid(
        title::String,
        diagram::String;
        theme::String = "default"
    )

Diagram and flowchart plugin using Mermaid.

Creates diagrams from text using Mermaid syntax. Supports flowcharts, sequence diagrams,
class diagrams, state diagrams, ER diagrams, Gantt charts, and more.

# Fields
- `title::String`: Diagram title displayed above the visualization
- `diagram::String`: Mermaid diagram syntax
- `theme::String`: Diagram theme (default: "default")

# Example: Flowchart
```julia
Patchwork.Mermaid(
    "System Architecture",
    \"\"\"
    graph TD
        A[Client] --> B[Load Balancer]
        B --> C[Server 1]
        B --> D[Server 2]
    \"\"\",
)
```

# Example: Sequence Diagram
```julia
Patchwork.Mermaid(
    "Authentication Flow",
    \"\"\"
    sequenceDiagram
        participant U as User
        participant A as App
        participant S as Server
        U->>A: Login
        A->>S: Authenticate
        S-->>A: Token
        A-->>U: Success
    \"\"\",
)
```

# Example: Class Diagram
```julia
Patchwork.Mermaid(
    "Data Model",
    \"\"\"
    classDiagram
        class User {
            +String name
            +String email
            +login()
        }
        class Order {
            +Date created
            +process()
        }
        User "1" --> "*" Order
    \"\"\",
)
```

# Example: Gantt Chart
```julia
Patchwork.Mermaid(
    "Project Timeline",
    \"\"\"
    gantt
        title Project Schedule
        dateFormat YYYY-MM-DD
        section Phase 1
        Design    :a1, 2024-01-01, 30d
        Development :after a1, 45d
    \"\"\",
)
```

# Supported Diagram Types
- Flowcharts (`graph` or `flowchart`)
- Sequence diagrams (`sequenceDiagram`)
- Class diagrams (`classDiagram`)
- State diagrams (`stateDiagram`)
- ER diagrams (`erDiagram`)
- Gantt charts (`gantt`)
- Pie charts (`pie`)
- Git graphs (`gitGraph`)

See also: `Plugin`
"""
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
