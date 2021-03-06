/proc/replace(haystack, needle, newneedle)
	var
		list/find_list = stringsplit(needle, haystack)
		final_text = listjoin(find_list,newneedle)
	return final_text

/proc/listjoin(list/list,delimiter)
	var
		final_text
		iter = 1
	for(var/E in list)
		if(iter > 1) final_text += "[delimiter]"
		final_text += E
		iter++
	return final_text

/proc/get_dir_3d(var/atom/ref, var/atom/target)
	return get_dir(ref, target) | (target.z > ref.z ? UP : 0) | (target.z < ref.z ? DOWN : 0)

//Bwahahaha! I am extending a built-in proc for personal gain!
//(And a bit of nonpersonal gain, I guess)
/proc/get_step_3d(atom/ref,dir)
	if(!dir&(UP|DOWN))
		return get_step(ref,dir)
	//Well, it *did* use temporary vars dx, dy, and dz, but this probably should be as fast as possible
	return locate(ref.x+((dir&EAST)?1:0)-((dir&WEST)?1:0),ref.y+((dir&NORTH)?1:0)-((dir&SOUTH)?1:0),ref.z+((dir&UP)?1:0)-((dir&DOWN)?1:0))

/proc/reverse_dir_3d(dir)
	var/ndir = (dir&NORTH)?SOUTH : 0
	ndir |= (dir&SOUTH)?NORTH : 0
	ndir |= (dir&EAST)?WEST : 0
	ndir |= (dir&WEST)?EAST : 0
	ndir |= (dir&UP)?DOWN : 0
	ndir |= (dir&DOWN)?UP : 0
	return ndir

/proc/stringsplit(character, txt)
	var
		cur_text = txt
		last_found = 1
		found_char = findtext(cur_text,character)
		list/list = list()
	if(found_char)
		var/fs = copytext(cur_text,last_found,found_char)
		list += fs
		last_found = found_char+length(character)
		found_char = findtext(cur_text,character,last_found)
	while(found_char)
		var
			found_string = copytext(cur_text,last_found,found_char)
		last_found = found_char+length(character)
		list += found_string
		found_char = findtext(cur_text,character,last_found)
	list += copytext(cur_text,last_found,length(cur_text)+1)
	return list

/proc/hex2num(hex)

	if (!( istext(hex) ))
		CRASH("hex2num not given a hexadecimal string argument (user error)")
		return
	var/num = 0
	var/power = 0
	var/i = null
	i = length(hex)
	while(i > 0)
		var/char = copytext(hex, i, i + 1)
		switch(char)
			if("0")
				power++
				goto Label_290
			if("9", "8", "7", "6", "5", "4", "3", "2", "1")
				num += text2num(char) * 16 ** power
			if("a", "A")
				num += 16 ** power * 10
			if("b", "B")
				num += 16 ** power * 11
			if("c", "C")
				num += 16 ** power * 12
			if("d", "D")
				num += 16 ** power * 13
			if("e", "E")
				num += 16 ** power * 14
			if("f", "F")
				num += 16 ** power * 15
			else
				CRASH("hex2num given non-hexadecimal string (user error)")
				return
		power++
		Label_290:
		i--
	return num

/proc/num2hex(num, placeholder)

	if (placeholder == null)
		placeholder = 2
	if (!( isnum(num) ))
		CRASH("num2hex not given a numeric argument (user error)")
		return
	if (!( num ))
		var/B = ""
		for(var/I = 1, I <= placeholder, I++)
			B += "#"
		return B
	var/hex = ""
	var/i = 0
	while(16 ** i < num)
		i++
	var/power = null
	power = i - 1
	while(power >= 0)
		var/val = round(num / 16 ** power)
		num -= val * 16 ** power
		switch(val)
			if(9.0, 8.0, 7.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0, 0.0)
				hex += text("[]", val)
			if(10.0)
				hex += "A"
			if(11.0)
				hex += "B"
			if(12.0)
				hex += "C"
			if(13.0)
				hex += "D"
			if(14.0)
				hex += "E"
			if(15.0)
				hex += "F"
			else
		power--
	while(length(hex) < placeholder)
		hex = text("0[]", hex)
	return hex

