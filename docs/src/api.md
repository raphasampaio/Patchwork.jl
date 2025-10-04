# API Reference

Complete reference for all Patchwork types and functions.

## Types

### Plugin

```julia
abstract type Plugin end
```

Base type for all plugins. Custom plugins must subtype `Plugin`.

**Example:**

```julia
struct MyPlugin <: Plugin
    content::String
end
```

### Tab

```julia
struct Tab
    label::String
    plugins::Vector{Plugin}
end
```

Represents a tab in the dashboard.

**Fields:**
- `label::String` - Tab label displayed in sidebar
- `plugins::Vector{Plugin}` - Vector of plugins to display in tab

**Example:**

```julia
tab = Patchwork.Tab(
    "Overview",
    [
        Patchwork.Markdown("# Title"),
        Patchwork.ChartJs(...),
    ]
)
```

### Dashboard

```julia
struct Dashboard
    title::String
    tabs::Vector{Tab}
    custom_css::String

    Dashboard(title::String, tabs::Vector{Tab}; custom_css::String = "")
end
```

Main dashboard type containing all content.

**Fields:**
- `title::String` - Dashboard title (displayed in header and browser tab)
- `tabs::Vector{Tab}` - Vector of tabs
- `custom_css::String` - Optional custom CSS styles

**Constructor:**

```julia
Dashboard(title::String, tabs::Vector{Tab}; custom_css::String = "")
```

**Example:**

```julia
dashboard = Patchwork.Dashboard(
    "My Dashboard",
    [
        Patchwork.Tab("Tab 1", [...]),
        Patchwork.Tab("Tab 2", [...]),
    ],
    custom_css = """
    .custom-class {
        color: blue;
    }
    """
)
```

## Built-in Plugin Types

### Markdown

```julia
struct Markdown <: Plugin
    content::String
end
```

Renders markdown content with syntax highlighting.

**Example:**

```julia
Patchwork.Markdown("# Title\n\nParagraph text")
```

### ChartJs

```julia
struct ChartJs <: Plugin
    title::String
    chart_type::String
    data::Dict{String, Any}
    options::Dict{String, Any}

    ChartJs(
        title::String,
        chart_type::String,
        data::Dict{String, Any};
        options::Dict{String, Any} = Dict{String, Any}()
    )
end
```

Creates Chart.js visualizations.

**Fields:**
- `title::String` - Chart title
- `chart_type::String` - Chart type (line, bar, radar, doughnut, pie, polarArea, bubble, scatter)
- `data::Dict{String,Any}` - Chart data configuration
- `options::Dict{String,Any}` - Optional chart options

**Example:**

```julia
Patchwork.ChartJs(
    "Sales",
    "bar",
    Dict{String,Any}("labels" => [...], "datasets" => [...])
)
```

### Highcharts

```julia
struct Highcharts <: Plugin
    title::String
    config::Dict{String, Any}

    Highcharts(title::String, config::Dict{String, Any})
    Highcharts(title::String, config::AbstractString)
end
```

Creates Highcharts visualizations.

**Fields:**
- `title::String` - Chart title
- `config::Dict{String,Any}` - Highcharts configuration object

**Constructors:**
- `Highcharts(title::String, config::Dict{String,Any})` - From dictionary
- `Highcharts(title::String, config::AbstractString)` - From JSON string

**Example:**

```julia
Patchwork.Highcharts(
    "Chart",
    Dict{String,Any}(
        "chart" => Dict("type" => "line"),
        "series" => [...]
    )
)
```

### Plotly

```julia
struct Plotly <: Plugin
    title::String
    data::Vector{Dict{String, Any}}
    layout::Dict{String, Any}
    config::Dict{String, Any}

    Plotly(
        title::String,
        data::Vector{Dict{String, Any}};
        layout::Dict{String, Any} = Dict{String, Any}(),
        config::Dict{String, Any} = Dict{String, Any}()
    )
end
```

Creates Plotly visualizations.

**Fields:**
- `title::String` - Chart title
- `data::Vector{Dict{String,Any}}` - Plotly data traces
- `layout::Dict{String,Any}` - Layout configuration
- `config::Dict{String,Any}` - Plotly config options

**Example:**

