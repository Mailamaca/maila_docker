##!/bin/bash

##  +-----------------------------------+-----------------------------------+
##  |                                                                       |
##  | Copyright (c) 2014-2019, https://github.com/andresgongora/synth-shell |
##  | Visit the above URL for details of license and authorship.            |
##  |                                                                       |
##  | This program is free software: you can redistribute it and/or modify  |
##  | it under the terms of the GNU General Public License as published by  |
##  | the Free Software Foundation, either version 3 of the License, or     |
##  | (at your option) any later version.                                   |
##  |                                                                       |
##  | This program is distributed in the hope that it will be useful,       |
##  | but WITHOUT ANY WARRANTY; without even the implied warranty of        |
##  | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         |
##  | GNU General Public License for more details.                          |
##  |                                                                       |
##  | You should have received a copy of the GNU General Public License     |
##  | along with this program. If not, see <http://www.gnu.org/licenses/>.  |
##  |                                                                       |
##  +-----------------------------------------------------------------------+
##
##
##  =======================
##  WARNING!!
##  DO NOT EDIT THIS FILE!!
##  =======================
##
##  This file was generated by an installation script.
##  If you edit this file, it might be overwritten without warning
##  and you will lose all your changes.
##
##  Visit for instructions and more information:
##  https://github.com/andresgongora/synth-shell/
##



