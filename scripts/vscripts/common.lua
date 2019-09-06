function _G.AddSeflBatrider(unit)
	local url = "particles/self_batrider.vpcf"
	local p = ParticleManager:CreateParticle(url, PATTACH_ABSORIGIN_FOLLOW, unit)
	ParticleManager:SetParticleControlEnt(p, 0, unit, PATTACH_ABSORIGIN_FOLLOW, "", Vector(100,100,100), true )
end

function _G.HideWearables( unit )
	local model = unit:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            print('item_effect')
			model:AddEffects(EF_NODRAW) -- Set model hidden
		end
		model = model:NextMovePeer()
	end
end

function _G.ChangeModel(unit,level)
	
    local level_data = selfKV.model.level[level]
    
    if level_data then
        HideWearables(unit)
	    Wearable:HideWearables(unit)
        unit:SetOriginalModel(level_data.Model)
        unit:SetModel(level_data.Model)
        unit.sHeroName = level_data.HeroName
        Wearable:WearDefaults(unit)
    end
    local scale = selfKV.model.scale[level]

    if scale then
        unit:SetModelScale(scale)
    end
end

function _G.CreatePhoenixSpirit(owner,tree)
    local origin = tree:GetAbsOrigin()
    local name = "phoenix_spirit"
    local unit = CreateUnitByName(name,origin,true,owner,owner,owner:GetTeam())
    origin.z = origin.z + 400
    unit:SetAbsOrigin(origin)
    tree.phoenix_spirit = unit
    AddSeflBatrider(unit)
end

function _G.EasyParticle(unit,url)
    local p = ParticleManager:CreateParticle(url, PATTACH_ABSORIGIN_FOLLOW, unit)
    ParticleManager:SetParticleControlEnt(p, 0, unit, PATTACH_ABSORIGIN_FOLLOW, "", Vector(100,100,100), true )
end

function _G.AxeCall(unit)
    local url1 = 'particles/econ/items/axe/axe_ti9_immortal/axe_ti9_call.vpcf'
    EasyParticle(url1)
end

function _G.InnerFire(unit)
    local url1 = 'particles/units/heroes/hero_huskar/huskar_inner_fire_flame_ring_b.vpcf'
    EasyParticle(unit,url1)
    local url2 = 'particles/units/heroes/hero_huskar/huskar_inner_fire_ring.vpcf'
    EasyParticle(unit,url2)
    local url3 = 'particles/units/heroes/hero_huskar/huskar_inner_fire_ring_b.vpcf'
    EasyParticle(unit,url3)
    local url4 = 'particles/units/heroes/hero_huskar/huskar_inner_fire_embers_b.vpcf'
    EasyParticle(unit,url4)
    local url5 = 'particles/units/heroes/hero_huskar/huskar_inner_fire_sparks_lrg.vpcf'
    EasyParticle(unit,url5)
end


function _G.FireTree(caster,pos,radius)
    local entities = Entities:FindAllByClassname('ent_dota_tree')
    for _ , tree in pairs(entities) do
        local tree_pos = tree:GetAbsOrigin()
        if #(tree_pos - pos) < radius then
            if tree.phoenix_spirit == nil then
                CreatePhoenixSpirit(caster,tree)
            end
        end
    end
end