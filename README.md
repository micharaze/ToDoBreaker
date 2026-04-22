# ToDoBreaker

A minimal macOS menu bar app for ephemeral daily task planning. Every morning, a full-screen overlay blocks your displays until you've planned your day. Todos expire at midnight and never carry over.

## Features

- **Morning Break overlay** — blocks all screens at a configured time until you enter your tasks for the day
- **Daily todos** — tasks are tied to the current day and disappear the next morning
- **Menu bar** — quick access to your task list and progress without opening a window
- **Snooze** — postpone the morning break by a configurable number of minutes
- **Active days** — configure which weekdays the morning break is active

## Requirements

- macOS 14.0 or later
- Xcode 15 or later
- [xcodegen](https://github.com/yonaskolb/XcodeGen)

## Build

```bash
# Install xcodegen (first time only)
brew install xcodegen

# Generate the Xcode project
xcodegen generate

# Open in Xcode
open ToDoBreaker.xcodeproj
```

Then press **Cmd+R** to build and run.

## Distribution

The app is not sandboxed (required for screen-level overlay windows), so Mac App Store distribution is not possible. Distribute via notarized DMG or share the `.app` bundle directly — recipients may need to right-click → Open on first launch.

## Tech Stack

- Swift + SwiftUI (macOS 14+)
- AppKit for overlay windows (`NSWindow` at `.screenSaver` level)
- [SQLite.swift](https://github.com/stephencelis/SQLite.swift) for local storage
- [xcodegen](https://github.com/yonaskolb/XcodeGen) for project generation
