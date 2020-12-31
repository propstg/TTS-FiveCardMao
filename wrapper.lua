Wrapper = {}

setmetatable(Wrapper, {
    __index = function(_, key)
        Wrapper[key] = _G[key]
        return _G[key]
    end
})