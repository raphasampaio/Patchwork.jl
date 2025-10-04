module TestDataTables

using Test
using Patchwork

@testset "DataTables Plugin" begin
    @testset "Basic table" begin
        table = Patchwork.DataTables(
            "Sales Data",
            [
                ["Q1", 100, 150],
                ["Q2", 120, 160],
                ["Q3", 140, 180],
                ["Q4", 130, 170],
            ],
            ["Period", "Product A", "Product B"],
        )

        @test table isa Patchwork.Plugin
        @test table.title == "Sales Data"
        @test length(table.data) == 4
        @test length(table.columns) == 3

        html = Patchwork.to_html(table)
        @test occursin("Sales Data", html)
        @test occursin("datatable", html)
        @test occursin("Period", html)
        @test occursin("Product A", html)
    end

    @testset "Dependencies" begin
        css = Patchwork.css_deps(Patchwork.DataTables)
        @test length(css) == 1
        @test occursin("datatables.net", css[1])
        @test occursin("2.3.0", css[1])

        js = Patchwork.js_deps(Patchwork.DataTables)
        @test length(js) == 2
        @test occursin("jquery", js[1])
        @test occursin("datatables", js[2])

        script = Patchwork.init_script(Patchwork.DataTables)
        @test occursin("DataTable", script)
    end

    @testset "Dashboard integration" begin
        table = Patchwork.DataTables(
            "Employee List",
            [
                ["John", "Engineering", 75000],
                ["Jane", "Marketing", 68000],
                ["Bob", "Sales", 72000],
            ],
            ["Name", "Department", "Salary"],
        )

        dashboard = Patchwork.Dashboard(
            "DataTables Demo",
            [Patchwork.Tab("Data", [table])],
        )

        html = Patchwork.generate_html(dashboard)
        @test occursin("DataTables Demo", html)
        @test occursin("Employee List", html)
        @test occursin("datatables.net", html)
    end
end

# Generate demo
table1 = Patchwork.DataTables(
    "Quarterly Sales",
    [
        ["Q1 2024", 125000, 98000, 145000],
        ["Q2 2024", 135000, 102000, 156000],
        ["Q3 2024", 148000, 115000, 167000],
        ["Q4 2024", 162000, 128000, 189000],
    ],
    ["Period", "Product A", "Product B", "Product C"],
)

table2 = Patchwork.DataTables(
    "Team Members",
    [
        ["Alice Johnson", "Engineering", "Senior Developer", "2019-03-15"],
        ["Bob Smith", "Marketing", "Marketing Manager", "2020-07-01"],
        ["Carol White", "Sales", "Sales Director", "2018-11-20"],
        ["David Brown", "Engineering", "Team Lead", "2021-01-10"],
        ["Eve Davis", "HR", "HR Manager", "2019-09-05"],
    ],
    ["Name", "Department", "Role", "Start Date"],
)

dashboard = Patchwork.Dashboard(
    "DataTables Demo",
    [
        Patchwork.Tab("Sales", [table1]),
        Patchwork.Tab("Team", [table2]),
    ],
)

output_dir = joinpath(@__DIR__, "output")
mkpath(output_dir)
Patchwork.save(dashboard, joinpath(output_dir, "test_datatables.html"))

end
