struct Dashboard
    title::String
    tabs::Vector{Tab}
    custom_css::String

    function Dashboard(title::String, tabs::Vector{Tab}; custom_css::String = "")
        return new(title, tabs, custom_css)
    end
end

function render(dashboard::Dashboard, path::String)
    html = generate_html(dashboard)
    write(path, html)
    return path
end

function generate_html(dashboard::Dashboard)
    all_types = unique([typeof(item) for tab in dashboard.tabs for item in tab.items])

    cdn_links = String[]
    for type in all_types
        for url in cdn_urls(type)
            if endswith(url, ".css")
                push!(cdn_links, "    <link rel=\"stylesheet\" href=\"$url\">")
            else
                push!(cdn_links, "    <script src=\"$url\"></script>")
            end
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

    tabs_data = []
    for tab in dashboard.tabs
        items_data = []
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
$(join(cdn_links, "\n"))
</head>
<body class="bg-gray-50">
    <div id="app" class="flex h-screen">
        <div v-if="sidebarOpen" @click="sidebarOpen = false" class="fixed inset-0 z-20 bg-black/50 lg:hidden"></div>

        <div :class="['bg-white border-r border-gray-200 w-80 flex flex-col transition-transform lg:translate-x-0', sidebarOpen ? 'translate-x-0 fixed inset-y-0 left-0 z-30' : '-translate-x-full fixed inset-y-0 left-0 z-30 lg:relative lg:translate-x-0']">
            <div class="p-6 border-b border-gray-200">
                <h1 class="text-2xl font-bold text-gray-900">$(escape_html(dashboard.title))</h1>
            </div>

            <div class="p-4 border-b border-gray-200">
                <div class="relative">
                    <input v-model="searchQuery" type="text" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="Search...">
                    <div v-if="searchQuery" @click="searchQuery = ''" class="absolute right-3 top-2.5 cursor-pointer text-gray-400 hover:text-gray-600">×</div>
                </div>
            </div>

            <nav class="flex-1 overflow-y-auto p-4">
                <button v-for="(tab, i) in tabs" :key="i" @click="activeTab = i; sidebarOpen = false" :class="['w-full text-left px-4 py-3 rounded-lg mb-2 transition', activeTab === i ? 'bg-blue-500 text-white' : 'text-gray-700 hover:bg-gray-100']">
                    {{ tab.label }}
                </button>
            </nav>
        </div>

        <div class="flex-1 flex flex-col overflow-hidden">
            <div class="bg-white border-b border-gray-200 px-6 py-4 flex items-center">
                <button @click="sidebarOpen = !sidebarOpen" class="lg:hidden mr-4 p-2 rounded hover:bg-gray-100">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
                    </svg>
                </button>
                <h2 class="text-xl font-semibold text-gray-800">{{ tabs[activeTab]?.label }}</h2>
            </div>

            <div class="flex-1 overflow-y-auto p-6">
                <div v-for="(tab, tabIdx) in tabs" :key="tabIdx" v-show="activeTab === tabIdx" class="space-y-6">
                    <div v-for="item in tab.items" :key="item.id" v-show="isVisible(item)" class="bg-white rounded-lg shadow p-6" v-html="item.html"></div>
                    <div v-if="searchQuery && visibleCount(tabIdx) === 0" class="text-center py-12 text-gray-500">No results found</div>
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
