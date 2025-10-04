@doc """
    Tab(label::String, plugins::Vector{Plugin})

Represents a tab in a Patchwork dashboard.

A tab contains a label that appears in the dashboard sidebar and a vector of plugins
that are displayed when the tab is selected.

# Fields
- `label::String`: Tab label displayed in the sidebar navigation
- `plugins::Vector{Plugin}`: Vector of plugins to render in the tab

# Example
```julia
tab = Patchwork.Tab(
    "Overview",
    [
        Patchwork.Markdown("# Welcome"),
        Patchwork.ChartJs("Sales", "bar", Dict{String,Any}(...)),
    ]
)
```

See also: [`Dashboard`](@ref), [`Plugin`](@ref)
"""
struct Tab
    label::String
    plugins::Vector{Plugin}
end
