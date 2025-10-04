module HTMLPlugin

import ..Plugin, ..to_html, ..css_deps, ..js_deps, ..init_script, ..css

export HTML

@doc """
    HTML(content::String)

Raw HTML content plugin.

This plugin allows you to include arbitrary HTML content in your dashboard. The content
is passed through without modification, allowing you to use custom HTML, CSS classes
(including Tailwind CSS utilities), and even inline JavaScript if needed.

# Fields
- `content::String`: Raw HTML string to include in the dashboard

# Example
```julia
Patchwork.HTML(\"\"\"
<div class="p-6 bg-gradient-to-r from-blue-500 to-purple-600 rounded-lg shadow-xl">
    <h2 class="text-2xl font-bold text-white mb-2">Custom Component</h2>
    <p class="text-blue-100">Styled with Tailwind CSS</p>
</div>
\"\"\")
```

# Example: Alert Box
```julia
Patchwork.HTML(\"\"\"
<div class="bg-yellow-50 border-l-4 border-yellow-400 p-4">
    <p class="text-sm text-yellow-700">
        <strong>Warning:</strong> This action cannot be undone.
    </p>
</div>
\"\"\")
```

See also: `Plugin`, `to_html`
"""
struct HTML <: Plugin
    content::String
end

to_html(plugin::HTML) = plugin.content
css_deps(::Type{HTML}) = String[]
js_deps(::Type{HTML}) = String[]
init_script(::Type{HTML}) = ""
css(::Type{HTML}) = ""

end