# MindVault AI -- Agent Guidelines

## Project Overview

- **App**: MindVault AI -- an AI-powered memory layer for capturing and organizing thoughts
- **Platforms**: iOS 26+, macOS 26+
- **Architecture**: MVVM with Services layer
- **Data**: SwiftData with CloudKit for iCloud sync
- **AI**: Apple Foundation Models framework (on-device)
- **Speech**: Apple Speech framework for voice input
- **UI**: SwiftUI with adaptive navigation (NavigationSplitView)

## Folder Structure

```
MindVaultAI/
├── App/                   App entry point, container setup
├── Models/                SwiftData @Model types
├── Views/
│   ├── Home/              Main screen (topic list, search, empty state)
│   ├── Detail/            Topic detail (entry list, entry bubbles)
│   ├── Input/             Voice/text input, topic picker
│   └── Settings/          App settings
├── ViewModels/            @Observable view models
├── Services/              AI and Speech services
├── Theme/                 Colors, fonts, spacing tokens
├── Extensions/            Small helpers (Date formatting, preview data)
└── Assets.xcassets/       Colors, icons, images
```

### Naming

- File names match their primary type: `HomeView.swift` contains `struct HomeView: View`
- One primary public type per file
- Max ~150 lines per file; extract subviews or helpers when exceeding

## Multi-Platform Pitfalls (CRITICAL)

This app targets both iOS and macOS. Many APIs are iOS-only and will break macOS builds.

### iOS-Only APIs -- Always Guard with `#if os(iOS)`

```swift
// WRONG -- crashes macOS build:
.navigationBarTitleDisplayMode(.inline)
.listStyle(.insetGrouped)
UIApplication.shared.open(url)
UIImage(systemName: name)

// CORRECT:
#if os(iOS)
.navigationBarTitleDisplayMode(.inline)
#endif

#if os(iOS)
.listStyle(.insetGrouped)
#endif

#if os(iOS)
if let url = URL(string: UIApplication.openSettingsURLString) {
    UIApplication.shared.open(url)
}
#endif
```

### Platform-Specific Image Lookup

```swift
// WRONG on macOS -- NSImage has no init(systemName:):
NSImage(systemName: name)

// CORRECT:
#if canImport(UIKit)
UIImage(systemName: name) != nil
#elseif canImport(AppKit)
NSImage(systemSymbolName: name, accessibilityDescription: nil) != nil
#endif
```

### AVAudioSession is iOS-Only

```swift
#if os(iOS)
let audioSession = AVAudioSession.sharedInstance()
try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
#endif
```

## SwiftUI Best Practices

- **Small composable views**: if a View body exceeds ~40 lines, extract child views
- **State ownership**: `@State` for local state, `@Binding` for parent-owned, `@Environment` for injected dependencies. Never pass `ModelContext` explicitly.
- **No logic in View body**: layout only. Business logic goes in ViewModels. Simple computed properties are fine.
- **ViewModels are `@Observable`**: never use `ObservableObject`/`@Published`
- **Adaptive layout**: `NavigationSplitView` for Mac sidebar / iPhone stack. Use `ViewThatFits` and `@Environment(\.horizontalSizeClass)` when needed.
- **SF Symbols**: use Apple SF Symbols for all icons. Never bundle custom images when a symbol exists.
- **Accessibility**: `.accessibilityLabel` on icon-only buttons. Semantic fonts (`.title`, `.body`, `.caption`) over hardcoded sizes.

### SwiftUI Type Matching in Ternary / Conditional Expressions

SwiftUI requires both branches of a ternary to return the **same type**. `Color` and `LinearGradient` are different types.

```swift
// WRONG -- compiler error: mismatching types 'Color' and 'LinearGradient'
.background(condition ? AppColors.textSecondary : AppColors.micGradient)

// CORRECT -- use @ViewBuilder background or AnyView:
.background {
    if condition {
        AnyView(AppColors.textSecondary)
    } else {
        AnyView(AppColors.micGradient)
    }
}
```

### Import Rules

