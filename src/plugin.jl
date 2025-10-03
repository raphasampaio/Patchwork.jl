abstract type Plugin end

function get_plugin_type(plugin::Plugin)
    name = string(typeof(plugin))
    return lowercase(split(name, ".")[end])
end
