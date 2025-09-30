using Rhinestone

# Example: Dashboard with custom chart rendering (no external library)

# Define chart placeholders
tabs = [
    Tab(
        "Simple Charts",
        [
            ChartPlaceholder("progress-chart", "Progress Indicator",
                height = "12rem",
                metadata = Dict{String, Any}(
                    "type" => "progress",
                    "value" => 75,
                    "max" => 100,
                    "color" => "#3b82f6",
                ),
            ),
            ChartPlaceholder("metric-chart", "Key Metric",
                height = "12rem",
                metadata = Dict{String, Any}(
                    "type" => "metric",
                    "value" => 1234,
                    "label" => "Total Sales",
                    "change" => "+12.5%",
                ),
            ),
        ],
    ),
    Tab(
        "Data Tables",
        [
            ChartPlaceholder("table-chart", "Data Table",
                height = "auto",
                metadata = Dict{String, Any}(
                    "type" => "table",
                    "headers" => ["Name", "Value", "Status"],
                    "rows" => [
                        ["Item A", "100", "Active"],
                        ["Item B", "200", "Pending"],
                        ["Item C", "150", "Active"],
                    ],
                ),
            ),
        ],
    ),
]

# Custom chart rendering without external libraries
chart_init_script = """
function initializeChart(chartId, metadata) {
    const container = document.getElementById(chartId);

    switch(metadata.type) {
        case 'progress':
            renderProgressChart(container, metadata);
            break;
        case 'metric':
            renderMetricChart(container, metadata);
            break;
        case 'table':
            renderTableChart(container, metadata);
            break;
        default:
            container.innerHTML = '<p class="text-gray-500">Unknown chart type</p>';
    }
}

function renderProgressChart(container, metadata) {
    const percentage = (metadata.value / metadata.max) * 100;

    container.innerHTML = `
        <div class="flex flex-col items-center justify-center h-full">
            <div class="text-6xl font-bold mb-4" style="color: \${metadata.color}">
                \${metadata.value}%
            </div>
            <div class="w-full bg-gray-200 rounded-full h-4 overflow-hidden">
                <div class="h-full rounded-full transition-all duration-500"
                     style="width: \${percentage}%; background-color: \${metadata.color}">
                </div>
            </div>
        </div>
    `;
}

function renderMetricChart(container, metadata) {
    const changeColor = metadata.change.startsWith('+') ? '#10b981' : '#ef4444';

    container.innerHTML = `
        <div class="flex flex-col items-center justify-center h-full">
            <div class="text-sm text-gray-600 mb-2">\${metadata.label}</div>
            <div class="text-5xl font-bold text-gray-900 mb-2">\${metadata.value.toLocaleString()}</div>
            <div class="text-lg font-semibold" style="color: \${changeColor}">
                \${metadata.change}
            </div>
        </div>
    `;
}

function renderTableChart(container, metadata) {
    let tableHTML = `
        <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                    <tr>
    `;

    metadata.headers.forEach(header => {
        tableHTML += `<th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">\${header}</th>`;
    });

    tableHTML += `
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
    `;

    metadata.rows.forEach(row => {
        tableHTML += '<tr>';
        row.forEach((cell, idx) => {
            if (idx === row.length - 1 && cell === 'Active') {
                tableHTML += `<td class="px-6 py-4 whitespace-nowrap"><span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">\${cell}</span></td>`;
            } else if (idx === row.length - 1 && cell === 'Pending') {
                tableHTML += `<td class="px-6 py-4 whitespace-nowrap"><span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800">\${cell}</span></td>`;
            } else {
                tableHTML += `<td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">\${cell}</td>`;
            }
        });
        tableHTML += '</tr>';
    });

    tableHTML += `
                </tbody>
            </table>
        </div>
    `;

    container.innerHTML = tableHTML;
}
"""

# Create dashboard configuration
config = DashboardConfig(
    "Custom Dashboard",
    tabs,
    chart_init_script = chart_init_script,
)

# Generate the dashboard
output_file = "dashboard_custom.html"
generate_dashboard(config, output_file)

println("Dashboard generated: \$output_file")
