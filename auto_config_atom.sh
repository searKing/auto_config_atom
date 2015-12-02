#!/bin/bash

function log_info() {
	echo "[INFO]$@"
}

function log_debug() {
	echo "[DEBUG]$@"
}

function log_warn() {
	echo "[WARN]$@"
}

function log_error() {
	echo "[ERROR]$@"
}

#使用方法说明
function usage() {
	cat<<USAGEEOF
	NAME
		$g_shell_name - 自动配置邮件发送环境
	SYNOPSIS
		source $g_shell_name [命令列表] [文件名]...
	DESCRIPTION
		$g_git_wrap_shell_name --自动配置git环境
			-h
				get help log_info
			-f
				force mode to override exist file of the same name
			-v
				verbose display
			-o
				the path of the out files
	AUTHOR 作者
    	由 searKing Chan 完成。

    DATE   日期
		2015-12-02

	REPORTING BUGS 报告缺陷
    	向 searKingChan@gmail.com 报告缺陷。
	REFERENCE	参见
		https://github.com/searKing/GithubHub.git
USAGEEOF
}
#循环嵌套调用程序,每次输入一个参数
#本shell中定义的其他函数都认为不支持空格字符串的序列化处理（pull其实也支持）
#@param func_in 	函数名 "func" 只支持单个函数
#@param param_in	以空格分隔的字符串"a b c",可以为空
function call_func_serializable()
{
	func_in=$1
	param_in=$2
	case $# in
		0)
			log_error "${LINENO}:$FUNCNAME expercts 1 param in at least, but receive only $#. EXIT"
			return 1
			;;
		1)
			case $func_in in
				"auto_config_atom" | "auto_config_keymap" | "auto_config_preference")
					$func_in
					;;
				*)
					log_error "${LINENO}:Invalid serializable cmd with no param: $func_in"
					return 1
					;;
			esac
			;;
		*)	#有参数函数调用
			error_num=0
			for curr_param in $param_in
			do
				case $func_in in
					"install_apt_app_from_ubuntu" | "install_addon_from_atom" )
						msmtp_generate_account_template_name=$curr_param
						$func_in "$msmtp_generate_account_template_name"
						if [ $? -ne 0 ]; then
							error_num+=0
						fi
					 	;;
					*)
						log_error "${LINENO}:Invalid serializable cmd with params: $func_in"
						return 1
					 	;;
				esac
			done
			return $error_num
			;;
	esac
}

#解析输入参数
function parse_params_in() {
	if [ "$#" -lt 0 ]; then
		cat << HELPEOF
use option -h to get more log_information .
HELPEOF
		return 1
	fi
	set_default_cfg_param #设置默认配置参数
	set_default_var_param #设置默认变量参数
	unset OPTIND
	while getopts "vfo:h" opt
	do
		case $opt in
		f)
			#覆盖前永不提示
			g_cfg_force_mode=1
			;;
		o)
			#输出文件路径
			g_cfg_output_root_dir=$OPTARG
			;;
		v)
			#是否显示详细信息
			g_cfg_visual=1
			;;
		h)
			usage
			return 1
			;;
		?)
			log_error "${LINENO}:$opt is Invalid"
			return 1
			;;
		*)
			;;
		esac
	done
	#去除options参数
	shift $(($OPTIND - 1))

	if [ "$#" -lt 0 ]; then
		cat << HELPEOF
use option -h to get more log_information .
HELPEOF
		return 0
	fi
  #默认插件安装路径
  g_addon_abs_root_path="$g_cfg_output_root_dir/packages"
	#默认配置文件绝对路径
  g_keymap_output_file_abs_name="$g_cfg_output_root_dir/$g_config_keymap_file_name"
  g_preference_output_file_abs_name="$g_cfg_output_root_dir/$g_preference_output_file_name"

}


