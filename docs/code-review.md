# director_ai Code Review & Iteration Roadmap

> Scope: `/Users/xuyu/Code/Xucroyuri/Github/director_ai` (Flutter mobile app + `web/` Python Gradio tool)

## 0) Executive Take

This repo actually contains two products:

- A Flutter mobile app (AI漫导) that orchestrates LLM/image/video APIs to generate screenplay → images → videos.
- A Python/Gradio “AI Storyboard Pro” tool living under `web/` with its own runtime and configuration.

The Flutter side is reasonably structured (Provider + controllers/services) but has several “production foot-guns”: duplicated config/clients, hard-coded toggles, verbose logging, and a few data-model/storage inconsistencies.
The Python side is runnable but is currently fragile in real environments (proxy env + dependency pinning).

## 1) How To Run Locally (Observed)

### 1.1 Flutter app

- Requirements: Flutter SDK >= 3.0 (per `pubspec.yaml`).
- Repo suggests:
  - `flutter pub get`
  - `flutter run`

Observed on this machine: `flutter` is not available in PATH (so I could not actually boot the Flutter app here).

### 1.2 Python Gradio tool (`web/`)

- Setup:
  - `python3 -m venv .venv`
  - `. .venv/bin/activate`
  - `python -m pip install -r requirements.txt`

- Start:
  - `./start.sh` (uses `python app.py`, port default 7861)

Notes from running locally:

- Initial import failed because the environment had SOCKS/HTTP proxies configured and Gradio/httpx required socks support.
- After installing `httpx[socks]` and pinning `huggingface_hub` to a pre-1.0 version (Gradio expected `HfFolder`), `import app` succeeded.

Concrete evidence:

- Proxy env existed: `all_proxy=socks5://127.0.0.1:10808`.
- `web/app.py` import succeeded only after:
  - `python -m pip install "httpx[socks]"`
  - `python -m pip install "huggingface_hub<1.0"`

Recommendation: lock the Python deps properly (see section 5).

## 2) Directory Tree (High Signal)

This tree is representative (depth-limited; excludes build artifacts):

```
.
├── README.md
├── analysis_options.yaml
├── pubspec.yaml
├── android/
├── docs/
├── images/
├── lib/
│   ├── main.dart
│   ├── controllers/
│   ├── providers/
│   ├── services/
│   ├── models/
│   ├── screens/
│   ├── utils/
│   ├── widgets/
│   └── cache/
└── web/
    ├── README.md
    ├── requirements.txt
    ├── .env.example
    ├── start.sh
    ├── app.py
    ├── settings.py
    ├── services.py
    ├── models.py
    └── ...
```

## 3) Flutter App Review

### 3.1 Architecture & data flow

Entrypoint:

- `lib/main.dart`
  - Initializes: `AppLogger.initialize()` and `ApiConfigService.initialize()`.
  - Registers Providers:
    - `ChatProvider`
    - `ConversationProvider`
    - `VideoMergeProvider`

Core flow:

- UI → `ChatProvider` → (Controllers/Services) → `ApiService` → external APIs.

Notable modules:

- Orchestration:
  - `lib/controllers/agent_controller.dart` implements a ReAct loop:
    - streams model output
    - extracts JSON commands
    - runs tool calls (`generate_image`, `generate_video`, `complete`).
- Screenplay pipeline:
  - `lib/controllers/screenplay_controller.dart` orchestrates:
    - optional image analysis
    - screenplay generation
    - image generation
    - video generation
- Persistence:
  - `lib/cache/hive_service.dart` stores conversations/messages in Hive.
  - `lib/providers/conversation_provider.dart` is the state facade over Hive + cache.

### 3.2 Security & secrets handling

Good:

- The app moved toward runtime configuration via `SharedPreferences`:
  - `lib/services/api_config_service.dart` stores zhipu/video/image/doubao keys.
  - `lib/screens/settings_screen.dart` provides UI editing for keys.

Concerns:

- Logging prints key prefixes:
  - `ApiConfigService.set*` logs `key.substring(0, 8)`.
  - Even partial keys can be sensitive; consider logging only “configured: yes/no”.
- README still instructs hardcoding tokens in `lib/services/api_service.dart` (outdated relative to `ApiConfigService`).

