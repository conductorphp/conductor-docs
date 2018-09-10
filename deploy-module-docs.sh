#!/usr/bin/env bash

RED='\033[0;31m'
NC='\033[0m' # No Color

# @see https://gist.github.com/pkuczynski/8665367
parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

eval $(parse_yaml mkdocs.yml "config_")

for dir in vendor/conductor/*/ ; do
    module=${dir:17:-1}
    module="$(sed s/-/_/g <<<$module)"
    varName="config_module_path_map_$module"
    path=${!varName}
    if [[ -z $path ]]; then
      echo -e "${RED}Conductor module \"$module\" not defined in module_path_map. Add module_path_map/$module to mkdocs.yml.${NC}"
      continue
    fi

    if [[ -d "./$dir/docs/" ]]; then
      mkdir -p "docs/modules/$path"
      rsync -r "$dir/docs/" "docs/modules/$path"
    fi
done
