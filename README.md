# Audio Converters

A set of shell utilities for converting and processing audio files, tailored for my specific tasks and workflows.

## Requirements

- [ffmpeg](https://ffmpeg.org/) — used by all scripts
- [xmp](http://xmp.sourceforge.net/) — tracker module player (used by `convert_tracker_mp3_ogg.sh`)
- [oggenc](https://xiph.org/vorbis/) — OGG Vorbis encoder (used by `convert_tracker_mp3_ogg.sh`)

Install on macOS: `brew install ffmpeg xmp vorbis-tools`

## Scripts

### Format Conversion

| Script | Description |
|---|---|
| `convert_mp3_wav.sh` | MP3 to 44.1kHz/16-bit/mono WAV |
| `convert_ogg_mp3.sh` | OGG to MP3 |
| `convert_ogg_wav.sh` | OGG to 44.1kHz/16-bit/mono WAV |
| `convert_wav_mp3.sh` | WAV to MP3 |
| `convert_tracker_mp3_ogg.sh` | Tracker module to MP3 and mono OGG |

### In-Place Processing

| Script | Description |
|---|---|
| `convert_wav_1_16_44.sh` | Normalize WAV to 44.1kHz/16-bit/mono |
| `convert_ogg_1_16_44.sh` | Normalize OGG to 44.1kHz/16-bit/mono |
| `strip_meta_wav.sh` | Remove metadata from WAV files |

## Usage

Each script accepts a single file or a directory:

```sh
# Convert a single file
./convert_wav_mp3.sh song.wav

# Convert all matching files in a directory
./convert_wav_mp3.sh /path/to/directory
```

Format conversion scripts support `--remove-source` to delete source files after conversion:

```sh
./convert_wav_mp3.sh --remove-source /path/to/directory
```

Run any script without arguments to see its help message.

***

```
© 2017-2026 Andrey A. Ugolnik. All Rights Reserved.
https://www.ugolnik.info
andrey@ugolnik.info
```
