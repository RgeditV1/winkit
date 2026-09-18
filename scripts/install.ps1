<#
    .SYNOPSIS
    obtiene el presetet y lo configura e.g(add to path, or install and upgrade)
#>
function Set-Install{
    param(
        [parameter(Mandatory=$true)]
        [hashtable]$Programs
    )
    foreach ($item in $Programs.GetEnumerator()) {
        foreach ($app in $item.Value) {
            $params = @{
                Id   = $app.id
                Name = $app.name
            }
            if ($app.ContainsKey('path')) { $params['Path'] = $app.path }

            Get-Program @params
        }
    }
}

<#
    .SYNOPSIS
    Comprueba que los pgogramas esten no esten instalado y en dado caso los actualiza/instala
#>
function Get-Program{
    param(
        [parameter(Mandatory=$true)]
        [string]$Id,
        [string]$Name,
        [parameter(Mandatory=$false)]
        [string]$Path
    )

    Write-Host "Comprobando si [$($Name)] esta instalado..." -ForegroundColor Cyan

    winget list --id $Id --exact > $null 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "'$Id' ya esta instalado. Intentando actualizar..." -ForegroundColor Yellow
        winget upgrade --id $Id --exact --accept-source-agreements --accept-package-agreements
    } else {
        Write-Host "'$Id' NO esta instalado. Procediendo a instalar..." -ForegroundColor Green
        winget install --id $Id --exact --accept-source-agreements --accept-package-agreements
    }
    
    Write-Host ""

    if (-not [string]::IsNullOrWhiteSpace($Path)) {
        Write-Host "Comprobando Variables de Entorno [PATH] para '$Name'..." -ForegroundColor Cyan
        Set-Path -PathToAdd $Path
    }
}

<#
    .SYNOPSIS
    Agrega una ruta a la variable de entorno PATH
#>
function Set-Path {
    param(
        [parameter(Mandatory=$true)]
        [string]$PathToAdd,

        [ValidateSet("User", "Machine")] # machine requiere admin
        [string]$Scope = "User"
    )

    if (-not (Test-Path -Path $PathToAdd)) {
        Write-Host "La ruta '$PathToAdd' no existe en el disco. Omitiendo actualización de PATH." -ForegroundColor Yellow
        return
    }

    # Obtener el PATH actual desde el Registro
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", $Scope)
    
    # Separar las rutas existentes para hacer una comparación exacta
    $pathList = $currentPath -split ';'

    if ($pathList -contains $PathToAdd) {
        Write-Host "La ruta '$PathToAdd' ya existe en el PATH ($Scope)." -ForegroundColor Yellow
    } else {
        Write-Host "Agregando '$PathToAdd' a la variable de entorno PATH ($Scope)..." -ForegroundColor Green
        
        $newPath = "$currentPath;$PathToAdd"

        $null = [Environment]::GetEnvironmentVariable("PATH", $Scope) # Refresco de contexto
        $null = [Environment]::SetEnvironmentVariable("PATH", $newPath, $Scope)

        # Actualizar la sesión actual de PowerShell inmediatamente
        $env:PATH = "$env:PATH;$PathToAdd"
        
        Write-Host "Ruta agregada exitosamente." -ForegroundColor Green
    }
}

<#
    .SYNOPSIS
    Instala los extras seleccionados
#>
function Get-Extras{
    param(
        [parameter(Mandatory=$true)]
        [string[]]$Extras
    )
}