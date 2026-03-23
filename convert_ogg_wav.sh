#!/bin/sh
#
# Andrey A. Ugolnik
# https://www.ugolnik.info
# andrey@ugolnik.info
#
# Convert OGG files to 44100/16-bit/mono WAV.

usage() {
    echo "Usage: $(basename "$0") [--remove-source] <file.ogg|directory>"
    echo ""
    echo "  file.ogg         Convert a single OGG file to WAV."
    echo "  directory         Convert all OGG files in the directory."
    echo "  --remove-source   Remove source OGG file(s) after conversion."
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "Error: ffmpeg is not installed."
    echo "Install it with: brew install ffmpeg"
    exit 1
fi

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
    echo "Error: no file or directory specified."
    usage
    exit 1
fi

convert() {
    INPUT_FILE="$1"
    OUTPUT_FILE="${INPUT_FILE%.*}.wav"

    echo "Input: $INPUT_FILE"

    rm -f "${OUTPUT_FILE}"
    ffmpeg -i "${INPUT_FILE}" -acodec pcm_s16le -ar 44100 -ac 1 "${OUTPUT_FILE}"

    if [ $REMOVE_SOURCE -eq 1 ]; then
        rm "${INPUT_FILE}"
        echo "  Removed source file."
    fi

    echo ""
}

if [ -f "$TARGET" ]; then
    case "$TARGET" in
        *.ogg) convert "$TARGET" ;;
        *) echo "Error: '$TARGET' is not an OGG file."; exit 1 ;;
    esac
elif [ -d "$TARGET" ]; then
    for i in "$TARGET"/*.ogg; do
        [ -f "$i" ] || continue
        convert "$i"
    done
else
    echo "Error: '$TARGET' is not a valid file or directory."
    exit 1
fi