loadConfigFile() {
	local config_file=$1
	if [ ! -f $config_file ]; then
		exit
	fi
	while IFS="" read -r p || [ -n "$p" ]
	do
		local line=$(echo "$p" |\
		             sed -e '/^$/d;
		                     /^[ \t]*\#/d;
		                     s/[ \t][ \t]*\#.*//g;
		                     s/^[ \t]*//g;
		                     s/[ \t]*$//g')
		local line_end_trimmed=$(echo "$line" | sed -n 's/[ \t]*\\$//p')
		if [ -z "$line_end_trimmed" ]; then
			local is_multiline_next=false
		else
			local is_multiline_next=true
			local line=$line_end_trimmed
		fi
		set -- $( echo "$line" | sed -e 's/\\//g;s/".*"/X/g' )
		if [ ! -z "$line" ] && [ "$#" -gt 1 ]; then
			local config_key_name=$1
			local config_param=$(echo "$line" |\
			                     sed -e "s/$config_key_name\s*//g" |\
			                     sed -e "s/^\"//g;s/\"$//g")
			eval config_key_current_value=\$$config_key_name
			if [ ! -z "$config_key_current_value" ]; then
				export "${config_key_name}"="$config_param"
			fi
		elif [ "$#" -eq 1 ] && $is_multiline ; then
			local line_end_trimmed=$(echo $line |\
			                         sed -n 's/[ \t]*\\$//p')
			if [ -z "$line_end_trimmed" ]; then
				local multi_line=false
			else
				echo ":) $line_end_trimmed"
				local multi_line=true
				local line=$line_end_trimmed
			fi
			local config_param_old=$config_param
			local config_param=$(echo "$line" |\
			                     sed "s/^\"//g;s/\"$//g")
			eval config_key_current_value=\$$config_key_name
			if [ ! -z "$config_key_current_value" ]; then
				export "${config_key_name}"="$config_key_current_value$config_param"
			fi
		fi
		local is_multiline=$is_multiline_next
	done < $config_file
}
get8bitCode()
{
	CODE=$1
	case $CODE in
		default)
			echo 9
			;;
		none)
			echo 9
			;;
		black)
			echo 0
			;;
		red)
			echo 1
			;;
		green)
			echo 2
			;;
		yellow)
			echo 3
			;;
		blue)
			echo 4
			;;
		magenta|purple|pink)
			echo 5
			;;
		cyan)
			echo 6
			;;
		light-gray)
			echo 7
			;;
		dark-gray)
			echo 60
			;;
		light-red)
			echo 61
			;;
		light-green)
			echo 62
			;;
		light-yellow)
			echo 63
			;;
		light-blue)
			echo 64
			;;
		light-magenta)
			echo 65
			;;
		light-cyan)
			echo 66
			;;
		white)
			echo 67
			;;
		*)
			echo 0
	esac
}
getColorCode()
{
	COLOR=$1
	if [ $COLOR -eq $COLOR ] 2> /dev/null; then
		if [ $COLOR -gt 0 -a $COLOR -lt 256 ]; then
			echo "38;5;$COLOR"
		else
			echo 0
		fi
	else
		BITCODE=$(get8bitCode $COLOR)
		COLORCODE=$(($BITCODE + 30))
		echo $COLORCODE
	fi
}
getBackgroundCode()
{
	COLOR=$1
	if [ $COLOR -eq $COLOR ] 2> /dev/null; then
		if [ $COLOR -gt 0 -a $COLOR -lt 256 ]; then
			echo "48;5;$COLOR"
		else
			echo 0
		fi
	else
		BITCODE=$(get8bitCode $COLOR)
		COLORCODE=$(($BITCODE + 40))
		echo $COLORCODE
	fi
}
getEffectCode()
{
	EFFECT=$1
	NONE=0
	case $EFFECT in
	none)
		echo $NONE
		;;
	default)
		echo $NONE
		;;
	bold)
		echo 1
		;;
	bright)
		echo 1
		;;
	dim)
		echo 2
		;;
	underline)
		echo 4
		;;
	blink)
		echo 5
		;;
	reverse)
		echo 7
		;;
	hidden)
		echo 8
		;;
	strikeout)
		echo 9
		;;
	*)
		echo $NONE
	esac
}
getFormattingSequence()
{
	START='\e[0;'
	MIDLE=$1
	END='m'
	echo -n "$START$MIDLE$END"
}
applyCodeToText()
{
	local RESET=$(getFormattingSequence $(getEffectCode none))
	TEXT=$1
	CODE=$2
	echo -n "$CODE$TEXT$RESET"
}
getFormatCode()
{
	local RESET=$(getFormattingSequence $(getEffectCode none))
	if [ "$#" -eq 0 ]; then
		echo -n "$RESET"
	elif [ "$#" -eq 1 ]; then
		TEXT_COLOR=$(getFormattingSequence $(getColorCode $1))
		echo -n "$TEXT_COLOR"
	else
		FORMAT=""
		while [ "$1" != "" ]; do
			TYPE=$1
			ARGUMENT=$2
			case $TYPE in
			-c)
				CODE=$(getColorCode $ARGUMENT)
				;;
			-b)
				CODE=$(getBackgroundCode $ARGUMENT)
				;;
			-e)
				CODE=$(getEffectCode $ARGUMENT)
				;;
			*)
				CODE=""
			esac
			if [ "$FORMAT" != "" ]; then
				FORMAT="$FORMAT;"
			fi
			FORMAT="$FORMAT$CODE"
			shift
			shift
		done
		FORMAT_CODE=$(getFormattingSequence $FORMAT)
		echo -n "${FORMAT_CODE}"
	fi
}
formatText()
{
	local RESET=$(getFormattingSequence $(getEffectCode none))
	if [ "$#" -eq 0 ]; then
		echo -n "${RESET}"
	elif [ "$#" -eq 1 ]; then
		TEXT=$1
		echo -n "${TEXT}${RESET}"
	else
		TEXT=$1
		FORMAT_CODE=$(getFormatCode "${@:2}")
		applyCodeToText "$TEXT" "$FORMAT_CODE"
	fi
}
removeColorCodes()
{
	printf "$1" | sed 's/\x1b\[[0-9;]*m//g'
}
shortenPath()
{
	local path=$1
	local max_length=$2
	local default_max_length=25
	local trunc_symbol=".."
	if   [ -z "$path" ]; then
		echo ""
		exit
	elif [ -z "$max_length" ]; then
		local max_length=$default_max_length
	fi
	local path=${path/#$HOME/\~}
	local dir=${path##*/}
	local dir_length=${#dir}
	local path_length=${#path}
	local print_length=$(( ( max_length < dir_length ) ? dir_length : max_length ))
	if [ $path_length -gt $print_length ]; then
		local offset=$(( $path_length - $print_length ))
		local truncated_path=${path:$offset}
		local clean_path=${truncated_path#*/}
		local short_path=${trunc_symbol}/${clean_path}
	else
		local short_path=$path
	fi
	echo $short_path
}
enableTerminalLineWrap()
{
	printf '\e[?7h'
}
disableTerminalLineWrap()
{
	printf '\e[?7l'
}
saveCursorPosition()
{
	printf "\e[s"
}
moveCursorToSavedPosition()
{
	printf "\e[u"
}
moveCursorToRowCol()
{
	local row=$1
	local col=$2
	printf "\e[${row};${col}H"
}
moveCursorHome()
{
	printf "\e[;H"
}
moveCursorUp()
{
	local inc=$1
	if   [ -z "$inc" ]; then
		printf "\e[1A"
	elif [ $inc -gt 0 ]; then
		printf "\e[${inc}A"
	fi
}
moveCursorDown()
{
	local inc=$1
	if   [ -z "$inc" ]; then
		printf "\e[1B"
	elif [ $inc -gt 0 ]; then
		printf "\e[${inc}B"
	fi
}
moveCursorRight()
{
	local inc=$1
	if   [ -z "$inc" ]; then
		printf "\e[1C"
	elif [ $inc -gt 0 ]; then
		printf "\e[${inc}D"
	fi
}
moveCursorLeft()
{
	local inc=$1
	if   [ -z "$inc" ]; then
		printf "\e[1D"
	elif [ $inc -gt 0 ]; then
		printf "\e[${inc}C"
	fi
}
getTerminalNumRows()
{
	tput lines
}
getTerminalNumCols()
{
	tput cols
}
getTextNumRows()
{
	local rows=$(echo -e "$1" | wc -l )
	echo "$rows"
}
getTextNumCols()
{
	local columns=$(echo -e "$1" | sed 's/\x1b\[[0-9;]*m//g' | wc -L )
	echo "$columns"
}
getTextShape()
{
	echo "$(getTextNumRows) $(getTextNumCols)"
}
printWithOffset()
{
	local row=$1
	local col=$2
	local text=${@:3}
	moveCursorDown "$row"
	if [ $col -gt 0 ]; then
		col_spacer="\\\\e[${col}C"
		local text=$(echo "$text" |\
		             sed "s/^/$col_spacer/g;s/\\\\n/\\\\n$col_spacer/g")
	fi
	disableTerminalLineWrap
	echo -e "${text}"
	enableTerminalLineWrap
}
printTwoElementsSideBySide()
{
	local element_1=$1
	local element_2=$2
	local print_cols_max=$3
	local term_cols=$(getTerminalNumCols)
	if [ ! -z "$print_cols_max" ]; then
		local term_cols=$(( ( $term_cols > $print_cols_max ) ?\
			$print_cols_max : $term_cols ))
	fi
	local e_1_cols=$(getTextNumCols "$element_1")
	local e_1_rows=$(getTextNumRows "$element_1")
	local e_2_cols=$(getTextNumCols "$element_2")
	local e_2_rows=$(getTextNumRows "$element_2")
	local free_cols=$(( $term_cols - $e_1_cols - $e_2_cols ))
	if [ $free_cols -lt 1 ]; then
		local free_cols=0
	fi
	if [ $e_1_cols -gt 0 ] && [ $e_2_cols -gt 0 ]; then
		local h_pad=$(( $free_cols/3 ))
		local e_1_h_pad=$h_pad
		local e_2_h_pad=$(( $e_1_cols + 2*$h_pad ))
	elif  [ $e_1_cols -gt 0 ]; then
		local h_pad=$(( $free_cols/2 ))
		local e_1_h_pad=$h_pad
		local e_2_h_pad=0
	elif  [ $e_2_cols -gt 0 ]; then
		local h_pad=$(( $free_cols/2 ))
		local e_1_h_pad=0
		local e_2_h_pad=$h_pad
	else
		local e_1_h_pad=0
		local e_2_h_pad=0
	fi
	local e_1_v_pad=$(( ( $e_1_rows > $e_2_rows ) ?\
		0 : (( ($e_2_rows - $e_1_rows)/2 )) ))
	local e_2_v_pad=$(( ( $e_2_rows > $e_1_rows ) ?\
		0 : (( ($e_1_rows - $e_2_rows)/2 )) ))
	local max_rows=$(( ( $e_1_rows > $e_2_rows ) ? $e_1_rows : $e_2_rows ))
	for i in `seq $max_rows`; do printf "\n"; done
	moveCursorUp $max_rows
	saveCursorPosition
	printWithOffset $e_1_v_pad $e_1_h_pad "$element_1"
	moveCursorToSavedPosition
	printWithOffset $e_2_v_pad $e_2_h_pad "$element_2"
	moveCursorToSavedPosition
	moveCursorDown $(( $max_rows ))
}
function better_ls()
{
	shopt -s extglob
	local LS="$(which ls)"
	if [ $# -eq 0 ]; then
		files=$($LS -U * 2> /dev/null | wc -l)	
		if [ "$files" != "0" ]
		then 
			$LS -d {.,..,*} -lA --color=auto --human-readable \
				--time-style=long-iso --group-directories-first;
			hidden_files=$($LS -U -d .[^.]* 2> /dev/null | wc -l)	
			if [ "$hidden_files" != "0" ]
			then
				echo ""
				$LS -d .[^.]* -l --color=auto --hide='..' \
					--human-readable --time-style=long-iso \
					--group-directories-first;
			fi
		else
			$LS -d {.,..,} -lA --color=auto --human-readable \
				--time-style=long-iso --group-directories-first;
		fi
	elif [ $# -eq 1 -a -d "$1" ]; then
		local current_pwd="$PWD"
		'cd' "$1/"
		better_ls
		'cd' "$current_pwd"
	elif [ $# -eq 1 -a -f "$1" ]; then
		$LS -l --color=auto --human-readable --time-style=long-iso "$1"
	else
		$LS --color=auto --human-readable --time-style=long-iso \
		    --group-directories-first "$@";	
	fi
}
alias ls='better_ls'