Every file must import **all** frameworks whose types it uses -- even indirectly:
- Using `ModelConfiguration`, `ModelContainer`, `@Query`, `@Model` → `import SwiftData`
- Using `SFSpeechRecognizerAuthorizationStatus`, `.notDetermined` → `import Speech`
- Using `AVAudioEngine`, `AVAudioSession` → `import AVFoundation`
- Using `UIImage`, `UIApplication` → `import UIKit` (inside `#if canImport(UIKit)`)

Do **not** rely on transitive imports. If a type is referenced in a file, that file must explicitly import the module.

## #Preview Rule (MANDATORY)

Every View file **must** include a `#Preview` block at the bottom.

### Preview Pitfalls to Avoid

1. **NEVER use `return` in `#Preview` blocks** -- they use `@ViewBuilder` result builders which forbid explicit `return`
2. **NEVER put complex setup (for loops, multi-let + mutations) inside `#Preview`** -- it fails with ambiguous type errors
3. **Use the shared `PreviewSampleData` helper** from `Extensions/PreviewSampleData.swift`

```swift
// WRONG -- return keyword not allowed:
#Preview {
    let container = ...
    return HomeView().modelContainer(container)
}

// WRONG -- complex setup causes ViewBuilder ambiguity:
#Preview {
    let container = ...
    for item in items {
        let topic = Topic()
        topic.title = item.title
        container.mainContext.insert(topic)
    }
    HomeView().modelContainer(container)
}

// CORRECT -- use shared preview data:
#Preview("With Topics") {
    HomeView()
        .modelContainer(PreviewSampleData.container)
}

#Preview("Empty State") {
    HomeView()
        .modelContainer(PreviewSampleData.emptyContainer)
}

// CORRECT -- simple standalone preview:
#Preview {
    SearchBarView(searchText: .constant(""))
}
```

### When Adding New Models or Preview Scenarios

Update `Extensions/PreviewSampleData.swift` to include sample data for the new type. All previews share this single source of truth for sample data.

## SwiftData + CloudKit Rules

### @Model Classes MUST Have Explicit init()

SwiftData's `@Model` macro generates a hidden init with a `backingData` parameter. Without your own `init()`, you cannot construct instances in code.

```swift
// WRONG -- no init, compiler error "missing argument for parameter 'backingData'":
@Model final class Topic {
    var title: String = ""
}
let topic = Topic() // ERROR

// CORRECT -- provide explicit init with defaults:
@Model final class Topic {
    var title: String = ""

    init(title: String = "") {
        self.title = title
    }
}
let topic = Topic(title: "My Topic") // OK
let topic2 = Topic() // Also OK
```

### Other CloudKit Rules

- All `@Model` properties **must** have default values (CloudKit requirement)
- Relationships **must** be optional (`var entries: [Entry]? = nil`)
- **Never** use `@Attribute(.unique)` with CloudKit
- Use `@Relationship(deleteRule: .cascade)` for parent-child (Topic -> Entry)
- Use `@Query` in views for fetching; `ModelContext` in ViewModels for mutations
- Production container: `ModelConfiguration(cloudKitDatabase: .automatic)`
- Preview container: `ModelConfiguration(isStoredInMemoryOnly: true)`
- Always handle optional unwrapping safely -- CloudKit objects may have nil relationships during sync

## Foundation Models (AI) Rules

### Correct API Usage

```swift
import FoundationModels

// WRONG -- LanguageModelSession has no isAvailable:
LanguageModelSession.isAvailable

// CORRECT -- availability is on SystemLanguageModel:
SystemLanguageModel.default.isAvailable

// Session creation with instructions (preferred over raw prompt):
let session = LanguageModelSession(instructions: "You are a summarizer...")
let response = try await session.respond(to: "Summarize these entries...")
let text: String = response.content
```

### Other AI Rules

- **Always** check `SystemLanguageModel.default.isAvailable` before any AI operation
- **Never** force-unwrap AI responses
- Wrap all AI calls in `do/catch` with meaningful error handling
- Degrade gracefully when unavailable: hide AI buttons, skip summaries, show topic picker instead of auto-categorize, use default icons
- Use `LanguageModelSession(instructions:)` to separate system instructions from user prompts
- Always show a loading indicator during AI operations

