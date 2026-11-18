# Draws the pixel basket from the app as PNG app icons (run: powershell -File tools\make-icons.ps1)
Add-Type -AssemblyName System.Drawing

$basket = @(
  "....KKKK....",
  "...K..G.K...",
  "..KRR.GG.K..",
  "KKKKKKKKKKKK",
  "KOOOOOOOOOOK",
  ".KOBOBOBOBK.",
  ".KBOBOBOBOK.",
  ".KOBOBOBOBK.",
  "..KKKKKKKK.."
)
$pal = @{
  'K' = '#3b2a1e'; 'O' = '#e0a868'; 'B' = '#a86b32'; 'R' = '#e2504a'; 'G' = '#5bb36a'
}

function New-Icon([int]$size, [string]$path) {
  $bmp = New-Object System.Drawing.Bitmap $size, $size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'None'
  $g.InterpolationMode = 'NearestNeighbor'
  # sky-blue ground with the app's dot grid
  $g.Clear([System.Drawing.ColorTranslator]::FromHtml('#7DC4EE'))
  $dot = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml('#A8DAF5'))
  $step = [math]::Max(4, [int]($size / 16))
  $d = [math]::Max(1, [int]($step / 5))
  for ($y = [int]($step / 2); $y -lt $size; $y += $step) {
    for ($x = [int]($step / 2); $x -lt $size; $x += $step) { $g.FillRectangle($dot, $x, $y, $d, $d) }
  }
  # basket centred inside the maskable safe zone (middle ~60%)
  $cell = [int][math]::Floor($size * 0.6 / 12)
  $w = 12 * $cell; $h = 9 * $cell
  $ox = [int](($size - $w) / 2); $oy = [int](($size - $h) / 2) + $cell
  # soft pixel shadow under the basket
  $sh = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(70, 18, 48, 74))
  $g.FillRectangle($sh, $ox + $cell, $oy + $h, $w - 2 * $cell, $cell)
  for ($r = 0; $r -lt $basket.Count; $r++) {
    $row = $basket[$r]
    for ($c = 0; $c -lt $row.Length; $c++) {
      $ch = [string]$row[$c]
      if ($pal.ContainsKey($ch)) {
        $b = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml($pal[$ch]))
        $g.FillRectangle($b, $ox + $c * $cell, $oy + $r * $cell, $cell, $cell)
        $b.Dispose()
      }
    }
  }
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
}

$root = Split-Path -Parent $PSScriptRoot
$dir = Join-Path $root 'icons'
New-Item -ItemType Directory -Force -Path $dir | Out-Null
New-Icon 512 (Join-Path $dir 'icon-512.png')
New-Icon 192 (Join-Path $dir 'icon-192.png')
New-Icon 180 (Join-Path $dir 'apple-touch-icon.png')
Get-ChildItem $dir | Select-Object Name, Length
