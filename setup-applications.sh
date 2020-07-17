#!/usr/bin/env bash

# ToDo offer grid like options 
# Single Choice
# Desktop (GUI)
# Touch (GUI + Speacial Touches)
# Web-Server (CLI)
# Custom
# -----------------------------
# Multiple Choice if Desktop 
# PiParty (Includes gphoto2, pibooth, spocon)

	dialog_checklist_array=('' '●─ Installation type ')
	dialog_checklist_array+=('Desktop' ': GUI - PIXEL, GNOME, BUDGIE, etc ...')    
	dialog_checklist_array+=('Touch' ': Same than Desktop but with battery includes for handling touch devices')        
	dialog_checklist_array+=('Web Server' ': Minimal CLI for servers ...')        

	dialog_checklist_array+=('' '●─ Build specific devices ')
	dialog_checklist_array+=('Pi Party' ': Desktop like plus pibooth, spocon, gphoto2, opencv, etc ...')        
	dialog_checklist_array+=('' '●─ Save Settings ')
	dialog_checklist_array+=('Next' ': Choose applications')

	G_WHIP_DEFAULT_ITEM=$LAST_SELECTED_NAME
	G_WHIP_BUTTON_CANCEL_TEXT='Exit'
	if G_WHIP_MENU "$text_status"; then        
        	installation_type=$f_dialog_RETURNED_VALUE
	else
		Menu_Exit
	        exit
	fi

	 dialog_checklist_array=('' '●─ CLI - Command Line Interface')
	 dialog_checklist_array+=('Fish' ': Shell with batteries and good looks when you need to go for the terminal')    
	 dialog_checklist_array+=('' '●─ GUI - Graphical User Interface ')
	 dialog_checklist_array+=('Guake' ': Drop Down Terminal') 

	if [[ $installation_type == 'Desktop' ]]; then

	    Save_Settings
	    Update_Wan_Ip

	elif [[ $G_WHIP_RETURNED_VALUE == 'Edit'* ]]; then

	    local fp=$FP_SETTINGS_UP
		[[ $G_WHIP_RETURNED_VALUE == *'Down' ]] && fp=$FP_SETTINGS_DOWN
		[[ -f $fp ]] || echo -e '#!/bin/bash\n# Clear this file completely, including line breaks, to have it removed.' > $fp
		nano $fp
		(( $(stat -c %s $fp) )) && chmod 700 $fp || rm $fp
	fi



