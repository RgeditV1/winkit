
<#
    .SYNOPSIS
    Devuelve el contenido del archivo Json

    .PARAMETER root
    Ruta al archivo json
#>
function Get-AppJson {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (Test-Path -Path $Path) {
        return Get-Content -Path $Path -Encoding UTF8 -Raw | ConvertFrom-Json
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
        return Get-Content -Path $Path -Encoding UTF8 -Raw | ConvertFrom-Json
    } else {
        Write-Error "No se encontró el archivo: $Path"
        return $null
    }
}