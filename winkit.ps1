$script:version = 2026.09.18

# Variables
$script:data = $null
$script:app  = $null

# Rutas
$script:root    = $PSScriptRoot
$script:config  = Join-Path $script:root -ChildPath "config"
$script:scripts = Join-Path $script:root -ChildPath "scripts"

# Listas de scripts y archivos JSON
$script_paths = @(
    Join-Path $script:scripts -ChildPath "presets.ps1"
    Join-Path $script:scripts -ChildPath "install.ps1"
)

$json_paths = @(
    Join-Path $script:config -ChildPath "apps.json"
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

# ==============================
# CLI
# ==============================

<#
    .SYNOPSIS
    Muestra un menú interactivo en consola y retorna la opción seleccionada. 
#>
function Select-Menu {
    param (
        [string[]]$Options,
        [string]$Title = "Selecciona tu Preset",
        [switch]$MultiSelect
    )

    $selectedIndex = 0
    [Console]::CursorVisible = $false

    if ($MultiSelect) {
        $selectedItems = New-Object 'System.Collections.Generic.HashSet[int]'
        try {
            while ($true) {
                Clear-Host
                Write-Host "---------------------------------------" -ForegroundColor DarkCyan
                Write-Host " $Title" -ForegroundColor Cyan
                Write-Host " (Espacio: Marcar | Enter: Confirmar)" -ForegroundColor DarkGray
                Write-Host "---------------------------------------" -ForegroundColor DarkCyan

                for ($i = 0; $i -lt $Options.Count; $i++) {
                    $isChecked = if ($selectedItems.Contains($i)) { "[X]" } else { "[ ]" }
                    if ($i -eq $selectedIndex) {
                        Write-Host " > $isChecked $($Options[$i]) " -ForegroundColor Black -BackgroundColor Cyan
                    } else {
                        Write-Host "   $isChecked $($Options[$i]) " -ForegroundColor Gray
                    }
                }

                $iVolver = $Options.Count
                if ($selectedIndex -eq $iVolver) {
                    Write-Host " > [ Confirmar / Volver ]" -ForegroundColor Black -BackgroundColor Yellow
                } else {
                    Write-Host "   [ Confirmar / Volver ]" -ForegroundColor Yellow
                }

                Write-Host "---------------------------------------" -ForegroundColor DarkCyan

                $key = [Console]::ReadKey($true)

                switch ($key.Key) {
                    'UpArrow' {
                        $selectedIndex = ($selectedIndex - 1 + ($Options.Count + 1)) % ($Options.Count + 1)
                    }
                    'DownArrow' {
                        $selectedIndex = ($selectedIndex + 1) % ($Options.Count + 1)
                    }
                    'Spacebar' {
                        if ($selectedIndex -lt $Options.Count) {
                            if ($selectedItems.Contains($selectedIndex)) {
                                [void]$selectedItems.Remove($selectedIndex)
                            } else {
                                [void]$selectedItems.Add($selectedIndex)
                            }
                        }
                    }
                    'Enter' {
                        $result = @()
                        foreach ($idx in $selectedItems) {
                            $result += $Options[$idx]
                        }
                        return $result
                    }
                }
            }
        }
        finally {
            Clear-Host
            [Console]::CursorVisible = $true
        }
    } 
    else {
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
}

<#
    .SYNOPSIS
    Muestra las apps disponibles organizadas por preset
#>
function Get-AppList {
    param (
        [parameter(Mandatory=$true)]
        $JsonData
    )

    while ($true) {
        $options = @()

        if ($JsonData -is [hashtable] -or $JsonData -is [System.Collections.Specialized.IOrderedDictionary]) {
            foreach ($key in $JsonData.Keys) {
                if ($key -ne 'extras') { $options += $key }
            }
        } else {
            foreach ($prop in $JsonData.PSObject.Properties) {
                if ($prop.Name -ne 'extras') { $options += $prop.Name }
            }
        }
        
        $options += "Volver"

        $selectedOption = Select-Menu -Options $options -Title "LISTA DE APLICACIONES Y PRESETS"

        if ($selectedOption -eq "Volver") {
            break
        }

        Clear-Host

        Write-Host "====================================================" -ForegroundColor Cyan
        Write-Host " PRESET: $selectedOption" -ForegroundColor Yellow
        Write-Host "====================================================" -ForegroundColor Cyan

        $presetData = if ($JsonData -is [hashtable]) { $JsonData[$selectedOption] } else { $JsonData.$selectedOption }

        if ($presetData -is [hashtable]) {
            foreach ($key in $presetData.Keys) {
                $apps = $presetData[$key]
                foreach ($app in $apps) {
                    Write-Host " * Name        : " -NoNewline -ForegroundColor Green
                    Write-Host $app.name
                    if ($app.id) {
                        Write-Host "   ID          : " -NoNewline -ForegroundColor Gray
                        Write-Host $app.id
                    }
                    if ($app.path) {
                        Write-Host "   Path        : " -NoNewline -ForegroundColor DarkYellow
                        Write-Host $app.path
                    }
                    if ($app.description) {
                        Write-Host "   Description : " -NoNewline -ForegroundColor White
                        Write-Host $app.description
                    }
                    Write-Host "----------------------------------------------------" -ForegroundColor DarkGray
                }
            }
        } else {
            foreach ($installerType in $presetData.PSObject.Properties) {
                $apps = $installerType.Value
                foreach ($app in $apps) {
                    Write-Host " * Name        : " -NoNewline -ForegroundColor Green
                    Write-Host $app.name
                    if ($app.id) {
                        Write-Host "   ID          : " -NoNewline -ForegroundColor Gray
                        Write-Host $app.id
                    }
                    if ($app.path) {
                        Write-Host "   Path        : " -NoNewline -ForegroundColor DarkYellow
                        Write-Host $app.path
                    }
                    if ($app.description) {
                        Write-Host "   Description : " -NoNewline -ForegroundColor White
                        Write-Host $app.description
                    }
                    Write-Host "----------------------------------------------------" -ForegroundColor DarkGray
                }
            }
        }

        Write-Host "`nPresiona cualquier tecla para volver..." -ForegroundColor DarkGray
        [Console]::ReadKey($true) | Out-Null
    }
}

# ==============================================================================
# EJECUCIÓN PRINCIPAL DEL CLI
# ==============================================================================
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

---@RgeditV1---

---V$script:version---
"@ -ForegroundColor Green

    Start-Sleep -Seconds 2
    Clear-Host

    while ($true) {
        $mainOptions = @(
            "Lista de Apps",
            "Instalar Preset: developer",
            "Instalar Preset: standard",
            "Instalar Preset: gaming",
            "Extras",
            "Salir"
        )

        $menuSelection = Select-Menu -Options $mainOptions -Title "MENÚ PRINCIPAL"

        switch ($menuSelection) {
            "Ver Lista de Apps" {
                Get-AppList -JsonData $script:data
            }
            "Instalar Preset: developer" {
                Set-Preset -Preset "developer" -Json $script:data
            }
            "Instalar Preset: standard" {
                Set-Preset -Preset "standard" -Json $script:data
            }
            "Instalar Preset: gaming" {
                Set-Preset -Preset "gaming" -Json $script:data
            }
            "Extras" {
                $extrasList = if ($script:data -is [hashtable]) { $script:data['extras']['github'] } else { $script:data.extras.github }
                
                if ($extrasList) {
                    $extrasNames = @()
                    foreach ($item in $extrasList) {
                        $extrasNames += "$($item.name)"
                    }

                    $selectedExtras = Select-Menu -Options $extrasNames -Title "SELECCIÓN DE EXTRAS" -MultiSelect

                    if ($selectedExtras.Count -gt 0) {
                        Clear-Host
                        Write-Host "Elementos seleccionados:" -ForegroundColor Green
                        foreach ($extra in $selectedExtras) {
                            Write-Host " -> $extra" -ForegroundColor Cyan
                        }
                        Start-Sleep -Seconds 3
                    }
                }
            }
            "Salir" {
                Write-Host "¡Hasta luego!" -ForegroundColor Cyan
                exit
            }
        }
    }
}