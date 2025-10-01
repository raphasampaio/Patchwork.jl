using Markdown
using JSON

"""
    generate_dashboard(config::DashboardConfig, output_path::String)

Generate a self-contained HTML dashboard file from the configuration.

# Examples

```julia
config = DashboardConfig("My Dashboard", [tab])
generate_dashboard(config, "dashboard.html")
```
"""
function generate_dashboard(config::DashboardConfig, output_path::String)
    # Validate configuration before generating
    validate_config(config)

    html = generate_html(config)
    write(output_path, html)
    return output_path
end

"""
    generate_html(config::DashboardConfig)

Generate the complete HTML string for the dashboard.
"""
function generate_html(config::DashboardConfig)
    tabs_json = generate_tabs_json(config.tabs)

    html = """
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$(escape_html(config.title))</title>
$(generate_cdn_scripts(config.cdn_urls))
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        'dashboard-blue': '#3b82f6',
                        'dashboard-gray': '#f8fafc',
                        'chart-border': '#e2e8f0'
                    }
                }
            }
        }
    </script>
</head>

<body class="bg-gray-50 min-h-screen">
    <div id="app" class="flex h-screen bg-gray-50">
        <!-- Mobile menu overlay -->
        <div v-if="sidebarOpen" @click="sidebarOpen = false"
            class="fixed inset-0 z-20 bg-black bg-opacity-50 lg:hidden"></div>

        <!-- Sidebar -->
        <div :class="[
            'bg-white border-r border-gray-200 flex flex-col transition-transform duration-300 ease-in-out',
            'w-80 lg:translate-x-0',
            sidebarOpen ? 'translate-x-0 fixed inset-y-0 left-0 z-30' : '-translate-x-full fixed inset-y-0 left-0 z-30 lg:relative lg:translate-x-0'
        ]">
            <!-- Header -->
            <div class="p-6 border-b border-gray-200">
                <h1 class="text-2xl font-bold text-gray-900 mb-2">$(escape_html(config.title))</h1>
            </div>

            <!-- Search Bar -->
            <div class="p-4 border-b border-gray-200">
                <div class="relative">
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <svg class="h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                        </svg>
                    </div>
                    <input v-model="searchQuery" type="text"
                        class="block w-full pl-9 pr-8 py-2 text-sm border border-gray-300 rounded-md placeholder-gray-500 focus:outline-none focus:ring-1 focus:ring-dashboard-blue focus:border-dashboard-blue"
                        placeholder="Search content...">
                    <div v-if="searchQuery" @click="searchQuery = ''"
                        class="absolute inset-y-0 right-0 pr-3 flex items-center cursor-pointer">
                        <svg class="h-4 w-4 text-gray-400 hover:text-gray-600" fill="none" stroke="currentColor"
                            viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M6 18L18 6M6 6l12 12"></path>
                        </svg>
                    </div>
                </div>
            </div>

            <!-- Navigation -->
            <nav class="flex-1 overflow-y-auto p-4">
                <div class="space-y-2">
                    <button v-for="(tab, index) in tabs" :key="index" @click="activeTab = index" :class="[
                                'w-full text-left px-4 py-3 rounded-lg transition-all duration-200 flex items-center justify-between group',
                                activeTab === index
                                    ? 'bg-dashboard-blue text-white shadow-sm'
                                    : 'text-gray-700 hover:bg-gray-100 hover:text-gray-900'
                            ]">
                        <div class="flex items-center space-x-3">
                            <div :class="[
                                'w-2 h-2 rounded-full transition-colors',
                                activeTab === index ? 'bg-white' : 'bg-gray-400'
                            ]"></div>
                            <span class="font-medium">{{ tab.label }}</span>
                        </div>
                        <span v-if="searchQuery && getVisibleItemsCount(index) > 0" :class="[
                                  'inline-flex items-center px-2 py-1 rounded-full text-xs font-medium',
                                  activeTab === index
                                      ? 'bg-white/20 text-white'
                                      : 'bg-dashboard-blue text-white'
                              ]">
                            {{ getVisibleItemsCount(index) }}
                        </span>
                    </button>
                </div>
            </nav>

            <!-- Footer -->
            <div class="p-4 border-t border-gray-200">
                <div class="text-xs text-gray-500 text-center">
                    {{ tabs.reduce((total, tab) => total + tab.items.length, 0) }} items across {{ tabs.length }} tabs
                </div>
            </div>
        </div>

        <!-- Main Content -->
        <div class="flex-1 flex flex-col overflow-hidden lg:ml-0">
            <!-- Content Header -->
            <div class="bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between">
                <!-- Mobile menu button -->
                <button @click="sidebarOpen = !sidebarOpen"
                    class="lg:hidden p-2 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-dashboard-blue">
                    <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M4 6h16M4 12h16M4 18h16" />
                    </svg>
                </button>

                <div class="flex-1 lg:flex-none">
                    <div v-for="(tab, tabIndex) in tabs" :key="tabIndex" v-show="activeTab === tabIndex">
                        <h2 class="text-xl font-semibold text-gray-800">{{ tab.label }}</h2>
                        <p class="text-sm text-gray-600 mt-1">
                            {{ searchQuery ? getVisibleItemsCount(tabIndex) : tab.items.length }}
                            {{ searchQuery ? 'matching' : 'total' }} items
                        </p>
                    </div>
                </div>
            </div>

            <!-- Content Area -->
            <div class="flex-1 overflow-y-auto p-6">
                <div v-for="(tab, tabIndex) in tabs" :key="tabIndex" v-show="activeTab === tabIndex"
                    class="animate-fadeIn h-full">

                    <!-- Content Grid -->
                    <div class="space-y-6">
                        <div v-for="(item, itemIndex) in tab.items" :key="'item-' + tabIndex + '-' + itemIndex"
                            v-show="isItemVisible(item)"
                            class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 hover:shadow-md transition-shadow duration-200">

                            <!-- Chart content -->
                            <div v-if="item.type === 'chart'">
                                <div class="mb-4">
                                    <h3 class="text-lg font-semibold text-gray-800"
                                        v-html="highlightSearchTerm(item.title)"></h3>
                                </div>
                                <div class="chart-container" :style="{ height: item.height }">
                                    <div :id="item.id" class="w-full h-full"></div>
                                </div>
                            </div>

                            <!-- Markdown content -->
                            <div v-if="item.type === 'markdown'" class="prose" v-html="item.html"></div>
                        </div>
                    </div>

                    <!-- No Search Results -->
                    <div v-if="searchQuery && getVisibleItemsCount(tabIndex) === 0"
                        class="text-center py-12 bg-white rounded-xl border border-gray-200">
                        <div class="w-16 h-16 mx-auto mb-4 bg-gray-100 rounded-full flex items-center justify-center">
                            <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                            </svg>
                        </div>
                        <h3 class="text-lg font-medium text-gray-900 mb-2">No content found</h3>
                        <p class="text-gray-500">No content matches your search query "{{ searchQuery }}"</p>
                    </div>

                    <!-- Empty State -->
                    <div v-else-if="!searchQuery && tab.items.length === 0"
                        class="text-center py-12 bg-white rounded-xl border border-gray-200">
                        <div class="w-16 h-16 mx-auto mb-4 bg-gray-100 rounded-full flex items-center justify-center">
                            <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z">
                                </path>
                            </svg>
                        </div>
                        <h3 class="text-lg font-medium text-gray-900 mb-2">No content available</h3>
                        <p class="text-gray-500">This tab doesn't contain any content yet.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <style>
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(10px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .animate-fadeIn {
            animation: fadeIn 0.3s ease-out;
        }

        ::-webkit-scrollbar {
            width: 6px;
        }

        ::-webkit-scrollbar-track {
            background: #f1f5f9;
        }

        ::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 3px;
        }

        ::-webkit-scrollbar-thumb:hover {
            background: #94a3b8;
        }

        .chart-container {
            position: relative;
            overflow: hidden;
        }

        .chart-container > div {
            width: 100% !important;
            height: 100% !important;
        }

        /* Markdown prose styling */
        .prose {
            color: #374151;
            max-width: none;
        }

        .prose h1 {
            font-size: 2.25em;
            font-weight: 800;
            margin-top: 0;
            margin-bottom: 0.8888889em;
            line-height: 1.1111111;
            color: #111827;
        }

        .prose h2 {
            font-size: 1.5em;
            font-weight: 700;
            margin-top: 2em;
            margin-bottom: 1em;
            line-height: 1.3333333;
            color: #111827;
        }

        .prose h3 {
            font-size: 1.25em;
            font-weight: 600;
            margin-top: 1.6em;
            margin-bottom: 0.6em;
            line-height: 1.6;
            color: #111827;
        }

        .prose p {
            margin-top: 1.25em;
            margin-bottom: 1.25em;
            line-height: 1.75;
        }

        .prose strong {
            font-weight: 600;
            color: #111827;
        }

        .prose ul {
            margin-top: 1.25em;
            margin-bottom: 1.25em;
            padding-left: 1.625em;
            list-style-type: disc;
        }

        .prose ul li {
            margin-top: 0.5em;
            margin-bottom: 0.5em;
        }

        .prose ul li p {
            margin-top: 0.75em;
            margin-bottom: 0.75em;
        }

        .prose pre {
            background-color: #1f2937;
            color: #e5e7eb;
            overflow-x: auto;
            font-size: 0.875em;
            line-height: 1.7142857;
            margin-top: 1.7142857em;
            margin-bottom: 1.7142857em;
            border-radius: 0.375rem;
            padding: 0.8571429em 1.1428571em;
        }

        .prose code {
            color: #111827;
            font-weight: 600;
            font-size: 0.875em;
        }

        .prose pre code {
            background-color: transparent;
            border-width: 0;
            border-radius: 0;
            padding: 0;
            font-weight: 400;
            color: inherit;
            font-size: inherit;
            font-family: inherit;
            line-height: inherit;
        }

        $(config.custom_css)
    </style>

    <script>
        const { createApp } = Vue;

        // User-provided chart initialization function
        $(config.chart_init_script)

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
                    this.initializeAllCharts();
                    this.highlightCode();
                });
            },
            watch: {
                activeTab(newTab, oldTab) {
                    this.sidebarOpen = false;
                }
            },
            methods: {
                highlightCode() {
                    if (typeof hljs !== 'undefined') {
                        document.querySelectorAll('pre code').forEach((block) => {
                            // Remove language class to force auto-detection
                            block.className = '';
                            hljs.highlightElement(block);
                        });
                    }
                },
                initializeAllCharts() {
                    this.tabs.forEach((tab, tabIndex) => {
                        tab.items.forEach((item, itemIndex) => {
                            if (item.type === 'chart' && typeof initializeChart === 'function') {
                                initializeChart(item.id, item.metadata);
                            }
                        });
                    });
                },
                isItemVisible(item) {
                    if (!this.searchQuery) return true;

                    const query = this.searchQuery.toLowerCase();
                    if (item.type === 'chart') {
                        return item.title.toLowerCase().includes(query);
                    } else if (item.type === 'markdown') {
                        // Search in HTML content (strip tags for better results)
                        const textContent = item.html.replace(/<[^>]*>/g, ' ');
                        return textContent.toLowerCase().includes(query);
                    }
                    return true;
                },
                getVisibleItemsCount(tabIndex) {
                    if (!this.searchQuery) return this.tabs[tabIndex].items.length;

                    return this.tabs[tabIndex].items.filter(item => this.isItemVisible(item)).length;
                },
                highlightSearchTerm(text) {
                    if (!this.searchQuery) return text;

                    const regex = new RegExp('(' + this.searchQuery + ')', 'gi');
                    return text.replace(regex, '<span class="bg-yellow-200 text-yellow-800 px-1 rounded">\$1</span>');
                }
            }
        }).mount('#app');
    </script>
</body>

</html>
"""
    return html
