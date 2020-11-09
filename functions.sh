f_printLn() {
    echo "$(tput setaf 6)$1$(tput setaf 7)"
}

f_readP() { 
    read -p "$(tput setaf 6)$1 $(tput setaf 7)" userInput
    if [ "$userInput" = "" ] && [ "$2" != "" ]; then
        echo $2
    else
        echo $userInput
    fi
}

f_readUpper() {    
    local upper=`f_readP "$1"`
    echo "${upper^^}"
}

f_readYesNo() {
    yes_no=`f_readUpper "$1"`
    if [ "$yes_no" != "Y" ]; then
        yes_no="N"
    fi
}

f_dateDiff() {
    echo "( `date -d "$1" +%s` - `date -d "$2" +%s`) / (24*3600)" | bc -l
}

cls() {
    clear
}

# f_check_valid_int | Simple test to verify if a variable is a valid integer.
# $1=input
# $2=Optional Min value range
# $3=Optional Max value range
#	disable_error=1 to disable notify/whiptail invalid value when recieved
# 1=no | scripts killed automatically
# 0=yes
# Usage = if f_check_valid_int input; then
f_check_valid_int(){
	local return_value=1
	local input=$1
	local min=$2
	local max=$3
	[[ $disable_error == 1 ]] || local disable_error=0
	if [[ $input =~ ^-?[0-9]+$ ]]; then
		if [[ $min =~ ^-?[0-9]+$ ]]; then
			if (( $input >= $min )); then
				if [[ $max =~ ^-?[0-9]+$ ]]; then
					if (( $input <= $max )); then
						return_value=0
					elif (( ! $disable_error )); then
						f_dialog_msg "Input value \"$input\" is higher than allowed \"$max\". No changes applied."
					fi
				else
					return_value=0
				fi
			elif (( ! $disable_error )); then
				f_dialog_msg "Input value \"$input\" is lower than allowed \"$min\". No changes applied."
			fi
		else
			return_value=0
		fi
	elif (( ! $disable_error )); then
		f_dialog_msg "Invalid input value \"$input\". No changes applied."
	fi
	unset disable_error
	return $return_value
}

#-----------------------------------------------------------------------------------
# Whiptail 
# - Automatically detects/processes for G_INTERACTIVE
# - Borrowed from DietPi, cheers!
#-----------------------------------------------------------------------------------
# Input:
# - dialog_default_item		    | Optional, to set the default selected/menu item or input box entry
# - dialog_size_X_Max=50	    | Optional, limits X to value, if below available screen X limits
# - dialog_button_OK_text	    | Optional, change as needed, defaults to "Ok"
# - dialog_button_CANCEL_text	| Optional, change as needed, defaults to "Cancel"
# - dialog_menu_array	    	| Required for f_dialog_menu to set available menu entries, 2 array indices per line: ('item' 'description')
# - dialog_checklist_array	    | Required for f_dialog_check_list set available checklist options, 3 array indices per line: ('item' 'description' 'on'/'off')
# Output:
# - f_dialog_RETURNED_VALUE | Returned value from inputbox/menu/checklist based whiptail items

# f_dialog_clean | Clear vars after run of whiptail
f_dialog_clean(){
    unset dialog_default_item dialog_size_X_Max
	unset dialog_button_OK_text dialog_button_CANCEL_text
	unset dialog_menu_array dialog_checklist_array
}

# Run once, to be failsafe in case any exported/environment variables are left from originating shell
f_dialog_clean

f_dialog_max_dimensions() {
    local dimensions=`echo -e "lines\ncols"|tput -S`
    terminal_max_height=`echo $test | cut -f 1 -d " "`
    terminal_max_widht=`echo $test | cut -f 2 -d " "`
}

