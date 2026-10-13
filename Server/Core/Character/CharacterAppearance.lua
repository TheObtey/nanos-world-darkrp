local CharacterAppearance = {}
CharacterAppearance.__index = CharacterAppearance

function CharacterAppearance.New(config)
    assert(config, "CharacterAppearance requires a configuration")

    local self = setmetatable({}, CharacterAppearance)

    self.config = config

    return self
end

function CharacterAppearance:Apply(character, mesh)
	-- Customization
	if (mesh == "nanos-world::SK_Male") then
		local selected_hair = self.config.SK_MALE_HAIR_MESHES[math.random(#self.config.SK_MALE_HAIR_MESHES)]
		if (selected_hair ~= "") then
			character:AddStaticMeshAttached("hair", selected_hair, "hair_male")
		end

		local selected_beard = self.config.SK_MALE_BEARD_MESHES[math.random(#self.config.SK_MALE_BEARD_MESHES)]
		if (selected_beard ~= "") then
			character:AddStaticMeshAttached("beard", selected_beard, "beard")
		end
	end

	if (mesh == "nanos-world::SK_Male" or mesh == "nanos-world::SK_Mannequin") then
		local selected_death_Sound = self.config.MALE_DEATH_SOUNDS[math.random(#self.config.MALE_DEATH_SOUNDS)]
		character:SetDeathSound(selected_death_Sound)

		local selected_pain_Sound = self.config.MALE_PAIN_SOUNDS[math.random(#self.config.MALE_PAIN_SOUNDS)]
		character:SetPainSound(selected_pain_Sound)
	end

	if (mesh == "nanos-world::SK_Female" or mesh == "nanos-world::SK_Mannequin_Female") then
		local selected_death_Sound = self.config.FEMALE_DEATH_SOUNDS[math.random(#self.config.FEMALE_DEATH_SOUNDS)]
		character:SetDeathSound(selected_death_Sound)

		local selected_pain_Sound = self.config.FEMALE_PAIN_SOUNDS[math.random(#self.config.FEMALE_PAIN_SOUNDS)]
		character:SetPainSound(selected_pain_Sound)
	end

	if (mesh == "nanos-world::SK_Female") then
		local selected_hair = self.config.SK_FEMALE_HAIR_MESHES[math.random(#self.config.SK_FEMALE_HAIR_MESHES)]
		if (selected_hair ~= "") then
			character:AddStaticMeshAttached("hair", selected_hair, "hair_female")
		end

		-- Those parameters are specific to female mesh
		character:SetMaterialColorParameter("BlushTint", Color(0.52, 0.12, 0.15))
		character:SetMaterialColorParameter("EyeShadowTint", Color(0.24, 0.05, 0.07))
		character:SetMaterialColorParameter("LipstickTint", Color(0.31, 0.03, 0.1))
	end

	-- Adds eyes to humanoid meshes
	if (mesh == "nanos-world::SK_Male" or mesh == "nanos-world::SK_Female") then
		character:AddStaticMeshAttached("eye_left", "nanos-world::SM_Eye", "eye_left")
		character:AddStaticMeshAttached("eye_right", "nanos-world::SM_Eye", "eye_right")

		-- Those parameters are specific to humanoid meshes (were added in their materials)
		character:SetMaterialColorParameter("HairTint", self.config.HAIR_TINTS[math.random(#self.config.HAIR_TINTS)], -1, "hair")
		character:SetMaterialColorParameter("Tint", self.config.HUMAN_SKIN_TONES[math.random(#self.config.HUMAN_SKIN_TONES)])

		character:SetMaterialScalarParameter("Muscular", math.random(100) / 100)
		character:SetMaterialScalarParameter("BaseColorPower", math.random(2) + 0.5)

		for _, morph_target in ipairs(self.config.HUMAN_MORPH_TARGETS) do
			character:SetMorphTarget(morph_target, math.random(200) / 100 - 1)
		end
	end
end

return CharacterAppearance