/proc/invertHTML(HTMLstring)

	if (!( istext(HTMLstring) ))
		CRASH("Given non-text argument!")
		return
	else
		if (length(HTMLstring) != 7)
			CRASH("Given non-HTML argument!")
			return
	var/textr = copytext(HTMLstring, 2, 4)
	var/textg = copytext(HTMLstring, 4, 6)
	var/textb = copytext(HTMLstring, 6, 8)
	var/r = hex2num(textr)
	var/g = hex2num(textg)
	var/b = hex2num(textb)
	textr = num2hex(255 - r)
	textg = num2hex(255 - g)
	textb = num2hex(255 - b)
	if (length(textr) < 2)
		textr = text("0[]", textr)
	if (length(textg) < 2)
		textr = text("0[]", textg)
	if (length(textb) < 2)
		textr = text("0[]", textb)
	return text("#[][][]", textr, textg, textb)
	return

/proc/shuffle(var/list/shufflelist)
	if(!shufflelist)
		return
	var/list/new_list = list()
	var/list/old_list = shufflelist.Copy()
	while(old_list.len)
		var/item = pick(old_list)
		new_list += item
		old_list -= item
	return new_list

/proc/uniquelist(var/list/L)
	var/list/K = list()
	for(var/item in L)
		if(!(item in K))
			K += item
	return K

/proc/sanitize(var/t)
	var/index = findtext(t, "\n")
	while(index)
		t = copytext(t, 1, index) + "#" + copytext(t, index+1)
		index = findtext(t, "\n")

	index = findtext(t, "\t")
	while(index)
		t = copytext(t, 1, index) + "#" + copytext(t, index+1)
		index = findtext(t, "\t")

	return html_encode(t)

/proc/strip_html(var/t,var/limit=MAX_MESSAGE_LEN)
	t = copytext(t,1,limit)
	var/index = findtext(t, "<")
	while(index)
		t = copytext(t, 1, index) + copytext(t, index+1)
		index = findtext(t, "<")
	index = findtext(t, ">")
	while(index)
		t = copytext(t, 1, index) + copytext(t, index+1)
		index = findtext(t, ">")
	return sanitize(t)

/proc/add_zero(t, u)
	while (length(t) < u)
		t = "0[t]"
	return t

/proc/add_lspace(t, u)
	while(length(t) < u)
		t = " [t]"
	return t

/proc/add_tspace(t, u)
	while(length(t) < u)
		t = "[t] "
	return t

/proc/trim_left(text)
	for (var/i = 1 to length(text))
		if (text2ascii(text, i) > 32)
			return copytext(text, i)
	return ""

/proc/trim_right(text)
	for (var/i = length(text), i > 0, i--)
		if (text2ascii(text, i) > 32)
			return copytext(text, 1, i + 1)

	return ""

/proc/trim(text)
	return trim_left(trim_right(text))

/proc/capitalize(var/t as text)
	return uppertext(copytext(t, 1, 2)) + copytext(t, 2)

/proc/sortList(var/list/L)
	if(L.len < 2)
		return L
	var/middle = L.len / 2 + 1 // Copy is first,second-1
	return mergeLists(sortList(L.Copy(0,middle)), sortList(L.Copy(middle))) //second parameter null = to end of list

/proc/sortNames(var/list/L)
	var/list/Q = new()
	for(var/atom/x in L)
		Q[x.name] = x
	return sortList(Q)

/proc/mergeLists(var/list/L, var/list/R)
	var/Li=1
	var/Ri=1
	var/list/result = new()
	while(Li <= L.len && Ri <= R.len)
		if(sorttext(L[Li], R[Ri]) < 1)
			result += R[Ri++]
		else
			result += L[Li++]

	if(Li <= L.len)
		return (result + L.Copy(Li, 0))
	return (result + R.Copy(Ri, 0))

