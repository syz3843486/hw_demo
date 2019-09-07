function OnSpellStart(keys)
    local ability = keys.ability
    local caster = keys.caster
    local forward = caster:GetForwardVector()
    
    local end_radius = ability:GetSpecialValueFor("end_radius")
    local fire_width = ability:GetSpecialValueFor("fire_width")

    local teamID = caster:GetTeamNumber()
    local vStartPos = caster:GetOrigin()
    local vEndPos = vStartPos + forward*end_radius

    local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
    local typeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
    local flags = DOTA_UNIT_TARGET_FLAG_NONE
    local targets = FindUnitsInLine(teamID,vStartPos,vEndPos,caster,fire_width,teamFilter,typeFilter,flags)
    
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

end