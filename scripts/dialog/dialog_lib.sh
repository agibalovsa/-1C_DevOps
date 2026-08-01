#!/usr/bin/env bash

open_dialog() {

    local yamlFile="${1}"
    local -n resultDialog_ref="${2}"
    
    local title
    local countFields=0
    
    if [ ! -f "${yamlFile}" ]; then
        echo "Файл ${yamlFile} не найден!" >&2
        return 1
    fi

    local cacheFile="${yamlFile}.cache"
    local -A cacheData=()
    if [ -f "${cacheFile}" ]; then
        while IFS='=' read -r cacheKey cacheVal; do
            # Пропускаем пустые строки или комментарии, если они есть
            [[ -z "$cacheKey" || "$cacheVal" =~ ^# ]] && continue
            cacheData["$cacheKey"]="$cacheVal"
        done < "$cacheFile"
    fi

    title=$(yq -r '.Title' "${yamlFile}" | tr -d '\r\n')
    fieldsData=$(yq -r '.Fields[] | [.Name, .Type, .Label, .Default] | join("|")' "$yamlFile")

    local formFields=()
    local fieldNames=()
    local fieldTypes=()

    local label_x=2
    local label_y=0
    local input_x=0
    local input_x_max=0
    local input_y=0
    local inputMaxWidth=50
    local inputMaxLen=0

    while IFS="|" read -r name type label default; do
        
        countFields=$((countFields + 1))
        
        name=$(echo -n "$name" | tr -d '\r\n')
        type=$(echo -n "$type" | tr -d '\r\n')
        label=$(echo -n "$label" | tr -d '\r\n')
        default=$(echo -n "$default" | tr -d '\r\n')

        local password=0
        local inputWidth=$inputMaxWidth
        if [ "$type" == "Password" ]; then
            password=1
        elif [ "$type" == "Separator" ]; then
            password=2
            inputWidth=0
        fi
        
        [ "${default}" == "null" ] && default=""
        [ "${name}" == "null" ] && name=""

        if [ "$type" != "Password" ] && [ "$type" != "Separator" ]; then
            if [ -n "${cacheData[$name]+unset}" ]; then
                default="${cacheData[$name]}"
            fi
        fi

        label_y=$((label_y + 1))
        input_y=$((input_y + 1))
        
        if [ "$type" != "Separator" ]; then
            input_x=$((label_x + ${#label} + 2))
            (( input_x_max = input_x_max > input_x ? input_x_max : input_x ))
        else
            input_x=0
        fi

        formFields+=(
            "${label}"
            "${label_y}"
            "${label_x}"
            "${default}"
            "${input_y}"
            "${input_x}"
            "${inputWidth}"
            "${inputMaxLen}"
            "${password}"
        )

        fieldNames+=("${name}")
        fieldTypes+=("${type}") 

    done <<< "${fieldsData}"

    local windowsHeight=$((countFields + 7))
    local windowsWidth=$((input_x_max + inputMaxWidth + 4))
    local formHeight=$countFields

    for ((i=0; i<${#formFields[@]}; i+=9)); do
        if [[ "${formFields[i]}" == =* ]]; then
            formFields[i+2]=2
            groupName=" ${formFields[i]:1} "
            separator=$(printf '%*s' "$((input_x_max + inputMaxWidth - 4))" '' | tr ' ' '=')
            separator="${separator:0:(((${#separator}-${#groupName})/2))}${groupName}${separator:(((${#separator}-${#groupName})/2+${#groupName}))}"
            formFields[i]="${separator}"
        else
            formFields[i+5]=${input_x_max}
        fi
    done

   dialogData=$(
        dialog --erase-on-exit --ascii-lines --no-shadow --no-tags --output-fd 1 --insecure \
            --title "$title" \
            --mixedform "Заполните параметры конфигурации:" \
            "$windowsHeight" "$windowsWidth" "$formHeight" \
            "${formFields[@]}"
    )

    local exit_status=$?
    if [ $exit_status -ne 0 ]; then
        return $exit_status
    fi

    mapfile -t dialogOutput <<< "$dialogData"

    resultDialog_ref=()

    local j=-1
    for ((i=0; i<countFields; i++)); do
        local key="${fieldNames[i]}"
        local type="${fieldTypes[i]}"
        [  "${type}" = "Separator" ] && continue
        j=$((j + 1))
        if [ -n "$key" ]; then
            local val="${dialogOutput[j]}"
            resultDialog_ref["$key"]="$val"
            if [ "$type" != "Password" ]; then
                cacheData["$key"]="$val"
            fi
        fi
    done

    for key in "${!cacheData[@]}"; do
        echo "$key=${cacheData[$key]}"
    done > "$cacheFile"

    return 0
}