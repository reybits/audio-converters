#!/bin/sh
#
# Andrey A. Ugolnik
# https://www.ugolnik.info
# andrey@ugolnik.info
#
# Convert OGG files to 44.1kHz / 16-bit / mono (in-place).

usage() {
    echo "Usage: $(basename "$0") <file.ogg|directory>"
    echo ""
    echo "  file.ogg    Convert a single OGG file to 44.1kHz/16-bit/mono."
    echo "  directory   Convert all OGG files in the directory."
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

TARGET_SAMPLE_RATE=44100
TARGET_CHANNELS=1

convert() {
    INPUT_FILE="$1"
    OUTPUT_FILE="${INPUT_FILE%.*}~.ogg"

    ffprobe_output=$(ffprobe -v error -select_streams a:0 \
        -show_entries stream=codec_name,channels,sample_rate \
        -of default=noprint_wrappers=1:nokey=1 "$INPUT_FILE")

    CODEC=$(printf '%s\n' "$ffprobe_output" | sed -n 1p)
    SAMPLE_RATE=$(printf '%s\n' "$ffprobe_output" | sed -n 2p)
    CHANNELS=$(printf '%s\n' "$ffprobe_output" | sed -n 3p)

    echo "Input: $INPUT_FILE"

    if [ "$CHANNELS" -ne "$TARGET_CHANNELS" ] || [ "$SAMPLE_RATE" -ne "$TARGET_SAMPLE_RATE" ]; then
        echo "  Codec: $CODEC"
        echo "  Channels: $CHANNELS"
        echo "  Sample rate: $SAMPLE_RATE"
        echo "  Converting to the required format..."
        ffmpeg -y -i "${INPUT_FILE}" -ac $TARGET_CHANNELS -ar $TARGET_SAMPLE_RATE -c:a libvorbis -q:a 5 "${OUTPUT_FILE}"
        mv -f "${OUTPUT_FILE}" "${INPUT_FILE}"
        echo "  Done."
    else
        echo "  File already in desired format."
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
