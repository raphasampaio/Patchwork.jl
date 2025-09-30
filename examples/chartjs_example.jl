using Rhinestone

# Example: Dashboard with Chart.js

# Define chart placeholders with metadata for Chart.js
tabs = [
    Tab(
        "Performance Metrics",
        [
            ChartPlaceholder("cpu-chart", "CPU Usage Over Time",
                metadata = Dict{String, Any}(
                    "type" => "line",
                    "data" => Dict(
                        "labels" => ["00:00", "01:00", "02:00", "03:00", "04:00"],
                        "datasets" => [Dict(
                            "label" => "CPU %",
                            "data" => [45.2, 52.1, 38.7, 61.3, 42.9],
                        )],
                    ),
                ),
            ),
            ChartPlaceholder("memory-chart", "Memory Usage by Process",
                metadata = Dict{String, Any}(
                    "type" => "bar",
                    "data" => Dict(
                        "labels" => ["Process A", "Process B", "Process C", "Process D"],
                        "datasets" => [Dict(
                            "label" => "Memory (MB)",
                            "data" => [256.0, 512.0, 128.0, 1024.0],
                        )],
                    ),
                ),
            ),
        ],
    ),
    Tab(
        "System Analysis",
        [
            ChartPlaceholder("disk-chart", "Disk Space Distribution",
                metadata = Dict{String, Any}(
                    "type" => "pie",
                    "data" => Dict(
                        "labels" => ["OS", "Applications", "Documents", "Media", "Other"],
                        "datasets" => [Dict(
                            "data" => [25.0, 35.0, 15.0, 20.0, 5.0],
                        )],
                    ),
                ),
            ),
        ],
    ),
]

# Chart.js initialization script
chart_init_script = """
// Chart.js must be loaded via CDN
const chartInstances = {};

function initializeChart(chartId, metadata) {
    const canvas = document.createElement('canvas');
    canvas.width = 400;
    canvas.height = 300;

    const container = document.getElementById(chartId);
    container.appendChild(canvas);

    const ctx = canvas.getContext('2d');

    // Default colors
    const colors = [
        'rgba(59, 130, 246, 0.8)',
        'rgba(16, 185, 129, 0.8)',
        'rgba(245, 158, 11, 0.8)',
        'rgba(239, 68, 68, 0.8)',
        'rgba(139, 92, 246, 0.8)'
    ];

    const borderColors = [
        'rgba(59, 130, 246, 1)',
        'rgba(16, 185, 129, 1)',
        'rgba(245, 158, 11, 1)',
        'rgba(239, 68, 68, 1)',
        'rgba(139, 92, 246, 1)'
    ];

    // Apply colors to datasets
    if (metadata.data && metadata.data.datasets) {
        metadata.data.datasets.forEach((dataset, idx) => {
            if (metadata.type === 'pie' || metadata.type === 'doughnut') {
                dataset.backgroundColor = colors;
                dataset.borderColor = borderColors;
            } else {
                dataset.backgroundColor = colors[idx % colors.length];
                dataset.borderColor = borderColors[idx % borderColors.length];
                dataset.borderWidth = 2;
            }
        });
    }

    // Chart configuration
    const config = {
        type: metadata.type,
        data: metadata.data,
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: true,
                    position: 'bottom'
                }
            }
        }
    };

    // Add scales for non-pie charts
    if (metadata.type !== 'pie' && metadata.type !== 'doughnut') {
        config.options.scales = {
            y: {
                beginAtZero: true
            }
        };
    }

    chartInstances[chartId] = new Chart(ctx, config);
}
"""

# Custom CSS
custom_css = """
.chart-container canvas {
    max-width: 100%;
    max-height: 100%;
}
"""

# Create dashboard configuration
config = DashboardConfig(
    "Performance Dashboard",
    tabs,
    custom_css = custom_css,
    chart_init_script = chart_init_script,
    cdn_urls = Dict(
        "chartjs" => "https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js",
    ),
)

# Generate the dashboard
output_file = "dashboard_chartjs.html"
generate_dashboard(config, output_file)

println("Dashboard generated: \$output_file")
