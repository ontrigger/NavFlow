---@param tbl T[]
---@param selector fun<T>(val: T, key: number): number
---@return number
function table.sum_by(tbl, selector)
    local total = 0
    for i, v in ipairs(tbl) do
        total = total + selector(v, i)
    end

    return total
end