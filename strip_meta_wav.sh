#!/bin/sh
#
# Andrey A. Ugolnik
# https://www.ugolnik.info
# andrey@ugolnik.info
#
# Remove metadata from WAV files (in-place).

usage() {
    echo "Usage: $(basename "$0") <file.wav|directory>"
    echo ""
    echo "  file.wav    Strip metadata from a single WAV file."
    echo "  directory   Strip metadata from all WAV files in the directory."
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

TARGET="$1"

strip_metadata() {
    INPUT_FILE="$1"
    TEMP_FILE="${INPUT_FILE%.*}~.wav"

    echo "Input: $INPUT_FILE"

    ffmpeg -y -i "${INPUT_FILE}" -map_metadata -1 -fflags +bitexact "${TEMP_FILE}"
    mv -f "${TEMP_FILE}" "${INPUT_FILE}"

    echo "  Done."
    echo ""
}

if [ -f "$TARGET" ]; then
    case "$TARGET" in
        *.wav) strip_metadata "$TARGET" ;;
        *) echo "Error: '$TARGET' is not a WAV file."; exit 1 ;;
    esac
elif [ -d "$TARGET" ]; then
    for i in "$TARGET"/*.wav; do
        [ -f "$i" ] || continue
        strip_metadata "$i"
    done
else
    echo "Error: '$TARGET' is not a valid file or directory."
    exit 1
fi
