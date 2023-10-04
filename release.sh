#!/usr/bin/env bash

# IE mod distribution script written by a drunk tiefling.

set -e

cd -- "$(dirname -- "${BASH_SOURCE[0]}")" 2>"/dev/null"


MODNAME="drunkshaders"
AUTHOR="drunktiefling"
VERSION="$(cat "${MODNAME}/${MODNAME}.tp2" | grep '^VERSION' | cut -d'~' -f2)"


RELEASE_DIR="releases/${MODNAME}-${VERSION}"

package_release() {
    PLATFORM="${1}"
    ARCHIVE_NAME="${PLATFORM:+${PLATFORM}-}${MODNAME}-${VERSION}"
    PLATFORM_RELEASE_DIR="${RELEASE_DIR}/${ARCHIVE_NAME}"

    mkdir -p "${PLATFORM_RELEASE_DIR}"
    cp -a "${MODNAME}" "${PLATFORM_RELEASE_DIR}/"

    OLD_PWD="${PWD}"

    cd "${PLATFORM_RELEASE_DIR}"
    PLATFORM_RELEASE_DIR_ABS="${PWD}"

    for TOOL in "${MODNAME}/tools/"*; do
        if [ ! -d "${TOOL}" ]; then
            continue
        fi
        cd "${TOOL}"
            case "${PLATFORM}" in
                "lin-x86_64") rm -rf "unix/x86" "osx" "win32" ;;
                "lin-i686")   rm -rf "unix/x86_64" "osx" "win32" ;;
                "mac")        rm -rf "unix" "win32" ;;
                "win")        rm -rf "unix" "osx" "win32/x86" ;;
                "win-32bit")  rm -rf "unix" "osx" "win32/x86_64" ;;
            esac
        cd "${PLATFORM_RELEASE_DIR_ABS}"
    done

    case "${PLATFORM}" in
        "lin"*)
            cat >"setup-${MODNAME}.sh" <<EOF
#!/usr/bin/env bash

cd -- "\$(dirname -- "\${BASH_SOURCE[0]}")" 2>"/dev/null"
exec "./setup-${MODNAME}"
EOF
            chmod +x "setup-${MODNAME}.sh"
            ;;
        "mac")
            cat >"setup-${MODNAME}.command" <<EOF
command_path=\${0%/*}
cd "\$command_path"
./setup-${MODNAME}
EOF
            chmod +x "setup-${MODNAME}.command"
            ;;
    esac

    cd "${OLD_PWD}"

    case "${PLATFORM}" in
        "lin-x86_64") cp "external/WeiDU-Linux-dtiefling/x86_64/weidu" "${PLATFORM_RELEASE_DIR}/setup-${MODNAME}" ;;
        "lin-i686")   cp "external/WeiDU-Linux-dtiefling/i686/weidu" "${PLATFORM_RELEASE_DIR}/setup-${MODNAME}" ;;
        "mac")        cp "external/WeiDU-Mac/weidu" "${PLATFORM_RELEASE_DIR}/setup-${MODNAME}" ;;
        "win")        cp "external/WeiDU-Windows-amd64/weidu.exe" "${PLATFORM_RELEASE_DIR}/setup-${MODNAME}.exe" ;;
        "win-32bit")  cp "external/WeiDU-Windows-x86/weidu.exe" "${PLATFORM_RELEASE_DIR}/setup-${MODNAME}.exe" ;;
    esac

    cd "${PLATFORM_RELEASE_DIR}"

    case "${PLATFORM}" in
        "lin"*)
            tar cf "../${ARCHIVE_NAME}.tar" *
            pigz -11 "../${ARCHIVE_NAME}.tar"
            ;;
        *)
            zip -r "../${ARCHIVE_NAME}.zip" *
            advzip -3 -i50 -z "../${ARCHIVE_NAME}.zip"
            ;;
    esac

    cd "${OLD_PWD}"
}


rm -rf "${RELEASE_DIR}"
mkdir "${RELEASE_DIR}"

package_release ""
package_release "lin-x86_64"
package_release "lin-i686"
package_release "mac"
package_release "win"
package_release "win-32bit"
