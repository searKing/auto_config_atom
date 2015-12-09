function _atom_autocomplete
{
    #local定义变量
    #cur表示当前光标下的单词
    #prev表示上一个单词
    #opts表示选项
    local cur prev opts
    #COMP_CWORD 已输入单词个数
    #给COMPREPLY赋值之前，最好将它重置清空，避免被其它补全函数干扰
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="init refresh -h -f -v -o -p"

    case "$prev" in
    init | refresh)
        COMPREPLY=()
        return 0
        ;;
    -p | -o)
    	#定位当前目录的文件
    	#http://cnswww.cns.cwru.edu/php/chet/bash/NEWS.
        COMPREPLY=( $(compgen -o default -o plusdirs -f -- "$cur") )
        return 0
        ;;
    -t)
        #atom版本发布类型
        COMPREPLY=( $(compgen -W "stable beta" -- "$cur" ))
        return 0
        ;;
    -f)
        COMPREPLY=( $(compgen -W "init refresh -o -p" -- "$cur" ))
        return 0
        ;;
    *)
        local prev2="${COMP_WORDS[COMP_CWORD-2]}"
        if [ "$prev2"x == "init"x ] || [ "$prev2"x == "refresh"x ] ;then
            return 0
        fi
        if [ "$prev2"x == "-p"x ]; then
        	COMPREPLY=( $(compgen -W "refresh" -- "$cur" ))
        	return 0
        fi
        ;;
    esac

    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    return 0
}
#调用auto_config_atom.sh命令，则会调用-F指定的补全函数_atom_autocomplete
complete -F _atom_autocomplete ./auto_config_atom.sh
