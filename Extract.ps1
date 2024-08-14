#requires -version 5

$CurrPathName = (Get-Location).Path

$ArchiveFile = Get-ChildItem (Join-Path $CurrPathName "nomad-net*.zip") |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1
if ( $null -eq $ArchiveFile ) {
  return
}

$ExpandDirName = Join-Path (Split-Path $ArchiveFile.FullName -Parent) "redist"

$OutputDir = New-Item $ExpandDirName -ItemType Directory
if ( $null -eq $OutputDir ) {
  return
}

$ArchiveFile | Expand-Archive -DestinationPath $OutputDir.FullName
if ( -not $? ) {
  return
}

$ItemNames = @(
  "be"
  "cs"
  "de"
  "fr"
  "it"
  "nl"
  "ru"
  "compile.bat"
  "Nomad.exe.config"
  "Nomad_x86.exe.config"
)
foreach ( $ItemName in $ItemNames ) {
  $Item = Get-Item (Join-Path $OutputDir.FullName $ItemName)
  if ( $null -ne $Item ) {
    if ( $Item -is [IO.DirectoryInfo] ) {
      $Item | Remove-Item -Force -Recurse
    }
    elseif ( $Item -is [IO.FileInfo] ) {
      $Item | Remove-Item
    }
  }
}

$ItemNames = @(
  "redist_x64"
  "redist_x86"
)
foreach ( $ItemName in $ItemNames ) {
  $FullName = Join-Path (Join-Path $CurrPathName $ItemName) "Plugins\Formats"
  New-Item $FullName -ItemType Directory -ErrorAction Stop | Out-Null
}

Move-Item (Join-Path $CurrPathName "redist\Nomad_x86.exe") "redist_x64"
Move-Item (Join-Path $CurrPathName "redist\Plugins\Formats\*_x64.*") "redist_x64\Plugins\Formats"
Move-Item (Join-Path $CurrPathName "redist\Plugins\Formats\*_x86.*") "redist_x86\Plugins\Formats"
