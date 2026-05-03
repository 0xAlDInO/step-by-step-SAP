# Cahier des Charges Techniques - Application Purchase Order RAP

## Vue d'ensemble
Cette application est un exemple de développement RAP (RESTful ABAP Programming) pour la gestion des bons de commande (Purchase Orders) en SAP S/4HANA. Elle utilise un scénario unmanaged pour intégrer le BAPI `BAPI_PO_CREATE1` lors de la création.

## Architecture
- **Technologie** : ABAP RAP unmanaged
- **OData** : Version 4
- **UI** : Fiori Elements (List Report / Object Page)
- **Package** : `ZPO_SMART_COCKPIT`

## Modèle de données
### Vues CDS Interface
- `ZI_PO_HEADER` : Vue sur table `EKKO` (en-tête du bon de commande)
- `ZI_PO_ITEM` : Vue sur table `EKPO` (lignes du bon de commande)
- Association : Header -> Items (1:N)

### Champs de l'en-tête (ZI_PO_HEADER)
- `EBELN` (key) : Numéro du bon de commande (CHAR 10)
- `BUKRS` : Société (CHAR 4)
- `LIFNR` : Fournisseur (CHAR 10)
- `BSART` : Type de document (CHAR 4)
- `BEDAT` : Date du document (DATS)
- `WAERS` : Devise (CUKY 5)
- `NETWR` : Montant net (CURR 15,2)
- `ERNAM` : Créé par (CHAR 12)
- `ERDAT` : Date de création (DATS)
- `AEDAT` : Date de modification (DATS)
- `LOEKZ` : Indicateur de suppression (CHAR 1)

### Champs des items (ZI_PO_ITEM)
- `EBELN` (key) : Numéro du bon de commande (CHAR 10)
- `EBELP` (key) : Numéro de ligne (NUMC 5)
- `MATNR` : Matériau (CHAR 18)
- `WERKS` : Division (CHAR 4)
- `MENGE` : Quantité (QUAN 13,3)
- `MEINS` : Unité de mesure (UNIT 3)
- `NETPR` : Prix net (CURR 11,2)
- `TXZ01` : Texte descriptif (CHAR 40)
- `LOEKZ` : Indicateur de suppression (CHAR 1)

### Vues CDS Consommation
- `ZC_PO_LIST` : Vue liste avec annotations Fiori (`@UI.lineItem`)
- `ZC_PO_DETAIL` : Vue détail avec annotations (`@UI.facet`, `@UI.identification`)

## Comportement RAP
### Définition (`ZI_PO_HEADER.bdef`)
- Opérations : create, update, delete
- Implémentation : Classe `ZBP_I_PO`
- Table persistante : `ekko`

### Implémentation (`ZBP_I_PO.abap`)
- **CREATE** : Appel `BAPI_PO_CREATE1` + `BAPI_TRANSACTION_COMMIT`
- **UPDATE** : Placeholder (simulation, recommande `BAPI_PO_CHANGE`)
- **DELETE** : Non supporté (annulation métier recommandée)
- **READ** : Automatique via CDS

## Service OData V4
- Définition : `ZUI_PO.srvd` (expose `ZC_PO_LIST` et `ZC_PO_DETAIL`)
- Binding : `ZUI_PO.srvb` (service `ZUI_PO_SRV`)

## Intégration Fiori Elements
- **List Report** : Utilise `POList` (entity set de `ZC_PO_LIST`)
- **Object Page** : Utilise `PODetail` (entity set de `ZC_PO_DETAIL`)
- Annotations : `@UI.lineItem`, `@UI.identification`, `@UI.facet` pour génération automatique

## Fonctionnement CRUD
### Lecture (READ)
- Automatique via CDS views
- Accessible via OData GET sur `/sap/opu/odata/v4/ZUI_PO_SRV/POList` ou `PODetail`

### Création (CREATE)
- Payload JSON envoyé via POST sur `POList`
- Mapping header/item vers structures BAPI
- Validation et commit transaction
- Retour du numéro de bon de commande créé

### Mise à jour (UPDATE)
- Implémentée avec `BAPI_PO_CHANGE` + `BAPI_TRANSACTION_COMMIT`
- Mappe header/item vers structures BAPI avec indicateurs de changement
- Gère les erreurs et commit la transaction

### Suppression (DELETE)
- Non supportée
- Raison : Les bons de commande SAP ne se suppriment pas directement (utiliser annulation)

## Déploiement
1. Créer package `ZPO_SMART_COCKPIT` dans ADT
2. Créer et activer CDS views (interface puis consommation)
3. Créer et activer behavior definition/implementation
4. Créer et activer service definition/binding
5. Créer et activer classe ABAP `ZBP_I_PO`
6. Publier service dans `/IWFND/MAINT_SERVICE`
7. Tester via `/IWFND/GW_CLIENT`
8. Créer app Fiori Elements pointant sur `ZUI_PO_SRV`

## Exemple de payload CREATE
```json
{
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

## Risques et considérations
- Champs obligatoires BAPI peuvent varier selon configuration SAP
- Autorisations nécessaires pour BAPI et tables
- Test en environnement de développement avant production
- UPDATE/DELETE à implémenter selon besoin métier

## Technologies utilisées
- SAP S/4HANA ABAP
- CDS Views
- Behavior Definition/Implementation
- OData V4
- Fiori Elements
- BAPI_PO_CREATE1