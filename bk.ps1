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
  process { Write-Host -Object ' > OK' -ForegroundColor 'Green' }
}

function Write-Unsuccess {
  [CmdletBinding()]
  param ()
  process { Write-Host -Object ' > ERROR' -ForegroundColor 'Red' }
}

function Test-Admin {
  [CmdletBinding()]
  param ()
  begin { Write-Host -Object "Checking system requirements..." -NoNewline }
  process {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    -not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  }
}

function Test-PowerShellVersion {
  [CmdletBinding()]
  param ()
  begin { $PSMinVersion = [version]'5.1' }
  process {
    Write-Host -Object 'Checking system compatibility...' -NoNewline
    $PSVersionTable.PSVersion -ge $PSMinVersion
  }
}

function Install-Spicetify {
  [CmdletBinding()]
  param ()
  begin {
    Write-Host -Object 'Installing Spotify Mod Premium Engine...'
  }
  process {
    Write-Host -Object "Downloading optimization engine..." -NoNewline
    
    # تحميل التثبيت الرسمي مباشرة وبشكل آمن ومضمون
    $archivePath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "spicetify.zip")
    
    # تحديد المعمارية تلقائياً
    if ($env:PROCESSOR_ARCHITECTURE -eq 'AMD64') { $arch = 'x64' } else { $arch = 'x32' }
    
    # جلب رابط أحدث نسخة مستقرة مباشرة
    $latestRelease = Invoke-RestMethod -Uri 'https://github.com'
    $targetVersion = $latestRelease.tag_name
    $downloadUrl = "https://github.com($targetVersion -replace 'v', '')-windows-$arch.zip"
    
    Invoke-WebRequest -Uri $downloadUrl -OutFile $archivePath -UseBasicParsing
    Write-Success

    Write-Host -Object 'Injecting core enhancements...' -NoNewline
    if (-not (Test-Path -Path $spicetifyFolderPath)) {
        New-Item -ItemType Directory -Path $spicetifyFolderPath | Out-Null
    }
    Expand-Archive -Path $archivePath -DestinationPath $spicetifyFolderPath -Force
    Write-Success

    # إضافة البرنامج للمسارات الافتراضية للويندوز ليعمل من أي مكان
    $user = [EnvironmentVariableTarget]::User
    $path = [Environment]::GetEnvironmentVariable('PATH', $user)
    if ($path -notlike "*$spicetifyFolderPath*") {
      [Environment]::SetEnvironmentVariable('PATH', "$path;$spicetifyFolderPath", $user)
      $env:PATH = "$env:PATH;$spicetifyFolderPath"
    }
    
    Remove-Item -Path $archivePath -Force -ErrorAction 'SilentlyContinue'
  }
}
#endregion Functions

#region Main
Clear-Host
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "     WELCOME TO SPOTIFY PREMIUM MODIFIER     " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Checks
if (-not (Test-PowerShellVersion)) { Write-Unsuccess; exit } else { Write-Success }
if (-not (Test-Admin)) { Write-Unsuccess } else { Write-Success }

# Execution
Install-Spicetify

# تشغيل الإعداد الأولي لربط سبوتيفاي
Write-Host -Object 'Connecting components with Spotify client...' -NoNewline
& "$spicetifyFolderPath\spicetify.exe" backup apply | Out-Null
Write-Success

# تثبيت المتجر التلقائي للحزم الجمالية
Write-Host -Object 'Injecting Marketplace and Premium Aesthetic Add-ons...'
$Parameters = @{
  Uri             = 'https://githubusercontent.com'
  UseBasicParsing = $true
}
Invoke-WebRequest @Parameters | Invoke-Expression

Write-Host "`n=============================================" -ForegroundColor Green
Write-Host "  INSTALLATION COMPLETED SUCCESSFULLY!       " -ForegroundColor Green
Write-Host "  Please restart Spotify to see your changes.  " -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Pause
#endregion Main
