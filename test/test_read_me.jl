module TestReadMe

using Test
using Patchwork

@testset "Read me" begin
    @testset "Example 1" begin
        dashboard = Patchwork.Dashboard(
            "My Dashboard",
            [
                Patchwork.Tab(
                    "Overview",
                    [
                        Patchwork.Markdown(
                            "# Welcome to Patchwork.jl\n" *
                            "This is a **simple** dashboard with:\n" *
                            "- Interactive tabs\n" *
                            "- Search functionality\n" *
                            "- Beautiful styling",
                        ),
                    ],
                ),
            ],
        )

        output_path = joinpath(@__DIR__, "output", "test_read_me_1.html")
        save(dashboard, output_path)
    end

    @testset "Example 2" begin
        dashboard = Patchwork.Dashboard(
            "Sales Analytics",
            [
                Patchwork.Tab(
                    "Monthly Revenue",
                    [
                        Patchwork.ChartJs(
                            "Revenue by Month",
                            "bar",
                            Dict{String, Any}(
                                "labels" => ["Jan", "Feb", "Mar", "Apr"],
                                "datasets" => [
                                    Dict{String, Any}(
                                        "label" => "2024",
                                        "data" => [12, 19, 8, 15],
                                        "backgroundColor" => "rgba(54, 162, 235, 0.5)",
                                    ),
                                ],
                            ),
                        ),
                    ],
                ),
            ],
        )

        output_path = joinpath(@__DIR__, "output", "test_read_me_2.html")
        save(dashboard, output_path)
    end
end

end
