# Teman Tuli iOS (`apps/teman-tuli-ios`)

SwiftUI app for live classroom captions and private transcript archives for Mahasiswa Tuli.

## Problem
Mahasiswa Tuli can lose classroom context when lectures move quickly, when interpreters are unavailable, or when accessible notes are not provided.

## Solution
Teman Tuli helps students:
- generate large live captions on-device
- save transcript sessions only after explicit consent
- review private transcript archives
- add personal notes and caption-quality feedback

## Architecture
- SwiftUI + MVVM
- Apple Speech framework + AVFoundation for live caption MVP
- API-first integration with `apps/teman-tuli-api`
- Core modules:
  - `Onboarding`
  - `Live Caption`
  - `Transcript Sessions`
  - `Session Detail`
  - `Settings`

## Setup
1. Install XcodeGen (optional but recommended):
   ```bash
   brew install xcodegen
   ```
2. Generate Xcode project:
   ```bash
   cd apps/teman-tuli-ios
   xcodegen generate
   ```
3. Open `TemanTuli.xcodeproj` in Xcode and run on a physical device for best microphone/speech testing.

## API Integration
Default API base URL is:
- `http://localhost:3000/api/v1`

Update `LiveAPIClient` base URL for LAN or remote backend testing on a real device.

## Privacy Defaults
- No automatic transcript upload while captioning.
- User taps `Save Privately` to archive a transcript.
- Saved sessions are scoped to the signed-in user.

## Tradeoffs
- v1 uses on-device Apple Speech framework for fast MVP and lower cost.
- Accuracy may vary by noise level and language support.

## Future Scope
- Share-by-class-code with explicit consent.
- Lecturer correction workflow.
- Export transcript to PDF or Markdown.
