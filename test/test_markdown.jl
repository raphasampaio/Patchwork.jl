module TestMarkdown

using Test
using Patchwork

@testset "Markdown Plugin" begin
    @testset "Markdown basics" begin
        md = PatchworkMarkdown("# Hello\n\nWorld")
        @test md isa Item

        html_output = tohtml(md)
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
        """)

        html_output = tohtml(md)
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

        html_output = tohtml(md)
        @test occursin("<code", html_output)
        @test occursin("x", html_output) && occursin("1", html_output)
    end

    @testset "Markdown plugin interface" begin
        @test cdnurls(PatchworkMarkdown) == String[]
        @test initscript(PatchworkMarkdown) == ""
    end
end

# Generate sample HTML output
dashboard = Dashboard(
    "PatchworkMarkdown Demo",
    [
        Tab(
            "Documentation",
            [
                PatchworkMarkdown(
                    "# PatchworkMarkdown Content Example\n" *
                    "This demonstrates the **PatchworkMarkdown plugin** for Patchwork.\n" *
                    "\n" *
                    "## Features\n" *
                    "- Easy formatting\n" *
                    "- Code blocks\n" *
                    "- Lists and emphasis\n" *
                    "\n" *
                    "### Code Example\n" *
                    "```julia\n" *
                    "function greet(name)\n" *
                    "    println(\"Hello, \$name!\")\n" *
                    "end\n" *
                    "greet(\"World\")\n" *
                    "```\n" *
                    "\n" *
                    "## Formatting\n" *
                    "You can use *italic*, **bold**, and ***bold italic*** text.\n" *
                    "> This is a blockquote.\n" *
                    "\n" *
                    "Links work too: [Patchwork](https://github.com)\n"),
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
