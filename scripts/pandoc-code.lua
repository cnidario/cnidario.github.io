-- require("mobdebug").start()
local function openTag(tag, classes)
    if classes == nil or #classes == 0 then
        return '<' .. tag .. '>'
    else
        local str = '<' .. tag .. ' class="'
        for i,c in ipairs(classes) do
            if i > 1 then
                str = str .. ' '
            end
            str = str .. c
        end
        return str .. '">'
    end
end
local function closeTag(tag)
    return '</'..tag..'>'
end

local function contains(list, elem)
    if list == nil or #list == 0 then return nil end
    for k,v in pairs(list) do
        if v == elem then
            return v
        end
    end
    return nil
end

function CodeBlock(el)
    --for k,v in pairs(el.attr.attributes) do print(k) print(v) end
    local args = { '-l', el.classes[1] }
    if contains(el.classes, 'numberLines') then
        local keys = 'linenos=inline'
        table.insert(args, '-O')
        if el.attributes['startFrom'] then
            keys = keys .. ',linenostart=100'
        end
        table.insert(args, keys)
    end
    table.insert(args, '-f')
    table.insert(args, 'html')
    if FORMAT:match '^html.?' then
        local pygmentized = pandoc.pipe('pygmentize', args, el.text)

        return pandoc.RawBlock(FORMAT, openTag('pre') .. openTag('code', el.classes) .. pygmentized .. closeTag('code') .. closeTag('pre'))
    else
        return el
    end
end

local function starts_with(start, str)
  return str:sub(1, #start) == start
end


function Code(elem)
    local iframe_file = string.match(elem.text, "{{< iframe ([%a%d-/%.]+) >}}")
    if iframe_file then
        return pandoc.RawInline(FORMAT, '<iframe src="' .. iframe_file .. '"></iframe>')
    else
        return elem
    end
end
