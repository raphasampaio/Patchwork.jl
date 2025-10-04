module DataTablesPlugin

import ..Plugin, ..to_html, ..css_deps, ..js_deps, ..init_script
export DataTables

@doc """
    DataTables(title::String, data::Vector{Vector{Any}}, columns::Vector{String})

Interactive table with sorting, searching, and pagination using DataTables.

# Fields
- `title::String`: Table title
- `data::Vector{Vector{Any}}`: Table data as rows
- `columns::Vector{String}`: Column headers

# Examples
```julia
using Patchwork

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

dashboard = Patchwork.Dashboard("Dashboard", [Patchwork.Tab("Data", [table])])
save(dashboard, "output.html")
```
"""
struct DataTables <: Plugin
    title::String
    data::Vector{Vector{Any}}
    columns::Vector{String}
end

function to_html(plugin::DataTables)
    headers = join(["<th>$(col)</th>" for col in plugin.columns], "")
    rows = join([
            "<tr>" * join(["<td>$(cell)</td>" for cell in row], "") * "</tr>"
            for row in plugin.data
        ], "")

    return """
    <div>
        <h3 class="text-lg font-semibold mb-4">$(plugin.title)</h3>
        <table class="datatable display" style="width:100%">
            <thead><tr>$headers</tr></thead>
            <tbody>$rows</tbody>
        </table>
    </div>
    """
end

css_deps(::Type{DataTables}) = [
    "https://cdn.datatables.net/2.3.0/css/dataTables.dataTables.min.css",
]

js_deps(::Type{DataTables}) = [
    "https://code.jquery.com/jquery-3.7.1.min.js",
    "https://cdn.datatables.net/2.3.0/js/dataTables.min.js",
]

init_script(::Type{DataTables}) = """
    document.querySelectorAll('.datatable').forEach(table => {
        new DataTable(table);
    });
"""

end
