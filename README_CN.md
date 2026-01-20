# 🚀 Codex-Sim

**Codex-Sim** 是一个轻量级的 **Codex CLI 风格模拟器**，让你在**不花一分钱买 token**的情况下，
体验“正在使用 Codex”的感觉 💸。

> 一个用于演示、学习和娱乐的本地离线 Codex 风格体验。

<p align="center">
  <img width="500" alt="image"
       src="https://github.com/user-attachments/assets/6e0cd541-1b6c-4b99-877b-5bbd627d86a9" />
</p>

本项目仅为模拟器。  
如需体验 **官方 / 原版 Codex**，请访问：https://chatgpt.com/codex

---

## 🧠 什么是 Codex-Sim？

**Codex-Sim** 用于模拟 Codex 命令行工具（CLI）的外观和交互体验。  
它**完全在本地运行**，并且**不需要**：

- OpenAI API Key
- 付费 Token
- 网络连接

它非常适合用于：

- 学习 Codex / AI CLI 工具的工作方式  
- 演示、录屏、截图  
- CLI / TUI 交互界面实验  
- 没钱但又想玩 Codex 😄  

---

## ✨ 功能特性

- 🧩 Codex 风格的交互式命令行界面  
- 💻 完全本地运行（无云端、无 API）  
- 🪶 轻量、快速  
- 📦 多种启动方式（EXE / Cargo / PowerShell）  
- 🔧 易于扩展和自定义  

---

## ⚡ 快速开始

你可以通过 **三种方式** 运行 Codex-Sim。

### ✅ 方法一：直接运行可执行文件（推荐）

1. 下载 `codex-sim.exe`
2. 双击运行
3. 开始输入命令

---

### 🦀 方法二：使用 Cargo 从源码运行

请确保已安装 **Rust 和 Cargo**。

```bash
git clone https://github.com/Kinsmo/Codex-Sim.git
cd Codex-Sim
cargo run
```

---

### 🖥 方法三：使用 PowerShell 运行

在项目目录中打开 PowerShell，然后执行：

```powershell
./codex-sim.ps1
```

---

## ⌨️ 示例交互

```text
> help
Available commands:
  /model        切换模拟的模型
  /clear        清屏
  /history      查看历史记录
  exit          退出 Codex-Sim
```

---

## 📁 项目结构

```
Codex-Sim/
├── src/                 # 核心源码
├── codex-sim.ps1        # PowerShell 启动脚本
├── codex-sim.exe        # 编译后的可执行文件
└── README.md            # 项目说明文档
```

---

## 💡 项目动机

创建 Codex-Sim 的原因很简单：

- Codex 看起来很酷  
- Token 很贵  
- 有时候你只想要 **体验感**，而不是账单  

Codex-Sim 让你可以 **完全离线** 地体验 Codex 风格的工作流。

---

## 🛠 从源码构建

```bash
cargo build --release
```

生成的可执行文件位于：

```
target/release/
```

---

## 📜 许可证

MIT License
