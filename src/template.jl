"""
    generate_dashboard(config::DashboardConfig, output_path::String)

Generate a self-contained HTML dashboard file from the configuration.
"""
function generate_dashboard(config::DashboardConfig, output_path::String)
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
                        placeholder="Search charts...">
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
                        <span v-if="searchQuery && getVisibleChartsCount(index) > 0" :class="[
                                  'inline-flex items-center px-2 py-1 rounded-full text-xs font-medium',
                                  activeTab === index
                                      ? 'bg-white/20 text-white'
                                      : 'bg-dashboard-blue text-white'
                              ]">
                            {{ getVisibleChartsCount(index) }}
                        </span>
                    </button>
                </div>
            </nav>

            <!-- Footer -->
            <div class="p-4 border-t border-gray-200">
                <div class="text-xs text-gray-500 text-center">
                    {{ tabs.reduce((total, tab) => total + tab.charts.length, 0) }} charts across {{ tabs.length }} tabs
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
                            {{ searchQuery ? getVisibleChartsCount(tabIndex) : tab.charts.length }}
                            {{ searchQuery ? 'matching' : 'total' }} charts
                        </p>
                    </div>
                </div>
            </div>

            <!-- Content Area -->
            <div class="flex-1 overflow-y-auto p-6">
                <div v-for="(tab, tabIndex) in tabs" :key="tabIndex" v-show="activeTab === tabIndex"
                    class="animate-fadeIn h-full">

                    <!-- Charts Grid -->
                    <div class="space-y-6">
                        <div v-for="(chart, chartIndex) in tab.charts" :key="'chart-' + tabIndex + '-' + chartIndex"
                            v-show="isChartVisible(chart)"
                            class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 hover:shadow-md transition-shadow duration-200">
                            <div class="mb-4">
                                <h3 class="text-lg font-semibold text-gray-800"
                                    v-html="highlightSearchTerm(chart.title)"></h3>
                            </div>
                            <div class="chart-container" :style="{ height: chart.height }">
                                <div :id="chart.id" class="w-full h-full"></div>
                            </div>
                        </div>
                    </div>

                    <!-- No Search Results -->
                    <div v-if="searchQuery && getVisibleChartsCount(tabIndex) === 0"
                        class="text-center py-12 bg-white rounded-xl border border-gray-200">
                        <div class="w-16 h-16 mx-auto mb-4 bg-gray-100 rounded-full flex items-center justify-center">
                            <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                            </svg>
                        </div>
                        <h3 class="text-lg font-medium text-gray-900 mb-2">No charts found</h3>
                        <p class="text-gray-500">No charts match your search query "{{ searchQuery }}"</p>
                    </div>

                    <!-- Empty State -->
                    <div v-else-if="!searchQuery && tab.charts.length === 0"
                        class="text-center py-12 bg-white rounded-xl border border-gray-200">
                        <div class="w-16 h-16 mx-auto mb-4 bg-gray-100 rounded-full flex items-center justify-center">
                            <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z">
                                </path>
                            </svg>
                        </div>
                        <h3 class="text-lg font-medium text-gray-900 mb-2">No charts available</h3>
                        <p class="text-gray-500">This tab doesn't contain any charts yet.</p>
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
                });
            },
            watch: {
                activeTab(newTab, oldTab) {
                    this.sidebarOpen = false;
                }
            },
            methods: {
                initializeAllCharts() {
                    this.tabs.forEach((tab, tabIndex) => {
                        tab.charts.forEach((chart, chartIndex) => {
                            if (typeof initializeChart === 'function') {
                                initializeChart(chart.id, chart.metadata);
                            }
                        });
                    });
                },
                isChartVisible(chart) {
                    if (!this.searchQuery) return true;

                    const query = this.searchQuery.toLowerCase();
                    return chart.title.toLowerCase().includes(query);
                },
                getVisibleChartsCount(tabIndex) {
                    if (!this.searchQuery) return this.tabs[tabIndex].charts.length;

                    return this.tabs[tabIndex].charts.filter(chart => this.isChartVisible(chart)).length;
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

Convert tabs configuration to JSON for embedding in the HTML.
"""
function generate_tabs_json(tabs::Vector{Tab})
    tabs_array = []

    for tab in tabs
        charts_array = []
        for chart in tab.charts
            chart_dict = Dict(
                "id" => chart.id,
                "title" => chart.title,
                "height" => chart.height,
                "metadata" => chart.metadata,
            )
            push!(charts_array, chart_dict)
        end

        tab_dict = Dict(
            "label" => tab.label,
            "charts" => charts_array,
        )
        push!(tabs_array, tab_dict)
    end

    return json_string(tabs_array)
end

"""
    json_string(obj)

Simple JSON serialization (minimal implementation).
For production use, consider using JSON.jl package.
"""
function json_string(obj)
    if obj isa AbstractString
        return "\"$(escape_json(obj))\""
    elseif obj isa Number || obj isa Bool
        return string(obj)
    elseif obj isa AbstractDict
        pairs = ["\"$(escape_json(string(k)))\":$(json_string(v))" for (k, v) in obj]
        return "{" * join(pairs, ",") * "}"
    elseif obj isa AbstractVector
        items = [json_string(item) for item in obj]
        return "[" * join(items, ",") * "]"
    elseif isnothing(obj)
        return "null"
    else
        return "\"$(escape_json(string(obj)))\""
    end
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
    escape_json(str::String)

Escape JSON special characters.
"""
function escape_json(str::String)
    str = replace(str, "\\" => "\\\\")
    str = replace(str, "\"" => "\\\"")
    str = replace(str, "\n" => "\\n")
    str = replace(str, "\r" => "\\r")
    str = replace(str, "\t" => "\\t")
    return str
end

"""
    generate_cdn_scripts(cdn_urls::Dict{String,String})

Generate script tags for all CDN URLs.
"""
function generate_cdn_scripts(cdn_urls::Dict{String, String})
    scripts = String[]
    for (name, url) in cdn_urls
        push!(scripts, "    <script src=\"$(url)\"></script>")
    end
    return join(scripts, "\n")
end
