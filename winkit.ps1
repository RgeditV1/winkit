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

# Banner ASCII si todo está correcto
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
"@
}


$script:data = Get-AppJson -Path ($script:app = $json_paths[0])
$script:env = Get-EnvJson -Path ($env = $json_paths[1])

foreach ($item in $script:data){
    foreach ($names in $item.standard.winget.name){
        Write-Host $names
    }
}