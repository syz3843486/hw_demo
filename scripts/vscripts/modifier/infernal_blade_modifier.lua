function AddPhyiscDamage(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
	local add_damge = ability:GetSpecialValueFor("add_damge")
    local data = {
        attacker = caster,
        victim = target,
        damage = add_damge,
        damage_type = ability:GetAbilityDamageType(),
        damage_flags = DOTA_UNIT_TARGET_FLAG_NONE,
        ability = ability,
    }
    ApplyDamage(data)
end