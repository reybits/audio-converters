#!/bin/sh
#
# Andrey A. Ugolnik
# https://www.ugolnik.info
# andrey@ugolnik.info
#
# Convert a tracker module file to MP3 and mono OGG.

usage() {
    echo "Usage: $(basename "$0") [--remove-source] <tracker-file>"
    echo ""
    echo "  tracker-file     Convert a tracker module to MP3 and mono OGG."
    echo "  --remove-source  Remove source file after conversion."
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

for cmd in xmp ffmpeg oggenc; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: $cmd is not installed."
        echo "Install it with: brew install $cmd"
        exit 1
    fi
done

REMOVE_SOURCE=0
TARGET=""

for arg in "$@"; do
    case "$arg" in
        --remove-source)
            REMOVE_SOURCE=1
            ;;
        *)
            TARGET="$arg"
            ;;
    esac
done

if [ -z "$TARGET" ]; then
    echo "Error: no file specified."
    usage
    exit 1
fi

if [ ! -f "$TARGET" ]; then
    echo "Error: '$TARGET' is not a valid file."
    exit 1
fi

INPUT_NAME="${TARGET%.*}"
INPUT_WAV="${INPUT_NAME}.wav"
MP3="${INPUT_NAME}.mp3"
OGG="${INPUT_NAME}.ogg"

echo "Input: $TARGET"

rm -f "${MP3}" "${OGG}" "${INPUT_WAV}"

xmp "${TARGET}" -o "${INPUT_WAV}"
ffmpeg -i "${INPUT_WAV}" -acodec mp3 "${MP3}"
oggenc --downmix "${INPUT_WAV}" -o "${OGG}"

rm -f "${INPUT_WAV}"

if [ $REMOVE_SOURCE -eq 1 ]; then
    rm "${TARGET}"
    echo "  Removed source file."
fi

echo ""
