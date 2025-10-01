struct Html <: Item
    content::String
end

to_html(item::Html) = item.content
css_deps(::Type{Html}) = String[]
js_deps(::Type{Html}) = String[]
init_script(::Type{Html}) = ""
css(::Type{Html}) = ""