# f_dialog_init
# - Update target whiptail size, based on current screen dimensions
# - $1 = input mode | 2: Z=dialog_menu_array 3: Z=dialog_checklist_array
f_dialog_init(){
	# Automagically set size of whiptail box and contents according to screen size and whiptail type
	local input_mode=$1
	# Update backtitle
	#dialog_BACKTITLE=$G_HW_MODEL_DESCRIPTION

	# Set default button text, if not defined
	dialog_button_OK_text=${dialog_button_OK_text:-Ok}
	dialog_button_CANCEL_text=${dialog_button_CANCEL_text:-Cancel}
	# Get current screen dimensions
	read -r dialog_SIZE_Y dialog_SIZE_X < <(stty size)
	# - Limit and reset non-valid integer values to 120 characters per line
	(( $dialog_SIZE_X <= 120 )) || dialog_SIZE_X=120
	# - If width is below 9 characters, the text field starts to cover the internal margin, regardless of content or button text, hence 9 is the absolute minimum.
	(( $dialog_SIZE_X >= 9 )) || dialog_SIZE_X=9
	# - dialog_size_X_Max allows to further reduce width, e.g. to keep X/Y ratio in beautiful range.
	disable_error=1 f_check_valid_int "$dialog_size_X_Max" 0 $dialog_SIZE_X && dialog_SIZE_X=$dialog_size_X_Max
	# - If height is below 7 lines, not a single line of text can be shown, hence 7 is the reasonable minimum.
	(( $dialog_SIZE_Y >= 7 )) || dialog_SIZE_Y=7
	# Calculate lines required to show all text content
	local dialog_lines_text=6 # Due to internal margins, the available height is 6 lines smaller
	local dialog_chars_text=$(( $dialog_SIZE_X - 4 )) # Due to internal margins, the available width is 4 characters smaller
	dialog_SCROLLTEXT= # Add "--scrolltext" automatically if text height exceeds max available
	Process_Line(){
		local split line=$1
		# Split line by "\n" newline escape sequences, the only one which is interpreted by whiptail, in a strict way: "\\n" still creates a newline, hence the sequence cannot be escaped!
		while [[ $line == *'\n'* ]]
		do
			# Grab first line
			split=${line%%\\n*}
			# Add required line + additional lines due to automated line breaks, if text exceeds internal box
			(( dialog_lines_text += 1 + ( ${#split} - 1 ) / $dialog_chars_text ))
			# Stop counting if required size exceeds screen already
			(( $dialog_lines_text > $dialog_SIZE_Y )) && return 1
			# Cut away handled line from string
			line=${line#*\\n}
		done
		# Process remaining line
		(( dialog_lines_text += 1 + ( ${#line} - 1 ) / $dialog_chars_text ))
		# Stop counting if required size exceeds screen already
		(( $dialog_lines_text <= $dialog_SIZE_Y )) || return 1
	}
	# - dialog_MESSAGE
	if [[ $dialog_ERROR$dialog_MESSAGE ]]; then
		while read -r line; do Process_Line "$line" || break; done <<< "$dialog_ERROR$dialog_MESSAGE"
	# - dialog_TEXTFILE
	elif [[ $dialog_TEXTFILE ]]; then
		while read -r line; do Process_Line "$line" || break; done < "$dialog_TEXTFILE"
	fi
	unset Process_Line
	# Process menu and checklist
	# - f_dialog_menu
	if [[ $input_mode == 2 ]]; then
		# Requires 1 additional line for text
		((dialog_lines_text++))
		# Lines required for menu: ( ${#array} + 1 ) to round up on uneven array entries
		dialog_SIZE_Z=$(( ( ${#dialog_menu_array[@]} + 1 ) / 2 ))
		# Auto length for ─
		# - Get max length of all lines in array indices 1 + 2n | '' 'this one'
		local i
		local character_count_max=0
		for (( i=1; i<${#dialog_menu_array[@]}; i+=2 ))
		do
			(( ${#dialog_menu_array[$i]} > $character_count_max )) && character_count_max=${#dialog_menu_array[$i]}
		done
		((character_count_max--)) # -1 for additional ●
		# - Now add the additional required lines
		for (( i=1; i<${#dialog_menu_array[@]}; i+=2 ))
		do
			[[ ${dialog_menu_array[$i]} == '●'* ]] || continue
			while (( ${#dialog_menu_array[$i]} < $character_count_max ))
			do
				dialog_menu_array[$i]+='─'
			done
			dialog_menu_array[$i]+='●'
		done
	# - f_dialog_check_list
	elif [[ $input_mode == 3 ]]; then
		# Lines required for checklist: ( ${#array} + 2 ) to round up single+double array entries
		dialog_SIZE_Z=$(( ( ${#dialog_checklist_array[@]} + 2 ) / 3 ))
		# Auto length for ─
		# - Get max length of all lines in array indices 1 + 3n 1st | '' 'this one' ''
		local i
		local character_count_max=0
		for (( i=1; i<${#dialog_checklist_array[@]}; i+=3 ))
		do
			(( ${#dialog_checklist_array[$i]} > $character_count_max )) && character_count_max=${#dialog_checklist_array[$i]}
		done
		((character_count_max--)) # -1 for additional ●
		# - Now add the additional required lines
		for (( i=1; i<${#dialog_checklist_array[@]}; i+=3 ))
		do
			[[ ${dialog_checklist_array[$i]} == '●'* ]] || continue
			while (( ${#dialog_checklist_array[$i]} < $character_count_max ))
			do
				dialog_checklist_array[$i]+='─'
			done
			dialog_checklist_array[$i]+='●'
		done
	fi
	# Adjust sizes to fit content
	# - f_dialog_menu/f_dialog_check_list needs to hold text + selection field (dialog_SIZE_Z)
	if [[ $input_mode == [23] ]]; then
		# If required lines would exceed screen, reduce dialog_SIZE_Z
		if (( $dialog_lines_text + $dialog_SIZE_Z > $dialog_SIZE_Y )); then
			dialog_SIZE_Z=$(( $dialog_SIZE_Y - $dialog_lines_text ))
			# Assure at least 2 lines to have the selection field scroll bar identifiable
			if (( $dialog_SIZE_Z < 2 )); then
				dialog_SIZE_Z=2
				# Since text is partly hidden now, add text scroll ability and info to backtitle
				dialog_SCROLLTEXT='--scrolltext'
				dialog_BACKTITLE+=' | Use up/down buttons to scroll text'
			fi
		# else reduce dialog_SIZE_Y to hold all content
		else
			dialog_SIZE_Y=$(( $dialog_lines_text + $dialog_SIZE_Z ))
		fi
	# - Everything else needs to hold text only
	elif (( $dialog_lines_text > $dialog_SIZE_Y )); then
		dialog_SCROLLTEXT='--scrolltext'
		dialog_BACKTITLE+=' | Use up/down buttons to scroll text'
	else
		dialog_SIZE_Y=$dialog_lines_text
	fi
}

# f_dialog_msg "message"
# - Display a message from input string
f_dialog_msg(){
	local dialog_MESSAGE=$@
    local dialog_ERROR dialog_BACKTITLE dialog_SCROLLTEXT dialog_SIZE_X dialog_SIZE_Y
	f_dialog_init
	whiptail ${G_PROGRAM_NAME+--title "$G_PROGRAM_NAME"} --backtitle "$dialog_BACKTITLE" --msgbox "$dialog_MESSAGE" --ok-button "$dialog_button_OK_text" $dialog_SCROLLTEXT $dialog_SIZE_Y $dialog_SIZE_X
	
    f_dialog_clean
}

# f_dialog_view_file "/path/to/file"
# - Display content from input file
# - Exit code: 1=file not found, else=file shown or noninteractive
f_dialog_view_file(){
	local result=0
	local dialog_ERROR dialog_MESSAGE dialog_BACKTITLE dialog_SCROLLTEXT dialog_SIZE_X dialog_SIZE_Y dialog_TEXTFILE=$1 header='File viewer'
	[[ $log == 1 ]] && header='Log viewer'
	if [[ -f $dialog_TEXTFILE ]]; then
		f_dialog_init
		whiptail --title "${G_PROGRAM_NAME+$G_PROGRAM_NAME | }$header" --backtitle "$dialog_BACKTITLE" --textbox "$dialog_TEXTFILE" --ok-button "$dialog_button_OK_text" $dialog_SCROLLTEXT $dialog_SIZE_Y $dialog_SIZE_X
	else
		result=1
		dialog_ERROR="[FAILED] File does not exist: $dialog_TEXTFILE"
		f_dialog_init
		whiptail --title "${G_PROGRAM_NAME+$G_PROGRAM_NAME | }$header" --backtitle "$dialog_BACKTITLE" --msgbox "$dialog_ERROR" --ok-button "$dialog_button_OK_text" $dialog_SCROLLTEXT $dialog_SIZE_Y $dialog_SIZE_X
	fi
	f_dialog_clean
	return $result
}

# f_dialog_yes_no "message"
# - Prompt user for Yes/No | Ok/Cancel choice and return result
# - Exit code: 0=Yes/Ok, else=No/Cancel or noninteractive
f_dialog_yes_no(){
	local result=1
	local dialog_ERROR dialog_BACKTITLE dialog_SCROLLTEXT dialog_SIZE_X dialog_SIZE_Y dialog_MESSAGE=$@
	f_dialog_init
	local default_no='--defaultno'
	[[ ${dialog_default_item,,} == 'yes' || ${dialog_default_item,,} == 'ok' ]] && default_no=
	whiptail ${G_PROGRAM_NAME+--title "$G_PROGRAM_NAME"} --backtitle "$dialog_BACKTITLE" --yesno "$dialog_MESSAGE" --yes-button "$dialog_button_OK_text" --no-button "$dialog_button_CANCEL_text" $default_no $dialog_SCROLLTEXT $dialog_SIZE_Y $dialog_SIZE_X
	result=$?
	f_dialog_clean
	return $result
}

# f_dialog_input "message"
# - Prompt user to input text and save it to f_dialog_RETURNED_VALUE
# - Exit code: 0=input done, else=user cancelled or noninteractive
f_dialog_input(){
	local result=1
	unset f_dialog_RETURNED_VALUE # in case left from last f_dialog
	local dialog_ERROR dialog_BACKTITLE dialog_SCROLLTEXT dialog_SIZE_X dialog_SIZE_Y dialog_MESSAGE=$@
	while :
	do
		f_dialog_init
		f_dialog_RETURNED_VALUE=$(whiptail ${G_PROGRAM_NAME+--title "$G_PROGRAM_NAME"} --backtitle "$dialog_BACKTITLE" --inputbox "$dialog_ERROR$dialog_MESSAGE" --ok-button "$dialog_button_OK_text" --cancel-button "$dialog_button_CANCEL_text" $dialog_SCROLLTEXT $dialog_SIZE_Y $dialog_SIZE_X "$dialog_default_item" 3>&1 1>&2 2>&3-; echo $? > /tmp/.f_dialog_input_RESULT)
		result=$(</tmp/.f_dialog_input_RESULT); rm /tmp/.f_dialog_input_RESULT
		[[ $result == 0 && -z $f_dialog_RETURNED_VALUE ]] && { dialog_ERROR='[FAILED] An input value was not entered, please try again...\n\n'; continue; }
		break
	done
	f_dialog_clean
	return $result
}

# f_dialog_pwd "message"
# - Prompt user to input password and save it in variable "result"
# - Originating script must "unset result" after value has been handled for security reasons!
# - Exit code: 0=input done + passwords match, else=noninteractive (Cancelling is disabled since no password in originating script can cause havoc!)
f_dialog_pwd(){
	local return_value=1
	unset result # in case left from last call
	local dialog_ERROR dialog_BACKTITLE dialog_SCROLLTEXT dialog_SIZE_X dialog_SIZE_Y dialog_MESSAGE=$@
	while :
	do
		f_dialog_init
		local password_0=$(whiptail ${G_PROGRAM_NAME+--title "$G_PROGRAM_NAME"} --backtitle "$dialog_BACKTITLE" --passwordbox "$dialog_ERROR$dialog_MESSAGE" --ok-button "$dialog_button_OK_text" --nocancel $dialog_SCROLLTEXT $dialog_SIZE_Y $dialog_SIZE_X 3>&1 1>&2 2>&3-)
		[[ $password_0 ]] || { dialog_ERROR='[FAILED] No password entered, please try again...\n\n'; continue; }
		local password_1=$(whiptail ${G_PROGRAM_NAME+--title "$G_PROGRAM_NAME"} --backtitle "$dialog_BACKTITLE" --passwordbox 'Please enter the new password again:' --ok-button "$dialog_button_OK_text" --nocancel 7 $dialog_SIZE_X 3>&1 1>&2 2>&3-)
		[[ $password_0 == "$password_1" ]] || { dialog_ERROR='[FAILED] Passwords do not match, please try again...\n\n'; continue; }
		result=$password_0
		return_value=0
		break
	done
	f_dialog_clean
	return $return_value
}

# f_dialog_menu "message"
# - Prompt user to select option from dialog_menu_array and save choice to f_dialog_RETURNED_VALUE
# - Exit code: 0=selection done, else=user cancelled or noninteractive
f_dialog_menu(){
	local result=1
	unset f_dialog_RETURNED_VALUE # in case left from last call

	local dialog_ERROR dialog_BACKTITLE dialog_SCROLLTEXT dialog_SIZE_X dialog_SIZE_Y dialog_SIZE_Z dialog_MESSAGE=$@
	f_dialog_init 2
	f_dialog_RETURNED_VALUE=$(whiptail ${G_PROGRAM_NAME+--title "$G_PROGRAM_NAME"} --backtitle "$dialog_BACKTITLE" --menu "$dialog_MESSAGE" --ok-button "$dialog_button_OK_text" --cancel-button "$dialog_button_CANCEL_text" --default-item "$dialog_default_item" $dialog_SCROLLTEXT $dialog_SIZE_Y $dialog_SIZE_X $dialog_SIZE_Z "${dialog_menu_array[@]}" 3>&1 1>&2 2>&3-; echo $? > /tmp/.dialog_MENU_RESULT)
	result=$(</tmp/.dialog_MENU_RESULT); rm /tmp/.dialog_MENU_RESULT

	f_dialog_clean
	return $result
}

# f_dialog_check_list "message"
# - Prompt user to select multiple options from dialog_checklist_array and save choice to f_dialog_RETURNED_VALUE
# - Exit code: 0=selection done, else=user cancelled or noninteractive
f_dialog_check_list(){
	local result=1
	unset f_dialog_RETURNED_VALUE # in case left from last call

	local dialog_ERROR dialog_BACKTITLE dialog_SCROLLTEXT dialog_SIZE_X dialog_SIZE_Y dialog_SIZE_Z dialog_MESSAGE=$@
	f_dialog_init 3
	f_dialog_RETURNED_VALUE=$(whiptail ${G_PROGRAM_NAME+--title "$G_PROGRAM_NAME"} --backtitle "$dialog_BACKTITLE" --checklist "$dialog_MESSAGE" --separate-output --ok-button "$dialog_button_OK_text" --cancel-button "$dialog_button_CANCEL_text" --default-item "$dialog_default_item" $dialog_SCROLLTEXT $dialog_SIZE_Y $dialog_SIZE_X $dialog_SIZE_Z "${dialog_checklist_array[@]}" 3>&1 1>&2 2>&3-; echo $? > /tmp/.dialog_CHECKLIST_RESULT)
	f_dialog_RETURNED_VALUE=$(echo -e "$f_dialog_RETURNED_VALUE" | tr '\n' ' ')
	result=$(</tmp/.dialog_CHECKLIST_RESULT); rm /tmp/.dialog_CHECKLIST_RESULT

	f_dialog_clean
	return $result
}

#-----------------------------------------------------------------------------------
# Package manager functions
# ToDo run different package managers according to distro
#-----------------------------------------------------------------------------------

f_app_install() {
    #ToDo run different package managers according to distro
    sudo apt install "$@" -y
}

f_app_is_installed() {
    package_info="$(dpkg -s $1)"

    if [ -z "$package_info" ] || [ "$package_info" = *"not installed"* ]; then
        false
    else
        true
    fi
}

f_pip_app_is_installed() {
	package_info="$(pip3 show $1)"
	
	if [ "$package_info" = *"not installed"* ]; then
        false
    else
        true
    fi
}

f_repository_is_installed() {
    repository_list=`egrep -v '^#|^ *$' /etc/apt/sources.list /etc/apt/sources.list.d/*`

    if [ "$package_info" = *"$1"* ]; then
        false
    else
        true
    fi
}

f_pkg_manager_update() {
	sudo apt-get update
}

#-----------------------------------------------------------------------------------
# File system functions
#-----------------------------------------------------------------------------------

f_file_exists() {
	if [ -f $1 ]; then
		true
	else 
		false
	fi
}