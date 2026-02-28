# MindVault AI

Your AI-powered memory layer. Capture thoughts by voice or text, and let on-device AI organize and summarize them automatically.

## Features

- **Voice & Text Input** -- tap the mic to speak, then edit the transcription before saving
- **AI Topic Suggestions** -- after saving a thought, AI suggests the best matching topic or a new topic name in real-time
- **AI Summaries** -- each topic gets an AI-generated summary after new entries
- **Ask AI** -- ask questions about your entries and get contextual answers
- **Swipe-to-Delete** -- swipe left on topics or individual entries to remove them
- **iCloud Sync** -- data syncs seamlessly across iPhone and Mac via CloudKit
- **Dark & Light Mode** -- adaptive theme with full appearance control

## Requirements

- Xcode 26+
- iOS 26+ / macOS 26+
- Apple ID with iCloud enabled
- Apple Silicon device (for AI features)

## Setup

1. Clone the repository
2. Open `MindVaultAI.xcodeproj` in Xcode
3. Select your development team in Signing & Capabilities
4. Enable iCloud capability with CloudKit (container: `iCloud.sahar.MindVaultAI`)
5. Add privacy usage descriptions (see below)
6. Build and run on your device or simulator

### Required Privacy Descriptions

Add these in Target > Info:

| Key | Value |
|-----|-------|
| `NSMicrophoneUsageDescription` | MindVault AI uses your microphone to capture voice entries |
| `NSSpeechRecognitionUsageDescription` | MindVault AI uses speech recognition to transcribe your thoughts |

## Architecture

```
MVVM + Services
├── Views        SwiftUI views with #Preview blocks
├── ViewModels   @Observable classes with business logic
├── Models       SwiftData @Model types (CloudKit-synced)
├── Services     AIService (Foundation Models), SpeechService (Speech framework)
└── Theme        Adaptive colors, fonts, spacing tokens
```

See [AGENTS.md](AGENTS.md) for full conventions and best practices.
