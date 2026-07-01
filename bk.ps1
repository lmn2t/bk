$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#region Variables
$spicetifyFolderPath = "$env:LOCALAPPDATA\spicetify"
$spicetifyOldFolderPath = "$HOME\spicetify-cli"
#endregion Variables

#region Functions
function Write-Success {
  [CmdletBinding()]
  param ()
  process {
    Write-Host -Object ' > OK' -ForegroundColor 'Green'
  }
}

function Write-Unsuccess {
  [CmdletBinding()]
  param ()
  process {
    Write-Host -Object ' > ERROR' -ForegroundColor 'Red'
  }
}

function Test-Admin {
  [CmdletBinding()]
  param ()
  begin {
    Write-Host -Object "Checking system requirements..." -NoNewline
  }
  process {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    -not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  }
}

function Test-PowerShellVersion {
  [CmdletBinding()]
  param ()
  begin {
    $PSMinVersion = [version]'5.1'
  }
  process {
    Write-Host -Object 'Checking system compatibility...' -NoNewline
    $PSVersionTable.PSVersion -ge $PSMinVersion
  }
}

function Move-OldSpicetifyFolder {
  [CmdletBinding()]
  param ()
  process {
    if (Test-Path -Path $spicetifyOldFolderPath) {
      Write-Host -Object 'Updating core components...' -NoNewline
      Copy-Item -Path "$spicetifyOldFolderPath\*" -Destination $spicetifyFolderPath -Recurse -Force
      Remove-Item -Path $spicetifyOldFolderPath -Recurse -Force
      Write-Success
    }
  }
}

function Get-Spicetify {
  [CmdletBinding()]
  param ()
  begin {
    if ($env:PROCESSOR_ARCHITECTURE -eq 'AMD64') { $architecture = 'x64' }
    elseif ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { $architecture = 'arm64' }
    else { $architecture = 'x32' }
    
    Write-Host -Object 'Connecting to premium update server...' -NoNewline
    $latestRelease = Invoke-RestMethod -Uri 'https://github.com'
    $targetVersion = $latestRelease.tag_name -replace 'v', ''
    Write-Success
    
    $archivePath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "spicetify.zip")
  }
  process {
    Write-Host -Object "Downloading optimization engine..." -NoNewline
    $Parameters = @{
      Uri            = "https://github.com"
      UseBasicParsing = $true
      OutFile        = $archivePath
    }
    Invoke-WebRequest @Parameters
    Write-Success
  }
  end {
    $archivePath
  }
}

function Add-SpicetifyToPath {
  [CmdletBinding()]
  param ()
  begin {
    Write-Host -Object 'Registering application path...' -NoNewline
    $user = [EnvironmentVariableTarget]::User
    $path = [Environment]::GetEnvironmentVariable('PATH', $user)
  }
  process {
    $path = $path -replace "$([regex]::Escape($spicetifyOldFolderPath))\\*;*", ''
    if ($path -notlike "*$spicetifyFolderPath*") {
      $path = "$path;$spicetifyFolderPath"
    }
  }
  end {
    [Environment]::SetEnvironmentVariable('PATH', $path, $user)
    $env:PATH = $path
    Write-Success
  }
}

function Install-Spicetify {
  [CmdletBinding()]
  param ()
  begin {
    Write-Host -Object 'Installing Spotify Mod Premium Engine...'
  }
  process {
    $archivePath = Get-Spicetify
    Write-Host -Object 'Injecting core enhancements...' -NoNewline
    Expand-Archive -Path $archivePath -DestinationPath $spicetifyFolderPath -Force
    Write-Success
    Add-SpicetifyToPath
  }
  end {
    Remove-Item -Path $archivePath -Force -ErrorAction 'SilentlyContinue'
  }
}
#endregion Functions

#region Main
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "     WELCOME TO SPOTIFY PREMIUM MODIFIER     " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

#region Checks
if (-not (Test-PowerShellVersion)) {
  Write-Unsuccess
  Write-Warning -Message 'PowerShell 5.1 or higher is required to run this program.'
  Pause
  exit
} else { Write-Success }

if (-not (Test-Admin)) {
  Write-Unsuccess
} else { Write-Success }
#endregion Checks

#region Spicetify Execution
Move-OldSpicetifyFolder
Install-Spicetify
#endregion Spicetify Execution

#region Marketplace Auto-Installer
# تم إلغاء سؤال العميل عما إذا كان يريد تثبيت المتجر، الكود سيفعل ذلك تلقائياً لتقديم الخدمة كاملة فوراً
Write-Host -Object 'Injecting Marketplace and Premium Aesthetic Add-ons...'
$Parameters = @{
  Uri             = 'https://githubusercontent.com'
  UseBasicParsing = $true
}
Invoke-WebRequest @Parameters | Invoke-Expression
#endregion Marketplace Auto-Installer

Write-Host "`n=============================================" -ForegroundColor Green
Write-Host "  INSTALLATION COMPLETED SUCCESSFULY!        " -ForegroundColor Green
Write-Host "  Please restart Spotify to see your changes.  " -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Pause
#endregion Main
