module MarkdownPlugin

import Markdown as MD
import ..Item, ..tohtml, ..cdnurls, ..initscript

export Markdown

struct Markdown <: Item
    content::String
end

tohtml(item::Markdown) = MD.html(MD.parse(item.content))

cdnurls(::Type{Markdown}) = String[]

initscript(::Type{Markdown}) = ""

end
