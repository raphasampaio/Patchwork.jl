module Patchwork

using UUIDs
import JSON

export save, to_html, css_deps, js_deps, init_script, css

include("string.jl")
include("plugin.jl")

@doc """
    to_html(plugin::Plugin) -> String

Convert plugin to HTML string. Must be implemented for all custom plugins.

# Arguments
- `plugin::Plugin`: Plugin instance to convert

# Returns
- `String`: HTML representation of the plugin

# Example
```julia
to_html(plugin::MyPlugin) = "<div class='my-plugin'>\$(plugin.content)</div>"
```

See also: [`Plugin`](@ref), [`css_deps`](@ref), [`js_deps`](@ref)
"""
function to_html end

@doc """
    css_deps(::Type{<:Plugin}) -> Vector{String}

Return vector of CSS dependency URLs for a plugin type.

# Arguments
- `::Type{<:Plugin}`: Plugin type (not instance)

# Returns
- `Vector{String}`: CDN URLs for CSS dependencies

# Default
Returns `String[]` if not implemented.

# Example
```julia
css_deps(::Type{MyPlugin}) = ["https://cdn.example.com/style.css"]
```

See also: [`js_deps`](@ref), [`to_html`](@ref)
"""
css_deps(::Type{<:Plugin}) = String[]

@doc """
    js_deps(::Type{<:Plugin}) -> Vector{String}

Return vector of JavaScript dependency URLs for a plugin type.

# Arguments
- `::Type{<:Plugin}`: Plugin type (not instance)

# Returns
- `Vector{String}`: CDN URLs for JavaScript dependencies

# Default
Returns `String[]` if not implemented.

# Example
```julia
js_deps(::Type{MyPlugin}) = ["https://cdn.example.com/lib.js"]
```

See also: [`css_deps`](@ref), [`init_script`](@ref)
"""
js_deps(::Type{<:Plugin}) = String[]

@doc """
    init_script(::Type{<:Plugin}) -> String

Return JavaScript initialization code for a plugin type.

This code runs after all dependencies are loaded and the DOM is ready.
Typically used to initialize JavaScript libraries on plugin elements.

# Arguments
- `::Type{<:Plugin}`: Plugin type (not instance)

# Returns
- `String`: JavaScript initialization code

# Default
Returns `""` if not implemented.

# Example
```julia
init_script(::Type{MyPlugin}) = \"\"\"
    document.querySelectorAll('.my-plugin').forEach(el => {
        // Initialize library
    });
\"\"\"
```

See also: [`js_deps`](@ref), [`to_html`](@ref)
"""
init_script(::Type{<:Plugin}) = ""

@doc """
    css(::Type{<:Plugin}) -> String

Return custom CSS styles for a plugin type.

# Arguments
- `::Type{<:Plugin}`: Plugin type (not instance)

# Returns
- `String`: CSS styles

# Default
Returns `""` if not implemented.

# Example
```julia
css(::Type{MyPlugin}) = \"\"\"
    .my-plugin {
        padding: 1rem;
        border: 1px solid #ccc;
    }
\"\"\"
```

See also: [`css_deps`](@ref), [`to_html`](@ref)
"""
css(::Type{<:Plugin}) = ""

include("tab.jl")
include("dashboard.jl")

include("plugins/html.jl")
include("plugins/markdown.jl")
include("plugins/chartjs.jl")
include("plugins/highcharts.jl")
include("plugins/plotly.jl")
include("plugins/leaflet.jl")
include("plugins/mermaid.jl")

using .MarkdownPlugin
using .ChartJsPlugin
using .HighchartsPlugin
using .PlotlyPlugin
using .LeafletPlugin
using .MermaidPlugin

end
