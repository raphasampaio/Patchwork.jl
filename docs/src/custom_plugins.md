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
using .MyPluginModule: MyPlugin
```

## Best Practices

1. **Use unique CSS classes** to avoid conflicts
2. **Generate unique IDs** with UUIDs for elements
3. **Store data in attributes** using `data-*` attributes
4. **Query by class in init_script** to initialize all instances
5. **Handle visibility** for libraries that need visible elements
6. **Use different module/struct names** to avoid conflicts
7. **Add error handling** in JavaScript initialization

## Example: DataTables Plugin

```julia
module DataTablesPlugin

import ..Plugin, ..to_html, ..css_deps, ..js_deps, ..init_script
using JSON
export DataTable

struct DataTable <: Plugin
    title::String
    data::Vector{Vector{Any}}
    columns::Vector{String}
end

function to_html(plugin::DataTable)
    headers = join(["<th>$(col)</th>" for col in plugin.columns], "")
    rows = join([
        "<tr>" * join(["<td>$(cell)</td>" for cell in row], "") * "</tr>"
        for row in plugin.data
    ], "")

    return """
    <div>
        <h3 class="text-lg font-semibold mb-4">$(plugin.title)</h3>
        <table class="datatable display" style="width:100%">
            <thead><tr>$headers</tr></thead>
            <tbody>$rows</tbody>
        </table>
    </div>
    """
end

css_deps(::Type{DataTable}) = [
    "https://cdn.datatables.net/1.13.7/css/jquery.dataTables.min.css"
]

js_deps(::Type{DataTable}) = [
    "https://code.jquery.com/jquery-3.7.0.min.js",
    "https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"
]

init_script(::Type{DataTable}) = """
    document.querySelectorAll('.datatable').forEach(table => {
        $(table).DataTable();
    });
"""

end
```

## Publishing Plugins

To share your plugin:

1. Create a separate Julia package
2. Include comprehensive tests
3. Add documentation with examples
4. Follow semantic versioning

Package structure:

```
MyPatchworkPlugin.jl/
├── src/
│   └── MyPatchworkPlugin.jl
├── test/
│   └── runtests.jl
├── Project.toml
└── README.md
```
