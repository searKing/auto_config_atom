#!/bin/bash

function log_info() {
	echo "[INFO]$*"
}

function log_debug() {
	echo "[DEBUG]$*"
}

function log_warn() {
	echo "[WARN]$*"
}

function log_error() {
	echo "[ERROR]$*"
}

#使用方法说明
function usage() {
	cat<<USAGEEOF
	NAME
		$g_shell_name - 自动配置atom编辑器环境
	SYNOPSIS
		source $g_shell_name [命令列表] [文件名]...
	DESCRIPTION
		"$g_shell_name" --自动配置git环境
			-h
				get help log_info
			-f
				force mode to override exist file of the same name
			-v
				verbose display
			-t
				atom release type: stable(default) or beta
			-o
				the path of the output config files
			-p
				the path of the dir which needs to be refreshed
			init
				auto install & config atom .
			refresh
			 	auto build file indexes for cscope & ctags
	TIPS
	  #source insight
	  'alt-b': 'navigation-history:back'
	  'alt-g': 'navigation-history:forward'
	  'alt-c': 'atom-cscope:find-functions-calling'
	  'ctrl-/': 'project-find:show'#"no-use"
	  #eclipse
	  'alt-left': 'navigation-history:back'
	  'alt-right': 'navigation-history:forward'
	  'cmd-e': 'atom-cscope:find-this-symbol'
	  'ctrl-shift-r': 'fuzzy-finder:toggle-file-finder'
	  'ctrl-o': 'atom-ctags:toggle-file-symbols'
	  'ctrl-shift-c': 'editor:toggle-line-comments'
	  #diy
	  'alt-t': 'termrk:toggle'
	  'alt-q': 'termrk:close-terminal'
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
				"init" | "refresh")
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
					"install_apt_app_from_ubuntu" | "install_addon_from_atom" \
					| "install_app_from_ruby" | "install_app_from_python" \
					| "install_app_from_haskell" |  "install_addon_from_git" \
					| "install_dpkg_app_from_local" | "install_dpkg_app_from_internet")
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
#设置默认配置参数
function set_default_cfg_param(){

	#获取当前脚本短路径名称
	g_shell_name="$(basename "$0")"
	#切换并获取当前脚本所在路径
	g_shell_repositories_abs_dir="$(cd "$(dirname "$0")" ; pwd)"

	#覆盖前永不提示-f
	g_cfg_force_mode=0
	cd ~
	#输出文件路径
	g_cfg_output_root_dir="$(cd ~; pwd)/.atom"
	cd - &>/dev/null

	#是否显示详细信息
	g_cfg_visual=0
	#atom主程序发布版本
	g_cfg_release_type="stable"
	#配置文件名称
	g_keymap_output_file_name="keymap.cson"
  	g_preference_output_file_name="config.cson"
  	g_uncrustify_output_file_name="uncrustify.cfg"
  	#atom插件所依赖应用名
	#atom-ctags			ctags
	#atom-cscope		cscope
	#atom-beautify	uncrustify htmlbeautifier language-marko python-sqlparse
	#ruby-beautify perltidy autopep8 ruby emacs tylish-haskell
  	g_thirdparty_app_names="ctags \
	cscope \
	universalindentgui \
	uncrustify \
	python-sqlparse \
	perltidy \
	ruby \
	ruby2.0 \
	emacs \
	cabal-install \
	python-pip \
	python-dev \
	build-essential \
	shellcheck \
	gnome-terminal"
  	#app插件名
  	g_addon_names="atom-chs-menu \
	atom-ctags \
	atom-cscope \
	javascript-snippets \
	file-icons \
	vim-mode \
	navigation-history \
	atom-terminal \
	minimap \
	minimap-autohide \
	minimap-bookmarks \
	minimap-codeglance \
	minimap-find-and-replace \
	minimap-git-diff \
	minimap-hide \
	minimap-highlight-selected \
	minimap-linter \
	minimap-pigments \
	minimap-selection \
	minimap-split-diff \
	google-repo-diff-minimap \
	tree-view-finder \
	git-plus \
	pretty-json \
	language-marko \
	atom-beautify \
	linter \
	linter-shellcheck \
	markdown-writer \
	tidy-markdown \
	linter-markdown \
	markdown-scroll-sync \
	markdown-preview-plus"
  	#app插件git地址，与g_addon_names一一对应
	g_addon_urns="https://github.com/searKing/atom-chs-menu.git \
	https://github.com/searKing/atom-ctags.git \
	https://github.com/searKing/atom-cscope.git \
	https://github.com/searKing/atom-javascript-snippets.git \
	https://github.com/searKing/file-icons.git \
	https://github.com/searKing/vim-mode.git \
	https://github.com/searKing/navigation-history.git \
	https://github.com/searKing/atom-terminal.git \
	https://github.com/searKing/minimap.git \
	https://github.com/searKing/minimap-autohide.git \
	https://github.com/searKing/minimap-bookmarks.git \
	https://github.com/searKing/minimap-codeglance.git \
	https://github.com/searKing/minimap-find-and-replace.git \
	https://github.com/searKing/minimap-git-diff.git \
	https://github.com/searKing/minimap-hide.git \
	https://github.com/searKing/minimap-highlight-selected.git \
	https://github.com/searKing/minimap-linter.git \
	https://github.com/searKing/minimap-pigments.git \
	https://github.com/searKing/minimap-selection.git \
	https://github.com/searKing/minimap-split-diff.git \
	https://github.com/searKing/tree-view-finder.git \
	https://github.com/searKing/git-plus.git \
	https://github.com/searKing/pretty-json.git \
	https://github.com/searKing/atom-language-marko.git \
	https://github.com/searKing/atom-beautify.git \
	https://github.com/searKing/linter.git \
	https://github.com/searKing/linter-shellcheck.git \
	https://github.com/searKing/md-writer.git \
	https://github.com/searKing/atom-tidy-markdown.git \
	https://github.com/searKing/linter-markdown.git \
	https://github.com/searKing/markdown-scroll-sync.git \
	https://github.com/searKing/markdown-preview-plus.git"

	#gem 安装的ruby包
	g_gem_app_names="ruby-beautify \
	htmlbeautifier"
	#cabal 安装的haskell包
	g_cabal_app_names="stylish-haskell"

	#pip 安装的python包
	g_pip_app_names="pip virtualenv autopep8"

	#当前动作
	g_wrap_action=""
}
#设置默认变量参数
function set_var_param(){

  	#atom主程序名
	if [[ "$g_cfg_release_type"x =~ [Ss][Tt][Aa][Bb][Ll][Ee]x ]]; then
  		g_atom_app_name="atom"
	else
  		g_atom_app_name="atom-beta"
	fi
  	#atom主程序下载地址
  	g_atom_deb_urn="https://atom.io/download/deb?channel=$g_cfg_release_type"
	#默认插件安装路径
	g_addon_abs_root_path="$g_cfg_output_root_dir/packages"
	#需刷新的项目文件夹地址--默认即当前shell脚本所在路径
	g_refresh_dir="$g_shell_repositories_abs_dir"

	#默认配置文件绝对路径
	g_keymap_output_file_abs_name="$g_cfg_output_root_dir/$g_keymap_output_file_name"
	g_preference_output_file_abs_name="$g_cfg_output_root_dir/$g_preference_output_file_name"
	g_uncrustify_output_file_abs_name="$g_cfg_output_root_dir/$g_uncrustify_output_file_name"
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
	unset OPTIND
	while getopts "vp:fo:t:h" opt
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
		t)
			#atom主程序发布版本
			g_cfg_release_type=$OPTARG
			;;
		p)
			#需刷新的项目文件夹地址
			g_refresh_dir=$OPTARG
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
	#shift $(( $OPTIND - 1 ))
	shift $(( OPTIND - 1 ))
	if [ "$#" -lt 1 ]; then
		cat << HELPEOF
