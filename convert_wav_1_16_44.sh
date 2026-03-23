#!/bin/sh
#
# Andrey A. Ugolnik
# https://www.ugolnik.info
# andrey@ugolnik.info
#
# Convert WAV files to 44.1kHz / 16-bit / mono (in-place).

usage() {
    echo "Usage: $(basename "$0") <file.wav|directory>"
    echo ""
    echo "  file.wav    Convert a single WAV file to 44.1kHz/16-bit/mono."
    echo "  directory   Convert all WAV files in the directory."
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
TARGET_CODEC="pcm_s16le"
TARGET_CHANNELS=1

convert() {
    INPUT_FILE="$1"
    OUTPUT_FILE="${INPUT_FILE%.*}~.wav"

    ffprobe_output=$(ffprobe -v error -select_streams a:0 \
        -show_entries stream=codec_name,channels,sample_rate \
        -of default=noprint_wrappers=1:nokey=1 "$INPUT_FILE")

    CODEC=$(printf '%s\n' "$ffprobe_output" | sed -n 1p)
    SAMPLE_RATE=$(printf '%s\n' "$ffprobe_output" | sed -n 2p)
    CHANNELS=$(printf '%s\n' "$ffprobe_output" | sed -n 3p)

    echo "Input: $INPUT_FILE"

    if [ "$CODEC" != "$TARGET_CODEC" ] || [ "$CHANNELS" -ne "$TARGET_CHANNELS" ] || [ "$SAMPLE_RATE" -ne "$TARGET_SAMPLE_RATE" ]; then
        echo "  Codec: $CODEC"
        echo "  Channels: $CHANNELS"
        echo "  Sample rate: $SAMPLE_RATE"
        echo "  Converting to the required format..."
        ffmpeg -y -i "${INPUT_FILE}" -ac $TARGET_CHANNELS -ar $TARGET_SAMPLE_RATE -sample_fmt s16 "${OUTPUT_FILE}"
        mv -f "${OUTPUT_FILE}" "${INPUT_FILE}"
        echo "  Done."
    else
        echo "  File already in desired format."
    fi

    echo ""
}

if [ -f "$TARGET" ]; then
    case "$TARGET" in
        *.wav) convert "$TARGET" ;;
        *) echo "Error: '$TARGET' is not a WAV file."; exit 1 ;;
    esac
elif [ -d "$TARGET" ]; then
    for i in "$TARGET"/*.wav; do
        [ -f "$i" ] || continue
        convert "$i"
    done
else
    echo "Error: '$TARGET' is not a valid file or directory."
    exit 1
fi
