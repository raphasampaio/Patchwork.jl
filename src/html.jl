struct Html <: Plugin
    content::String
end

to_html(plugin::Html) = plugin.content
css_deps(::Type{Html}) = String[]
js_deps(::Type{Html}) = String[]
init_script(::Type{Html}) = ""
css(::Type{Html}) = ""
