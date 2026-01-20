# codex_tui.ps1
# Goal: draw a simple Codex-like cmd UI in Windows Terminal (ANSI-capable).

# =========================
# Fixed parameters (tweak here)
# =========================
$APP_NAME  = "OpenAI Codex"
$VERSION   = "v0.87.0"
$MODEL     = "gpt-5.2-codex"
$DIR       = (Get-Location).Path
$TIP       = "Tip: Use /compact when the conversation gets long to summarize history and free up context."
$PROMPT    = "> "
$PLACEHOLDER = "Implement {feature}"
$STATUS    = "100% context left ? for shortcuts"

# =========================
# ANSI / terminal helpers
# =========================
$ESC = [char]27

function SGR([string]$s) { return "$ESC[$s" }

# Common styles
$RESET   = SGR "0m"
$BOLD    = SGR "1m"
$DIM     = SGR "2m"
$ITALIC  = SGR "3m"

# Colors (soft gray UI, cyan hints)
$FG      = SGR "38;2;230;230;230m"
$FG_DIM  = SGR "38;2;150;150;150m"
$FG_TIP  = SGR "38;2;170;170;170m"
$FG_CYAN = SGR "38;2;120;200;255m"
$FG_INPUT = SGR "38;2;255;170;60m"

function ClearScreen() {
  Write-Host -NoNewline (SGR "2J")
  Write-Host -NoNewline "$ESC[1;1H"
}

function HideCursor() { Write-Host -NoNewline (SGR "?25l") }
function ShowCursor() { Write-Host -NoNewline (SGR "?25h") }

function MoveTo([int]$row, [int]$col) {
  # 1-indexed
  Write-Host -NoNewline "$ESC[$row;${col}H"
}

function WriteAt([int]$row, [int]$col, [string]$text) {
  MoveTo $row $col
  Write-Host -NoNewline $text
}

function PadRightExact([string]$s, [int]$len) {
  if ($s.Length -ge $len) { return $s.Substring(0, $len) }
  return $s + (" " * ($len - $s.Length))
}

function DrawBoxSmooth([int]$top, [int]$left, [int]$width, [int]$height) {
  # width/height: outer size including borders
  $w = $width
  $h = $height
  if ($w -lt 2 -or $h -lt 2) { return }

  # Use char codes to avoid file encoding issues.
  $tl=[char]0x256D  # top-left  (╭)
  $tr=[char]0x256E  # top-right (╮)
  $bl=[char]0x2570  # bot-left  (╰)
  $br=[char]0x256F  # bot-right (╯)
  $hz=[char]0x2500  # horiz     (─)
  $vt=[char]0x2502  # vert      (│)

  WriteAt $top $left ($FG + $tl + ($hz.ToString() * ($w-2)) + $tr + $RESET)
  for ($r = 1; $r -le ($h-2); $r++) {
    WriteAt ($top+$r) $left ($FG + $vt + $RESET)
    WriteAt ($top+$r) ($left+$w-1) ($FG + $vt + $RESET)
  }
  WriteAt ($top+$h-1) $left ($FG + $bl + ($hz.ToString() * ($w-2)) + $br + $RESET)
}

# =========================
# Render (layout)
# =========================
$script:Layout = @{}

function RenderFrame([string]$inputLine, [int]$cursorIndex, [bool]$showHelp) {
  $raw = $Host.UI.RawUI
  $rows = $raw.WindowSize.Height
  $cols = $raw.WindowSize.Width

  ClearScreen

  # Top two lines (simulate cmd banner)
  WriteAt 1 1 ($FG + "Microsoft Windows [Version 10.0.26200.7623]" + $RESET)
  WriteAt 2 1 ($FG + "(c) Microsoft Corporation. All rights reserved." + $RESET)

  # Current path line
  $pathLine = "$DIR>codex"
  WriteAt 4 1 ($FG + $pathLine + $RESET)

  # Main box
  $boxTop = 6
  $boxLeft = 3
  $boxWidth = [Math]::Min(84, $cols - 6)
  $boxHeight = 6
  DrawBoxSmooth $boxTop $boxLeft $boxWidth $boxHeight

  # Box content
  $innerLeft = $boxLeft + 2
  $r1 = $boxTop + 1
  $r2 = $boxTop + 2
  $r3 = $boxTop + 3
  $r4 = $boxTop + 4

  $title = ">_ $APP_NAME ($VERSION)"
  WriteAt $r1 $innerLeft ($FG + $title + $RESET)

  # model line: model: gpt-5.2-codex /model to change
  $modelLabel = "model:"
  $modelValue = " $MODEL "
  $modelHint  = "/model"
  $modelHint2 = " to change"
  WriteAt $r3 $innerLeft ($FG_DIM + $modelLabel + $RESET)
  WriteAt $r3 ($innerLeft + $modelLabel.Length + 1) ($FG + $modelValue + $RESET)
  WriteAt $r3 ($innerLeft + $modelLabel.Length + 1 + $modelValue.Length + 1) ($FG_CYAN + $modelHint + $RESET)
  WriteAt $r3 ($innerLeft + $modelLabel.Length + 1 + $modelValue.Length + 1 + $modelHint.Length) ($FG_DIM + $modelHint2 + $RESET)

  # directory line
  $dirLabel = "directory:"
  $dirValue = " $DIR"
  WriteAt $r4 $innerLeft ($FG_DIM + $dirLabel + $RESET)
  WriteAt $r4 ($innerLeft + $dirLabel.Length + 1) ($FG + $dirValue + $RESET)

  # Tip
  WriteAt ($boxTop + $boxHeight + 2) 1 ($FG_TIP + $TIP + $RESET)

  # Input area: > [placeholder]
  $inputRow = $boxTop + $boxHeight + 5
  $inputCol = 1

  # Bottom status
  WriteAt ($inputRow + 2) 1 ($FG_DIM + $STATUS + $RESET)

  # Help panel (toggle with ?)
  if ($showHelp) {
    $helpTop = $inputRow + 4
    $helpLeft = 3
    $helpWidth = [Math]::Min(72, $cols - 6)
    $helpHeight = 7
    if ($helpTop + $helpHeight -lt $rows) {
      DrawBoxSmooth $helpTop $helpLeft $helpWidth $helpHeight
      $hL = $helpLeft + 2
      WriteAt ($helpTop+1) $hL ($FG + "Shortcuts" + $RESET)
      WriteAt ($helpTop+2) $hL ($FG_DIM + "?    toggle this help" + $RESET)
      WriteAt ($helpTop+3) $hL ($FG_DIM + "Enter submit line" + $RESET)
      WriteAt ($helpTop+4) $hL ($FG_DIM + "Ctrl+L clear screen" + $RESET)
      WriteAt ($helpTop+5) $hL ($FG_DIM + "Ctrl+C exit" + $RESET)
    }
  }

  $script:Layout = @{
    Rows = $rows
    Cols = $cols
    InputRow = $inputRow
    InputCol = $inputCol
    InputWidth = $cols - $inputCol + 1
    PromptLen = $PROMPT.Length
  }

  RenderInputLine $inputLine $cursorIndex
}

