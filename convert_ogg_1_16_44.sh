#!/bin/sh
#
# Andrey A. Ugolnik
# https://www.ugolnik.info
# andrey@ugolnik.info
#
# Convert all OGG files to 44.1kHz / 16-bit / mono.
#
# Modified: May 21, 2025
#

TARGET_SAMPLE_RATE=44100
TARGET_CHANNELS=1

convert() {
    INPUT_FILE="$1"
    OUTPUT_FILE="$2"

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

for i in *.ogg; do
    INPUT_FILE="${i}"
    OUTPUT_FILE="${INPUT_FILE%.*}~.ogg"

    convert "$INPUT_FILE" "$OUTPUT_FILE"
done
