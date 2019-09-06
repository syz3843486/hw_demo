local selfKV = {}

local function LoadModelKV()
    local model = {}
    local kv = LoadKeyValues("scripts/selfKV/model.txt")
    
    local level = {}
    for k,v in pairs(kv.level) do
        level[tonumber(k)]=v
    end

    model.level = level

    local scale = {}
    for k,v in pairs(kv.scale) do
        scale[tonumber(k)] = tonumber(v)
    end
    model.scale = scale

    return model
end

selfKV.model = LoadModelKV()

local function LoadRequiredExpKV()
    local required_exp = {}
    local kv = LoadKeyValues("scripts/selfKV/required_exp.txt")

    for k , v in pairs(kv) do
        print('k',k,'v',v)
        required_exp[tonumber(k)] = tonumber(v)
    end

    for k , v in ipairs(required_exp) do
        print('k',k,v)
    end

    return required_exp
end

selfKV.required_exp = LoadRequiredExpKV()


_G.selfKV = selfKV
