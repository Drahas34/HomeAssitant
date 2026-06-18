<#
.SYNOPSIS
  Synchronise la config Home Assistant entre le partage Samba (Z:) et ce depot git.

.DESCRIPTION
  pull : copie /config (Z:) -> depot local  (pour recuperer les changements faits dans HA)
  push : copie depot local -> /config (Z:)  (pour appliquer tes edits a Home Assistant)

  Dans les deux sens, les memes exclusions que le .gitignore sont respectees :
  secrets, bases de donnees, .storage, logs, code HACS, esphome, etc.
  Aucune suppression n'est faite (pas de /MIR) : on ne fait qu'ajouter/mettre a jour.

.EXAMPLE
  .\sync-ha.ps1 pull        # rapatrier depuis Home Assistant
  .\sync-ha.ps1 push        # envoyer vers Home Assistant
  .\sync-ha.ps1 push -WhatIf  # simulation (ne copie rien, montre ce qui changerait)
#>
param(
  [Parameter(Mandatory)][ValidateSet('pull','push')] [string]$Direction,
  [string]$Share = 'Z:\',
  [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
$Repo = $PSScriptRoot

# Dossiers et fichiers a ne jamais synchroniser (alignes sur .gitignore)
$excludeDirs  = @('.git','.storage','.cloud','.cache','deps','tts','www\community','custom_components','esphome','zigbee2mqtt\log','backups')
$excludeFiles = @('*.db','*.db-shm','*.db-wal','*.log','*.log.*','*.fault','.ha_run.lock','*.tar','Thumbs.db','.DS_Store')

if (-not (Test-Path $Share)) {
  Write-Host "ERREUR : le partage $Share n'est pas monte." -ForegroundColor Red
  Write-Host "Monte-le d'abord :  net use Z: \\192.168.1.35\config /user:drahas *" -ForegroundColor Yellow
  exit 1
}

if ($Direction -eq 'pull') { $src = $Share; $dst = $Repo }
else                       { $src = $Repo;  $dst = $Share }

# Construire les arguments robocopy
$xd = $excludeDirs  | ForEach-Object { Join-Path $src $_ }
$args = @($src, $dst, '/E', '/R:1', '/W:1', '/NFL', '/NDL', '/NP', '/NJH')
if ($xd.Count)            { $args += '/XD'; $args += $xd }
if ($excludeFiles.Count)  { $args += '/XF'; $args += $excludeFiles }
if ($WhatIf)              { $args += '/L' }   # /L = liste seulement, ne copie rien

Write-Host ("== {0} : {1}  ->  {2} ==" -f $Direction.ToUpper(), $src, $dst) -ForegroundColor Cyan
robocopy @args
$code = $LASTEXITCODE
if ($code -ge 8) { Write-Host "robocopy a signale une erreur (code $code)" -ForegroundColor Red; exit $code }

Write-Host "Termine (code robocopy $code = OK)." -ForegroundColor Green
if ($Direction -eq 'push' -and -not $WhatIf) {
  Write-Host "Pense a recharger la config dans HA : Outils de developpement -> YAML -> Recharger." -ForegroundColor Yellow
}
