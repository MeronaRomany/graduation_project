# AI Language Practice App - Ecosystem & Integration

This document provides a high-level overview of the application's ecosystem. It focuses on how the mobile application interacts with various external services, cloud infrastructure, and AI models to deliver a seamless language learning and practice experience.

## 1. High-Level Ecosystem Diagram

This diagram illustrates the main connections between the user's device (the App) and the external services that power it.

```mermaid
graph TB
    classDef box font-size:16px,stroke-width:2px

    User([User])

    subgraph App[Mobile App]
        AWP[AI Writing Practice]
        PAI[Practice with AI]
        PWF[Practice with Friends]
        AgoraCli[Agora RTC SDK]
    end

    subgraph Backend[Backend - Cloudflare Workers]
        API[API Gateway]
        Match[Matchmaking Engine]
        Prompt[Prompt Engineering Layer]
    end

    Firestore[(Firebase Firestore<br/>NoSQL DB)]
    Gemini[Google Gemini AI]
    STT[Cloud STT]
    TTS[Cloud TTS]
    Agora[Agora SD-RTN<br/>Live Meeting Servers]

    User --> AWP & PAI & PWF

    AWP -->|text| API
    PAI -->|voice / text| API
    API --> Prompt
    Prompt --> Gemini
    Gemini --> Prompt
    Prompt --> API

    PAI --> STT
    STT --> API
    API --> TTS
    TTS --> PAI

    API <--> Firestore

    PWF --> API
    API --> Match
    Match --> API
    PWF <--> AgoraCli
    AgoraCli <--> Agora
```

## 2. Use Case Diagram

```mermaid
graph LR
    classDef actor fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef system fill:#fff,stroke:#333,stroke-width:2px

    User([User])
    
    subgraph System[Fluentify App]
        direction TB
        UC1(Sign Up)
        UC2(Sign In)
        UC3(Sign In with Google)
        UC4(Reset Password)
        UC5(Browse Role-Play Scenarios)
        UC6(Create Custom Scenario)
        UC7(Start AI Conversation)
        UC8(Speak & Receive Voice Response)
        UC9(Finish Session & Get Evaluation)
        UC10(Enter Waiting Room)
        UC11(Find a Partner)
        UC12(Join Voice Call)
        UC13(Submit Writing for Analysis)
        UC14(View Writing Analysis)
        UC15(View Profile)
        UC16(Edit Profile)
        UC17(View Progress & Insights)
        UC18(View Score Trends)
        UC19(View Session History)
        UC20(Toggle Dark Mode)
        UC21(Select Voice Engine)
        UC22(Mute / Unmute)
        UC23(Leave Call)
        UC24(Reset Conversation)
    end

    Gemini(Google Gemini AI)
    Firebase(Firebase Auth + Firestore)
    Agora(Agora SD-RTN)
    Speech(Cloud STT / TTS)

    User --> UC1
    User --> UC2
    User --> UC3
    User --> UC4
    User --> UC5
    User --> UC6
    User --> UC7
    User --> UC8
    User --> UC9
    User --> UC10
    User --> UC11
    User --> UC12
    User --> UC13
    User --> UC14
    User --> UC15
    User --> UC16
    User --> UC17
    User --> UC18
    User --> UC19
    User --> UC20
    User --> UC21
    User --> UC22
    User --> UC23
    User --> UC24

    UC1 --> Firebase
    UC2 --> Firebase
    UC3 --> Firebase
    UC4 --> Firebase
    UC9 --> Gemini
    UC9 --> Firebase
    UC7 --> Gemini
    UC7 --> Speech
    UC8 --> Speech
    UC13 --> Gemini
    UC14 --> Gemini
    UC10 --> Firebase
    UC11 --> Firebase
    UC12 --> Agora
    UC12 --> Firebase
    UC15 --> Firebase
    UC16 --> Firebase
    UC17 --> Firebase
    UC18 --> Firebase
    UC19 --> Firebase
    UC22 --> Agora
    UC23 --> Agora
    UC23 --> Firebase
```

## 3. Core Service Integrations

