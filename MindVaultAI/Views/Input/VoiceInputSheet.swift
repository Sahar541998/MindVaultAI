import SwiftUI
import SwiftData
import Speech

struct VoiceInputSheet: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Topic.updatedAt, order: .reverse) private var topics: [Topic]

    @State private var speechService = SpeechService()
    @State private var isTypingMode = false
    @State private var typedText = ""
    @State private var showTopicPicker = false

    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.Spacing.sectionGap) {
                transcriptionView
                inputControl
                modeSwitchButton
            }
            .padding(.top, AppTheme.Spacing.sectionGap)
            .padding(.horizontal, AppTheme.Spacing.sectionGap)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background)
            .navigationTitle("Speak your mind")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            .onAppear { speechService.checkAuthorization() }
            .sheet(isPresented: $showTopicPicker) {
                TopicPickerSheet(text: typedText) { dismiss() }
            }
            .onChange(of: speechService.isRecording) { wasRecording, isNowRecording in
                if wasRecording && !isNowRecording && !speechService.transcribedText.isEmpty {
                    typedText = speechService.transcribedText
                    isTypingMode = true
                }
            }
        }
        .presentationDetents([.fraction(0.4), .medium])
        .presentationDragIndicator(.visible)
        .presentationBackground(AppColors.background)
    }

    @ViewBuilder
    private var transcriptionView: some View {
        if isTypingMode {
            TextField("Type your thought...", text: $typedText, axis: .vertical)
                .textFieldStyle(.plain)
                .font(AppTheme.Fonts.entryBody)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(3...8)
                .padding()
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.entryBubble))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.entryBubble)
                        .stroke(AppColors.cardBorder, lineWidth: 1)
                )
        } else if speechService.isDenied {
            permissionDeniedView
        } else if speechService.isRecording {
            VStack(spacing: AppTheme.Spacing.itemSpacing) {
                if !speechService.transcribedText.isEmpty {
                    Text(speechService.transcribedText)
                        .font(AppTheme.Fonts.entryBody)
                        .foregroundStyle(AppColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                Text("Listening...")
                    .font(AppTheme.Fonts.topicSubtitle)
                    .foregroundStyle(AppColors.textSecondary)
            }
        } else {
            Text("Tap to start speaking")
                .font(AppTheme.Fonts.topicSubtitle)
                .foregroundStyle(AppColors.textSecondary)
        }

        if let error = speechService.errorMessage {
            Text(error)
                .font(AppTheme.Fonts.topicMeta)
                .foregroundStyle(.red)
        }
    }

    @ViewBuilder
    private var inputControl: some View {
        if isTypingMode {
            Button(action: submitThought) {
                Text("Save")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background {
                        if typedText.trimmingCharacters(in: .whitespaces).isEmpty {
                            AnyView(AppColors.textSecondary)
                        } else {
                            AnyView(AppColors.micGradient)
                        }
                    }
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(typedText.trimmingCharacters(in: .whitespaces).isEmpty)
        } else {
            micButtonView
        }
    }

    private var micButtonView: some View {
        Button(action: toggleRecording) {
            ZStack {
                Circle()
                    .fill(AppColors.micGradient)
                    .frame(width: 80, height: 80)
                    .shadow(color: AppColors.accentPurple.opacity(0.4), radius: 16, y: 4)

                if speechService.isRecording {
                    Circle()
                        .stroke(AppColors.accentTeal.opacity(0.5), lineWidth: 3)
                        .frame(width: 96, height: 96)
                        .scaleEffect(speechService.isRecording ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1).repeatForever(), value: speechService.isRecording)
                }

                Image(systemName: speechService.isRecording ? "stop.fill" : "mic.fill")
                    .font(.title)
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(speechService.isRecording ? "Stop recording" : "Start recording")
    }

    private var modeSwitchButton: some View {
        Button(action: switchMode) {
            HStack(spacing: AppTheme.Spacing.tinySpacing) {
                Image(systemName: isTypingMode ? "mic.fill" : "keyboard")
                Text(isTypingMode ? "Switch to speaking" : "Switch to typing")
            }
            .font(AppTheme.Fonts.topicMeta)
            .foregroundStyle(AppColors.textSecondary)
        }
        .buttonStyle(.plain)
    }

    private var permissionDeniedView: some View {
        VStack(spacing: AppTheme.Spacing.itemSpacing) {
            Image(systemName: "mic.slash")
                .font(.largeTitle)
                .foregroundStyle(AppColors.textSecondary)

            Text("Microphone access is required for voice input.")
                .font(AppTheme.Fonts.topicSubtitle)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            #if os(iOS)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.body.weight(.semibold))
            .foregroundStyle(AppColors.accentTeal)
            #endif
        }
    }

    private func switchMode() {
        if isTypingMode {
            typedText = ""
            speechService.transcribedText = ""
            isTypingMode = false
        } else {
            isTypingMode = true
        }
    }

    private func toggleRecording() {
        if speechService.isRecording {
            speechService.stopRecording()
        } else {
            if speechService.authorizationStatus == .notDetermined {
                speechService.requestAuthorization()
            } else {
                speechService.startRecording()
            }
        }
    }

    private func submitThought() {
        let trimmed = typedText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        showTopicPicker = true
    }
}

#Preview {
    VoiceInputSheet()
        .modelContainer(PreviewSampleData.emptyContainer)
}
