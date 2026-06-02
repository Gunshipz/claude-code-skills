---
name: ffmpeg
description: Audio and video processing with ffmpeg. Use when the user wants to trim, cut, convert, compress, merge, extract, resize, adjust, normalize, or otherwise manipulate audio or video files.
license: MIT
allowed-tools: Bash, Read, AskUserQuestion
argument-hint: [file-path(s)]
---

# ffmpeg Media Processing Skill

Process audio and video files using ffmpeg/ffprobe. Covers trimming, conversion, compression, merging, extraction, resizing, filters, and more.

## Inputs

- `$ARGUMENTS` - One or more file paths or a description of what the user wants to do.

If no arguments are provided, ask the user what they need.

## Prerequisites Check

**Before doing anything else**, verify ffmpeg is installed:
```bash
ffmpeg -version 2>/dev/null && echo "OK" || echo "NOT FOUND"
```

If ffmpeg is not installed, guide the user to install it:

| Platform | Command |
|----------|---------|
| **macOS (Homebrew)** | `brew install ffmpeg` |
| **Ubuntu/Debian** | `sudo apt update && sudo apt install ffmpeg` |
| **Windows (winget)** | `winget install ffmpeg` |
| **Windows (Chocolatey)** | `choco install ffmpeg` |
| **Windows (Scoop)** | `scoop install ffmpeg` |

After installation, verify with `ffmpeg -version` before proceeding.

---

## General Workflow

1. **Always probe first** to understand the input:
   ```
   ffprobe -v error -show_format -show_streams -of json "<file>"
   ```
2. **Clarify the task** with the user if ambiguous.
3. **Prefer `-c copy`** (stream copy) whenever possible for speed and quality.
4. **Always quote file paths** - they often contain spaces and special characters.
5. **When overwriting the input file**, always write to a temp file first, then `mv` over the original.
6. **Report the result**: confirm the output path, duration, file size, and any relevant details.

---

## Operations Reference

### Trimming / Cutting
```bash
ffmpeg -ss 52 -i "input.mp4" -c copy "output.mp4"
ffmpeg -ss 00:01:00 -to 00:03:30 -i "input.mp4" -c copy "output.mp4"
```

### Format Conversion
```bash
ffmpeg -i "input.mov" -c:v libx264 -c:a aac "output.mp4"
ffmpeg -i "input.mp4" -vn -c:a libmp3lame -q:a 2 "output.mp3"
ffmpeg -i "input.mp4" -c:v libvpx-vp9 -crf 30 -b:v 0 -c:a libopus "output.webm"
```

### Compression
```bash
ffmpeg -i "input.mp4" -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k "output.mp4"
```
CRF: 18=visually lossless, 23=default, 28=smaller/lower quality.

### Resizing
```bash
ffmpeg -i "input.mp4" -vf "scale=1280:-2" -c:a copy "output.mp4"
```

### Merging / Concatenating
```bash
printf "file '%s'\n" file1.mp4 file2.mp4 > /tmp/ffmpeg_concat.txt
ffmpeg -f concat -safe 0 -i /tmp/ffmpeg_concat.txt -c copy "output.mp4"
```

### Extracting Streams
```bash
ffmpeg -i "input.mp4" -vn -c:a copy "output.aac"   # audio only
ffmpeg -i "input.mp4" -an -c:v copy "output.mp4"   # video only
```

### Audio Processing
```bash
ffmpeg -i "input.mp4" -af "loudnorm=I=-16:TP=-1.5:LRA=11" -c:v copy "output.mp4"
ffmpeg -i "input.mp4" -af "volume=1.5" -c:v copy "output.mp4"
```

### Screenshots / Thumbnails
```bash
ffmpeg -ss 00:01:30 -i "input.mp4" -frames:v 1 "thumbnail.png"
ffmpeg -i "input.mp4" -vf "fps=1" "frame_%04d.png"
```

### GIF Creation
```bash
ffmpeg -ss 5 -t 3 -i "input.mp4" -vf "fps=15,scale=480:-2,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" "output.gif"
```

### Speed Changes
```bash
ffmpeg -i "input.mp4" -vf "setpts=0.5*PTS" -af "atempo=2.0" "output.mp4"
```

### Video Filters
```bash
ffmpeg -i "input.mp4" -vf "transpose=1" -c:a copy "output.mp4"          # rotate 90 CW
ffmpeg -i "input.mp4" -vf "eq=brightness=0.1:contrast=1.2" -c:a copy "output.mp4"
```

### Batch Processing
```bash
for f in *.mkv; do ffmpeg -i "$f" -c:v libx264 -crf 23 -c:a aac "${f%.mkv}.mp4"; done
```

## Output Naming Convention
- Trim: `name_trimmed.ext`
- Convert: `name.new_ext`
- Compress: `name_compressed.ext`
- Resize: `name_720p.ext`

## Safety Rules
- **Never overwrite input files directly.** Always write to a temp file first.
- **Always probe first** before running a command.
- **Warn about long operations** - re-encoding large files can be slow.
- **Warn about quality loss** - if converting to lossy or compressing aggressively, note it.
