module MarkdownPlugin

using Markdown
import ..Item, ..tohtml, ..cdnurls, ..initscript

export PatchworkMarkdown

struct PatchworkMarkdown <: Item
    content::String
end

tohtml(item::PatchworkMarkdown) = Markdown.html(Markdown.parse(item.content))

cdnurls(::Type{PatchworkMarkdown}) = String[]

initscript(::Type{PatchworkMarkdown}) = ""

end
