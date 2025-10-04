module TestELKJs

using Test
using Patchwork

@testset "ELKJs Plugin" begin
    @testset "Basic graph" begin
        graph = Patchwork.ELKJs(
            "Flow Diagram",
            Dict{String, Any}(
                "id" => "root",
                "layoutOptions" => Dict("elk.algorithm" => "layered"),
                "children" => [
                    Dict("id" => "n1", "width" => 80, "height" => 40),
                    Dict("id" => "n2", "width" => 80, "height" => 40),
                ],
                "edges" => [
                    Dict("id" => "e1", "sources" => ["n1"], "targets" => ["n2"]),
                ],
            ),
        )

        @test graph isa Patchwork.Plugin
        @test graph.title == "Flow Diagram"
        @test haskey(graph.graph, "children")
        @test haskey(graph.graph, "edges")

        html = Patchwork.to_html(graph)
        @test occursin("Flow Diagram", html)
        @test occursin("elkjs-graph", html)
        @test occursin("data-graph", html)
    end

    @testset "Dependencies" begin
        js = Patchwork.js_deps(Patchwork.ELKJs)
        @test length(js) == 1
        @test occursin("elkjs", js[1])
        @test occursin("0.11.0", js[1])

        script = Patchwork.init_script(Patchwork.ELKJs)
        @test occursin("ELK", script)
        @test occursin("layout", script)
    end

    @testset "Dashboard integration" begin
        graph = Patchwork.ELKJs(
            "Network Topology",
            Dict{String, Any}(
                "id" => "root",
                "layoutOptions" => Dict("elk.algorithm" => "layered", "elk.direction" => "DOWN"),
                "children" => [
                    Dict("id" => "server", "width" => 100, "height" => 50),
                    Dict("id" => "db", "width" => 100, "height" => 50),
                    Dict("id" => "cache", "width" => 100, "height" => 50),
                ],
                "edges" => [
                    Dict("id" => "e1", "sources" => ["server"], "targets" => ["db"]),
                    Dict("id" => "e2", "sources" => ["server"], "targets" => ["cache"]),
                ],
            ),
        )

        dashboard = Patchwork.Dashboard(
            "ELKJs Demo",
            [Patchwork.Tab("Graph", [graph])],
        )

        html = Patchwork.generate_html(dashboard)
        @test occursin("ELKJs Demo", html)
        @test occursin("Network Topology", html)
        @test occursin("elkjs", html)
    end
end

# Generate demo
graph1 = Patchwork.ELKJs(
    "Simple Flow",
    Dict{String, Any}(
        "id" => "root",
        "layoutOptions" => Dict("elk.algorithm" => "layered", "elk.direction" => "RIGHT"),
        "children" => [
            Dict("id" => "Start", "width" => 80, "height" => 40),
            Dict("id" => "Process", "width" => 80, "height" => 40),
            Dict("id" => "End", "width" => 80, "height" => 40),
        ],
        "edges" => [
            Dict("id" => "e1", "sources" => ["Start"], "targets" => ["Process"]),
            Dict("id" => "e2", "sources" => ["Process"], "targets" => ["End"]),
        ],
    ),
)

graph2 = Patchwork.ELKJs(
    "Multi-Level Hierarchy",
    Dict{String, Any}(
        "id" => "root",
        "layoutOptions" => Dict("elk.algorithm" => "layered", "elk.direction" => "DOWN"),
        "children" => [
            Dict("id" => "A", "width" => 60, "height" => 40),
            Dict("id" => "B", "width" => 60, "height" => 40),
            Dict("id" => "C", "width" => 60, "height" => 40),
            Dict("id" => "D", "width" => 60, "height" => 40),
            Dict("id" => "E", "width" => 60, "height" => 40),
            Dict("id" => "F", "width" => 60, "height" => 40),
        ],
        "edges" => [
            Dict("id" => "e1", "sources" => ["A"], "targets" => ["B"]),
            Dict("id" => "e2", "sources" => ["A"], "targets" => ["C"]),
            Dict("id" => "e3", "sources" => ["B"], "targets" => ["D"]),
            Dict("id" => "e4", "sources" => ["C"], "targets" => ["E"]),
            Dict("id" => "e5", "sources" => ["C"], "targets" => ["F"]),
        ],
    ),
)

dashboard = Patchwork.Dashboard(
    "ELKJs Demo",
    [
        Patchwork.Tab("Simple", [graph1]),
        Patchwork.Tab("Hierarchy", [graph2]),
    ],
)

output_dir = joinpath(@__DIR__, "output")
mkpath(output_dir)
Patchwork.save(dashboard, joinpath(output_dir, "test_elkjs.html"))

end
