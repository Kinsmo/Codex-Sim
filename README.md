# 🚀 Codex-Sim

**Codex-Sim** is a lightweight **Codex CLI–style simulator** that lets you pretend you’re using Codex —  
without spending money on tokens 💸.

> A local, offline Codex-like experience for demos, learning, and fun.

---

## 🧠 What Is Codex-Sim?

**Codex-Sim** simulates the look & feel of the Codex command-line interface.  
It runs entirely on your local machine and does **not** require:

- OpenAI API keys
- Paid tokens
- Internet connection

It’s perfect for:
- Learning how Codex-style tools work
- Demos & screenshots
- CLI / TUI experimentation
- Having fun when you’re broke 😄

---

## ✨ Features

- 🧩 Codex-like interactive CLI
- 💻 Runs locally (no cloud, no API)
- 🪶 Lightweight and fast
- 📦 Multiple launch methods (EXE / Cargo / PowerShell)
- 🔧 Easy to extend or customize

---

## ⚡ Getting Started

You can run Codex-Sim in **three different ways**.

### ✅ Method 1 — Run the Executable (Recommended)

1. Download `codex-sim.exe`
2. Double-click it
3. Start typing commands

---

### 🦀 Method 2 — Run with Cargo (From Source)

Make sure you have **Rust + Cargo** installed.

```bash
git clone https://github.com/Kinsmo/Codex-Sim.git
cd Codex-Sim
cargo run
```

---

### 🖥 Method 3 — Run with PowerShell

Open PowerShell in the project directory and run:

```powershell
./codex-sim.ps1
```

---

## ⌨️ Example Interaction

```text
> help
Available commands:
  /model        switch the simulated model
  /clear        clear the screen
  /history      show chat history
  exit          quit Codex-Sim
```

---

## 📁 Project Structure

```
Codex-Sim/
├── src/                 # Core source code
├── codex-sim.ps1        # PowerShell launcher
├── codex-sim.exe        # Compiled executable
└── README.md            # Documentation
```

---

## 💡 Motivation

Codex-Sim exists because:

- Codex looks cool
- Tokens are expensive
- Sometimes you just want the *experience*, not the bill

This project lets you experiment with Codex-style workflows **completely offline**.

---

## 🛠 Build From Source

```bash
cargo build --release
```

The binary will be generated in:

```
target/release/
```

---

## 📜 License

MIT License
