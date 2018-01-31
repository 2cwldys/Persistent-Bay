#define SAVEFILE_VERSION_MIN	8
#define SAVEFILE_VERSION_MAX	17

/proc/load_path(ckey,filename="preferences.sav")
	if(!ckey)	return
	var/path = "data/player_saves/[copytext(ckey,1,2)]/[ckey]/[filename]"
	return path

/datum/preferences/proc/load_preferences()
	path = load_path(client.ckey)
	if(!fexists(path))		return 0
	var/savefile/S = new /savefile(path)
	if(!S)					return 0
	S.cd = "/"

	S["version"] >> savefile_version
	player_setup.load_preferences(S)
	loaded_preferences = S
	return 1

/datum/preferences/proc/save_preferences()
	path = load_path(client.ckey)
	var/savefile/S = new /savefile(path)
	if(!S)					return 0
	S.cd = "/"

	S["version"] << SAVEFILE_VERSION_MAX
	player_setup.save_preferences(S)
	loaded_preferences = S
	return 1

/datum/preferences/proc/load_character(slot)
//	if(!path)				return 0
//	if(!fexists(path))		return 0
//	var/savefile/S = new /savefile(path)
//	if(!S)					return 0
//	S.cd = "/"
//	if(!slot)	slot = default_slot

	
	
	
	
	
	
	/**
	if(slot != SAVE_RESET) // SAVE_RESET will reset the slot as though it does not exist, but keep the current slot for saving purposes.
		slot = sanitize_integer(slot, 1, config.character_slots, initial(default_slot))
		if(slot != default_slot)
			default_slot = slot
			S["default_slot"] << slot
	else
		S["default_slot"] << default_slot

	if(slot != SAVE_RESET)
		S.cd = GLOB.using_map.character_load_path(S, slot)
		player_setup.load_character(S)
	else
		player_setup.load_character(S)
		S.cd = GLOB.using_map.character_load_path(S, default_slot)

	loaded_character = S
	**/
	return 1

/datum/preferences/proc/save_character()
//	if(!path)				return 0
//	var/savefile/S = new /savefile(path)
//	if(!S)					return 0
//	S.cd = GLOB.using_map.character_save_path(default_slot)
	var/use_path = load_path(client.ckey, "")
	var/savefile/S = new("[use_path][chosen_slot].sav")
	var/mob/living/carbon/human/mannequin = new()
	dress_preview_mob(mannequin, TRUE)
	mannequin.name = real_name
	mannequin.real_name = real_name
	mannequin.dna.ResetUIFrom(mannequin)
	mannequin.dna.ready_dna(mannequin)
	mannequin.dna.b_type = client.prefs.b_type
	mannequin.sync_organ_dna()
	mannequin.internal_organs_by_name[BP_STACK] = new /obj/item/organ/internal/stack(mannequin,1)
	var/money_amount = 500
	var/datum/money_account/M = create_account(mannequin.real_name, money_amount, null)
	M.remote_access_pin = chosen_pin
	if(!mannequin.mind)
		mannequin.mind = new()
	var/remembered_info = ""
	remembered_info += "<b>Your account number is:</b> #[M.account_number]<br>"
	remembered_info += "<b>Your account pin is:</b> [M.remote_access_pin]<br>"
	remembered_info += "<b>Your account funds are:</b> [M.money]<br>"

	if(M.transaction_log.len)
		var/datum/transaction/T = M.transaction_log[1]
		remembered_info += "<b>Your account was created:</b> [T.time], [T.date] at [T.source_terminal]<br>"
	mannequin.mind.store_memory(remembered_info)

	mannequin.mind.initial_account = M
	CreateModularRecord(mannequin)
	var/decl/hierarchy/outfit/job/assistant/outfit = new()
	
	outfit.equip(mannequin)
	S << mannequin
	load_characters()
	qdel(mannequin)

//	S["version"] << SAVEFILE_VERSION_MAX
//	player_setup.save_character(S)
//	loaded_character = S
//	return S

/datum/preferences/proc/sanitize_preferences()
	player_setup.sanitize_setup()
	return 1

/datum/preferences/proc/update_setup(var/savefile/preferences, var/savefile/character)
	if(!preferences || !character)
		return 0
	return player_setup.update_setup(preferences, character)

#undef SAVEFILE_VERSION_MAX
#undef SAVEFILE_VERSION_MIN
