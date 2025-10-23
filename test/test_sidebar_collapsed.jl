module TestSidebarCollapsed

using Patchwork

# Test with sidebar initially collapsed
dashboard_collapsed = Patchwork.Dashboard(
    "Test Collapsed Sidebar",
    [
        Patchwork.Tab(
            "Tab 1",
            [
                Patchwork.Markdown("# Sidebar starts collapsed"),
            ],
        ),
        Patchwork.Tab(
            "Tab 2",
            [
                Patchwork.Markdown("## Another tab"),
            ],
        ),
    ],
    sidebar_open = false
)

output_collapsed = joinpath(@__DIR__, "output", "test_sidebar_collapsed.html")
save(dashboard_collapsed, output_collapsed)
println("Generated: $output_collapsed (sidebar_open = false)")

# Test with sidebar initially expanded (default)
dashboard_expanded = Patchwork.Dashboard(
    "Test Expanded Sidebar",
    [
        Patchwork.Tab(
            "Tab 1",
            [
                Patchwork.Markdown("# Sidebar starts expanded (default)"),
            ],
        ),
    ],
)

output_expanded = joinpath(@__DIR__, "output", "test_sidebar_expanded.html")
save(dashboard_expanded, output_expanded)
println("Generated: $output_expanded (sidebar_open = true, default)")

end
