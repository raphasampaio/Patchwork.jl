"""
# RhinestoneMarkdown

Built-in plugin for markdown content support in Rhinestone dashboards.

This module is included with Rhinestone as a core plugin, but serves as an example
of how external packages can extend Rhinestone with custom content types.
"""
module RhinestoneMarkdown

using Markdown
import Rhinestone: ContentItem, ContentRenderer
import Rhinestone: render_to_dict, content_type, register_renderer!

export MarkdownContent

"""
    MarkdownContent <: ContentItem

Represents markdown content that will be converted to HTML.

# Fields
- `id::String`: Unique identifier for the content block
- `content::String`: Markdown content (will be converted to HTML)

# Example
```julia
using Rhinestone.RhinestoneMarkdown

markdown = MarkdownContent(
    "intro",
    \"\"\"
    # Welcome

    This is **markdown** content.
    \"\"\"
)
```
"""
struct MarkdownContent <: ContentItem
    id::String
    content::String
end

# Markdown Renderer
struct MarkdownRenderer <: ContentRenderer end

function render_to_dict(::MarkdownRenderer, item::MarkdownContent)
    html = Markdown.html(Markdown.parse(item.content))
    return Dict{String, Any}(
        "type" => "markdown",
        "id" => item.id,
        "html" => html
    )
end

content_type(::MarkdownRenderer) = "markdown"

# Auto-register when module is loaded
function __init__()
    register_renderer!(MarkdownContent, MarkdownRenderer())
end

end # module
