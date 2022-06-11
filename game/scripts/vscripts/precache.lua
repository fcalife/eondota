local particles = {
	--"particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_buff.vpcf"
}

local particle_folders = {
    --"particles/creature"
}

local models = {
	--"models/units/heroes/"
}

local model_folders = {
    --"models/"
}

local sounds = {
    -- "soundevents/game_sounds.vsndevts"
}

local units = {
    -- "npc_dota_hero_starter",
}

local items = {
    --"item_example",
}

return function(context)
    print("Performing pre-load static precache")
    
    for _, p in pairs(particles) do
        PrecacheResource("particle", p, context)
    end

    for _, p in pairs(particle_folders) do
        PrecacheResource("particle_folder", p, context)
    end

    for _, p in pairs(models) do
        PrecacheResource("model", p, context)
    end

    for _, p in pairs(model_folders) do
        PrecacheResource("model_folder", p, context)
    end

    for _, p in pairs(sounds) do
        PrecacheResource("soundfile", p, context)
    end

    for _, p in pairs(units) do
        PrecacheUnitByNameSync(p, context)
    end

    for _, p in pairs(items) do
        PrecacheItemByNameSync(p, context)
    end
    
	print("Finished pre-load precache")
end