```julia
Patchwork.Plotly(
    "Scatter",
    [Dict{String,Any}("x" => [1,2,3], "y" => [1,2,3], "type" => "scatter")],
    layout = Dict{String,Any}("title" => "Plot")
)
```

### Leaflet

```julia
struct Leaflet <: Plugin
    title::String
    center::Tuple{Float64, Float64}
    zoom::Int
    markers::Vector{Dict{String, Any}}
    options::Dict{String, Any}

    Leaflet(
        title::String,
        center::Tuple{Float64, Float64};
        zoom::Int = 13,
        markers::Vector{Dict{String, Any}} = Dict{String, Any}[],
        options::Dict{String, Any} = Dict{String, Any}()
    )
end
```

Creates interactive Leaflet maps.

**Fields:**
- `title::String` - Map title
- `center::Tuple{Float64,Float64}` - Map center coordinates (latitude, longitude)
- `zoom::Int` - Initial zoom level (default: 13)
- `markers::Vector{Dict{String,Any}}` - Markers to display
- `options::Dict{String,Any}` - Leaflet map options

**Marker Format:**

```julia
Dict{String,Any}(
    "lat" => 40.7128,
    "lng" => -74.0060,
    "popup" => "Popup text"
)
```

**Example:**

```julia
Patchwork.Leaflet(
    "Map",
    (40.7128, -74.0060),
    zoom = 12,
    markers = [Dict{String,Any}("lat" => 40.7128, "lng" => -74.0060, "popup" => "NYC")]
)
```

### Mermaid

```julia
struct Mermaid <: Plugin
    title::String
    diagram::String
    theme::String

    Mermaid(
        title::String,
        diagram::String;
        theme::String = "default"
    )
end
```

Creates Mermaid diagrams.

**Fields:**
- `title::String` - Diagram title
- `diagram::String` - Mermaid diagram syntax
- `theme::String` - Diagram theme (default: "default")

**Example:**

```julia
Patchwork.Mermaid(
    "Flow",
    "graph TD\n    A --> B",
    theme = "dark"
)
```

### HTML

```julia
struct HTML <: Plugin
    content::String
end
```

Raw HTML content.

**Fields:**
- `content::String` - HTML string

**Example:**

```julia
Patchwork.HTML("<div class='p-4'>Custom HTML</div>")
```

## Core Functions

### save

```julia
save(dashboard::Dashboard, path::String)
```

Generate complete HTML and save to file.

**Arguments:**
- `dashboard::Dashboard` - Dashboard to save
- `path::String` - Output file path

**Example:**

```julia
save(dashboard, "output.html")
save(dashboard, "/path/to/dashboard.html")
```

### generate_html

```julia
generate_html(dashboard::Dashboard) -> String
```

Generate complete HTML string for dashboard (used internally by `save`).

**Arguments:**
- `dashboard::Dashboard` - Dashboard to generate HTML for

**Returns:**
- `String` - Complete HTML document

**Example:**

```julia
html = generate_html(dashboard)
write("output.html", html)
```

## Plugin Interface Functions

### to_html

```julia
to_html(plugin::Plugin) -> String
```

Convert plugin to HTML string. Must be implemented for all custom plugins.

**Arguments:**
- `plugin::Plugin` - Plugin instance

**Returns:**
- `String` - HTML representation

**Example:**

```julia
to_html(plugin::MyPlugin) = "<div>$(plugin.content)</div>"
```

### css_deps

```julia
css_deps(::Type{<:Plugin}) -> Vector{String}
```

Return vector of CSS dependency URLs.

**Arguments:**
- `::Type{<:Plugin}` - Plugin type

**Returns:**
- `Vector{String}` - CDN URLs for CSS dependencies

**Default:** `String[]`

**Example:**

```julia
css_deps(::Type{MyPlugin}) = [
    "https://cdn.example.com/style.css"
]
```

### js_deps

```julia
js_deps(::Type{<:Plugin}) -> Vector{String}
```

Return vector of JavaScript dependency URLs.

**Arguments:**
- `::Type{<:Plugin}` - Plugin type

**Returns:**
- `Vector{String}` - CDN URLs for JavaScript dependencies

**Default:** `String[]`

**Example:**