## Speech Framework Rules

- Check `SFSpeechRecognizer.authorizationStatus()` before use
- Handle all 4 states: `.notDetermined` (request), `.authorized` (proceed), `.denied` (Settings link), `.restricted` (unavailable message)
- Request microphone permission alongside speech permission
- Tear down `AVAudioEngine` and recognition task on dismiss/stop
- Check `SFSpeechRecognizer.isAvailable` for locale-specific availability
- Any file referencing Speech types must `import Speech` explicitly

## Error Handling

- Use typed errors (`enum AppError: LocalizedError`)
- Never use `try!` or `!` in production code (previews are acceptable)
- Surface errors via `.alert` modifiers -- never silently swallow
- Network/CloudKit errors should offer retry

## Code Style

- No comments that narrate what the code does -- comments only for non-obvious "why"
- No `// MARK:` unless the file has 4+ distinct logical sections
- Trailing closure syntax
- `let` over `var` when the value doesn't change
- Swift concurrency (`async/await`, `@MainActor`) -- never Combine or completion handlers
- Access control: `private` by default, implicit `internal` for cross-module types

## Git & Workflow

- Commit messages: imperative mood ("Add home view" not "Added home view")
- One logical change per commit
- Never commit binary files, xcuserdata, or .DS_Store

## Files Requiring Manual Xcode Changes

These must never be edited by code:

- `.pbxproj` -- Xcode manages this automatically
- `.entitlements` -- add via Signing & Capabilities tab
- `Info.plist` keys -- add via Target > Info tab or build settings
- Asset catalogs -- Xcode for image/icon drag-drop; JSON edits for color sets are OK

When a task requires manual Xcode work, flag it clearly.

## User Interaction Patterns

### Swipe-to-Delete

- Topics and user entries support swipe-to-delete via `.swipeActions(edge: .trailing, allowsFullSwipe: true)`
- **Requires `List` context** -- `.swipeActions` does NOT work in `ScrollView` + `ForEach`
- AI Summary entries are NOT deletable (no swipe action)
- Use `.listRowBackground(Color.clear)` and `.listRowSeparator(.hidden)` for custom card styling inside `List`

### Voice Input Flow

1. User taps mic -> starts recording
2. User taps stop -> recording ends, **automatically switches to typing mode** with transcribed text pre-filled
3. User can edit the text, then taps Save
4. TopicPickerSheet opens **immediately** -- user sees "Suggesting topic..." while AI works
5. AI result appears: matched existing topic shown at top, or new topic name pre-filled in Create section
6. User doesn't have to wait for AI -- they can pick any topic or type a new name immediately

### AI Categorization

`AIService.categorize()` returns one of:
- `.matched(topicTitle:)` -- AI found a confident match among existing topics
- `.newTopicSuggestion(suggestedTitle:)` -- AI suggests a new topic name (may be empty)

The TopicPickerSheet consumes this asynchronously via `.task` on appear.

## Pre-Build Checklist

Before declaring any code complete, verify:

1. [ ] Every `@Model` class has an explicit `init()` with default parameter values
2. [ ] No `#Preview` block contains a `return` statement
3. [ ] No `#Preview` block has complex setup -- uses `PreviewSampleData` instead
4. [ ] Every iOS-only API is wrapped in `#if os(iOS)` / `#endif`
5. [ ] Every file imports all frameworks whose types it references directly
6. [ ] No ternary or `? :` mixes different SwiftUI types (Color vs Gradient, Text vs Image, etc.)
7. [ ] Foundation Models uses `SystemLanguageModel.default.isAvailable`, not `LanguageModelSession`
8. [ ] All SwiftData properties have default values; relationships are optional
9. [ ] `.swipeActions` is only used inside `List`, never in `ScrollView` + `ForEach`
10. [ ] `.listStyle(.insetGrouped)` is guarded with `#if os(iOS)`
