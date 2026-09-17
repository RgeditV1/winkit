function Set-Install{
    param(
        [parameter(Mandatory=$true)]
        [hashtable]$Programs
    )
    foreach ($item in $Programs.GetEnumerator()) {
        foreach ($app in $item.Value) {
            
            Write-Host "Categoría: $($item.Key) | Instalando: $($app.name)"
            
        }
    }
}