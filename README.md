# step-by-step-SAP

## RAP Purchase Order - Guide pas à pas

Ce projet contient un exemple de package ABAP RAP pour un cas d'utilisation "Purchase Order" avec une intégration `BAPI_PO_CREATE1`.

### Structure du package `ZPO_SMART_COCKPIT`

- `cds/`
  - `ZI_PO_HEADER.ddls` : interface view PO header
  - `ZI_PO_ITEM.ddls` : interface view PO item
  - `ZC_PO_LIST.ddls` : consommation liste Fiori
  - `ZC_PO_DETAIL.ddls` : consommation détail Fiori
- `behavior/`
  - `ZI_PO_HEADER.bdef` : définition du comportement RAP
  - `ZI_PO_HEADER.bimpl` : implémentation du comportement
- `service/`
  - `ZUI_PO.srvd` : définition du service OData V4
  - `ZUI_PO.srvb` : binding du service OData V4
- `abap/`
  - `ZBP_I_PO.abap` : classe ABAP de comportement et appel BAPI

## Étapes de création dans ADT (Eclipse ou BAS)

### 1. Créer le package ABAP

1. Ouvrir votre projet ABAP dans ADT.
2. Clic droit sur le projet > `New` > `ABAP Package`.
3. Nom du package : `ZPO_SMART_COCKPIT`.
4. Sélectionner un transport et valider.

### 2. Créer les CDS Views

Pour chaque fichier :

1. Clic droit sur `ZPO_SMART_COCKPIT` > `New` > `ABAP Repository Object`.
2. Choisir `Data Definition`.
3. Nommer l'objet : `ZI_PO_HEADER`, `ZI_PO_ITEM`, `ZC_PO_LIST`, `ZC_PO_DETAIL`.
4. Coller le code correspondant depuis les fichiers du projet.
5. Sauvegarder et activer.

Ordre recommandé :

1. `ZI_PO_HEADER` (racine)
2. `ZI_PO_ITEM` (enfant)
3. `ZC_PO_LIST` (liste)
4. `ZC_PO_DETAIL` (détail)

### 3. Créer la définition de comportement RAP

1. Clic droit sur le package > `New` > `ABAP Repository Object`.
2. Choisir `Behavior Definition`.
3. Nommer : `ZI_PO_HEADER`.
4. Coller le code de `ZI_PO_HEADER.bdef`.
5. Activer.

### 4. Créer l'implémentation du comportement

1. Clic droit sur le package > `New` > `ABAP Repository Object`.
2. Choisir `Behavior Implementation`.
3. Nommer : `ZI_PO_HEADER`.
4. Coller le code de `ZI_PO_HEADER.bimpl`.
5. Activer.

### 5. Créer le service OData V4

1. Clic droit sur le package > `New` > `ABAP Repository Object`.
2. Choisir `Service Definition`.
3. Nommer : `ZUI_PO`.
4. Coller le code de `ZUI_PO.srvd`.
5. Activer.

### 6. Créer le service binding

1. Clic droit sur le package > `New` > `ABAP Repository Object`.
2. Choisir `Service Binding`.
3. Nommer : `ZUI_PO`.
4. Coller le code de `ZUI_PO.srvb`.
5. Activer.

### 7. Créer la classe ABAP de comportement

1. Clic droit sur le package > `New` > `ABAP Repository Object`.
2. Choisir `Class`.
3. Nommer : `ZBP_I_PO`.
4. Coller le code ABAP depuis `abap/ZBP_I_PO.abap`.
5. Activer.

## Activation et publication

1. Activer chaque objet un par un.
2. Vérifier l'activation sans erreur.
3. Ouvrir `/IWFND/MAINT_SERVICE` pour enregistrer le service OData si nécessaire.
4. Vérifier que le service `ZUI_PO_SRV` est actif.

## Test via `/IWFND/GW_CLIENT`

1. Aller à : `/sap/opu/odata/v4/ZUI_PO_SRV/`.
2. Vérifier le metadata.
3. Tester `POList` et `PODetail`.

## Test Fiori Elements

1. Créer une application Fiori Elements List Report / Object Page.
2. Pointer vers le service OData V4 `ZUI_PO_SRV`.
3. Vérifier que la liste affiche les achats et que le détail fonctionne.

## Remarques importantes

- La lecture (`READ`) est native via CDS.
- La création (`CREATE`) est implémentée via `BAPI_PO_CREATE1`.
- La mise à jour (`UPDATE`) est pour l’instant un placeholder.
- La suppression (`DELETE`) n’est pas supportée dans ce code car les bons de commande ne se suppriment pas en standard.

## Exemple de payload JSON pour CREATE

```json
{
  "EBELN": "0000001234",
  "BUKRS": "1000",
  "LIFNR": "0000123456",
  "BSART": "NB",
  "BEDAT": "20260503",
  "WAERS": "EUR",
  "NETWR": "1000.00",
  "AEDAT": "20260503",
  "POItems": [
    {
      "EBELP": "00010",
      "MATNR": "MAT001",
      "WERKS": "1000",
      "MENGE": "10",
      "MEINS": "PC",
      "NETPR": "100.00",
      "TXZ01": "Item 1 description"
    }
  ]
}
```

## Commande HTTP POST d'exemple

```http
POST /sap/opu/odata/v4/ZUI_PO_SRV/POList HTTP/1.1
Host: <sap-host>:<port>
Content-Type: application/json
Accept: application/json

{ ...payload JSON... }
```
