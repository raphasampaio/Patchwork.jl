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
├── Patchwork.jl          # Main module (exports, using statements)
├── string.jl              # HTML escape utilities
├── plugin.jl              # Plugin abstract type and utilities
├── html.jl                # HTML plugin (raw HTML content)
├── tab.jl                 # Tab struct definition
├── dashboard.jl           # Dashboard struct and HTML generation
└── plugins/               # Built-in plugins
    ├── markdown.jl        # Markdown content support
    ├── chartjs.jl         # Chart.js integration
    ├── highcharts.jl      # Highcharts integration
    ├── plotly.jl          # Plotly integration
    ├── leaflet.jl         # Leaflet maps integration
    └── mermaid.jl         # Mermaid diagrams integration

test/
├── runtests.jl            # Main test runner (recursive)
├── test_core.jl           # Core types tests
├── test_markdown.jl       # Markdown plugin tests
├── test_charts.jl         # Chart plugins tests
├── test_html.jl           # HTML generation tests
├── test_leaflet.jl        # Leaflet plugin tests
├── test_mermaid.jl        # Mermaid plugin tests
├── test_plotly_scattermap.jl  # Plotly scattermap tests
├── test_read_me.jl        # README example tests
└── output/                # Generated HTML demos
```

## Core API

### Types

```julia
abstract type Plugin end

struct HTML <: Plugin
    content::String
end

struct Tab
    label::String
    plugins::Vector{Plugin}
end

struct Dashboard
    title::String
    tabs::Vector{Tab}
    custom_css::String

    Dashboard(title::String, tabs::Vector{Tab}; custom_css::String = "")
end
```

### Functions

```julia
save(dashboard::Dashboard, path::String)       # Generate HTML file
to_html(plugin::Plugin)                        # Render plugin to HTML
css_deps(::Type{<:Plugin})                     # Get CSS dependencies for plugin type
js_deps(::Type{<:Plugin})                      # Get JS dependencies for plugin type
init_script(::Type{<:Plugin})                  # Get JS initialization script
css(::Type{<:Plugin})                          # Get CSS styles for plugin type
get_plugin_type(plugin::Plugin)                # Get lowercase plugin type name
escape_html(s::String)                         # Escape HTML special characters
generate_html(dashboard::Dashboard)            # Generate complete HTML string
```

## Plugin System

Plugins implement five functions (one required, four optional):

```julia
# Required: Convert plugin to HTML
to_html(plugin::MyPlugin) = "<div>...</div>"

# Optional: CSS dependencies (CDN URLs)
css_deps(::Type{MyPlugin}) = ["https://cdn.example.com/lib.css"]

# Optional: JS dependencies (CDN URLs)
js_deps(::Type{MyPlugin}) = ["https://cdn.example.com/lib.js"]

# Optional: JavaScript initialization code (runs on mount)
init_script(::Type{MyPlugin}) = "/* init code */"

# Optional: Custom CSS styles
css(::Type{MyPlugin}) = "/* custom styles */"
```

All plugins must be subtypes of `Plugin` and live in their own module inside `src/plugins/`.

### Built-in Plugins

**HTML** (`src/html.jl`)
- Raw HTML content passthrough
- No dependencies, no initialization
- Useful for custom HTML snippets

**Markdown** (`src/plugins/markdown.jl`)
- Converts markdown to HTML using Julia's Markdown stdlib
- Uses `import Markdown as MD` to avoid namespace conflicts
- No external dependencies

**ChartJs** (`src/plugins/chartjs.jl`)
- Creates Chart.js charts
- Stores config in `data-config` attribute
- Requires `Dict{String,Any}` for type safety
- CDN: Chart.js v4.4.7

**Highcharts** (`src/plugins/highcharts.jl`)
- Creates Highcharts charts
- Uses UUID for unique chart IDs
- CDN: Highcharts v11.4.8

**Plotly** (`src/plugins/plotly.jl`)
- Creates Plotly charts
- Supports data, layout, and config options
- CDN: Plotly.js v2.35.2

**Leaflet** (`src/plugins/leaflet.jl`)
- Creates interactive maps using Leaflet
- Supports center coordinates, zoom levels, and markers with popups
- CDN: Leaflet v1.9.4 + CSS

**Mermaid** (`src/plugins/mermaid.jl`)
- Renders diagrams using Mermaid
- Supports flowcharts, sequence diagrams, class diagrams, and more
- CDN: Mermaid v11.4.0

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

The HTML generation in `src/dashboard.jl` (`generate_html` function):
1. Collects unique plugin types from all tabs
2. Collects CSS dependencies (CDN URLs) from all plugin types
3. Collects JS dependencies (CDN URLs) from all plugin types
4. Collects initialization scripts from all plugin types
5. Collects custom CSS from all plugin types
6. Auto-generates UUIDs for each plugin instance
7. Converts plugins to HTML using `to_html(plugin)`
8. Embeds all tab/plugin data as JSON
9. Generates Vue.js-powered single-page application with:
   - Responsive sidebar navigation
   - Search functionality across all content
   - Tab switching
   - Mobile-friendly hamburger menu
   - Tailwind CSS styling via CDN

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
module MyPluginModule

import ..Plugin, ..to_html, ..css_deps, ..js_deps, ..init_script, ..css
export MyPlugin

struct MyPlugin <: Plugin
    content::String
end

to_html(plugin::MyPlugin) = "<div class='my-plugin'>$(plugin.content)</div>"
css_deps(::Type{MyPlugin}) = ["https://cdn.example.com/mylib.css"]
js_deps(::Type{MyPlugin}) = ["https://cdn.example.com/mylib.js"]
init_script(::Type{MyPlugin}) = "// initialization code"
css(::Type{MyPlugin}) = "/* custom styles */"

end
```

2. Include in `src/Patchwork.jl`:
```julia
include("plugins/myplugin.jl")
using .MyPluginModule
```

3. Add tests in `test/test_myplugin.jl`

**Note**: Module names should be different from struct names (e.g., `MyPluginModule` vs `MyPlugin`) to avoid naming conflicts.

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

Removes burden from users. IDs are only needed internally for Vue.js reactivity and plugin initialization.

### Why Single HTML File?

Self-contained outputs are easier to share and deploy. CDN dependencies keep file size small while providing full functionality.

### Why Vue.js + Tailwind?

- Vue 3: Reactive UI without build step, CDN-ready
- Tailwind (browser edition): Utility-first CSS via CDN
- Both work from CDN without compilation or build tools

### Why Separate Files for Core Types?

- `plugin.jl`: Abstract type and utilities
- `tab.jl`: Tab struct
- `dashboard.jl`: Dashboard struct and HTML generation
- `html.jl`: HTML plugin (not HTML generation)

This separation follows single responsibility principle and makes the codebase easier to navigate.

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
