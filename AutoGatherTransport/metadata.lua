return PlaceObj('ModDef', {
	'title', "AutoGatherTransport",
	'description', "Idle RC Transports automatically gather resources scattered around the surface and bring them back to the closest Universal Storage location as well as automatically recharging from a nearby Power Cable. Such resources are Metal and Polymer surface deposits revealed by surface scanning. The transporter will not pick up other forms of resources dumped on the surface automatically.\r\n\r\nThe Transporter's Info Panel features an \"Auto Gather\" section that can be toggled on.\r\n\r\nIf ModConfig is installed, the status notifications can be disabled in the Mod Config Menu.\r\n\r\nNotes:\r\n- The Transports dump their gathered resources near the Universal Storage instead of into them because I wasn't able to prevent the popup of the \"Select resource to unload\" dialog.\r\n- The rovers may try to get to unreachable anomalies unfortunately (don't know how to check for reachability when picking a target).\r\n- I made this mod to avoid trying to click on every rock to see if it is a resource deposit or not. Some maps have large amounts of such deposits scattered all around.",
	'tags', "",
	'image', "AutoGatherTransport.png",
	'id', "Zq7BVyy",
	'steam_id', "1342196777",
	'author', "akarnokd",
	'version', 22,
	'lua_revision', 228184,
	'code', {
		"Code/AutoGatherTransportScript.lua",
	},
	'saved', 1522162510,
})