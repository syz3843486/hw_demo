function OnCreated(keys)
    local caster = keys.caster
    local forward = caster:GetForwardVector()
    local origin = caster:GetAbsOrigin()
    local blink_dist = keys.ability:GetSpecialValueFor("blink_dist")
    origin = origin - forward * blink_dist
    caster:SetAbsOrigin(origin)
end

function OnIntervalThink(keys)
    local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")
    local interval = ability:GetSpecialValueFor("interval") 
    local damage = ability:GetSpecialValueFor("damage") * interval

    local caster = keys.caster
    local teamID = caster:GetTeamNumber()
    local pos = caster:GetOrigin()
    local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
    local typeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
    local flags = DOTA_UNIT_TARGET_FLAG_NONE
    local targets = FindUnitsInRadius(teamID,pos,caster,radius,teamFilter,typeFilter,flags,FIND_CLOSEST,true)
    
    for _ , target in pairs(targets) do
        --print('target',target:GetUnitName(),damage)
        local data = {
            attacker = caster,
            victim = target,
            damage = damage,
            damage_type = ability:GetAbilityDamageType(),
            damage_flags = DOTA_UNIT_TARGET_FLAG_NONE,
            ability = ability,
        }
        ApplyDamage(data)
    end

    FireTree(caster,pos,radius)
end