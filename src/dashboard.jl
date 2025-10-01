struct PatchworkDashboard
    title::String
    tabs::Vector{PatchworkTab}
    custom_css::String

    function PatchworkDashboard(title::String, tabs::Vector{PatchworkTab}; custom_css::String = "")
        return new(title, tabs, custom_css)
    end
end

function save(dashboard::PatchworkDashboard, path::String)
    html = generate_html(dashboard)
    write(path, html)
    return path
end

function generate_html(dashboard::PatchworkDashboard)
    all_types = unique([typeof(item) for tab in dashboard.tabs for item in tab.items])

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
        items_data = Dict{String, Any}[]
        for item in tab.items
            item_id = "item-$(uuid4())"
            item_html = to_html(item)
            item_type = get_item_type(item)
            push!(items_data, Dict(
                "id" => item_id,
                "type" => item_type,
                "html" => item_html,
            ))
        end
        push!(tabs_data, Dict("label" => tab.label, "items" => items_data))
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
                    <input v-model="searchQuery" type="text" class="w-full px-3 py-2 text-sm border border-gray-200 rounded focus:outline-none focus:border-gray-400 transition-colors" placeholder="Search...">
                    <div v-if="searchQuery" @click="searchQuery = ''" class="absolute right-2 top-2 cursor-pointer text-gray-400 hover:text-gray-600 text-lg leading-none">×</div>
                </div>
            </div>

            <nav class="flex-1 overflow-y-auto px-4 space-y-1">
                <button v-for="(tab, i) in tabs" :key="i" @click="activeTab = i; sidebarOpen = false" :class="['w-full text-left text-sm px-4 py-2.5 rounded transition-colors', activeTab === i ? 'bg-gray-900 text-white' : 'text-gray-600 hover:text-gray-900 hover:bg-gray-50']">
                    {{ tab.label }}
                </button>
            </nav>
        </div>

        <div class="flex-1 flex flex-col overflow-hidden bg-gray-50">
            <div class="bg-white border-b border-gray-100 px-8 py-3 flex items-center">
                <button @click="sidebarOpen = !sidebarOpen" class="lg:hidden mr-4 p-1.5 rounded hover:bg-gray-100 transition-colors">
                    <svg class="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
                    </svg>
                </button>
                <h2 class="text-sm font-medium text-gray-900">{{ tabs[activeTab]?.label }}</h2>
            </div>

            <div class="flex-1 overflow-y-auto px-8 py-6">
                <div v-for="(tab, tabIdx) in tabs" :key="tabIdx" v-show="activeTab === tabIdx" class="max-w-4xl mx-auto space-y-8">
                    <div v-for="item in tab.items" :key="item.id" v-show="isVisible(item)" class="bg-white border border-gray-100 rounded-lg p-8 shadow-sm hover:shadow-md transition-shadow" v-html="item.html"></div>
                    <div v-if="searchQuery && visibleCount(tabIdx) === 0" class="text-center py-16 text-sm text-gray-400">No results found</div>
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
            methods: {
                initializeContent() {
                    $combined_init
                },
                isVisible(item) {
                    if (!this.searchQuery) return true;
                    const query = this.searchQuery.toLowerCase();
                    return item.html.toLowerCase().includes(query);
                },
                visibleCount(tabIdx) {
                    return this.tabs[tabIdx].items.filter(item => this.isVisible(item)).length;
                }
            }
        }).mount('#app');
    </script>
</body>
</html>
"""
end
