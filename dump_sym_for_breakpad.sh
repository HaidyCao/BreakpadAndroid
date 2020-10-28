#! /bin/bash

# set -- $(getopt -q s:o: "$@")

while getopts "s:d:o:" opt; do
    case "${opt}" in
    s)
        # echo "sym path: ${OPTARG}"
        SYM_PATH="${OPTARG}"
        ;;
    d)
        DUMP_PATH="${OPTARG}"
        ;;
    o)
        LOG_OUT_PATH="${OPTARG}"
        ;;
    ?)
        echo "bad args: %${opt}"
        exit
        ;;
    esac

done

# set -x
OUT_PATH=$(mktemp -d /tmp/sym.XXXXXXXXXX)

function handle_so_file() {
    so=${1}
    so_name=$(basename ${so})
    mkdir -p "${OUT_PATH}/symbols/${so_name}"
    sym_name="${OUT_PATH}/symbols/${so_name}/${so_name}.sym"

    if [[ -f error ]]; then
        rm error
    fi
    dump_syms ${so} >"${sym_name}" 2>error
    if [[ -f error ]] && [[ $(cat error) =~ "Failed" ]]; then
        rm -rf "${OUT_PATH}/symbols/${so_name}"
        echo "dump_syms result: $(cat error)"
        rm error
        return
    fi
    rm error

    uuid=$(head -n1 ${sym_name} | awk -F " " '{print $4}')
    mkdir -p "${OUT_PATH}/symbols/${so_name}/${uuid}"
    mv ${sym_name} "${OUT_PATH}/symbols/${so_name}/${uuid}/"
}

mkdir -p ${OUT_PATH}

if [[ -d "${SYM_PATH}" ]]; then
    for so in "${SYM_PATH}"/*.so; do
        handle_so_file ${so}
    done
elif [[ -f "${SYM_PATH}" ]]; then
    handle_so_file ${SYM_PATH}
fi

# set -x
# echo "LOG_OUT_PATH=${LOG_OUT_PATH}"
if [[ ! -z "${LOG_OUT_PATH}" ]]; then
    minidump_stackwalk ${DUMP_PATH} ${OUT_PATH}/symbols >${LOG_OUT_PATH}
else
    minidump_stackwalk ${DUMP_PATH} ${OUT_PATH}/symbols | more
fi

rm -rf ${OUT_PATH}
