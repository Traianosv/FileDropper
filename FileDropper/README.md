# FileDropper

A simple, open-source macOS app with a floating ball for quick file drag-and-drop, copying, and AirDrop sharing.

## Features

- Draggable floating ball that stays on top.
- Click to expand into a file management window.
- Drag files for previews.
- Open files from folders.
- Copy to folders (keeps originals).
- AirDrop sharing.
- Clean, minimal UI.

## Requirements

- macOS 12.0+
- Swift 6.2

## Installation

Clone and build:
```
git clone https://github.com/Traianosv/FileDropper.git
cd FileDropper
swift build --configuration release
cp .build/release/FileDropper FileDropper.app/Contents/MacOS/
open FileDropper.app
```

## Usage

- Launch: Grey ball appears.
- Drag to move.
- Click to expand.
- Drop files or open from folder.
- Copy or AirDrop.
- Click X to close.

##Licence
-MIT License
