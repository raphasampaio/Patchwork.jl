struct Html <: Item
    content::String
end

to_html(item::Html) = item.content
cdn_urls(::Type{Html}) = String[]
init_script(::Type{Html}) = ""
css(::Type{Html}) = ""