### Firebase Firestore (Data Layer)
*   **Role:** Primary NoSQL database for the entire app.
*   **Integration:** Stores user profiles, progress tracking, practice history, room metadata, and matchmaking queues. Accessed by the backend API via CRUD operations.

### Google Gemini AI (Cloud AI)
*   **Role:** Core LLM powering all AI-driven practice modules.
*   **Usage:**
    *   **AI Writing Practice** — evaluates written text, provides grammar corrections, and suggests improvements.
    *   **Practice with AI** — drives conversational AI tutor with voice input/output.
*   Both modules integrate through a **Prompt Engineering Layer** hosted on the backend, which structures prompts, manages context windows, and refines raw model responses before returning them to the app.

### Cloud STT & TTS (Cloud AI)
*   **Role:** Enable voice interactions in the Practice with AI module.
*   **Integration:** Audio streams from the user are sent to cloud-based Speech-to-Text for transcription; AI responses are synthesized via cloud Text-to-Speech and streamed back as audio. Both models are hosted on cloud infrastructure (not on-device).

### Agora SDK (Live Communication)
*   **Role:** Real-time audio/video communication for Practice with Friends.
*   **Integration:** The app embeds the Agora RTC SDK. When a user joins or creates a practice room, the app connects to Agora's SD-RTN (Software Defined Real-Time Network) servers to enable low-latency live meetings with matched partners.

### Matchmaking Engine (Backend)
*   **Role:** Matchmaking logic for the Practice with Friends module.
*   **Integration:** The backend (Cloudflare Workers) runs a matchmaking engine that pairs users based on language, proficiency level, and availability. Once matched, room metadata is stored in Firestore and Agora tokens are issued for the live session.

## 4. High-Level User Flow Diagrams

### AI Practice Flow (Writing / Practice with AI)

```mermaid
sequenceDiagram
    actor User
    participant App as Mobile App
    participant Backend as Backend (Workers)
    participant Prompt as Prompt Engineering Layer
    participant AI as Cloud AI (Gemini)
    participant STT as Cloud STT
    participant TTS as Cloud TTS
    participant DB as Firebase Firestore

    alt Practice with AI (Voice)
        User->>App: Speaks into microphone
        App->>STT: Sends audio stream
        STT-->>App: Returns transcribed text
    end

    User->>App: Submits text (written or transcribed)
    App->>Backend: Sends input + module context
    Backend->>Prompt: Builds structured prompt
    Prompt->>AI: Sends engineered prompt
    AI-->>Prompt: Returns raw response
    Prompt-->>Backend: Refines & formats response
    Backend->>DB: Logs practice session & progress
    Backend-->>App: Returns final feedback

    alt Practice with AI (Voice)
        App->>TTS: Sends response text
        TTS-->>App: Returns synthesized audio
        App-->>User: Plays audio response
    else AI Writing Practice
        App-->>User: Displays corrections & feedback
    end
```

### Practice with Friends Flow

```mermaid
sequenceDiagram
    actor User1
    actor User2
    participant App1 as User 1 App
    participant App2 as User 2 App
    participant Backend as Backend (Workers)
    participant Match as Matchmaking Engine
    participant DB as Firebase Firestore
    participant Agora as Agora SD-RTN

    User1->>App1: Opens Practice with Friends
    App1->>Backend: Request match (language, level)
    Backend->>Match: Enqueue User1
    Match->>DB: Store match request

    User2->>App2: Opens Practice with Friends
    App2->>Backend: Request match (language, level)
    Backend->>Match: Enqueue User2
    Match->>DB: Find compatible partner

    Match-->>Backend: User1 matched with User2
    Backend-->>App1: Match found + Agora token
    Backend-->>App2: Match found + Agora token
    Backend->>DB: Create room document

    App1->>Agora: Join room with token
    App2->>Agora: Join room with token
    Agora-->>App1: Live audio/video stream
    Agora-->>App2: Live audio/video stream

    User1->>App1: Speaks / Practices
    App1->>Agora: Publishes media
    Agora->>App2: Receives media

    User2->>App2: Speaks / Practices
    App2->>Agora: Publishes media
    Agora->>App1: Receives media
```
