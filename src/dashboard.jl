@doc """
    Dashboard(title::String, tabs::Vector{Tab}; custom_css::String = "")

Main dashboard type containing all content to be rendered.

A dashboard generates a self-contained HTML file with Vue.js reactivity, Tailwind CSS styling,
and a responsive tabbed interface. It automatically collects and includes all necessary
dependencies from the plugins used.

# Fields
- `title::String`: Dashboard title displayed in the header and browser tab
- `tabs::Vector{Tab}`: Vector of tabs to display in the sidebar
- `custom_css::String`: Optional custom CSS styles to apply globally

# Example
```julia
dashboard = Patchwork.Dashboard(
    "Analytics Dashboard",
    [
        Patchwork.Tab("Overview", [...]),
        Patchwork.Tab("Details", [...]),
    ],
    custom_css = \"\"\"
    .custom-header {
        background: linear-gradient(to right, #667eea, #764ba2);
    }
    \"\"\"
)
```

See also: [`Tab`](@ref), [`save`](@ref), [`generate_html`](@ref)
"""
struct Dashboard
    title::String
    tabs::Vector{Tab}
    custom_css::String

    function Dashboard(title::String, tabs::Vector{Tab}; custom_css::String = "")
        return new(title, tabs, custom_css)
    end
end

@doc """
    save(dashboard::Dashboard, path::String) -> String

Generate complete HTML and save to file.

This function generates a self-contained HTML file from the dashboard and writes it to
the specified path. The generated file includes all necessary CSS and JavaScript dependencies,
plugin content, and initialization code.

# Arguments
- `dashboard::Dashboard`: Dashboard to save
- `path::String`: Output file path (absolute or relative)

# Returns
- `String`: Path to the saved file

# Example
```julia
dashboard = Patchwork.Dashboard("Title", tabs)
save(dashboard, "output.html")
save(dashboard, "/path/to/dashboard.html")
```

See also: [`Dashboard`](@ref), [`generate_html`](@ref)
"""
function save(dashboard::Dashboard, path::String)
    html = generate_html(dashboard)
    write(path, html)
    return path
end

@doc """
    generate_html(dashboard::Dashboard) -> String

Generate complete HTML string for dashboard.

This function generates a self-contained HTML document from the dashboard. It collects
all unique plugin types, gathers their dependencies, and creates a Vue.js-powered
single-page application with reactive tab switching and search functionality.

The generation process:
1. Collects unique plugin types from all tabs
2. Gathers CSS dependencies (CDN URLs) from plugin types
3. Gathers JavaScript dependencies (CDN URLs) from plugin types
4. Gathers initialization scripts from plugin types
5. Gathers custom CSS from plugin types
6. Generates unique IDs for each plugin instance
7. Converts plugins to HTML using `to_html`
8. Embeds all data as JSON in Vue.js application
9. Creates responsive UI with sidebar, search, and mobile support

# Arguments
- `dashboard::Dashboard`: Dashboard to generate HTML for

# Returns
- `String`: Complete HTML document as a string

# Example
```julia
dashboard = Patchwork.Dashboard("Title", tabs)
html = generate_html(dashboard)
write("output.html", html)
```

See also: [`Dashboard`](@ref), [`save`](@ref)
"""
function generate_html(dashboard::Dashboard)
    all_types = unique([typeof(plugin) for tab in dashboard.tabs for plugin in tab.plugins])

    css_urls = String[]
    for type in all_types
        for url in css_deps(type)
            push!(css_urls, "    <link rel=\"stylesheet\" href=\"$url\">")
        end
    end

    js_urls = String[]
    for type in all_types
        for url in js_deps(type)
            push!(js_urls, "    <script src=\"$url\"></script>")
        end
    end

    init_scripts = String[]
    for type in all_types
        script = init_script(type)
        if !isempty(script)
            push!(init_scripts, script)
        end
    end

    css_blocks = String[]
    for type in all_types
        css_content = css(type)
        if !isempty(css_content)
            push!(css_blocks, css_content)
        end
    end

    tabs_data = Dict{String, Any}[]
    for tab in dashboard.tabs
        plugins_data = Dict{String, Any}[]
        for plugin in tab.plugins
            plugin_id = "plugin-$(uuid4())"
            plugin_html = to_html(plugin)
            plugin_type = get_plugin_type(plugin)
            push!(plugins_data, Dict(
                "id" => plugin_id,
                "type" => plugin_type,
                "html" => plugin_html,
            ))
        end
        push!(tabs_data, Dict("label" => tab.label, "plugins" => plugins_data))
    end

    tabs_json = JSON.json(tabs_data)
    combined_init = join(init_scripts, "\n")
    all_css = join(css_blocks, "\n\n")

    return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$(escape_html(dashboard.title))</title>
    <script src="https://cdn.jsdelivr.net/npm/vue@3.5.12/dist/vue.global.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