use option -h to get more log_information .
HELPEOF
		return 1
	fi
	#获取当前动作
	g_wrap_action="$1"

	set_var_param #设置默认变量参数

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
			log_error "$LINENO: install $app_name from $app_urn failed<$ret>. Exit."
			return 1
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
		wget -c "$app_urn" -O "$app_name"
		ret=$?
		if [ $ret -ne 0 ]; then
			log_error "${LINENO}: wget $app_name from $app_urn failed<$ret>. Exit."
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
		sudo apt-get install -y "$app_name"
		ret=$?
		if [ $ret -ne 0 ]; then
			log_error "${LINENO}: install $app_name failed<$ret>. Exit."
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
		apm install -q "$addon_name"
		ret=$?
		if [ $ret -ne 0 ]; then
			log_error "${LINENO}: apm install $addon_name failed<$ret>. Exit."
			return 1;
		fi
	fi
}

#安装addon应用,来源git
function install_addon_from_git()
{
	expected_params_in_num=1
	if [ $# -ne $expected_params_in_num ]; then
		log_error "${LINENO}:$FUNCNAME expercts $expected_params_in_num param_in, but receive only $#. EXIT"
		return 1;
	fi
	addon_urn=$1
	addon_name=${addon_urn##*/}
	addon_name=${addon_name%%.git}
	addon_abs_full_name="$g_addon_abs_root_path/$addon_name"
	#切换到插件packages目录
	cd "$g_addon_abs_root_path"/
	dir_names=$(ls)
	contain_name=0
	for dir_name in $dir_names ; do
		if [[ "$dir_name"x == "$addon_name"x ]]; then
			contain_name=1
			break
		fi
	done
	#contain_name=$(ls |grep -i "$addon_name")
	#检测是否安装成功msmtp
	addon_installed=0
	if [[ ( -d $addon_abs_full_name ) || ( $contain_name -ne 0 ) ]]; then
		addon_installed=1
	fi

	if [ $addon_installed -eq 0 ]; then
		git clone "$addon_urn"
		ret=$?
		if [ $ret -ne 0 ]; then
			log_error "${LINENO}: apm install $addon_name failed<$ret>. Exit."
			cd - &>/dev/null
			return 1;
		fi
		#tidy-markdown等addon需要在包目录再本地安装一下
		bash -c "cd $addon_name;apm install"		
	fi
	cd - &>/dev/null
}
#切换ruby版本
function switch_ruby_version_if_lessthan_2_0()
{
	expected_params_in_num=1
	if [ $# -ne $expected_params_in_num ]; then
		log_error "${LINENO}:$FUNCNAME expercts $expected_params_in_num param_in, but receive only $#. EXIT"
		return 1;
	fi
	deault_version_number=$1
	#检测当前ruby版本
	ruby_link=$(ls -l "$(which ruby)")
	#>=2.0 不切换，因为atom需要最低2.0
	if [[ ( "$ruby_link"x =~ ruby0 ) \
		|| ( "$ruby_link"x =~ ruby1 ) ]]; then
		#检测默认要求版本是否存在
		ruby_new_link=$(which "ruby$deault_version_number")
		if [[ "$ruby_new_link"x == ""x ]]; then
			log_error "${LINENO}:$FUNCNAME: ruby$deault_version_number is not installed yet. \
			try to install a ruby version higher than 2.0 mannauly please.EXIT"
			return 1;
		fi
		#若ruby版本存在且满足要求，则切换之
		sudo ln -sb ruby"$deault_version_number" 	"$(which ruby)"
		sudo ln -sf gem"$deault_version_number" 	"$(which gem)"
		sudo ln -sf erb"$deault_version_number" 	"$(which erb)"
		sudo ln -sf irb"$deault_version_number" 	"$(which irb)"
		sudo ln -sf rake"$deault_version_number" 	"$(which rake)"
		sudo ln -sf rdoc"$deault_version_number"	"$(which rdoc)"
		sudo ln -sf testrb"$deault_version_number" 	"$(which testrb)"
		sudo gem update --system
		sudo gem pristine --all
	fi
}
#安装ruby应用
function install_app_from_ruby()
{
	expected_params_in_num=1
	if [ $# -ne $expected_params_in_num ]; then
		log_error "${LINENO}:$FUNCNAME expercts $expected_params_in_num param_in, but receive only $#. EXIT"
		return 1;
	fi
	app_name=$1
	#检测并切换当前ruby版本
	switch_ruby_version_if_lessthan_2_0 "2.0"
	if [ $? -ne 0 ]; then
		return 1;
	fi


	#检测是否安装成功app
	if [ $g_cfg_visual -ne 0 ]; then
		which "$app_name"
	else
		which "$app_name"	1>/dev/null
	fi
	#检测是否安装成功msmtp
	if [ $? -ne 0 ]; then
		sudo gem install "$app_name"
		ret=$?
		if [ $ret -ne 0 ]; then
			#由于Ruby定期被墙，因此临时换用淘宝的server
			gem sources --remove https://rubygems.org/
			gem sources -a https://ruby.taobao.org/
			log_info "${LINENO}:switch ruby server to :"
			gem sources -l
			sudo gem install "$app_name"
			ret=$?
			gem sources --remove https://ruby.taobao.org/
			gem sources -a https://rubygems.org/
			if [[ $ret -ne 0 ]]; then
				log_error "${LINENO}: gem install app_name failed<$ret>. Exit."
				return 1
			fi
		fi
	fi
}
#安装haskell应用
function install_app_from_haskell()
{
	expected_params_in_num=1
	if [ $# -ne $expected_params_in_num ]; then
		log_error "${LINENO}:$FUNCNAME expercts $expected_params_in_num param_in, but receive only $#. EXIT"
		return 1;
	fi
	app_name=$1
	#检测是否安装成功app
	if [ $g_cfg_visual -ne 0 ]; then
		cabal list "$app_name"
	else
		cabal list "$app_name"	1>/dev/null
	fi
	#检测是否安装成功msmtp
	if [ $? -ne 0 ]; then
		cabal install "$app_name"
		ret=$?
		if [ $ret -ne 0 ]; then
			log_error "${LINENO}: gem install $app_name failed<$ret>. Exit."
			return 1;
		fi
	fi
}
#安装haskell应用
function install_app_from_python()
{
	expected_params_in_num=1
	if [ $# -ne $expected_params_in_num ]; then
		log_error "${LINENO}:$FUNCNAME expercts $expected_params_in_num param_in, but receive only $#. EXIT"
		return 1;
	fi
	app_name=$1
	#检测是否安装成功app
	if [ $g_cfg_visual -ne 0 ]; then
		cabal list "$app_name"
	else
		cabal list "$app_name"	1>/dev/null
	fi
	#检测是否安装成功msmtp
	if [ $? -ne 0 ]; then
		pip install --upgrade "$app_name"
		ret=$?
		if [ $ret -ne 0 ]; then
			log_error "${LINENO}: gem install $app_name failed<$ret>. Exit."
			return 1;
		fi
	fi
}

#自动配置快捷键映射
function auto_config_keymap()
{
	if [ -f "$g_keymap_output_file_abs_name" ]; then
	   	if [ $g_cfg_force_mode -eq 0 ]; then
			log_error "${LINENO}:$g_keymap_output_file_abs_name files is already exist. use -f to override? Exit."
			return 1
		else
			mv "$g_keymap_output_file_abs_name" "$g_keymap_output_file_abs_name".bak
    	fi
  	else
      config_file_dir=${g_keymap_output_file_abs_name%/*}
      if [ ! -d "$config_file_dir" ]; then
        mkdir -p "$config_file_dir"
      fi
  	fi
	if [[ ! -f $g_keymap_output_file_name ]]; then
		log_error "${LINENO}:$g_keymap_output_file_name files is not exist. use git clone to reload? Exit."
		return 1
	fi
	cp "$g_keymap_output_file_name" "$g_keymap_output_file_abs_name"
	#检测是否安装成功msmtp
	if [ $? -ne 0 ]; then
		log_error "${LINENO}: cp $g_keymap_output_file_name to  $g_keymap_output_file_abs_name failed. Exit."
		return 1;
	fi
}
#自动配置偏好信息
function auto_config_preference()
{
	if [ -f "$g_preference_output_file_abs_name" ]; then
	   	if [ $g_cfg_force_mode -eq 0 ]; then
			log_error "${LINENO}:$g_preference_output_file_abs_name files is already exist. use -f to override? Exit."
			return 1
		else
			mv "$g_preference_output_file_abs_name" "$g_preference_output_file_abs_name".bak
    	fi
	else
		config_file_dir=${g_preference_output_file_abs_name%/*}
		if [ ! -d "$config_file_dir" ]; then
			mkdir -p "$config_file_dir"
		fi
  	fi
	if [[ ! -f $g_preference_output_file_name ]]; then
		log_error "${LINENO}:$g_preference_output_file_name files is not exist. use git clone to reload? Exit."
		return 1
	fi

	sed "s/\/home\/searking\//\/home\/$(whoami)\//g" $g_preference_output_file_name > "$g_preference_output_file_name".tmp
	cp "$g_preference_output_file_name".tmp "$g_preference_output_file_abs_name"
	ret=$?
	rm "$g_preference_output_file_name".tmp -Rf
	#检测是否安装成功msmtp
	if [ $ret -ne 0 ]; then
		log_error "${LINENO}: cp $g_preference_output_file_name to  $g_preference_output_file_abs_name failed<$ret>. Exit."
		return 1;
	fi
}
#自动配置uncrustify格式化信息
function auto_config_uncrustify()
{
	if [ -f "$g_uncrustify_output_file_abs_name" ]; then
	   	if [ $g_cfg_force_mode -eq 0 ]; then
			log_error "${LINENO}:$g_uncrustify_output_file_abs_name files is already exist. use -f to override? Exit."
			return 1
		else
			mv "$g_uncrustify_output_file_abs_name" "$g_uncrustify_output_file_abs_name".bak
		fi
	else
		config_file_dir=${g_uncrustify_output_file_abs_name%/*}
		if [ ! -d "$config_file_dir" ]; then
			mkdir -p "$config_file_dir"
		fi
	fi
	if [[ ! -f "$g_uncrustify_output_file_name" ]]; then
		log_error "${LINENO}:$g_uncrustify_output_file_name files is not exist. use git clone to reload? Exit."
		return 1
	fi
	cp "$g_uncrustify_output_file_name" "$g_uncrustify_output_file_abs_name"
	#检测是否安装成功msmtp
	if [ $? -ne 0 ]; then
		log_error "${LINENO}: cp $g_uncrustify_output_file_name to  $g_uncrustify_output_file_abs_name failed. Exit."
		return 1;
	fi
}
#自动配置atom
function auto_config_atom()
{
	expected_params_in_num=0
	if [ $# -ne $expected_params_in_num ]; then
		log_error "${LINENO}:$FUNCNAME expercts $expected_params_in_num param_in, but receive only $#. EXIT"
		return 1;
	fi

	log_info "${LINENO}:install_dpkg_app_from_internet start. "
	#下载并安装atom主程序
	install_dpkg_app_from_internet "$g_atom_app_name" "$g_atom_deb_urn"
	if [[ $? -ne 0 ]]; then
		return 1
	fi
	log_info "${LINENO}:install_apt_app_from_ubuntu start. "
	#下载
	#安装deb应用
	call_func_serializable install_apt_app_from_ubuntu "$g_thirdparty_app_names"
	if [[ $? -ne 0 ]]; then
		return 1
	fi

	log_info "${LINENO}:install_addon_from_atom start. "
	#配置显示apm安装进度
	apm config set loglevel=http
	log_info "${LINENO}:if you got stuck for too much time(For the Great Fire Wall as you know), \
just press <ctrl-c> to ignore the current addon, \
this add_on will be installed from git automatically later. easy easy"
	#安装addon应用
	call_func_serializable install_addon_from_atom "$g_addon_names"
	if [[ $? -ne 0 ]]; then
		return 1
	fi

	log_info "${LINENO}:install_addon_from_git start. "
	#安装addon应用
	call_func_serializable install_addon_from_git "$g_addon_urns"
	if [[ $? -ne 0 ]]; then
		return 1
	fi

	log_info "${LINENO}:install_app_from_ruby start. "
	#安装ruby应用
	call_func_serializable install_app_from_ruby "$g_gem_app_names"
	if [[ $? -ne 0 ]]; then
		return 1
	fi

	log_info "${LINENO}:install_app_from_haskell start. "
	#安装haskell应用
	call_func_serializable install_app_from_haskell "$g_cabal_app_names"
	if [[ $? -ne 0 ]]; then
		return 1
	fi

	log_info "${LINENO}:install_app_from_python start. "
	#安装python应用
	call_func_serializable install_app_from_python "$g_pip_app_names"
	if [[ $? -ne 0 ]]; then
		return 1
	fi
}

#完整配置atom编辑器
function init(){
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
	auto_config_uncrustify
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
#更新工程目录的ctags、cscope等的索引文件
function refresh(){
	if [[ ! -d $g_refresh_dir ]]; then
		log_error "${LINENO}:refresh path<$g_refresh_dir> must be a dir. EXIT"
		return 1
	fi
	cd "$g_refresh_dir"
	find . -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" -o -name "*.java" -o -name "*.class" -o -name "*.sh" -o -name "*.cc" > cscope.files
	ret=$?
	if [ $ret -ne 0 ]; then
		log_error "${LINENO}:generate cscope.files failed : $ret"
		cd - &>/dev/null
		return 1
	fi
	cscope -q -R -b -i cscope.files
	ret=$?
	if [ $ret -ne 0 ]; then
		log_error "${LINENO}:cscope run failed : $ret"
		cd - &>/dev/null
		return 1
	fi
	ctags -R
	ret=$?
	if [ $ret -ne 0 ]; then
		log_error "${LINENO}:ctags run failed : $ret"
		cd - &>/dev/null
		return 1
	fi
	cd - &>/dev/null
}
function do_work(){
	call_func_serializable "$g_wrap_action"
	ret=$?
	if [ $? -ne 0 ]; then
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
	log_info "$0 $* is running successfully, restart the atom to ensure the config to make effect"
	read -n1 -p "Press any key to continue..."
	return 0
}
shell_wrap "$@"
