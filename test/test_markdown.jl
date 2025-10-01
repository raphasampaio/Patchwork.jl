module TestMarkdown

using Test
using Patchwork

@testset "Markdown Plugin" begin
    @testset "Markdown basics" begin
        md = PatchworkMarkdown("# Hello\n\nWorld")
        @test md isa Item

        html_output = to_html(md)
        @test occursin("<h1>Hello</h1>", html_output)
        @test occursin("World", html_output)
    end

    @testset "Markdown formatting" begin
        md = PatchworkMarkdown("""
# Heading 1
## Heading 2

**bold** and *italic*

- List item 1
- List item 2
"""
        )

        html_output = to_html(md)
        @test occursin("<h1>Heading 1</h1>", html_output)
        @test occursin("<h2>Heading 2</h2>", html_output)
        @test occursin("<strong>bold</strong>", html_output)
        @test occursin("<em>italic</em>", html_output)
        @test occursin("List item 1", html_output) && occursin("<li>", html_output)
    end

    @testset "Markdown code blocks" begin
        md = PatchworkMarkdown("""
```julia
x = 1 + 1
```
        """)

        html_output = to_html(md)
        @test occursin("<code", html_output)
        @test occursin("x", html_output) && occursin("1", html_output)
    end

    @testset "Markdown plugin interface" begin
        @test cdn_urls(PatchworkMarkdown) == String[]
        @test init_script(PatchworkMarkdown) == ""
    end
end

# Generate sample HTML output
dashboard = Dashboard(
    "Markdown Demo",
    [
        Tab(
            "Documentation",
            [
                PatchworkMarkdown(
                    """
# Markdown Content Example
This demonstrates the **Markdown plugin** for Patchwork.

## Features
- Easy formatting
- Code blocks
- Lists and emphasis

### Code Example
```julia
function greet(name)
    println(\"Hello, \$name!\")
end
greet(\"World\")
```

## Formatting
You can use *italic*, **bold**, and ***bold italic*** text.
> This is a blockquote.
>

Links work too: [Patchwork](https://github.com)
"""),
            ],
        ),
        Tab(
            "Mixed Content",
            [
                PatchworkMarkdown("## Introduction\n\nThis tab combines markdown with HTML."),
                Html("<hr>"),
                PatchworkMarkdown("### Details\n\nMore markdown content here."),
            ],
        ),
    ],
)

output_path = joinpath(@__DIR__, "output", "test_markdown.html")
render(dashboard, output_path)

end
