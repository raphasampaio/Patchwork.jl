struct HTML <: Plugin
    content::String
end

to_html(plugin::HTML) = plugin.content
css_deps(::Type{HTML}) = String[]
js_deps(::Type{HTML}) = String[]
init_script(::Type{HTML}) = ""
css(::Type{HTML}) = ""
