
$script:install = Join-Path $PSScriptRoot -ChildPath "install.ps1"

. $script:install

<#
    .SYNOPSIS
    Devuelve el contenido del archivo Json

    .PARAMETER path
    Ruta al archivo json
#>
function Get-AppJson {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (Test-Path -Path $Path) {
        return Get-Content -Path $Path -Encoding UTF8 -Raw | ConvertFrom-Json -AsHashtable
    } else {
        Write-Error "No se encontró el archivo: $Path"
        return $null
    }
}

function Get-EnvJson {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (Test-Path -Path $Path) {
        return Get-Content -Path $Path -Encoding UTF8 -Raw | ConvertFrom-Json -AsHashtable
    } else {
        Write-Error "No se encontró el archivo: $Path"
        return $null
    }
}

<#
    .SYNOPSIS
    establece la configuracion seleccionada
#>
function Set-Preset{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("standard", "developer", "gaming")]
        [string]$Preset,
        [hashtable]$Json
    )

    $selected = $Json[$Preset]
    Set-Install $selected

}