#安装deb应用
function install_dpkg_app_from_local()
{
	expected_params_in_num=2
	if [ $# -ne $expected_params_in_num ]; then
		log_error "${LINENO}:$FUNCNAME expercts $expected_params_in_num param_in, but receive only $#. EXIT"
		return 1;
	fi
	app_name=$1
	app_urn=$2

  #检测是否安装成功app
  if [ $g_cfg_visual -ne 0 ]; then
    which "$app_name"
  else
    which "$app_name"	1>/dev/null
  fi

  if [ $? -ne 0 ]; then
    sudo dpkg -i "$app_urn"
    ret=$?
    if [ $ret -ne 0 ]; then
      log_error "${LINENO}: install "$app_name" from "$app_urn" failed($ret). Exit."
      return 1;
    fi
  fi
}
#安装deb应用
function install_dpkg_app_from_internet()
{
	expected_params_in_num=2
	if [ $# -ne $expected_params_in_num ]; then
		log_error "${LINENO}:$FUNCNAME expercts $expected_params_in_num param_in, but receive only $#. EXIT"
		return 1;
	fi
	app_name=$1
	app_urn=$2
  #检测是否安装成功app
  if [ $g_cfg_visual -ne 0 ]; then
    which "$app_name"
  else
    which "$app_name"	1>/dev/null
  fi
  if [ $? -ne 0 ]; then
    wget -c "$app_urn" -O $app_name
    ret=$?
    if [ $ret -ne 0 ]; then
      log_error "${LINENO}: wget "$app_name" from "$app_urn" failed($ret). Exit."
      return 1;
    fi
  fi
  install_dpkg_app_from_local "$app_name" "$app_name"
  if [[ $? -ne 0 ]]; then
    return 1
  fi

}
#安装apt应用
function install_apt_app_from_ubuntu()
{
	expected_params_in_num=1
	if [ $# -ne $expected_params_in_num ]; then
		log_error "${LINENO}:$FUNCNAME expercts $expected_params_in_num param_in, but receive only $#. EXIT"
		return 1;
	fi
	app_name=$1
	#检测是否安装成功app
	if [ $g_cfg_visual -ne 0 ]; then
		which "$app_name"
	else
		which "$app_name"	1>/dev/null
	fi

	if [ $? -ne 0 ]; then
		sudo apt-get install "$app_name"
		ret=$?
		if [ $ret -ne 0 ]; then
			log_error "${LINENO}: install "$app_name" failed($ret). Exit."
			return 1;
		fi
	fi
}

#安装addon应用
function install_addon_from_atom()
{
	expected_params_in_num=1
	if [ $# -ne $expected_params_in_num ]; then
		log_error "${LINENO}:$FUNCNAME expercts $expected_params_in_num param_in, but receive only $#. EXIT"
		return 1;
	fi
  addon_name=$1
  addon_abs_full_name="$g_addon_abs_root_path/$addon_name"
	#检测是否安装成功msmtp
  addon_installed=0
  if [[ -d $addon_abs_full_name ]]; then
    addon_installed=1
  fi

	if [ $addon_installed -eq 0 ]; then
		apm install "$addon_name"
		ret=$?
		if [ $ret -ne 0 ]; then
			log_error "${LINENO}: apm install "$addon_name" failed($ret). Exit."
			return 1;
		fi
	fi
}
#设置默认配置参数
function set_default_cfg_param(){
	#覆盖前永不提示-f
	g_cfg_force_mode=0
	cd ~
	#输出文件路径
	g_cfg_output_root_dir="$(cd ~; pwd)/.atom"
	cd - &>/dev/null

	#是否显示详细信息
	g_cfg_visual=0
	#配置文件名称
	g_config_keymap_file_name="keymap.cson"
  g_preference_output_file_name="config.cson"
  #atom主程序名
  g_atom_app_name="atom"
  #atom主程序下载地址
  g_atom_deb_urn="https://atom.io/download/deb"
  #atom插件所依赖应用名
  g_thirdparty_app_names="ctags cscope"
  #app插件名
  g_addon_names="atom-chs-menu \
  atom-ctags \
  atom-cscope \
  javascript-snippets \
  file-icons \
  navigation-history \
  Termrk \
  tree-view-finder \
  git-plus \
  pretty-json \
  formatter"
}
#设置默认变量参数
function set_default_var_param(){
	#获取当前脚本短路径名称
	g_shell_name="$(basename $0)"
	#切换并获取当前脚本所在路径
	g_shell_repositories_abs_dir="$(cd `dirname $0`; pwd)"
}
#自动配置快捷键映射
function auto_config_keymap()
{
	if [ -f $g_keymap_output_file_abs_name ]; then
	   	if [ $g_cfg_force_mode -eq 0 ]; then
			log_error "${LINENO}:"$g_keymap_output_file_abs_name" files is already exist. use -f to override? Exit."
			return 1
		else
    		rm "$g_keymap_output_file_abs_name" -Rf
    fi
  else
      config_file_dir=${g_keymap_output_file_abs_name%/*}
      if [ ! -d $config_file_dir ]; then
        mkdir -p "$config_file_dir"
      fi
  fi

    cat > $g_keymap_output_file_abs_name <<CONFIGEOF
'atom-text-editor.vim-mode':
  #关闭vim-mode下的快捷键，ctrl-c/v与系统冲突
  #'ctrl-c': 'vim-mode:reset-normal-mode'
  'ctrl-c': 'core:copy'
'atom-text-editor.vim-mode.normal-mode':
  #'ctrl-v': 'vim-mode:activate-blockwise-visual-mode'
  'ctrl-v': 'core:paste'
  #'ctrl-a': 'vim-mode:increase'
  'ctrl-a': 'core:select-all'
'atom-text-editor.vim-mode.visual-mode':
  #'ctrl-v': 'vim-mode:activate-blockwise-visual-mode'
  'ctrl-v': 'core:paste'

'atom-text-editor.vim-mode:not(.insert-mode)':
  #'ctrl-f': 'vim-mode:scroll-full-screen-down'
  'ctrl-f': 'find-and-replace:show'
#导航
'atom-text-editor':
  'alt-g': 'navigation-history:back'
  'alt-b': 'navigation-history:forward'

'.platform-linux atom-text-editor':
  #跳转到定义--ctrl+left
  #'alt-g': 'atom-ctags:go-to-declaration'
  #跳转回调用
  #'alt-b': 'atom-ctags:return-from-declaration'
  #Symbol Definition
  #'alt-/': 'atom-cscope:this-global-definition'
  #Jump to Caller
	'alt-c': 'atom-cscope:find-functions-calling'
	#Jump to definition
	'cmd-e': 'atom-cscope:find-this-symbol'
'atom-workspace':
  'alt-t': 'termrk:toggle'
  'alt-q': 'termrk:close-terminal'
  #find . -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" -o -name "*.java" -o -name "*.class" -o -name "*.sh" -o -name "*.cc" > cscope.files
  #cscope -q -R -b -i cscope.files
  #ctags -R
CONFIGEOF
}
#自动配置偏好信息
function auto_config_preference()
{
	if [ -f $g_preference_output_file_abs_name ]; then
	   	if [ $g_cfg_force_mode -eq 0 ]; then
			log_error "${LINENO}:"$g_preference_output_file_abs_name" files is already exist. use -f to override? Exit."
			return 1
		else
    		rm "$g_preference_output_file_abs_name" -Rf
    fi
  else
      config_file_dir=${g_preference_output_file_abs_name%/*}
      if [ ! -d $config_file_dir ]; then
        mkdir -p "$config_file_dir"
      fi
  fi
  cat > "$g_preference_output_file_abs_name" <<CONFIGEOF
"*":
  "exception-reporting":
    userId: "3e7650fb-7f09-2225-ecd9-24a24ac508ba"
  welcome:
    showOnStartup: true
  core:
    disabledPackages: [
      "symbols-view"
      "run-in-terminal"
    ]
    audioBeep: false
  editor:
    invisibles: {}
    fontSize: 13
  "atom-ctags":
    GotoSymbolKey: [
      "ctrl"
    ]
  "atom-cscope": {}
  "vim-mode": {}
  "android-debugger": {}
  "navigation-history":
    maxNavigationsToRemember: 10000
  "run-in-terminal":
    save_before_launch: false
  "Termrk":
    useDefaultKeymap: false
    defaultHeight: 81
  "minimap": {}
  "git-plus": {}
  Termrk:
    useDefaultKeymap: false
    defaultHeight: 81
CONFIGEOF
}
#自动配置atom
function auto_config_atom()
{
	expected_params_in_num=0
	if [ $# -ne $expected_params_in_num ]; then
		log_error "${LINENO}:$FUNCNAME expercts $expected_params_in_num param_in, but receive only $#. EXIT"
		return 1;
	fi

  #下载并安装atom主程序
  install_dpkg_app_from_internet "$g_atom_app_name" "$g_atom_deb_urn"
  if [[ $? -ne 0 ]]; then
    return 1
  fi
  #下载
  #安装deb应用
  call_func_serializable install_apt_app_from_ubuntu "$g_thirdparty_app_names"
  if [[ $? -ne 0 ]]; then
    return 1
  fi
  #安装addon应用
  call_func_serializable install_addon_from_atom "$g_addon_names"
  if [[ $? -ne 0 ]]; then
    return 1
  fi
}



function do_work(){

	auto_config_atom
  ret=$?
	if [ $ret -ne 0 ]; then
		return 1
	fi
  auto_config_keymap
  ret=$?
  if [ $ret -ne 0 ]; then
  	return 1
  fi
  auto_config_preference
  ret=$?
  if [ $ret -ne 0 ]; then
    return 1
  fi
}
################################################################################
#脚本开始
################################################################################
function shell_wrap()
{
	#含空格的字符串若想作为一个整体传递，则需加*
	#"$*" is equivalent to "$1c$2c...", where c is the first character of the value of the IFS variable.
	#"$@" is equivalent to "$1" "$2" ...
	#$*、$@不加"",则无区别，
	parse_params_in "$@"
	if [ $? -ne 0 ]; then
		return 1
	fi
	do_work
	if [ $? -ne 0 ]; then
		return 1
	fi
	log_info "$0 $@ is running successfully"
	read -n1 -p "Press any key to continue..."
	return 0
}
shell_wrap "$@"
