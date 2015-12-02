#!/bin/bash

function log_info() {
	echo "[INFO]$@"
}

function log_warn() {
	echo "[WARN]$@"
}

function log_error() {
	echo "[ERROR]$@"
}

#自动补全脚本环境搭建
function auto_support_bash_completion()
{
	bash_name="auto_config_atom.bash"
	if [ ! -f "$bash_name" ]; then
		log_error "${LINENO}:$bash_name does NOT exist as a file. EXIT"
	fi
	sudo cp "$bash_name" /etc/bash_completion.d/
	ret=$?
	if [ $ret -ne 0 ]; then
		log_error "${LINENO}: cp $bash_name to /etc/bash_completion.d/ failed : $ret. EXIT"
		return 1
	fi
	source /etc/bash_completion.d/$bash_name
	ret=$?
	if [ $ret -ne 0 ]; then
		log_error "${LINENO}: source /etc/bash_completion.d/$bash_name failed : $ret. EXIT"
		return 1
	fi
	log_info "${LINENO}:$0 is finnished successfully"
}
if [[ $0 != "bash" ]]; then
		log_warn "${LINENO}: source me please, or it'll not work until /etc/bash_completion.d/$bash_name to be source or reboot the PC Mannually."
		read -n1 -p "Press any key to continue..."
fi
auto_support_bash_completion
