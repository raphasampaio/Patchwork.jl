# Rhinestone Plugin Development Guide

This guide shows how to create plugins for Rhinestone.jl that add support for custom content types.

## Architecture Overview

Rhinestone uses a plugin-based architecture where:

1. **Core Package (Rhinestone.jl)**: Provides the dashboard framework, tab system, and plugin registry
2. **Core Content Type**: Only `HtmlContent` for raw HTML
3. **Built-in Plugins**: `RhinestoneMarkdown` submodule included with the package
4. **External Plugin Packages**: Separate packages that add support for specific content types (charts, maps, etc.)

## Creating a Plugin Package

### Step 1: Package Structure

For a package like `RhinestoneHighcharts.jl`:

```
RhinestoneHighcharts.jl/
├── Project.toml
├── src/
│   └── RhinestoneHighcharts.jl
└── test/
    └── runtests.jl
```

### Step 2: Define Your Content Type

```julia
# src/RhinestoneHighcharts.jl
module RhinestoneHighcharts

using Rhinestone

export HighchartsPlot

"""
A Highcharts plot configuration.
"""
struct HighchartsPlot <: Rhinestone.ContentItem
    id::String
    title::String
    config::Dict{String, Any}
    height::String

    function HighchartsPlot(id::String, title::String, config::Dict{String, Any};
                           height::String = "24rem")
        new(id, title, config, height)
    end
end
```

### Step 3: Implement the Renderer

```julia
struct HighchartsRenderer <: Rhinestone.ContentRenderer end

# Required: Convert content to JSON-serializable dict
function Rhinestone.render_to_dict(::HighchartsRenderer, item::HighchartsPlot)
    return Dict{String, Any}(
        "type" => "highcharts",
        "id" => item.id,
        "title" => item.title,
        "height" => item.height,
        "config" => item.config
    )
end

# Required: Return the content type identifier
Rhinestone.content_type(::HighchartsRenderer) = "highcharts"

# Optional: Provide CDN URLs for required libraries
function Rhinestone.get_cdn_urls(::HighchartsRenderer)
    return Dict{String, String}(
        "highcharts" => "https://code.highcharts.com/highcharts.js"
    )
end

# Optional: Provide JavaScript initialization code
function Rhinestone.get_init_script(::HighchartsRenderer)
    return """
    function initializeHighcharts(container, config) {
        Highcharts.chart(container, config);
    }
    """
end
```

### Step 4: Register the Renderer

```julia
# Register at module initialization
function __init__()
    Rhinestone.register_renderer!(HighchartsPlot, HighchartsRenderer())
end

end # module
```

### Complete Example Package

See `example_plugin.jl` for a complete working example with Leaflet maps.

## Plugin Interface Reference

### Required Methods

Every renderer must implement:

```julia
# Convert item to dictionary for JSON serialization
Rhinestone.render_to_dict(renderer::YourRenderer, item::YourContentType) -> Dict{String, Any}

# Return the content type identifier (used in HTML/JS)
Rhinestone.content_type(renderer::YourRenderer) -> String
```

### Optional Methods

Renderers can optionally provide:

```julia
# Return CDN URLs for required libraries
Rhinestone.get_cdn_urls(renderer::YourRenderer) -> Dict{String, String}

# Return JavaScript initialization code
Rhinestone.get_init_script(renderer::YourRenderer) -> String
```

### Registry Functions

Available functions for managing renderers:

```julia
# Register a renderer for a content type
Rhinestone.register_renderer!(ContentType, renderer)

# Get the registered renderer for an item
Rhinestone.get_renderer(item::ContentItem)

# Check if a renderer is registered
Rhinestone.has_renderer(item::ContentItem)

# Clear all registrations (useful for testing)
Rhinestone.clear_registry!()
```

## Built-in Plugin Example

Rhinestone includes `RhinestoneMarkdown` as a built-in plugin. You can study its implementation in `src/RhinestoneMarkdown.jl`:

```julia
using Rhinestone.RhinestoneMarkdown

markdown = MarkdownContent("intro", """
# Welcome
This is **markdown** content.
""")
```

## Example External Plugins

Here are example plugin packages you could create:

- `RhinestoneHighcharts.jl` - Highcharts support
- `RhinestonePlotly.jl` - Plotly.js charts
- `RhinestoneLeaflet.jl` - Interactive maps
- `RhinestoneD3.jl` - D3.js visualizations
- `RhinestoneVega.jl` - Vega/Vega-Lite plots
- `RhinestoneMermaid.jl` - Mermaid diagrams

## Testing Your Plugin

```julia
using Test
using Rhinestone
using YourPlugin

@testset "YourPlugin" begin
    # Create content
    item = YourContentType("test-id", "Test Title", config)

    # Test renderer registration
    @test Rhinestone.has_renderer(item)

    # Test rendering
    renderer = Rhinestone.get_renderer(item)
    dict = Rhinestone.render_to_dict(renderer, item)
    @test dict["type"] == "your-type"
    @test dict["id"] == "test-id"

    # Test dashboard generation
    tab = Rhinestone.Tab("Test", [item])
    config = Rhinestone.DashboardConfig("Test Dashboard", [tab])
    output = Rhinestone.generate_dashboard(config, "test_output.html")
    @test isfile(output)
end
```

## Best Practices

1. **Namespacing**: Always prefix your content types and exports to avoid conflicts
2. **Documentation**: Provide clear docstrings for all public types and functions
3. **Testing**: Include comprehensive tests with actual dashboard generation
4. **Examples**: Provide example usage in your README
5. **CDN URLs**: Use specific versions in CDN URLs for reproducibility
6. **Error Handling**: Validate configuration in your content type constructors

## Questions or Issues?

- Open an issue on the Rhinestone.jl repository
- Check existing plugin packages for inspiration
- Review the built-in renderers in `src/builtin_renderers.jl`
