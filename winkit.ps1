$script:version = 2026.09

# Variables
$script:data = $null
$script:app  = $null
$script:env  = $null

# Rutas
$script:root    = $PSScriptRoot
$script:config  = Join-Path $script:root -ChildPath "config"
$script:scripts = Join-Path $script:root -ChildPath "scripts"

# Listas de scripts y archivos JSON
$script_paths = @(
    Join-Path $script:scripts -ChildPath "presets.ps1"
    Join-Path $script:scripts -ChildPath "install.ps1"
    Join-Path $script:scripts -ChildPath "set-env.ps1"
)

$json_paths = @(
    Join-Path $script:config -ChildPath "apps.json"
    Join-Path $script:config -ChildPath "env.json"
)

$fine = $true

# Importación de scripts
foreach ($script in $script_paths) {
    $name = Split-Path $script -Leaf

    if (-not (Test-Path $script)) {
        Write-Host "[$name] no se pudo importar" -ForegroundColor Red
        $fine = $false
    } else {
        . $script
    }
}

# Verificación de archivos JSON
foreach ($json in $json_paths) {
    if (-not (Test-Path $json)) {
        $name = Split-Path $json -Leaf
        Write-Host "No se pudo encontrar [$name]" -ForegroundColor Red
        $fine = $false
    }
}

$script:data = Get-AppJson -Path ($script:app = $json_paths[0])
$script:env = Get-EnvJson -Path ($env = $json_paths[1])

# $script:data.GetType()


<#
    .SYNOPSIS
    DESDE ESTA PARTE DEL CODIGO COMIENZA EL CLI
#>
if ($fine) {
Write-Host @"

RRRRRRRRRRRRRRRRR     GGGGGGGGGGGGG EEEEEEEEEEEEEEEEEEEEEE DDDDDDDDDDDDD        CCCCCCCCCCCCC TTTTTTTTTTTTTTTTTTTTTTT
R::::::::::::::::R   GG::::::::::::G E::::::::::::::::::::E D::::::::::::DDD   CC::::::::::::C T:::::::::::::::::::::T
R::::::RRRRRR:::::R C:::::::GGGG::::G E::::::::::::::::::::E D:::::::::::::::DD C:::::CCCCCCCC::::C T:::::::::::::::::::::T
RR:::::R     R:::::RG::::::G    GGGGG EE::::::EEEEEEEE::::E  DDD:::::DDD:::::::DC:::::C       CCCCCC T:::::TT:::::::TT:::::T
  R::::R     R:::::RG:::::G            E:::::E       EEEEEE    D::::D   D:::::DC:::::C               TTTTTT  T:::::T  TTTTTT
  R::::R     R:::::RG:::::G            E:::::E                 D::::D    D::::DC:::::C                       T:::::T        
  R::::RRRRRR:::::R G:::::G    GGGGGGG EE::::::EEEEEEEE        D::::D    D::::DC:::::C                       T:::::T        
  R:::::::::::::RR  G:::::G    G::::::GE::::::::::::::::E      D::::D    D::::DC:::::C                       T:::::T        
  R::::RRRRRR::::R  G:::::G    GG::::G EE::::::EEEEEEEE        D::::D    D::::DC:::::C                       T:::::T        
  R::::R     R::::R G:::::G      G::::GE:::::E                 D::::D    D::::DC:::::C                       T:::::T        
  R::::R     R::::R  G:::::G    GG::::GE:::::E       EEEEEE    D::::D   D:::::DC:::::C       CCCCCC          T:::::T        
  R::::R     R::::R   G::::::GGGG::::G E::::::EEEEEEEE::::E  DDD:::::DDD:::::::DC:::::CCCCCCCC::::C        TT:::::::TT      
RR:::::R     R:::::R   GG::::::::::::G E::::::::::::::::::::ED:::::::::::::::DD CC:::::::::::::::C        T:::::::::T      
R::::::R     R::::::R    GGGGGGGGGGGGG EEEEEEEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDD      CCCCCCCCCCCCCCC         TTTTTTTTTTT      

---RgeditV1---

---V$script:version---
"@ -ForegroundColor Green

Start-Sleep -Seconds 2
Clear-Host

function Select-Menu {
        param (
            [string[]]$Options,
            [string]$Title = "Selecciona tu Preset"
        )

        $selectedIndex = 0
        [Console]::CursorVisible = $false

        try {
            while ($true) {
                Clear-Host

                Write-Host "---------------------------------------" -ForegroundColor DarkCyan
                Write-Host " $Title" -ForegroundColor Cyan
                Write-Host "---------------------------------------" -ForegroundColor DarkCyan

                for ($i = 0; $i -lt $Options.Count; $i++) {
                    if ($i -eq $selectedIndex) {
                        Write-Host " > [$($i + 1)] $($Options[$i]) " -ForegroundColor Black -BackgroundColor Cyan
                    } else {
                        Write-Host "   [$($i + 1)] $($Options[$i]) " -ForegroundColor Gray
                    }
                }

                Write-Host "---------------------------------------" -ForegroundColor DarkCyan
                Write-Host "(Usa Flechas Arriba/Abajo y Enter)" -ForegroundColor DarkGray

                $key = [Console]::ReadKey($true)

                switch ($key.Key) {
                    'UpArrow' {
                        $selectedIndex = ($selectedIndex - 1 + $Options.Count) % $Options.Count
                    }
                    'DownArrow' {
                        $selectedIndex = ($selectedIndex + 1) % $Options.Count
                    }
                    'Enter' {
                        return $Options[$selectedIndex]
                    }
                }
            }
        }
        finally {
            Clear-Host
            [Console]::CursorVisible = $true
        }
    }

    $selection = @("developer", "standard", "gaming")

    $presetSelected = Select-Menu -Options $selection -Title "Selecciona tu Preset"

    if ($presetSelected) {
        try {
            Set-Preset -Preset $presetSelected -Json $script:data
        }
        catch {
            Write-Error "No se encuentra el preset seleccionado" -RecommendedAction "standard, developer, gaming"
        }
    }
}