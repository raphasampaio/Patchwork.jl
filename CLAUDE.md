# Patchwork.jl - AI Development Guide

This document provides context for AI assistants (like Claude) working on the Patchwork.jl codebase.

## Project Overview

**Patchwork.jl** is a Julia package for creating interactive, self-contained HTML dashboards with Vue.js and Tailwind CSS. It emphasizes simplicity, clean code, and extensibility through a plugin system.

## Architecture

### Core Principles

1. **Simple & Minimal** - No over-engineering, clean code with minimal comments
2. **Plugin-based** - Core stays lean, plugins add functionality
3. **Single responsibility** - Each module does one thing well
4. **Zero backward compatibility** - Fresh, clean design (v0.2.0 was a complete rewrite)

### Directory Structure

```
src/
├── Patchwork.jl          # Main module (exports, core types)
├── html.jl                # HTML generation and rendering
└── plugins/               # Built-in plugins
    ├── markdown.jl        # PatchworkMarkdown content support
    ├── chartjs.jl         # Chart.js integration
    ├── highcharts.jl      # PatchworkHighcharts integration
    ├── plotly.jl          # PatchworkPlotly integration
    ├── leaflet.jl         # PatchworkLeaflet maps integration
    └── mermaid.jl         # PatchworkMermaid diagrams integration

test/
├── runtests.jl            # Main test runner (recursive)
├── test_core.jl           # Core types tests
├── test_markdown.jl       # PatchworkMarkdown plugin tests
├── test_charts.jl         # Chart plugins tests
├── test_html.jl           # HTML generation tests
└── output/                # Generated HTML demos
```

## Core API

### Types

```julia
abstract type Plugin end

struct Html <: Plugin
    content::String
end

struct PatchworkTab
    label::String
    plugins::Vector{Plugin}
end

struct PatchworkDashboard
    title::String
    tabs::Vector{PatchworkTab}
    custom_css::String
end
```

### Functions

```julia
save(dashboard::PatchworkDashboard, path::String)  # Generate HTML file
to_html(plugin::Plugin)                          # Render plugin to HTML
css_deps(::Type{<:Plugin})                     # Get CSS dependencies for plugin type
js_deps(::Type{<:Plugin})                      # Get JS dependencies for plugin type
init_script(::Type{<:Plugin})                 # Get JS initialization script
css(::Type{<:Plugin})                         # Get CSS styles for plugin type
```

## Plugin System

Plugins implement four functions:

```julia
# Required: Convert plugin to HTML
to_html(plugin::MyItem) = "<div>...</div>"

# Optional: CSS dependencies
css_deps(::Type{MyItem}) = ["https://cdn.example.com/lib.css"]

# Optional: JS dependencies
js_deps(::Type{MyItem}) = ["https://cdn.example.com/lib.js"]

# Optional: JavaScript initialization
init_script(::Type{MyItem}) = "/* init code */"

# Optional: CSS styles
css(::Type{MyItem}) = "/* custom styles */"
```

### Built-in Plugins

**Patchwork.Markdown** (`src/plugins/markdown.jl`)
- Converts markdown to HTML using Julia's Markdown stdlib
- Uses `import Markdown as MD` to avoid namespace conflicts

**Patchwork.ChartJs** (`src/plugins/chartjs.jl`)
- Creates Chart.js charts
- Stores config in `data-config` attribute
- Requires `Dict{String,Any}` for type safety

**Patchwork.Highcharts** (`src/plugins/highcharts.jl`)
- Creates Highcharts charts
- Uses UUID for unique chart IDs

**Patchwork.Plotly** (`src/plugins/plotly.jl`)
- Creates Plotly charts
- Supports data, layout, and config options

**Patchwork.Leaflet** (`src/plugins/leaflet.jl`)
- Creates interactive maps using Leaflet
- Supports center coordinates, zoom levels, and markers with popups

**Patchwork.Mermaid** (`src/plugins/mermaid.jl`)
- Renders diagrams using Mermaid
- Supports flowcharts, sequence diagrams, class diagrams, and more

## Important Implementation Details

### Type Safety

Always use `Dict{String,Any}` for chart configurations to avoid Julia's type inference issues:

```julia
# ✓ Correct
Patchwork.ChartJs("Title", "bar", Dict{String,Any}("labels" => [...]))

# ✗ Wrong - will cause type errors
Patchwork.ChartJs("Title", "bar", Dict("labels" => [...]))
```

### HTML Generation

The HTML template in `src/html.jl`:
1. Collects CDN URLs from all plugin types
2. Collects init scripts from all plugin types
3. Collects CSS styles from all plugin types
4. Generates Vue.js-powered single-page application
5. Auto-generates UUIDs for plugins
6. Embeds all data as JSON

### Testing Pattern

Tests follow the `test_*.jl` naming convention and:
- Use modules to avoid namespace pollution
- Generate demo HTML files in `test/output/`
- Test actual rendering, not just types
- Use `Dict{String,Any}` consistently

## Common Tasks

### Adding a New Plugin

1. Create `src/plugins/myplugin.jl`:
```julia
module MyPlugin

import ..Plugin, ..to_html, ..css_deps, ..js_deps, ..init_script
export MyItem

struct MyItem <: Plugin
    content::String
end

to_html(plugin::MyItem) = "<div class='my-plugin'>$(plugin.content)</div>"
css_deps(::Type{MyItem}) = ["https://cdn.example.com/mylib.css"]
js_deps(::Type{MyItem}) = ["https://cdn.example.com/mylib.js"]
init_script(::Type{MyItem}) = "// initialization code"

end
```

2. Include in `src/Patchwork.jl`:
```julia
include("plugins/myplugin.jl")
using .MyPlugin
export MyItem
```

3. Add tests in `test/test_myplugin.jl`

### Updating Dependencies

Edit `Project.toml`:
```toml
[deps]
JSON = "..."
Markdown = "..."
UUIDs = "..."

[compat]
julia = "1.9"
```

### Running Tests

```bash
julia --project -e 'using Pkg; Pkg.test()'
```

Tests generate HTML demos in `test/output/` for manual inspection.

## Design Decisions

### Why No Validation?

Trust users and Julia's type system. Validation adds complexity without significant benefit.

### Why Auto-generated UUIDs?

Removes burden from users. IDs are only needed internally for Vue.js reactivity.

### Why Single HTML File?

Self-contained outputs are easier to share and deploy. CDN dependencies keep file size small.

### Why Vue.js + Tailwind?

- Vue: Reactive UI without build step
- Tailwind: Utility-first CSS via CDN
- Both work from CDN without compilation

## Code Style

- **Minimal comments** - Code should be self-explanatory
- **No emojis** - Professional, clean output
- **Explicit types** where needed for clarity (especially `Dict{String,Any}`)
- **Short functions** - Each does one thing
- **Direct imports** - `import X as Y` when needed to avoid conflicts

## Testing Philosophy

- **Test behavior, not implementation**
- **Generate real output** for visual verification
- **Cover edge cases** but don't over-test
- **Keep tests simple** and readable

## Future Considerations

Keep the package:
- Simple and focused
- Easy to extend
- Fast to load
- Clear to understand

Avoid:
- Feature creep
- Complex abstractions
- Breaking the plugin interface
- Heavy dependencies