end

"""
    generate_tabs_json(tabs::Vector{Tab})

Convert tabs configuration to JSON string for embedding in the HTML.
"""
function generate_tabs_json(tabs::Vector{Tab})
    tabs_array = []

    for tab in tabs
        items_array = []
        for item in tab.items
            if item isa ChartPlaceholder
                item_dict = Dict(
                    "type" => "chart",
                    "id" => item.id,
                    "title" => item.title,
                    "height" => item.height,
                    "metadata" => item.metadata,
                )
                push!(items_array, item_dict)
            elseif item isa MarkdownContent
                # Convert markdown to HTML using Markdown.jl
                html_content = Markdown.html(Markdown.parse(item.content))
                item_dict = Dict(
                    "type" => "markdown",
                    "id" => item.id,
                    "html" => html_content,
                )
                push!(items_array, item_dict)
            end
        end

        tab_dict = Dict(
            "label" => tab.label,
            "items" => items_array,
        )
        push!(tabs_array, tab_dict)
    end

    return JSON.json(tabs_array)
end

"""
    escape_html(str::String)

Escape HTML special characters.
"""
function escape_html(str::String)
    str = replace(str, "&" => "&amp;")
    str = replace(str, "<" => "&lt;")
    str = replace(str, ">" => "&gt;")
    str = replace(str, "\"" => "&quot;")
    str = replace(str, "'" => "&#39;")
    return str
end

"""
    generate_cdn_scripts(cdn_urls::Dict{String,String})

Generate script and link tags for all CDN URLs.
"""
function generate_cdn_scripts(cdn_urls::Dict{String, String})
    tags = String[]
    for (name, url) in cdn_urls
        if endswith(url, ".css")
            push!(tags, "    <link rel=\"stylesheet\" href=\"$(url)\">")
        else
            push!(tags, "    <script src=\"$(url)\"></script>")
        end
    end
    return join(tags, "\n")
end