/proc/dd_file2list(file_path, separator)
	var/file
	if(separator == null)
		separator = "\n"
	if(isfile(file_path))
		file = file_path
	else
		file = file(file_path)
	return dd_text2list(file2text(file), separator)

/proc/dd_range(var/low, var/high, var/num)
	return max(low,min(high,num))

/proc/dd_replacetext(text, search_string, replacement_string)
	var/textList = dd_text2list(text, search_string)
	return dd_list2text(textList, replacement_string)

/proc/dd_replaceText(text, search_string, replacement_string)
	var/textList = dd_text2List(text, search_string)
	return dd_list2text(textList, replacement_string)

/proc/dd_hasprefix(text, prefix)
	var/start = 1
	var/end = length(prefix) + 1
	return findtext(text, prefix, start, end)

/proc/dd_hasPrefix(text, prefix)
	var/start = 1
	var/end = length(prefix) + 1
	return findtextEx(text, prefix, start, end)

/proc/dd_hassuffix(text, suffix)
	var/start = length(text) - length(suffix)
	if(start)
		return findtext(text, suffix, start, null)
	return

/proc/dd_hasSuffix(text, suffix)
	var/start = length(text) - length(suffix)
	if(start)
		return findtextEx(text, suffix, start, null)

/proc/dd_text2list(text, separator, var/list/withinList)
	var/textlength = length(text)
	var/separatorlength = length(separator)
	if(withinList && !withinList.len) withinList = null
	var/list/textList = new()
	var/searchPosition = 1
	var/findPosition = 1
	while(1)
		findPosition = findtext(text, separator, searchPosition, 0)
		var/buggyText = copytext(text, searchPosition, findPosition)
		if(!withinList || (buggyText in withinList)) textList += "[buggyText]"
		if(!findPosition) return textList
		searchPosition = findPosition + separatorlength
		if(searchPosition > textlength)
			textList += ""
			return textList
	return

/proc/dd_text2List(text, separator, var/list/withinList)
	var/textlength = length(text)
	var/separatorlength = length(separator)
	if(withinList && !withinList.len) withinList = null
	var/list/textList = new()
	var/searchPosition = 1
	var/findPosition = 1
	while(1)
		findPosition = findtextEx(text, separator, searchPosition, 0)
		var/buggyText = copytext(text, searchPosition, findPosition)
		if(!withinList || (buggyText in withinList)) textList += "[buggyText]"
		if(!findPosition) return textList
		searchPosition = findPosition + separatorlength
		if(searchPosition > textlength)
			textList += ""
			return textList
	return

/proc/dd_list2text(var/list/the_list, separator)
	var/total = the_list.len
	if(!total)
		return
	var/count = 2
	var/newText = text("[]", the_list[1])
	while(count <= total)
		if(separator)
			newText += separator
		newText += text("[]", the_list[count])
		count++
	return newText

/proc/dd_centertext(message, length)
	var/new_message = message
	var/size = length(message)
	var/delta = length - size
	if(size == length)
		return new_message
	if(size > length)
		return copytext(new_message, 1, length + 1)
	if(delta == 1)
		return new_message + " "
	if(delta % 2)
		new_message = " " + new_message
		delta--
	var/spaces = add_lspace("",delta/2-1)
	return spaces + new_message + spaces

/proc/dd_limittext(message, length)
	var/size = length(message)
	if(size <= length)
		return message
	return copytext(message, 1, length + 1)

/proc/angle2dir(var/degree)
	degree = ((degree+22.5)%365)
	if(degree < 45)		return NORTH
	if(degree < 90)		return NORTH|EAST
	if(degree < 135)	return EAST
	if(degree < 180)	return SOUTH|EAST
	if(degree < 225)	return SOUTH
	if(degree < 270)	return SOUTH|WEST
	if(degree < 315)	return WEST
	return NORTH|WEST

/proc/angle2text(var/degree)
	return dir2text(angle2dir(degree))

