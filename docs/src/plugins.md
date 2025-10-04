# Overview

Patchwork includes seven built-in plugins for common dashboard components. Each plugin is designed to work seamlessly with the dashboard system and requires no additional configuration.

# Creating Custom Plugins

Extend Patchwork with any JavaScript library by creating custom plugins.

## Plugin Interface

All plugins must implement `to_html`. Optional functions include `css_deps`, `js_deps`, `init_script`, and `css`.

```julia
module MyPluginModule

import ..Plugin, ..to_html, ..css_deps, ..js_deps, ..init_script, ..css
export MyPlugin

struct MyPlugin <: Plugin
    content::String
end

# Required
to_html(plugin::MyPlugin) = "<div class='myplugin'>$(plugin.content)</div>"

# Optional
css_deps(::Type{MyPlugin}) = ["https://cdn.example.com/lib.css"]
js_deps(::Type{MyPlugin}) = ["https://cdn.example.com/lib.js"]
init_script(::Type{MyPlugin}) = "// initialization code"
css(::Type{MyPlugin}) = ".myplugin { padding: 1rem; }"

end
```

## Integration

Add to `src/Patchwork.jl`:

```julia
include("plugins/myplugin.jl")
using .MyPluginModule
```

## Best Practices

1. **Use unique CSS classes** to avoid conflicts
2. **Generate unique IDs** with UUIDs for elements
3. **Store data in attributes** using `data-*` attributes
4. **Query by class in init_script** to initialize all instances
5. **Handle visibility** for libraries that need visible elements
6. **Use different module/struct names** to avoid conflicts
7. **Add error handling** in JavaScript initialization
