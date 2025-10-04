# Built-in Plugins

Patchwork includes six built-in plugins for common dashboard components.

## Markdown

Render markdown with syntax highlighting for code blocks.

```julia
Patchwork.Markdown(content::String)
```

**Example:**

```julia
Patchwork.Markdown("""
# Title

**Bold text** and *italic text*

- List item 1
- List item 2

```julia
println("Code with syntax highlighting")
```
""")
```

The Markdown plugin uses Julia's built-in Markdown parser and includes Highlight.js for code syntax highlighting (Julia, Lua, and many other languages supported).

## Chart.js

Create interactive charts using Chart.js. Always use `Dict{String,Any}` for type safety.

```julia
Patchwork.ChartJs(
    title::String,
    chart_type::String,
    data::Dict{String,Any};
    options::Dict{String,Any} = Dict{String,Any}()
)
```

**Supported chart types:** `line`, `bar`, `radar`, `doughnut`, `pie`, `polarArea`, `bubble`, `scatter`

### Example: Bar Chart

```julia
Patchwork.ChartJs(
    "Sales by Quarter",
    "bar",
    Dict{String,Any}(
        "labels" => ["Q1", "Q2", "Q3", "Q4"],
        "datasets" => [
            Dict{String,Any}(
                "label" => "2024",
                "data" => [12, 19, 8, 15],
                "backgroundColor" => "rgba(54, 162, 235, 0.5)",
            ),
        ],
    ),
)
```

### Example: Doughnut Chart

```julia
Patchwork.ChartJs(
    "Traffic Sources",
    "doughnut",
    Dict{String,Any}(
        "labels" => ["Direct", "Social", "Organic", "Referral"],
        "datasets" => [
            Dict{String,Any}(
                "data" => [300, 150, 200, 100],
                "backgroundColor" => ["#FF6384", "#36A2EB", "#FFCE56", "#4BC0C0"],
            ),
        ],
    ),
)
```

### Example: Line Chart with Options

```julia
Patchwork.ChartJs(
    "Time Series",
    "line",
    Dict{String,Any}(
        "labels" => ["Jan", "Feb", "Mar"],
        "datasets" => [
            Dict{String,Any}(
                "label" => "Sales",
                "data" => [65, 59, 80],
                "borderColor" => "rgb(75, 192, 192)",
            ),
        ],
    ),
    options = Dict{String,Any}(
        "plugins" => Dict(
            "legend" => Dict("position" => "top"),
        ),
    ),
)
```

## Highcharts

Create Highcharts visualizations.

```julia
Patchwork.Highcharts(
    title::String,
    config::Dict{String,Any}
)
```

### Example: Line Chart

```julia
Patchwork.Highcharts(
    "Monthly Performance",
    Dict{String,Any}(
        "chart" => Dict("type" => "line"),
        "xAxis" => Dict("categories" => ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]),
        "yAxis" => Dict("title" => Dict("text" => "Value")),
        "series" => [
            Dict("name" => "Series A", "data" => [29, 71, 106, 129, 144, 176]),
            Dict("name" => "Series B", "data" => [50, 80, 95, 110, 130, 150]),
        ],
    ),
)
```

### Example: Column Chart

```julia
Patchwork.Highcharts(
    "Distribution",
    Dict{String,Any}(
        "chart" => Dict("type" => "column"),
        "xAxis" => Dict("categories" => ["Alpha", "Beta", "Gamma", "Delta"]),
        "series" => [
            Dict("name" => "Values", "data" => [5, 3, 4, 7]),
        ],
    ),
)
```

### Example: Area Chart

```julia
Patchwork.Highcharts(
    "Area Trend",
    Dict{String,Any}(
        "chart" => Dict("type" => "area"),
        "title" => Dict("text" => ""),
        "series" => [
            Dict("name" => "Data", "data" => [1, 3, 2, 4, 3, 5, 4]),
        ],
    ),
)
```

## Plotly

Create Plotly charts with support for 3D plots, maps, and scientific visualizations.

```julia
Patchwork.Plotly(
    title::String,
    data::Vector{Dict{String,Any}};
    layout::Dict{String,Any} = Dict{String,Any}(),
    config::Dict{String,Any} = Dict{String,Any}()
)
```

### Example: Scatter Plot

```julia
Patchwork.Plotly(
    "Scatter Analysis",
    [
        Dict{String,Any}(
            "x" => [1, 2, 3, 4, 5, 6],
            "y" => [1, 4, 9, 16, 25, 36],
            "mode" => "markers+lines",
            "type" => "scatter",
            "name" => "Quadratic",
        ),
    ],
    layout = Dict{String,Any}(
        "xaxis" => Dict("title" => "X"),
        "yaxis" => Dict("title" => "Y²"),
    ),
)
```

### Example: 3D Surface

```julia
Patchwork.Plotly(
    "3D Surface",
    [
        Dict{String,Any}(
            "z" => [[1, 2, 3], [2, 3, 4], [3, 4, 5]],
            "type" => "surface",
        ),
    ],
    layout = Dict{String,Any}("title" => "3D Surface Plot"),
)
```

### Example: Scattermap

```julia
Patchwork.Plotly(
    "US Cities",
    [
        Dict{String,Any}(
            "type" => "scattermapbox",
            "lat" => [40.7128, 34.0522, 41.8781],
            "lon" => [-74.0060, -118.2437, -87.6298],
            "mode" => "markers",
            "marker" => Dict("size" => 14),
            "text" => ["New York", "Los Angeles", "Chicago"],
        ),
    ],
    layout = Dict{String,Any}(
        "mapbox" => Dict(
            "style" => "open-street-map",
            "center" => Dict("lat" => 37.0902, "lon" => -95.7129),
            "zoom" => 3,
        ),
    ),
)
```

