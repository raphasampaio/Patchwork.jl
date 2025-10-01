abstract type Item end

function get_item_type(item::Item)
    name = string(typeof(item))
    return lowercase(split(name, ".")[end])
end
