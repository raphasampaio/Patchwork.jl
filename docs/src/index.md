# Patchwork.jl

Create interactive, self-contained HTML dashboards with Julia. Patchwork generates single-page applications with Vue.js reactivity, Tailwind CSS styling, and a powerful plugin system for any JavaScript library.

## Features

- **Self-contained HTML files** - Share dashboards anywhere, no server required
- **Tabbed interface** with search and mobile support
- **Built-in plugins** - Markdown, Chart.js, Highcharts, Plotly, Leaflet, Mermaid
- **Plugin system** - Integrate any JavaScript library with five simple functions
- **Zero configuration** - Works out of the box

## Installation

```julia
using Pkg
Pkg.add("Patchwork")
```

## Quick Start

```julia
using Patchwork

dashboard = Patchwork.Dashboard(
    "My Dashboard",
    [
        Patchwork.Tab(
            "Overview",
            [
                Patchwork.Markdown("""
                # Welcome to Patchwork.jl

                Create beautiful dashboards with:
                - Interactive charts
                - Maps
                - Diagrams
                - Custom content
                """),
            ],
        ),
    ],
)

save(dashboard, "dashboard.html")
```

## Core Concepts

### Dashboard

A `Dashboard` contains a title, tabs, and optional custom CSS:

```julia
Dashboard(title::String, tabs::Vector{Tab}; custom_css::String = "")
```

### Tab

A `Tab` contains a label and a vector of plugins:

```julia
Tab(label::String, plugins::Vector{Plugin})
```

### Plugin

All content types inherit from the abstract `Plugin` type. Built-in plugins include:
- `Markdown` - Rendered markdown with syntax highlighting
- `ChartJs` - Chart.js visualizations
- `Highcharts` - Highcharts visualizations
- `Plotly` - Plotly charts and maps
- `Leaflet` - Interactive maps
- `Mermaid` - Diagrams and flowcharts
- `HTML` - Raw HTML content

## Built-in Plugins

### Markdown

Render markdown with syntax highlighting for code blocks.

```julia
Patchwork.Markdown("""
# Title

**Bold text** and *italic text*

- List item 1
- List item 2

```julia
println("Code with syntax highlighting")
```
""")
```

The Markdown plugin uses Julia's built-in Markdown parser and includes Highlight.js for code syntax highlighting.

### Chart.js

Create interactive charts using Chart.js. Always use `Dict{String,Any}` for type safety.

```julia
Patchwork.ChartJs(
    title::String,
    chart_type::String,
    data::Dict{String,Any};
    options::Dict{String,Any} = Dict{String,Any}()
)
```

**Example - Bar Chart:**

```julia
Patchwork.ChartJs(
    "Sales by Quarter",
    "bar",
    Dict{String,Any}(
        "labels" => ["Q1", "Q2", "Q3", "Q4"],
        "datasets" => [
            Dict{String,Any}(
                "label" => "2024",
                "data" => [12, 19, 8, 15],
                "backgroundColor" => "rgba(54, 162, 235, 0.5)",
            ),
        ],
    ),
)
```

**Example - Doughnut Chart:**

```julia
Patchwork.ChartJs(
    "Traffic Sources",
    "doughnut",
    Dict{String,Any}(
        "labels" => ["Direct", "Social", "Organic", "Referral"],
        "datasets" => [
            Dict{String,Any}(
                "data" => [300, 150, 200, 100],
                "backgroundColor" => ["#FF6384", "#36A2EB", "#FFCE56", "#4BC0C0"],
            ),
        ],
    ),
)
```

**Supported chart types:** `line`, `bar`, `radar`, `doughnut`, `pie`, `polarArea`, `bubble`, `scatter`

### Highcharts

Create Highcharts visualizations.

```julia
Patchwork.Highcharts(
    title::String,
    config::Dict{String,Any}
)
```

**Example - Line Chart:**

```julia
Patchwork.Highcharts(
    "Monthly Performance",
    Dict{String,Any}(
        "chart" => Dict("type" => "line"),
        "xAxis" => Dict("categories" => ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]),
        "yAxis" => Dict("title" => Dict("text" => "Value")),
        "series" => [
            Dict("name" => "Series A", "data" => [29, 71, 106, 129, 144, 176]),
            Dict("name" => "Series B", "data" => [50, 80, 95, 110, 130, 150]),
        ],
    ),
)
```

**Example - Column Chart:**

```julia
Patchwork.Highcharts(
    "Distribution",
    Dict{String,Any}(
        "chart" => Dict("type" => "column"),
        "xAxis" => Dict("categories" => ["Alpha", "Beta", "Gamma", "Delta"]),
        "series" => [
            Dict("name" => "Values", "data" => [5, 3, 4, 7]),
        ],
    ),
)
```

### Plotly

Create Plotly charts with support for 3D plots, maps, and scientific visualizations.

```julia
Patchwork.Plotly(
    title::String,
    data::Vector{Dict{String,Any}};
    layout::Dict{String,Any} = Dict{String,Any}(),
    config::Dict{String,Any} = Dict{String,Any}()
)
```

