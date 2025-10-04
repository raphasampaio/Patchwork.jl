# Creating Custom Plugins

Extend Patchwork with any JavaScript library by creating custom plugins. Plugins implement a simple interface with five functions (one required, four optional).

## Plugin Interface

```julia
# Required: Convert plugin to HTML
to_html(plugin::MyPlugin) -> String

# Optional: CSS dependencies (CDN URLs)
css_deps(::Type{MyPlugin}) -> Vector{String}

# Optional: JavaScript dependencies (CDN URLs)
js_deps(::Type{MyPlugin}) -> Vector{String}

# Optional: JavaScript initialization code
init_script(::Type{MyPlugin}) -> String

# Optional: Custom CSS styles
css(::Type{MyPlugin}) -> String
```

All functions except `to_html` have default implementations that return empty values.

## Basic Plugin Example

Here's a minimal plugin with just the required function:

```julia
module MyPluginModule

import ..Plugin, ..to_html
export MyPlugin

struct MyPlugin <: Plugin
    content::String
end

to_html(plugin::MyPlugin) = "<div class='my-plugin'>$(plugin.content)</div>"

end
```

## Complete Plugin Example: DataTables

This example shows how to integrate jQuery DataTables:

```julia
module DataTablesPlugin

import ..Plugin, ..to_html, ..css_deps, ..js_deps, ..init_script, ..css
using JSON
export DataTable

struct DataTable <: Plugin
    title::String
    data::Vector{Vector{Any}}
    columns::Vector{String}
end

function to_html(plugin::DataTable)
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

css_deps(::Type{DataTable}) = [
    "https://cdn.datatables.net/1.13.7/css/jquery.dataTables.min.css"
]

js_deps(::Type{DataTable}) = [
    "https://code.jquery.com/jquery-3.7.0.min.js",
    "https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"
]

init_script(::Type{DataTable}) = """
    document.querySelectorAll('.datatable').forEach(table => {
        $(table).DataTable();
    });
"""

css(::Type{DataTable}) = ""

end
```

## Integrating the Plugin

### Step 1: Add to Patchwork Module

Add your plugin to `src/Patchwork.jl`:

```julia
include("plugins/datatables.jl")
using .DataTablesPlugin
```

### Step 2: Use the Plugin

```julia
using Patchwork

dashboard = Patchwork.Dashboard(
    "Data Dashboard",
    [
        Patchwork.Tab(
            "Sales Data",
            [
                Patchwork.DataTable(
                    "Q1 Sales",
                    [
                        ["John", "Sales", 50000],
                        ["Jane", "Marketing", 60000],
                        ["Bob", "Engineering", 75000],
                    ],
                    ["Name", "Department", "Salary"]
                ),
            ],
        ),
    ],
)

save(dashboard, "data.html")
```

## Advanced Plugin Example: D3.js

Here's a more complex plugin using D3.js for custom visualizations:

```julia
module D3Plugin

import ..Plugin, ..to_html, ..js_deps, ..init_script
using UUIDs, JSON
export D3Chart

struct D3Chart <: Plugin
    title::String
    data::Vector{Dict{String,Any}}
    chart_type::String
end

function to_html(plugin::D3Chart)
    chart_id = "d3-$(uuid4())"
    data_json = JSON.json(plugin.data)

    return """
    <div>
        <h3 class="text-lg font-semibold mb-4">$(plugin.title)</h3>
        <div id="$chart_id" class="d3-chart"
             data-type="$(plugin.chart_type)"
             data-data='$data_json'
             style="width: 100%; height: 400px;">
        </div>
    </div>
    """
end

js_deps(::Type{D3Chart}) = [
    "https://d3js.org/d3.v7.min.js"
]

init_script(::Type{D3Chart}) = """
    document.querySelectorAll('.d3-chart').forEach(container => {
        const data = JSON.parse(container.getAttribute('data-data'));
        const type = container.getAttribute('data-type');
        const id = container.id;

        if (type === 'bar') {
            const margin = {top: 20, right: 20, bottom: 30, left: 40};
            const width = container.offsetWidth - margin.left - margin.right;
            const height = 400 - margin.top - margin.bottom;

            const svg = d3.select('#' + id)
                .append('svg')
                .attr('width', width + margin.left + margin.right)
                .attr('height', height + margin.top + margin.bottom)
                .append('g')
                .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

            const x = d3.scaleBand()
                .range([0, width])
                .padding(0.1);

            const y = d3.scaleLinear()
                .range([height, 0]);

            x.domain(data.map(d => d.label));
            y.domain([0, d3.max(data, d => d.value)]);

            svg.selectAll('.bar')
                .data(data)
                .enter().append('rect')
                .attr('class', 'bar')
                .attr('x', d => x(d.label))
                .attr('width', x.bandwidth())
                .attr('y', d => y(d.value))
                .attr('height', d => height - y(d.value))
                .attr('fill', 'steelblue');

            svg.append('g')
                .attr('transform', 'translate(0,' + height + ')')
                .call(d3.axisBottom(x));

            svg.append('g')
                .call(d3.axisLeft(y));
        }
    });
"""

end
```

Usage:

```julia
Patchwork.D3Chart(
    "Sales by Region",
    [
        Dict("label" => "East", "value" => 120),
        Dict("label" => "West", "value" => 180),
        Dict("label" => "North", "value" => 90),
        Dict("label" => "South", "value" => 150),
    ],
    "bar"
)
```

## Plugin with Configuration

Create plugins that accept configuration options:

```julia
module TimelinePlugin

import ..Plugin, ..to_html, ..css_deps, ..js_deps, ..init_script
using JSON, UUIDs
export Timeline

struct Timeline <: Plugin
    title::String
    events::Vector{Dict{String,Any}}
    theme::String
end

function Timeline(title::String, events::Vector{Dict{String,Any}}; theme::String = "default")
    return Timeline(title, events, theme)
end

function to_html(plugin::Timeline)
    timeline_id = "timeline-$(uuid4())"
    events_json = JSON.json(plugin.events)

    return """
    <div>
        <h3 class="text-lg font-semibold mb-4">$(plugin.title)</h3>
        <div id="$timeline_id"
             class="timeline-container"
             data-events='$events_json'
             data-theme="$(plugin.theme)">
        </div>
    </div>
    """
end

css_deps(::Type{Timeline}) = [
    "https://cdn.knightlab.com/libs/timeline3/latest/css/timeline.css"
]

js_deps(::Type{Timeline}) = [
    "https://cdn.knightlab.com/libs/timeline3/latest/js/timeline.js"
]

init_script(::Type{Timeline}) = """
    document.querySelectorAll('.timeline-container').forEach(container => {
        const events = JSON.parse(container.getAttribute('data-events'));
        const options = {
            initial_zoom: 2
        };
        new TL.Timeline(container.id, {events: events}, options);
    });
"""

end
```

## Best Practices

### 1. Use Unique CSS Classes

Always use unique class names to avoid conflicts:

```julia
# Good
to_html(plugin::MyPlugin) = "<div class='myplugin-container'>...</div>"

# Bad - generic name may conflict
to_html(plugin::MyPlugin) = "<div class='container'>...</div>"
```

### 2. Generate Unique IDs

Use UUIDs for unique element IDs:

```julia
using UUIDs

function to_html(plugin::MyPlugin)
    id = "myplugin-$(uuid4())"
    return "<div id='$id' class='myplugin'>...</div>"
end
```

### 3. Store Data in Attributes

Use `data-*` attributes to pass configuration to JavaScript:

```julia
function to_html(plugin::MyPlugin)
    config_json = JSON.json(plugin.config)
    return """
    <div class='myplugin' data-config='$config_json'>
        <!-- content -->
    </div>
    """
end
```

### 4. Query by Class in init_script

Use class selectors to initialize all plugin instances:

```julia
init_script(::Type{MyPlugin}) = """
    document.querySelectorAll('.myplugin').forEach(element => {
        const config = JSON.parse(element.getAttribute('data-config'));
        // Initialize plugin
    });
"""
```

### 5. Handle Visibility

Some libraries need special handling for hidden elements:

```julia
init_script(::Type{MyPlugin}) = """
    const initPlugin = () => {
        document.querySelectorAll('.myplugin').forEach(element => {
            if (element.offsetParent !== null && !element.classList.contains('initialized')) {
                // Initialize only if visible
                element.classList.add('initialized');
            }
        });
    };

    initPlugin();
    // Re-check periodically for newly visible elements
    setInterval(initPlugin, 100);
"""
```

### 6. Module Naming

Use different names for module and struct to avoid conflicts:

```julia
# Good
module MyPluginModule
export MyPlugin
struct MyPlugin <: Plugin
end

# Bad - naming conflict
module MyPlugin
struct MyPlugin <: Plugin
end
```

### 7. Error Handling

Add defensive checks in JavaScript:

```julia
init_script(::Type{MyPlugin}) = """
    document.querySelectorAll('.myplugin').forEach(element => {
        try {
            const config = JSON.parse(element.getAttribute('data-config') || '{}');
            // Initialize
        } catch (error) {
            console.error('MyPlugin initialization failed:', error);
        }
    });
"""
```

## Testing Custom Plugins

Create a test file for your plugin:

```julia
module TestMyPlugin

using Test
using Patchwork

@testset "MyPlugin" begin
    @testset "Constructor" begin
        plugin = Patchwork.MyPlugin("test content")
        @test plugin isa Patchwork.Plugin
        @test plugin.content == "test content"
    end

    @testset "HTML rendering" begin
        plugin = Patchwork.MyPlugin("test")
        html = to_html(plugin)
        @test occursin("myplugin", html)
        @test occursin("test", html)
    end

    @testset "Dependencies" begin
        @test !isempty(js_deps(Patchwork.MyPlugin))
        @test !isempty(css_deps(Patchwork.MyPlugin))
    end

    @testset "Dashboard integration" begin
        dashboard = Patchwork.Dashboard(
            "Test",
            [Patchwork.Tab("Tab", [Patchwork.MyPlugin("test")])],
        )
        output_path = joinpath(@__DIR__, "output", "test_myplugin.html")
        save(dashboard, output_path)
        @test isfile(output_path)
    end
end

end
```

## Publishing Plugins

To share your plugin with others:

1. **Separate Package**: Create a standalone Julia package
2. **Plugin Registry**: Submit to a plugin registry (if available)
3. **Documentation**: Include examples and API docs
4. **Testing**: Add comprehensive tests
5. **Versioning**: Follow semantic versioning

Example package structure:

```
MyPatchworkPlugin.jl/
├── src/
│   └── MyPatchworkPlugin.jl
├── test/
│   └── runtests.jl
├── Project.toml
└── README.md
```

`src/MyPatchworkPlugin.jl`:

```julia
module MyPatchworkPlugin

using Patchwork
import Patchwork: Plugin, to_html, css_deps, js_deps, init_script, css

export MyPlugin

struct MyPlugin <: Plugin
    content::String
end

# Implementation...

end
```

Usage in other projects:

```julia
using Patchwork
using MyPatchworkPlugin

dashboard = Patchwork.Dashboard(
    "Dashboard",
    [Patchwork.Tab("Tab", [MyPlugin("content")])],
)
```
