#Requires -RunAsAdministrator

param(
    [ValidateSet("Full","Updates","Apps","Export","Status","EnableStartup","DisableStartup")]
    [string]$Mode = "Full",

    [switch]$Silent
)

# ================================
# CONFIGURATION
# ================================

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$SetupFile  = Join-Path $ScriptDir "setup.json"
$ExportFile = Join-Path $ScriptDir "Installed_Programs.txt"
$LogFile    = Join-Path $ScriptDir "Provisioning_Log.txt"

# ================================
# LOGGING FUNCTIONS
# ================================

function Write-Log {
    param([string]$Message)

    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$time - $Message"

    Write-Host $line
    Add-Content -Path $LogFile -Value $line
}

function Write-ErrorLog {
    param([string]$Message)

    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$time - ERROR - $Message"

    Write-Host $line -ForegroundColor Red
    Add-Content -Path $LogFile -Value $line
}

# ================================
# SAFE EXECUTION WRAPPER
# ================================

function Run-Safely {
    param(
        [string]$Name,
        [scriptblock]$Code
    )

    try {
        Write-Log "Starting: $Name"
        & $Code
        Write-Log "Completed: $Name"
    }
    catch {
        Write-ErrorLog "$Name FAILED: $($_.Exception.Message)"
    }
}

# ================================
# MODULE INSTALLATION
# ================================

function Install-RequiredModules {

    if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Install-PackageProvider NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction Stop
        Install-Module PSWindowsUpdate -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
    }
}

# ================================
# APPLICATION INSTALLATION
# ================================

function Install-ApplicationsFromJSON {

    if (!(Test-Path $SetupFile)) {
        Write-Log "setup.json not found - skipping application installation."
        return
    }

    $json = Get-Content $SetupFile | ConvertFrom-Json

    foreach ($app in $json.applications) {
        Write-Log "Installing: $app"
        winget install --id $app --exact --accept-package-agreements --accept-source-agreements --silent
    }
}

# ================================
# SOFTWARE UPDATES
# ================================

function Update-Software {
    Write-Log "Running Winget upgrade..."
    winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements --silent
}

# ================================
# WINDOWS UPDATES
# ================================

function Install-WindowsUpdates {
    Import-Module PSWindowsUpdate -ErrorAction Stop
    Get-WindowsUpdate -Install -AcceptAll -MicrosoftUpdate -IgnoreReboot
}

# ================================
# EXPORT SOFTWARE INVENTORY
# ================================

function Export-InstalledSoftware {

    $apps = Get-ItemProperty `
        HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*,
        HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
        Where-Object { $_.DisplayName } |
        Select-Object DisplayName, DisplayVersion, Publisher

    $apps | Sort-Object DisplayName | Out-File $ExportFile
}

# ================================
# RESTART PROMPT
# ================================

function Ask-Restart {

    if ($Silent) { return }

    Add-Type -AssemblyName PresentationFramework

    $result = [System.Windows.MessageBox]::Show(
        "Provisioning completed. Restart now?",
        "System Restart Required",
        "YesNo",
        "Question"
    )

    if ($result -eq "Yes") {
        Restart-Computer
    }
}

# ================================
# STARTUP TASK MANAGEMENT
# ================================

function Register-UpdateAtStartupTask {

    Write-Log "Registering automatic update startup task..."

    $scriptPath = $MyInvocation.MyCommand.Path

    $action = New-ScheduledTaskAction `
        -Execute "powershell.exe" `
        -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Mode Updates -Silent"

    $trigger = New-ScheduledTaskTrigger -AtStartup

    $settings = New-ScheduledTaskSettingsSet `
        -RunOnlyIfNetworkAvailable `
        -StartWhenAvailable `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries

    Register-ScheduledTask `
        -TaskName "WindowsProvisioningAutoUpdate" `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -User "SYSTEM" `
        -RunLevel Highest `
        -Force

    Write-Log "Startup task successfully registered."
}

function Unregister-UpdateAtStartupTask {

    Write-Log "Removing startup task..."

    $taskName = "WindowsProvisioningAutoUpdate"

    if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Log "Startup task removed."
    }
    else {
        Write-Log "Startup task not found."
    }
}

function Get-StartupTaskStatus {

    $taskName = "WindowsProvisioningAutoUpdate"
    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

    if ($task) {
        Write-Host "Startup update task is REGISTERED." -ForegroundColor Green
    }
    else {
        Write-Host "Startup update task is NOT registered." -ForegroundColor Yellow
    }
}

# ================================
# MAIN EXECUTION
# ================================

Write-Log "Provisioning started"
Write-Log "Selected mode: $Mode"

Run-Safely "Module Check" { Install-RequiredModules }

switch ($Mode) {

    "Apps" {
        Run-Safely "Install Applications" { Install-ApplicationsFromJSON }
    }

    "Updates" {
        Run-Safely "Winget Updates" { Update-Software }
        Run-Safely "Windows Updates" { Install-WindowsUpdates }
    }

    "Export" {
        Run-Safely "Export Inventory" { Export-InstalledSoftware }
    }

    "Status" {
        Get-StartupTaskStatus
    }

    "EnableStartup" {
        Register-UpdateAtStartupTask
    }

    "DisableStartup" {
        Unregister-UpdateAtStartupTask
    }

    "Full" {
        Run-Safely "Install Applications" { Install-ApplicationsFromJSON }
        Run-Safely "Winget Updates" { Update-Software }
        Run-Safely "Windows Updates" { Install-WindowsUpdates }
        Run-Safely "Export Inventory" { Export-InstalledSoftware }
        Ask-Restart
    }
}

Write-Log "Provisioning completed"