## Leaflet

Create interactive maps with markers and popups.

```julia
Patchwork.Leaflet(
    title::String,
    center::Tuple{Float64,Float64};
    zoom::Int = 13,
    markers::Vector{Dict{String,Any}} = Dict{String,Any}[],
    options::Dict{String,Any} = Dict{String,Any}()
)
```

### Example: Simple Map

```julia
Patchwork.Leaflet(
    "New York City",
    (40.7128, -74.0060),
    zoom = 12,
)
```

### Example: Map with Markers

```julia
Patchwork.Leaflet(
    "Major US Cities",
    (39.8283, -98.5795),
    zoom = 4,
    markers = [
        Dict{String,Any}(
            "lat" => 40.7128,
            "lng" => -74.0060,
            "popup" => "<b>New York</b><br>Population: 8.3M",
        ),
        Dict{String,Any}(
            "lat" => 34.0522,
            "lng" => -118.2437,
            "popup" => "<b>Los Angeles</b><br>Population: 4.0M",
        ),
        Dict{String,Any}(
            "lat" => 41.8781,
            "lng" => -87.6298,
            "popup" => "<b>Chicago</b><br>Population: 2.7M",
        ),
    ],
)
```

### Example: Custom Options

```julia
Patchwork.Leaflet(
    "Custom Map",
    (51.505, -0.09),
    zoom = 13,
    options = Dict{String,Any}(
        "scrollWheelZoom" => false,
    ),
)
```

## Mermaid

Create diagrams using Mermaid syntax.

```julia
Patchwork.Mermaid(
    title::String,
    diagram::String;
    theme::String = "default"
)
```

**Supported diagram types:** flowcharts, sequence diagrams, class diagrams, state diagrams, ER diagrams, Gantt charts, and more.

### Example: Flowchart

```julia
Patchwork.Mermaid(
    "System Architecture",
    """
    graph TD
        A[Client] --> B[Load Balancer]
        B --> C[Server 1]
        B --> D[Server 2]
    """,
)
```

### Example: Sequence Diagram

```julia
Patchwork.Mermaid(
    "Authentication Flow",
    """
    sequenceDiagram
        participant U as User
        participant A as App
        participant S as Server
        U->>A: Login
        A->>S: Authenticate
        S-->>A: Token
        A-->>U: Success
    """,
)
```

### Example: Class Diagram

```julia
Patchwork.Mermaid(
    "Data Model",
    """
    classDiagram
        class User {
            +String name
            +String email
            +login()
        }
        class Order {
            +Date created
            +Float total
            +process()
        }
        User "1" --> "*" Order
    """,
)
```

### Example: Gantt Chart

```julia
Patchwork.Mermaid(
    "Project Timeline",
    """
    gantt
        title Project Schedule
        dateFormat  YYYY-MM-DD
        section Phase 1
        Design           :a1, 2024-01-01, 30d
        Development      :a2, after a1, 45d
        section Phase 2
        Testing          :a3, after a2, 20d
        Deployment       :a4, after a3, 10d
    """,
)
```

## HTML

Include raw HTML content with access to Tailwind CSS classes.

```julia
Patchwork.HTML(content::String)
```

### Example: Custom Component

```julia
Patchwork.HTML("""
<div class="p-6 bg-gradient-to-r from-blue-500 to-purple-600 rounded-lg shadow-xl">
    <h2 class="text-2xl font-bold text-white mb-2">Custom Component</h2>
    <p class="text-blue-100">Styled with Tailwind CSS</p>
</div>
""")
```

### Example: Alert Box

```julia
Patchwork.HTML("""
<div class="bg-yellow-50 border-l-4 border-yellow-400 p-4">
    <div class="flex">
        <div class="flex-shrink-0">
            <svg class="h-5 w-5 text-yellow-400" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
            </svg>
        </div>
        <div class="ml-3">
            <p class="text-sm text-yellow-700">
                <strong>Warning:</strong> This action cannot be undone.
            </p>
        </div>
    </div>
</div>
""")
```

### Example: Data Grid

```julia
Patchwork.HTML("""
<div class="overflow-x-auto">
    <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
            <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Role</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
            </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
            <tr>
                <td class="px-6 py-4 whitespace-nowrap">John Doe</td>
                <td class="px-6 py-4 whitespace-nowrap">Admin</td>
                <td class="px-6 py-4 whitespace-nowrap">
                    <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">Active</span>
                </td>
            </tr>
        </tbody>
    </table>
</div>
""")
```

## Mixing Plugins

Combine different plugins in a single tab:

```julia
Patchwork.Tab(
    "Analysis",
    [
        Patchwork.Markdown("## Sales Analysis"),
        Patchwork.ChartJs("Revenue", "bar", ...),
        Patchwork.Markdown("## Geographic Distribution"),
        Patchwork.Leaflet("Locations", ...),
        Patchwork.Markdown("## System Architecture"),
        Patchwork.Mermaid("Flow", ...),
    ],
)
```

## Type Safety

Always use `Dict{String,Any}` for chart configurations to avoid type inference issues:

```julia
# ✓ Correct
Dict{String,Any}("labels" => [...], "datasets" => [...])

# ✗ Wrong - may cause type errors
Dict("labels" => [...], "datasets" => [...])
```
