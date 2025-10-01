"""
Validation functions for Rhinestone dashboard configuration.
"""

"""
    validate_id(id::String)

Validate that an ID is non-empty and contains only valid characters (alphanumeric, hyphens, underscores).
Throws an ArgumentError if invalid.
"""
function validate_id(id::String)
    if isempty(id)
        throw(ArgumentError("ID cannot be empty"))
    end
    if !occursin(r"^[a-zA-Z0-9_-]+$", id)
        throw(
            ArgumentError(
                "ID '$id' contains invalid characters. Only alphanumeric, hyphens, and underscores are allowed.",
            ),
        )
    end
    return true
end

"""
    validate_unique_ids(items::Vector{ContentItem})

Validate that all IDs in a list of content items are unique.
Throws an ArgumentError if duplicates are found.
"""
function validate_unique_ids(items::Vector{ContentItem})
    ids = String[]
    for item in items
        if item isa ChartPlaceholder
            push!(ids, item.id)
        elseif item isa MarkdownContent
            push!(ids, item.id)
        end
    end

    unique_ids = unique(ids)
    if length(unique_ids) < length(ids)
        duplicates = [id for id in unique_ids if count(==(id), ids) > 1]
        throw(ArgumentError("Duplicate IDs found: $(join(duplicates, ", "))"))
    end
    return true
end

"""
    validate_config(config::DashboardConfig)

Validate a complete dashboard configuration.
Throws an ArgumentError if any validation fails.
"""
function validate_config(config::DashboardConfig)
    # Validate title is non-empty
    if isempty(config.title)
        throw(ArgumentError("Dashboard title cannot be empty"))
    end

    # Validate at least one tab exists
    if isempty(config.tabs)
        throw(ArgumentError("Dashboard must have at least one tab"))
    end

    # Collect all items across all tabs and validate IDs
    all_items = ContentItem[]
    for tab in config.tabs
        # Validate tab label is non-empty
        if isempty(tab.label)
            throw(ArgumentError("Tab label cannot be empty"))
        end

        # Validate tab has at least one item
        if isempty(tab.items)
            throw(ArgumentError("Tab '$(tab.label)' must have at least one item"))
        end

        # Validate individual IDs and collect items
        for item in tab.items
            if item isa ChartPlaceholder
                validate_id(item.id)
            elseif item isa MarkdownContent
                validate_id(item.id)
            end
            push!(all_items, item)
        end
    end

    # Validate all IDs are unique across the entire dashboard
    validate_unique_ids(all_items)

    return true
end
