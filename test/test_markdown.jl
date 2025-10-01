module TestMarkdown

using Test
using Rhinestone

@testset "Markdown Plugin" begin
    @testset "Markdown basics" begin
        md = Markdown("# Hello\n\nWorld")
        @test md isa Item

        html_output = tohtml(md)
        @test occursin("<h1>Hello</h1>", html_output)
        @test occursin("World", html_output)
    end

    @testset "Markdown formatting" begin
        md = Markdown("""
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
        @test occursin("<li>List item 1</li>", html_output)
    end

    @testset "Markdown code blocks" begin
        md = Markdown("""
        ```julia
        x = 1 + 1
        ```
        """)

        html_output = tohtml(md)
        @test occursin("<code", html_output)
        @test occursin("x = 1 + 1", html_output)
    end

    @testset "Markdown plugin interface" begin
        @test cdnurls(Markdown) == String[]
        @test initscript(Markdown) == ""
    end
end

end