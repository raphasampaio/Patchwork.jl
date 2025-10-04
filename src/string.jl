@doc """
    escape_html(s::String) -> String

Escape HTML special characters in a string.

This function converts special HTML characters to their corresponding HTML entities to
prevent them from being interpreted as HTML markup. Used internally to safely include
user-provided text in generated HTML.

# Arguments
- `s::String`: String to escape

# Returns
- `String`: Escaped string with HTML entities

# Escapes
- `&` → `&amp;`
- `<` → `&lt;`
- `>` → `&gt;`
- `"` → `&quot;`

# Example
```julia
escape_html("<script>alert('xss')</script>")
# Returns: "&lt;script&gt;alert('xss')&lt;/script&gt;"

escape_html("Hello & goodbye")
# Returns: "Hello &amp; goodbye"
```

See also: [`Dashboard`](@ref), [`generate_html`](@ref)
"""
function escape_html(s::String)
    s = replace(s, "&" => "&amp;")
    s = replace(s, "<" => "&lt;")
    s = replace(s, ">" => "&gt;")
    s = replace(s, "\"" => "&quot;")
    return s
end
