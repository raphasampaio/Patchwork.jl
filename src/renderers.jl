"""
Plugin system for Rhinestone content renderers.

Plugins can register custom content types and their rendering logic.
"""

"""
    ContentRenderer

Abstract type for content renderers. Each renderer handles a specific content type.

Plugins should implement:
- `render_to_dict(renderer, item)` - Convert item to JSON-serializable dict
- `get_cdn_urls(renderer)` - Return Dict of CDN URLs needed
- `get_init_script(renderer)` - Return JavaScript initialization code
- `content_type(renderer)` - Return string identifier for this content type
"""
abstract type ContentRenderer end

"""
    render_to_dict(renderer::ContentRenderer, item::ContentItem)

Convert a content item to a JSON-serializable dictionary for embedding in HTML.
Must be implemented by each renderer.
"""
function render_to_dict end

"""
    get_cdn_urls(renderer::ContentRenderer)

Return a Dict{String,String} of CDN URLs required by this renderer.
Default implementation returns empty dict.
"""
get_cdn_urls(renderer::ContentRenderer) = Dict{String,String}()

"""
    get_init_script(renderer::ContentRenderer)

Return JavaScript code for initializing content of this type.
Default implementation returns empty string.
"""
get_init_script(renderer::ContentRenderer) = ""

"""
    content_type(renderer::ContentRenderer)

Return the string identifier for this content type (e.g., "chart", "markdown", "map").
Must be implemented by each renderer.
"""
function content_type end

"""
    RendererRegistry

Global registry of content renderers.
"""
mutable struct RendererRegistry
    renderers::Dict{DataType, ContentRenderer}
end

# Global registry instance
const RENDERER_REGISTRY = RendererRegistry(Dict{DataType, ContentRenderer}())

"""
    register_renderer!(item_type::Type{<:ContentItem}, renderer::ContentRenderer)

Register a renderer for a specific content item type.

# Example
```julia
register_renderer!(MyChartType, MyChartRenderer())
```
"""
function register_renderer!(item_type::Type{<:ContentItem}, renderer::ContentRenderer)
    RENDERER_REGISTRY.renderers[item_type] = renderer
    return nothing
end

"""
    get_renderer(item::ContentItem)

Get the registered renderer for a content item.
Throws an error if no renderer is registered.
"""
function get_renderer(item::ContentItem)
    renderer = get(RENDERER_REGISTRY.renderers, typeof(item), nothing)
    if renderer === nothing
        error("No renderer registered for type $(typeof(item)). Use register_renderer! to register one.")
    end
    return renderer
end

"""
    has_renderer(item::ContentItem)

Check if a renderer is registered for this content item type.
"""
function has_renderer(item::ContentItem)
    return haskey(RENDERER_REGISTRY.renderers, typeof(item))
end

"""
    clear_registry!()

Clear all registered renderers. Useful for testing.
"""
function clear_registry!()
    empty!(RENDERER_REGISTRY.renderers)
    return nothing
end