/proc/text_input(var/Message, var/Title, var/Default, var/length=MAX_MESSAGE_LEN)
	return sanitize(input(Message, Title, Default) as text, length)

/proc/scrub_input(var/Message, var/Title, var/Default, var/length=MAX_MESSAGE_LEN)
	return strip_html(input(Message,Title,Default) as text, length)

/proc/InRange(var/A, var/lower, var/upper)
	if(A < lower) return 0
	if(A > upper) return 0
	return 1

/proc/LinkBlocked(turf/A, turf/B)
	if(A == null || B == null) return 1
	var/adir = get_dir(A,B)
	var/rdir = get_dir(B,A)
	if((adir & (NORTH|SOUTH)) && (adir & (EAST|WEST)))	//	diagonal
		var/iStep = get_step(A,adir&(NORTH|SOUTH))
		if(!LinkBlocked(A,iStep) && !LinkBlocked(iStep,B)) return 0

		var/pStep = get_step(A,adir&(EAST|WEST))
		if(!LinkBlocked(A,pStep) && !LinkBlocked(pStep,B)) return 0
		return 1

	if(DirBlocked(A,adir)) return 1
	if(DirBlocked(B,rdir)) return 1
	return 0


/proc/DirBlocked(turf/loc,var/dir)
	for(var/obj/window/D in loc)
		if(!D.density)			continue
		if(D.dir == SOUTHWEST)	return 1
		if(D.dir == dir)		return 1

	for(var/obj/machinery/door/D in loc)
		if(!D.density)			continue
		if(istype(D, /obj/machinery/door/window))
			if((dir & SOUTH) && (D.dir & (EAST|WEST)))		return 1
			if((dir & EAST ) && (D.dir & (NORTH|SOUTH)))	return 1
		else return 1	// it's a real, air blocking door
	return 0

/proc/sign(x) //Should get bonus points for being the most compact code in the world!
	return x?x/abs(x):0 //((x<0)?-1:((x>0)?1:0))

/proc/getline(atom/M,atom/N)//Ultra-Fast Bresenham Line-Drawing Algorithm
	var/px=M.x		//starting x
	var/py=M.y
	var/line[] = list(locate(px,py,M.z))
	var/dx=N.x-px	//x distance
	var/dy=N.y-py
	var/dxabs=abs(dx)//Absolute value of x distance
	var/dyabs=abs(dy)
	var/sdx=sign(dx)	//Sign of x distance (+ or -)
	var/sdy=sign(dy)
	var/x=dxabs>>1	//Counters for steps taken, setting to distance/2
	var/y=dyabs>>1	//Bit-shifting makes me l33t.  It also makes getline() unnessecarrily fast.
	var/j			//Generic integer for counting
	if(dxabs>=dyabs)	//x distance is greater than y
		for(j=0;j<dxabs;j++)//It'll take dxabs steps to get there
			y+=dyabs
			if(y>=dxabs)	//Every dyabs steps, step once in y direction
				y-=dxabs
				py+=sdy
			px+=sdx		//Step on in x direction
			line+=locate(px,py,M.z)//Add the turf to the list
	else
		for(j=0;j<dyabs;j++)
			x+=dxabs
			if(x>=dyabs)
				x-=dyabs
				px+=sdx
			py+=sdy
			line+=locate(px,py,M.z)
	return line

/proc/IsGuestKey(key)
	if (findtextEx(ckey(key), "guest", 1) != 1)
		return 0

	var/i
	var/ch
	var/len = length(key)

	for (i = 7, i <= len, ++i)
		ch = text2ascii(key, i)
		if (ch < 48 || ch > 57)
			return 0

	return 1

/proc/getZlevel(var/level)
	if(level==Z_STATION)
		return pick(stationfloors)
	else if(level==Z_SPACE)
		return pick(3,4,5) //This needs to be changed
	else if(level==Z_CENTCOM)
		return pick(centcomfloors)
	else if(level==Z_ENGINE_EJECT)
		return engine_eject_z_target
	return world.maxz//Default