**Example - Scatter Plot:**

```julia
Patchwork.Plotly(
    "Scatter Analysis",
    [
        Dict{String,Any}(
            "x" => [1, 2, 3, 4, 5, 6],
            "y" => [1, 4, 9, 16, 25, 36],
            "mode" => "markers+lines",
            "type" => "scatter",
            "name" => "Quadratic",
        ),
    ],
    layout = Dict{String,Any}(
        "xaxis" => Dict("title" => "X"),
        "yaxis" => Dict("title" => "Y²"),
    ),
)
```

**Example - 3D Surface:**

```julia
Patchwork.Plotly(
    "3D Surface",
    [
        Dict{String,Any}(
            "z" => [[1, 2, 3], [2, 3, 4], [3, 4, 5]],
            "type" => "surface",
        ),
    ],
    layout = Dict{String,Any}("title" => "3D Surface Plot"),
)
```

### Leaflet

Create interactive maps with markers and popups.

```julia
Patchwork.Leaflet(
    title::String,
    center::Tuple{Float64,Float64};
    zoom::Int = 13,
    markers::Vector{Dict{String,Any}} = Dict{String,Any}[],
    options::Dict{String,Any} = Dict{String,Any}()
)
```

**Example - Simple Map:**

```julia
Patchwork.Leaflet(
    "New York City",
    (40.7128, -74.0060),
    zoom = 12,
)
```

**Example - Map with Markers:**

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

### Mermaid

Create diagrams using Mermaid syntax.

```julia
Patchwork.Mermaid(
    title::String,
    diagram::String;
    theme::String = "default"
)
```

**Example - Flowchart:**

```julia
Patchwork.Mermaid(
    "System Architecture",
    """
    graph TD
        A[Client] --> B[Load Balancer]
        B --> C[Server 1]
        B --> D[Server 2]
    """,
)
```

**Example - Sequence Diagram:**

```julia
Patchwork.Mermaid(
    "Authentication Flow",
    """
    sequenceDiagram
        participant U as User
        participant A as App
        participant S as Server
        U->>A: Login
        A->>S: Authenticate
        S-->>A: Token
        A-->>U: Success
    """,
)
```

**Supported diagram types:** flowcharts, sequence diagrams, class diagrams, state diagrams, ER diagrams, Gantt charts, and more.

### HTML

Include raw HTML content with access to Tailwind CSS classes.

```julia
Patchwork.HTML(content::String)
```

**Example:**

```julia
Patchwork.HTML("""
<div class="p-6 bg-gradient-to-r from-blue-500 to-purple-600 rounded-lg shadow-xl">
    <h2 class="text-2xl font-bold text-white mb-2">Custom Component</h2>
    <p class="text-blue-100">Styled with Tailwind CSS</p>
</div>
""")
```

## Creating Custom Plugins

Create a plugin for any JavaScript library by implementing five functions (one required, four optional):

### Plugin Interface

```julia
# Required: Convert plugin to HTML
to_html(plugin::MyPlugin) = "<div>...</div>"

# Optional: CSS dependencies (CDN URLs)
css_deps(::Type{MyPlugin}) = ["https://cdn.example.com/lib.css"]

# Optional: JavaScript dependencies (CDN URLs)
js_deps(::Type{MyPlugin}) = ["https://cdn.example.com/lib.js"]

# Optional: JavaScript initialization code (runs on mount)
init_script(::Type{MyPlugin}) = "// init code"

# Optional: Custom CSS styles
css(::Type{MyPlugin}) = "/* custom styles */"
```

### Example: DataTables Plugin

```julia
module DataTablesPlugin

import ..Plugin, ..to_html, ..css_deps, ..js_deps, ..init_script, ..css
using JSON
export DataTable

struct DataTable <: Plugin
    title::String
    data::Vector{Vector{Any}}
    columns::Vector{String}
end

function to_html(plugin::DataTable)
    headers = join(["<th>$(col)</th>" for col in plugin.columns], "")
    rows = join([
        "<tr>" * join(["<td>$(cell)</td>" for cell in row], "") * "</tr>"
        for row in plugin.data
    ], "")

    return """
    <div>
        <h3 class="text-lg font-semibold mb-4">$(plugin.title)</h3>
        <table class="datatable display" style="width:100%">
            <thead><tr>$headers</tr></thead>
            <tbody>$rows</tbody>
        </table>
    </div>
    """
end

css_deps(::Type{DataTable}) = [
    "https://cdn.datatables.net/1.13.7/css/jquery.dataTables.min.css"
]

js_deps(::Type{DataTable}) = [
    "https://code.jquery.com/jquery-3.7.0.min.js",
    "https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"
]

init_script(::Type{DataTable}) = """
    document.querySelectorAll('.datatable').forEach(table => {
        $(table).DataTable();
    });
"""

css(::Type{DataTable}) = ""

end
```

### Integrating Custom Plugins

Add your plugin module to `src/Patchwork.jl`:

```julia
include("plugins/datatables.jl")
using .DataTablesPlugin
```

Then use it like any built-in plugin:

```julia
Patchwork.DataTable(
    "Sales Data",
    [
        ["John", "Sales", 50000],
        ["Jane", "Marketing", 60000],
        ["Bob", "Engineering", 75000],
    ],
    ["Name", "Department", "Salary"]
)
```

## API Reference

### Types

```julia
abstract type Plugin end
```

Base type for all plugins. Custom plugins must subtype `Plugin`.

```julia
struct Tab
    label::String
    plugins::Vector{Plugin}
end
```

Represents a tab in the dashboard containing a label and vector of plugins.

```julia
struct Dashboard
    title::String
    tabs::Vector{Tab}
    custom_css::String

    Dashboard(title::String, tabs::Vector{Tab}; custom_css::String = "")
end
```

Main dashboard type containing title, tabs, and optional custom CSS.

### Functions

```julia
save(dashboard::Dashboard, path::String)
```

Generate complete HTML and save to file.

```julia
to_html(plugin::Plugin) -> String
```

Convert plugin to HTML string. Must be implemented for all custom plugins.

```julia
css_deps(::Type{<:Plugin}) -> Vector{String}
```

Return vector of CSS dependency URLs. Default: `String[]`

```julia
js_deps(::Type{<:Plugin}) -> Vector{String}
```

Return vector of JavaScript dependency URLs. Default: `String[]`

```julia
init_script(::Type{<:Plugin}) -> String
```

Return JavaScript initialization code. Default: `""`

```julia
css(::Type{<:Plugin}) -> String
```

Return custom CSS styles. Default: `""`

```julia
get_plugin_type(plugin::Plugin) -> String
```

Get lowercase plugin type name for internal use.

```julia
escape_html(s::String) -> String
```

Escape HTML special characters (`&`, `<`, `>`, `"`, `'`).

```julia
generate_html(dashboard::Dashboard) -> String
```

Generate complete HTML string for dashboard (used internally by `save`).

## Advanced Usage

### Multiple Tabs with Mixed Content

```julia
dashboard = Patchwork.Dashboard(
    "Analytics Dashboard",
    [
        Patchwork.Tab("Overview", [
            Patchwork.Markdown("# Executive Summary"),
            Patchwork.ChartJs(
                "Revenue",
                "line",
                Dict{String,Any}(...),
            ),
        ]),
        Patchwork.Tab("Geographic", [
            Patchwork.Leaflet(
                "Sales by Region",
                (37.0, -95.0),
                markers = [...],
            ),
        ]),
        Patchwork.Tab("Architecture", [
            Patchwork.Mermaid(
                "System Design",
                "graph TD\n...",
            ),
        ]),
    ],
)
```

### Custom Styling

Add custom CSS to modify dashboard appearance:

```julia
dashboard = Patchwork.Dashboard(
    "Branded Dashboard",
    tabs,
    custom_css = """
    :root {
        --primary-color: #667eea;
        --secondary-color: #764ba2;
    }

    .sidebar {
        background: linear-gradient(to bottom, var(--primary-color), var(--secondary-color));
    }

    h1, h2, h3 {
        color: var(--primary-color);
    }
    """,
)
```

### Combining Multiple Chart Libraries

```julia
Patchwork.Tab(
    "Comparison",
    [
        Patchwork.Markdown("## Chart.js vs Plotly"),
        Patchwork.ChartJs("Chart.js Line", "line", ...),
        Patchwork.Plotly("Plotly Line", [...]),
        Patchwork.Markdown("## Highcharts Implementation"),
        Patchwork.Highcharts("Highcharts Line", ...),
    ],
)
```

### Type Safety

Always use `Dict{String,Any}` for chart configurations to avoid type inference issues:

```julia
# ✓ Correct
Dict{String,Any}("labels" => [...], "datasets" => [...])

# ✗ Wrong - may cause type errors
Dict("labels" => [...], "datasets" => [...])
```

## Architecture

### HTML Generation

Patchwork generates self-contained single-page applications with:

1. **Dependency Collection** - Automatically collects all CSS/JS dependencies from plugins
2. **Vue.js Integration** - Creates reactive UI with tab switching and search
3. **Tailwind CSS** - Provides utility-first styling via CDN
4. **Plugin Initialization** - Runs all plugin init scripts on mount
5. **Mobile Support** - Responsive design with hamburger menu

### Plugin System Design

Plugins use a simple interface pattern:

- **Declarative** - Define HTML structure, dependencies, and initialization
- **Composable** - Mix different plugins in tabs
- **Extensible** - Add new plugins without modifying core
- **Type-safe** - Strong typing with Julia's type system

### Output Format

Generated HTML includes:

- All CSS dependencies in `<head>`
- All JavaScript dependencies before closing `</body>`
- Vue.js application with reactive data
- Embedded plugin content and configuration
- Custom CSS if provided
- Complete standalone file (no external data dependencies)

## Contributing

Contributions are welcome! Areas for contribution:

- New built-in plugins
- Documentation improvements
- Bug fixes
- Performance optimizations
- Example dashboards

Please open an issue or submit a pull request on [GitHub](https://github.com/raphasampaio/Patchwork.jl).

## License

MIT License
