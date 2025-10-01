"""
Built-in content renderers for Rhinestone.

This file implements renderers for the core content types provided by Rhinestone.
"""

# HTML Renderer
struct HtmlRenderer <: ContentRenderer end

function render_to_dict(::HtmlRenderer, item::HtmlContent)
    return Dict{String, Any}(
        "type" => "html",
        "id" => item.id,
        "html" => item.html
    )
end

content_type(::HtmlRenderer) = "html"

# Register built-in renderer
register_renderer!(HtmlContent, HtmlRenderer())
