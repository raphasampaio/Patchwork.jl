module MarkdownPlugin

using Markdown
import ..Item, ..to_html, ..cdn_urls, ..init_script, ..css

export PatchworkMarkdown

struct PatchworkMarkdown <: Item
    content::String
end

to_html(item::PatchworkMarkdown) = Markdown.html(Markdown.parse(item.content))

cdn_urls(::Type{PatchworkMarkdown}) = String[]

init_script(::Type{PatchworkMarkdown}) = ""

css(::Type{PatchworkMarkdown}) = """
/* Markdown content styling */
h1 { font-size: 2em; font-weight: bold; margin: 0.67em 0; }
h2 { font-size: 1.5em; font-weight: bold; margin: 0.75em 0; }
h3 { font-size: 1.17em; font-weight: bold; margin: 0.83em 0; }
h4 { font-size: 1em; font-weight: bold; margin: 1.12em 0; }
h5 { font-size: 0.83em; font-weight: bold; margin: 1.5em 0; }
h6 { font-size: 0.75em; font-weight: bold; margin: 1.67em 0; }

p { margin: 1em 0; line-height: 1.6; }

ul, ol { margin: 1em 0; padding-left: 2em; }
li { margin: 0.5em 0; }

blockquote {
    margin: 1em 0;
    padding-left: 1em;
    border-left: 4px solid #e5e7eb;
    color: #6b7280;
}

code {
    background: #f3f4f6;
    padding: 0.2em 0.4em;
    border-radius: 3px;
    font-family: 'Courier New', monospace;
    font-size: 0.9em;
}

pre {
    background: #1f2937;
    color: #e5e7eb;
    padding: 1em;
    border-radius: 6px;
    overflow-x: auto;
    margin: 1em 0;
}

pre code {
    background: transparent;
    padding: 0;
    color: inherit;
}

a {
    color: #3b82f6;
    text-decoration: underline;
}

a:hover {
    color: #2563eb;
}

strong { font-weight: bold; }
em { font-style: italic; }

hr {
    border: none;
    border-top: 1px solid #e5e7eb;
    margin: 2em 0;
}
"""

end
