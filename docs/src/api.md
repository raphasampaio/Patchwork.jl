# API Reference

## Core Types

```@autodocs
Modules = [Patchwork]
Pages   = ["plugin.jl", "tab.jl", "dashboard.jl"]
Order   = [:type]
```

## Core Functions

```@autodocs
Modules = [Patchwork]
Pages   = ["dashboard.jl", "string.jl"]
Order   = [:function]
Filter  = t -> t ∈ [Patchwork.save, Patchwork.generate_html, Patchwork.escape_html]
```

## Plugin Interface Functions

```@autodocs
Modules = [Patchwork]
Pages   = ["Patchwork.jl"]
Order   = [:function]
Filter  = t -> t ∈ [Patchwork.to_html, Patchwork.css_deps, Patchwork.js_deps, Patchwork.init_script, Patchwork.css]
```

## Utility Functions

```@autodocs
Modules = [Patchwork]
Pages   = ["plugin.jl"]
Order   = [:function]
Filter  = t -> t === Patchwork.get_plugin_type
```