$(join(css_urls, "\n"))
$(join(js_urls, "\n"))
</head>
<body class="bg-white">
    <div id="app" class="flex h-screen">
        <div v-if="sidebarOpen" @click="sidebarOpen = false" class="fixed inset-0 z-20 bg-black/20 lg:hidden"></div>

        <div :class="['bg-white border-r border-gray-100 w-64 flex flex-col transition-transform lg:translate-x-0', sidebarOpen ? 'translate-x-0 fixed inset-y-0 left-0 z-30' : '-translate-x-full fixed inset-y-0 left-0 z-30 lg:relative lg:translate-x-0']">
            <div class="px-8 py-6">
                <h1 class="text-lg font-medium text-gray-900 tracking-tight">$(escape_html(dashboard.title))</h1>
            </div>

            <div class="px-6 pb-4">
                <div class="relative">
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <svg class="h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                        </svg>
                    </div>
                    <input v-model="searchQuery" type="text" class="w-full pl-10 pr-8 py-2 text-sm border border-gray-200 rounded focus:outline-none focus:border-gray-400 transition-colors" placeholder="Search...">
                    <div v-if="searchQuery" @click="searchQuery = ''" class="absolute right-2 top-2 cursor-pointer text-gray-400 hover:text-gray-600 text-lg leading-none">×</div>
                </div>
            </div>

            <nav class="flex-1 overflow-y-auto px-4 space-y-1">
                <button v-for="(tab, i) in tabs" :key="i" @click="activeTab = i; sidebarOpen = false" :class="['w-full text-left text-sm px-4 py-2.5 rounded transition-colors flex items-center justify-between', activeTab === i ? 'bg-gray-900 text-white' : 'text-gray-600 hover:text-gray-900 hover:bg-gray-50']">
                    <span>{{ tab.label }}</span>
                    <span v-if="searchQuery && visibleCount(i) > 0" :class="['px-2 py-0.5 rounded-full text-xs font-medium', activeTab === i ? 'bg-white/20 text-white' : 'bg-blue-500 text-white']">
                        {{ visibleCount(i) }}
                    </span>
                </button>
            </nav>
        </div>

        <div class="flex-1 flex flex-col overflow-hidden bg-gray-50">
            <div class="bg-white border-b border-gray-100 px-8 py-3 flex plugins-center">
                <button @click="sidebarOpen = !sidebarOpen" class="lg:hidden mr-4 p-1.5 rounded hover:bg-gray-100 transition-colors">
                    <svg class="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
                    </svg>
                </button>
                <h2 class="text-sm font-medium text-gray-900">{{ tabs[activeTab]?.label }}</h2>
            </div>

            <div class="flex-1 overflow-y-auto px-8 py-6">
                <div v-for="(tab, tabIdx) in tabs" :key="tabIdx" v-show="activeTab === tabIdx" class="max-w-4xl mx-auto space-y-8">
                    <div v-for="plugin in tab.plugins" :key="plugin.id" v-show="isVisible(plugin)" class="bg-white border border-gray-100 rounded-lg p-8 shadow-sm hover:shadow-md transition-shadow" :class="{'highlight-content': searchQuery}" v-html="plugin.html"></div>
                    <div v-if="searchQuery && visibleCount(tabIdx) === 0" class="text-center py-16">
                        <div class="w-16 h-16 mx-auto mb-4 bg-gray-100 rounded-full flex items-center justify-center">
                            <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                            </svg>
                        </div>
                        <h3 class="text-base font-medium text-gray-900 mb-2">No results found</h3>
                        <p class="text-sm text-gray-500">No content matches your search query "{{ searchQuery }}"</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <style>
        $all_css
        $(dashboard.custom_css)
    </style>

    <script>
        const { createApp } = Vue;

        createApp({
            data() {
                return {
                    activeTab: 0,
                    searchQuery: '',
                    sidebarOpen: false,
                    tabs: $tabs_json
                }
            },
            mounted() {
                this.\$nextTick(() => {
                    this.initializeContent();
                });
            },
            watch: {
                searchQuery() {
                    this.\$nextTick(() => {
                        this.highlightContent();
                    });
                }
            },
            methods: {
                initializeContent() {
                    $combined_init
                },
                isVisible(plugin) {
                    if (!this.searchQuery) return true;
                    const query = this.searchQuery.toLowerCase();
                    return plugin.html.toLowerCase().includes(query);
                },
                visibleCount(tabIdx) {
                    return this.tabs[tabIdx].plugins.filter(plugin => this.isVisible(plugin)).length;
                },
                highlightContent() {
                    document.querySelectorAll('.highlight-match').forEach(el => {
                        const parent = el.parentNode;
                        parent.replaceChild(document.createTextNode(el.textContent), el);
                        parent.normalize();
                    });

                    if (!this.searchQuery) return;

                    const query = this.searchQuery.toLowerCase();
                    document.querySelectorAll('.highlight-content').forEach(container => {
                        const textElements = container.querySelectorAll('h3, p, span, div, td, th, li');

                        textElements.forEach(el => {
                            if (el.querySelector('canvas, svg, .highlight-match')) return;
                            if (el.classList.contains('highlight-match')) return;

                            const walk = document.createTreeWalker(el, NodeFilter.SHOW_TEXT, {
                                acceptNode: function(node) {
                                    if (node.parentElement.closest('canvas, svg')) {
                                        return NodeFilter.FILTER_REJECT;
                                    }
                                    return NodeFilter.FILTER_ACCEPT;
                                }
                            }, false);

                            const nodesToReplace = [];
                            while (walk.nextNode()) {
                                const node = walk.currentNode;
                                if (node.textContent.toLowerCase().includes(query)) {
                                    nodesToReplace.push(node);
                                }
                            }

                            nodesToReplace.forEach(node => {
                                const text = node.textContent;
                                const lowerText = text.toLowerCase();
                                const fragments = [];
                                let lastIndex = 0;
                                let index = lowerText.indexOf(query);

                                while (index !== -1) {
                                    if (index > lastIndex) {
                                        fragments.push(document.createTextNode(text.substring(lastIndex, index)));
                                    }
                                    const span = document.createElement('span');
                                    span.className = 'highlight-match bg-yellow-200 text-yellow-800 px-1 rounded';
                                    span.textContent = text.substring(index, index + query.length);
                                    fragments.push(span);
                                    lastIndex = index + query.length;
                                    index = lowerText.indexOf(query, lastIndex);
                                }

                                if (lastIndex < text.length) {
                                    fragments.push(document.createTextNode(text.substring(lastIndex)));
                                }

                                const parent = node.parentNode;
                                fragments.forEach(frag => parent.insertBefore(frag, node));
                                parent.removeChild(node);
                            });
                        });
                    });
                }
            }
        }).mount('#app');
    </script>
</body>
</html>
"""
end
