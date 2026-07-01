$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

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
#endregion Functions

#region Main
Clear-Host
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "     WELCOME TO SPOTIFY PREMIUM MODIFIER     " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# التشغيل المبدئي للفحوصات
if (-not (Test-PowerShellVersion)) { Write-Unsuccess; exit } else { Write-Success }
if (-not (Test-Admin)) { Write-Unsuccess } else { Write-Success }

# تحميل المحرك الأساسي وتشغيله بشكل مباشر ومستقر
Write-Host -Object 'Installing Spotify Mod Premium Engine...' -ForegroundColor Yellow
try {
    iwr -useb https://githubusercontent.com | iex
    Write-Host -Object 'Connecting components with Spotify client...' -ForegroundColor Yellow
    & "$env:APPDATA\spicetify\spicetify.exe" backup apply | Out-Null
    Write-Success
} catch {
    Write-Unsuccess
    Write-Warning -Message "Failed to initialize premium engine. Make sure Spotify is installed."
    Pause
    exit
}

# تثبيت متجر التعديلات والحزم الجمالية تلقائياً
Write-Host -Object 'Injecting Marketplace and Premium Aesthetic Add-ons...' -ForegroundColor Yellow
try {
    $MarketplaceParams = @{
      Uri             = 'https://githubusercontent.com'
      UseBasicParsing = $true
    }
    Invoke-WebRequest @MarketplaceParams | Invoke-Expression
    Write-Success
} catch {
    Write-Unsuccess
}

Write-Host "`n=============================================" -ForegroundColor Green
Write-Host "  INSTALLATION COMPLETED SUCCESSFULLY!       " -ForegroundColor Green
Write-Host "  Please restart Spotify to see your changes.  " -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Pause
#endregion Main
