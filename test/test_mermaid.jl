module TestMermaid

using Test
using Patchwork

@testset "Mermaid Plugin" begin
    @testset "PatchworkMermaid constructor" begin
        diagram = PatchworkMermaid("Test Diagram", "graph TD\nA-->B")
        @test diagram.title == "Test Diagram"
        @test diagram.diagram == "graph TD\nA-->B"
        @test diagram.theme == "default"

        diagram_with_theme = PatchworkMermaid("Dark Diagram", "graph LR\nX-->Y", theme = "dark")
        @test diagram_with_theme.theme == "dark"
    end

    @testset "PatchworkMermaid rendering" begin
        diagram = PatchworkMermaid("Flowchart", "graph TD\nStart-->End")
        html = to_html(diagram)
        @test occursin("Flowchart", html)
        @test occursin("mermaid-diagram", html)
        @test occursin("graph TD", html)
        @test occursin("Start-->End", html)
    end

    @testset "PatchworkMermaid plugin interface" begin
        @test css_deps(PatchworkMermaid) == String[]
        @test js_deps(PatchworkMermaid) == ["https://cdn.jsdelivr.net/npm/mermaid@11.4.1/dist/mermaid.min.js"]
        @test occursin("mermaid.initialize", init_script(PatchworkMermaid))
        @test occursin(".mermaid-diagram", css(PatchworkMermaid))
    end
end

# Generate sample HTML output
dashboard = Dashboard(
    "Mermaid Diagrams Demo",
    [
        Tab(
            "Flowcharts",
            [
                PatchworkMermaid(
                    "Simple Flowchart",
                    """
                    graph TD
                        A[Start] --> B{Is it?}
                        B -->|Yes| C[OK]
                        B -->|No| D[End]
                        C --> D
                    """,
                ),
                PatchworkMermaid(
                    "Process Flow",
                    """
                    graph LR
                        A[Input] --> B[Process]
                        B --> C{Decision}
                        C -->|Option 1| D[Result 1]
                        C -->|Option 2| E[Result 2]
                    """,
                ),
            ],
        ),
        Tab(
            "Diagrams",
            [
                PatchworkMermaid(
                    "Sequence Diagram",
                    """
                    sequenceDiagram
                        participant User
                        participant Browser
                        participant Server
                        User->>Browser: Click button
                        Browser->>Server: HTTP Request
                        Server->>Browser: HTTP Response
                        Browser->>User: Display result
                    """,
                ),
                PatchworkMermaid(
                    "Class Diagram",
                    """
                    classDiagram
                        class Animal {
                            +String name
                            +int age
                            +makeSound()
                        }
                        class Dog {
                            +String breed
                            +bark()
                        }
                        class Cat {
                            +String color
                            +meow()
                        }
                        Animal <|-- Dog
                        Animal <|-- Cat
                    """,
                ),
            ],
        ),
    ],
)

output_path = joinpath(@__DIR__, "output", "test_mermaid.html")
render(dashboard, output_path)

end
