/client/proc/dsay(msg as text)
	set category = "Адм.Игра"
	set name = "Dsay"
	set hidden = TRUE
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(!mob)
		return
	if(prefs.muted & MUTE_DEADCHAT)
		to_chat(src, span_danger("You cannot send DSAY messages (muted)."))
		return

	if (handle_spam_prevention(msg,MUTE_DEADCHAT))
		return

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)
	mob.log_talk(msg, LOG_DSAY)

	if (!msg)
		return
	var/rank_name = holder.rank
	var/admin_name = key
	if(holder.fakekey)
		rank_name = pick(strings("admin_nicknames.json", "ranks", "cfg"))
		admin_name = pick(strings("admin_nicknames.json", "names", "cfg"))
	var/rendered = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>[rank_name]([admin_name])</span> says, <span class='message'>\"[emoji_parse(msg)]\"</span></span>"

	for (var/mob/M in GLOB.player_list)
		var/admin_holder = M.client?.holder
		if(isnewplayer(M) && !admin_holder) // We want to make sure admins can see this when in the lobby too!
			continue
		if (M.stat == DEAD || (admin_holder && (M.client?.prefs.chat_toggles & CHAT_DEAD))) //admins can toggle deadchat on and off. This is a proc in admin.dm and is only given to Administrators and above
			to_chat(M, rendered)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Dsay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/get_dead_say()
	var/msg = input(src, null, "dsay \"text\"") as text|null

	if (isnull(msg))
		return

	dsay(msg)