```julia
js_deps(::Type{MyPlugin}) = [
    "https://cdn.example.com/lib.js"
]
```

### init_script

```julia
init_script(::Type{<:Plugin}) -> String
```

Return JavaScript initialization code. This code runs after all dependencies are loaded.

**Arguments:**
- `::Type{<:Plugin}` - Plugin type

**Returns:**
- `String` - JavaScript code

**Default:** `""`

**Example:**

```julia
init_script(::Type{MyPlugin}) = """
    document.querySelectorAll('.myplugin').forEach(el => {
        // Initialize
    });
"""
```

### css

```julia
css(::Type{<:Plugin}) -> String
```

Return custom CSS styles.

**Arguments:**
- `::Type{<:Plugin}` - Plugin type

**Returns:**
- `String` - CSS styles

**Default:** `""`

**Example:**

```julia
css(::Type{MyPlugin}) = """
    .myplugin {
        padding: 1rem;
        border: 1px solid #ccc;
    }
"""
```

## Utility Functions

### get_plugin_type

```julia
get_plugin_type(plugin::Plugin) -> String
```

Get lowercase plugin type name for internal use.

**Arguments:**
- `plugin::Plugin` - Plugin instance

**Returns:**
- `String` - Lowercase type name

**Example:**

```julia
plugin = Patchwork.ChartJs(...)
get_plugin_type(plugin)  # Returns "chartjs"
```

### escape_html

```julia
escape_html(s::String) -> String
```

Escape HTML special characters.

**Arguments:**
- `s::String` - String to escape

**Returns:**
- `String` - Escaped string

**Escapes:**
- `&` → `&amp;`
- `<` → `&lt;`
- `>` → `&gt;`
- `"` → `&quot;`
- `'` → `&#39;`

**Example:**

```julia
escape_html("<script>alert('xss')</script>")
# Returns: "&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;"
```

## Advanced Usage

### Custom CSS

Apply global custom CSS to dashboard:

```julia
dashboard = Patchwork.Dashboard(
    "Styled Dashboard",
    tabs,
    custom_css = """
    :root {
        --primary-color: #667eea;
    }

    .sidebar {
        background: var(--primary-color);
    }

    h1, h2, h3 {
        color: var(--primary-color);
    }
    """
)
```

### Accessing Plugin Types

Get all unique plugin types in dashboard:

```julia
plugin_types = unique([typeof(p) for tab in dashboard.tabs for p in tab.plugins])
```

### Type Safety with Dictionaries

Always use `Dict{String,Any}` for chart configurations:

```julia
# ✓ Correct - explicit type parameters
data = Dict{String,Any}(
    "labels" => ["A", "B", "C"],
    "datasets" => [...]
)

# ✗ Wrong - may cause type inference issues
data = Dict(
    "labels" => ["A", "B", "C"],
    "datasets" => [...]
)
```

### Plugin Dependencies

Dependencies are automatically collected and deduplicated:

```julia
# Multiple ChartJs plugins only load Chart.js once
Patchwork.Tab("Charts", [
    Patchwork.ChartJs("Chart 1", ...),
    Patchwork.ChartJs("Chart 2", ...),
    Patchwork.ChartJs("Chart 3", ...),
])
```

### HTML Generation Flow

1. Collect unique plugin types from all tabs
2. Gather CSS dependencies from plugin types
3. Gather JavaScript dependencies from plugin types
4. Gather initialization scripts from plugin types
5. Gather custom CSS from plugin types
6. Generate Vue.js application with:
   - Embedded tab/plugin data as JSON
   - Reactive tab switching
   - Search functionality
   - Mobile-responsive sidebar

### Output Structure

Generated HTML includes:

```html
<!DOCTYPE html>
<html>
<head>
    <!-- CSS dependencies from plugins -->
    <!-- Tailwind CSS -->
    <!-- Custom CSS from plugins -->
    <!-- Dashboard custom CSS -->
</head>
<body>
    <!-- Vue.js app container -->
    <div id="app">...</div>

    <!-- Vue.js framework -->
    <!-- JavaScript dependencies from plugins -->
    <!-- Vue.js application code -->
    <!-- Plugin initialization scripts -->
</body>
</html>
```