function RenderInputLine([string]$inputLine, [int]$cursorIndex) {
  $layout = $script:Layout
  if (-not $layout.InputRow) { return }

  $inputRow = $layout.InputRow
  $inputCol = $layout.InputCol
  $cols = $layout.Cols
  $promptLen = $layout.PromptLen
  $contentWidth = $layout.InputWidth - $promptLen

  WriteAt $inputRow $inputCol ($FG + $PROMPT + $RESET)

  if ([string]::IsNullOrEmpty($inputLine)) {
    $text = PadRightExact $PLACEHOLDER $contentWidth
    WriteAt $inputRow ($inputCol + $promptLen) ($DIM + $FG_DIM + $text + $RESET)
  } else {
    $text = PadRightExact $inputLine $contentWidth
    WriteAt $inputRow ($inputCol + $promptLen) ($FG_INPUT + $text + $RESET)
  }

  # Place cursor at input position
  $cursorX = $inputCol + $PROMPT.Length + $cursorIndex
  $cursorY = $inputRow
  if ($cursorX -lt 1) { $cursorX = 1 }
  if ($cursorX -gt $cols) { $cursorX = $cols }
  MoveTo $cursorY $cursorX
}

# =========================
# Main loop (minimal line editor)
# =========================
$line = ""
$idx = 0
$showHelp = $false

try {
  HideCursor
  RenderFrame $line $idx $showHelp

  while ($true) {
    $k = [System.Console]::ReadKey($true)

    # Ctrl+C
    if ($k.Modifiers -band [ConsoleModifiers]::Control -and $k.Key -eq "C") {
      break
    }

    # Ctrl+L redraw
    if ($k.Modifiers -band [ConsoleModifiers]::Control -and $k.Key -eq "L") {
      RenderFrame $line $idx $showHelp
      continue
    }

    # Toggle help
    if ($k.KeyChar -eq '?') {
      $showHelp = -not $showHelp
      RenderFrame $line $idx $showHelp
      continue
    }

    switch ($k.Key) {
      "LeftArrow" {
        if ($idx -gt 0) { $idx-- }
      }
      "RightArrow" {
        if ($idx -lt $line.Length) { $idx++ }
      }
      "Home" { $idx = 0 }
      "End"  { $idx = $line.Length }
      "Backspace" {
        if ($idx -gt 0) {
          $line = $line.Remove($idx-1, 1)
          $idx--
        }
      }
      "Delete" {
        if ($idx -lt $line.Length) {
          $line = $line.Remove($idx, 1)
        }
      }
      "Enter" {
        # Simulate "submit": clear input line.
        $line = ""
        $idx = 0
      }
      default {
        # Insert printable chars
        if ($k.KeyChar -ne [char]0 -and -not [char]::IsControl($k.KeyChar)) {
          $ch = [string]$k.KeyChar
          if ($idx -ge $line.Length) {
            $line += $ch
            $idx = $line.Length
          } else {
            $line = $line.Insert($idx, $ch)
            $idx++
          }
        }
      }
    }

    $raw = $Host.UI.RawUI
    $curRows = $raw.WindowSize.Height
    $curCols = $raw.WindowSize.Width
    if ($curRows -ne $script:Layout.Rows -or $curCols -ne $script:Layout.Cols) {
      RenderFrame $line $idx $showHelp
    } else {
      RenderInputLine $line $idx
    }
  }
}
finally {
  ShowCursor
  Write-Host -NoNewline $RESET
  Write-Host ""
}
