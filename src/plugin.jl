@doc """
    Plugin

Abstract base type for all Patchwork plugins.

All plugin types must subtype `Plugin` and implement the `to_html` function. Optionally,
plugins can implement `css_deps`, `js_deps`, `init_script`, and `css` functions to provide
external dependencies and initialization code.

# Example
```julia
struct MyPlugin <: Plugin
    content::String
end

to_html(plugin::MyPlugin) = "<div>\$(plugin.content)</div>"
```

See also: [`to_html`](@ref), [`css_deps`](@ref), [`js_deps`](@ref), [`init_script`](@ref), [`css`](@ref)
"""
abstract type Plugin end

@doc """
    get_plugin_type(plugin::Plugin) -> String

Get the lowercase type name of a plugin.

This function extracts the plugin type name from the fully qualified type name and
converts it to lowercase. Used internally for HTML class generation and plugin identification.

# Arguments
- `plugin::Plugin`: Plugin instance

# Returns
- `String`: Lowercase plugin type name

# Example
```julia
plugin = Patchwork.ChartJs("Title", "bar", Dict{String,Any}(...))
get_plugin_type(plugin)  # Returns "chartjs"
```
"""
function get_plugin_type(plugin::Plugin)
    name = string(typeof(plugin))
    return lowercase(split(name, ".")[end])
end