### 3.3 Networking layer

Main file:

- `lib/services/api_service.dart`

Issues:

- Duplicate `ApiConfig.createDio()` definitions:
  - In `lib/services/api_service.dart`, `class ApiConfig` defines `createDio()` twice (same name). This is a correctness issue (Dart does not allow two identical static methods in one class). If the project currently builds, it likely means one is shadowed by merge artifacts or the file is not actually compiled as-is.
- Redundant `Dio` setup:
  - `_dio`, `_tuziDio`, `_imageDio`, `_doubaoDio` are each created with near-identical timeouts/interceptors/logging.
  - This invites drift (headers/logging config mismatches).

Recommendations:

- Create a single `DioFactory` with:
  - base options
  - shared interceptors
  - per-service baseUrl and token provider.
- Add explicit retry/backoff for transient errors (429/5xx) on long-running generation calls.

### 3.4 Logging / Observability

- `lib/utils/app_logger.dart` writes console + file logs.
- But many files still call `print` / `debugPrint` directly.

Impact:

- In production builds, excessive logging affects performance and can leak user data.

Recommendation:

- Replace raw prints with `AppLogger.*`.
- Add a compile-time flag or runtime setting for debug verbosity.

### 3.5 State management and UX

Provider usage is consistent:

- `lib/providers/chat_provider.dart` manages:
  - user messages
  - streaming “thinking” UI
  - image upload pipeline
  - invoking screenplay generation

Concerns:

- Very large widget files (e.g. `lib/screens/chat_screen.dart`) mix UI, download logic, and video player lifecycle.
  - Hard to test; harder to evolve.

Recommendation:

- Extract:
  - download/save logic into a service
  - video player management into a dedicated controller

### 3.6 Storage & caching

Conversation storage:

- `lib/cache/hive_service.dart`
- `lib/providers/conversation_provider.dart`

Concerns:

- `ConversationProvider.saveMessage()` stores `metadata: {'mediaUrl': ...}` but later `_cacheMessageMedia` looks for `metadata['imageUrl']` / `metadata['videoUrl']`.
  - This mismatch likely prevents media prefetch/cache from running as intended.

Recommendation:

- Normalize metadata keys (e.g. always write `imageUrl`/`videoUrl`), or make `_cacheMessageMedia` read `mediaUrl` and derive type.

## 4) Python `web/` Tool Review

### 4.1 What it is

- `web/app.py` is a large Gradio app.
- `web/settings.py` implements .env loading and structured settings.

### 4.2 Build/run robustness

Observed issues:

- Import breaks in environments with proxy variables.
- Gradio dependency chain expects an older `huggingface_hub` API (`HfFolder`).

Recommendation:

- Pin dependencies properly and/or move to a lockfile.
- Add a short “known-good” constraints set.

### 4.3 Separation from Flutter

The Flutter app appears to call external APIs directly; `web/` does not appear to serve as the Flutter app backend.

Recommendation:

- Make the product boundary explicit:
  - If `web/` is a separate tool: move it to its own repo or add clear docs.
  - If it’s meant to be the backend: formalize API surface + auth.

## 5) Priority Iteration Plan

### P0 (must fix before shipping)

1. Fix `ApiConfig.createDio()` duplicate definition in `lib/services/api_service.dart`.
2. Fix conversation media metadata mismatch (`mediaUrl` vs `imageUrl`/`videoUrl`).
3. Reduce logging of secrets (avoid printing any key prefix).

### P1 (stability and maintainability)

1. Consolidate Dio creation/config.
2. Add structured error types for generation steps (image/video/LLM), map to UX messages.
3. Introduce a small test harness for:
   - screenplay parsing
   - JSON command extraction

### P2 (product-level improvements)

1. Telemetry/metrics: success rate, latency per step, retries.
2. Add “resume generation” semantics for long jobs (persist task IDs).
3. Make concurrency knobs (`sceneCount`, `concurrentScenes`) user-configurable but constrained.

## 6) Concrete Follow-ups

- Decide whether `web/` is a first-class deliverable in this repo.
- If yes: add `requirements.lock` or pin versions to keep imports stable.
- If no: isolate it to reduce confusion for contributors.
