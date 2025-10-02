module MarkdownPlugin

import Markdown as MD
import ..Item, ..to_html, ..css_deps, ..js_deps, ..init_script, ..css

export Markdown

struct Markdown <: Item
    content::String
end

to_html(item::Markdown) = MD.html(MD.parse(item.content))

css_deps(::Type{Markdown}) = [
    "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/styles/github-light.min.css",
]

js_deps(::Type{Markdown}) = [
    "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/highlight.min.js",
    "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/languages/julia.min.js",
    "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/languages/lua.min.js",
]

init_script(::Type{Markdown}) = """
    document.querySelectorAll('pre code').forEach((block) => {
        hljs.highlightElement(block);
    });
"""

css(::Type{Markdown}) = """
/* Markdown content styling */
h1 {
    font-size: 1.875rem;
    font-weight: 600;
    margin: 1.5rem 0 1rem 0;
    color: #111827;
    letter-spacing: -0.025em;
}

h2 {
    font-size: 1.5rem;
    font-weight: 600;
    margin: 1.25rem 0 0.75rem 0;
    color: #111827;
    letter-spacing: -0.025em;
}

h3 {
    font-size: 1.25rem;
    font-weight: 600;
    margin: 1rem 0 0.5rem 0;
    color: #111827;
}

h4, h5, h6 {
    font-size: 1rem;
    font-weight: 600;
    margin: 0.875rem 0 0.5rem 0;
    color: #374151;
}

p {
    margin: 0.75rem 0;
    line-height: 1.7;
    color: #374151;
}

ul, ol {
    margin: 0.75rem 0;
    padding-left: 1.5rem;
    line-height: 1.7;
    color: #374151;
}

li {
    margin: 0.375rem 0;
}

blockquote {
    margin: 1rem 0;
    padding-left: 1rem;
    border-left: 3px solid #e5e7eb;
    color: #6b7280;
    font-style: italic;
}

code {
    background: #f9fafb;
    padding: 0.125rem 0.375rem;
    border-radius: 0.25rem;
    font-family: 'Monaco', 'Menlo', 'Consolas', monospace;
    font-size: 0.875em;
    color: #1f2937;
    border: 1px solid #e5e7eb;
}

pre {
    padding: 1rem;
    border-radius: 0.5rem;
    overflow-x: auto;
    margin: 1rem 0;
    border: 1px solid #e5e7eb;
}

pre code {
    background: transparent !important;
    padding: 0;
    border: none;
}

a {
    color: #111827;
    text-decoration: underline;
    text-decoration-color: #d1d5db;
    text-underline-offset: 2px;
    transition: text-decoration-color 0.2s;
}

a:hover {
    text-decoration-color: #111827;
}

strong {
    font-weight: 600;
    color: #111827;
}

em {
    font-style: italic;
}

hr {
    border: none;
    border-top: 1px solid #e5e7eb;
    margin: 2rem 0;
}
"""

end
