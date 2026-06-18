# Configuration Home Assistant

Sauvegarde versionnée de la configuration de mon installation Home Assistant.

## Contexte

- **Home Assistant OS** sur `192.168.1.35` (http://homeassistant.local:8123)
- Ce dépôt est une **copie locale** du dossier `/config`, accédé via le partage Samba.
- Les secrets et données sensibles **ne sont pas versionnés** (voir `.gitignore`).

## Accès au partage

```powershell
net use Z: \\192.168.1.35\config /user:drahas *
```

## Synchronisation

Le script `sync-ha.ps1` copie la config entre le partage `Z:` et ce dépôt,
en respectant les mêmes exclusions que `.gitignore` (aucune suppression).

```powershell
.\sync-ha.ps1 pull            # Home Assistant -> dépôt (récupérer les changements)
.\sync-ha.ps1 push            # dépôt -> Home Assistant (appliquer mes edits)
.\sync-ha.ps1 push -WhatIf    # simulation, ne copie rien
```

Après un `push`, recharger la config dans HA :
**Outils de développement → YAML → Recharger**.

## Non versionné (géré ailleurs)

- `secrets.yaml`, `.storage/`, `.cloud/` — secrets et authentification
- `*.db` — bases de données (historique, zigbee)
- `custom_components/`, `www/community/` — intégrations/ressources HACS
- `esphome/` — dépôt git autonome géré par l'add-on ESPHome
