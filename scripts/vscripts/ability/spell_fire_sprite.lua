function OnSpellStart(keys)
    for k , v in pairs(keys) do
        print('k',k)
    end

    local ability = keys.ability
    local cursor_pos = ability:GetCursorPosition()
    local radius = ability:GetSpecialValueFor("radius")

    local entities = Entities:FindAllByClassname('ent_dota_tree')
    for _ , tree in pairs(entities) do
        if tree.phoenix_spirit then
            print('radius',radius)
            tree.phoenix_spirit.targetpos = cursor_pos + RandomVector(radius) * math.random()
            tree.phoenix_spirit:AddNewModifier(keys.caster,nil,"phoenix_spirit_fly",{})
            tree.phoenix_spirit = nil
        end
    end
end