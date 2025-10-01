module MarkdownPlugin

using Markdown
import ..Item, ..tohtml, ..cdnurls, ..initscript

export Markdown

struct Markdown <: Item
    content::String
end

tohtml(item::Markdown) = Base.Markdown.html(Base.Markdown.parse(item.content))

cdnurls(::Type{Markdown}) = String[]

initscript(::Type{Markdown}) = ""

end
