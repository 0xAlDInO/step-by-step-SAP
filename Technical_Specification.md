# Cahier des Charges Techniques - Fiori element / CDS

## 1. Objet

`ZPO_SMART_COCKPIT` est un exemple de Business Object RAP pour la consultation de Purchase Orders SAP sur la base des tables standard `EKKO` et `EKPO`.

Le projet est construit en **RAP unmanaged avec draft**. Dans l'état actuel documenté ici, l'usage retenu et validé est la **consommation de données** via OData V4 et Fiori Elements.

## 2. Périmètre actuel

Le périmètre actuellement retenu comme fonctionnel est le suivant :

- Exposition OData V4 d'un BO `PurchaseOrder`
- Lecture header et items
- Navigation `PurchaseOrder -> Items`
- Navigation `PurchaseOrderItem -> Header`
- Exposition des annotations UI pour Fiori Elements

Les opérations de modification (`create`, `update`, `delete`, `Edit`) existent dans le code technique, mais elles ne sont pas considérées comme stabilisées ni incluses dans le périmètre fonctionnel de cette spécification.

## 3. Architecture

### 3.1 Stack technique

- SAP S/4HANA ABAP
- RAP unmanaged
- OData V4 UI service binding
- Fiori Elements List Report / Object Page
- Tables standards SAP : `EKKO`, `EKPO`

### 3.2 Package

- Package logique : `ZPO_SMART_COCKPIT`

### 3.3 Objets principaux

- CDS interface header : [ZI_PO_HEADER_RAL.ddls](/home/ralobo/step-cds-fiori/step-by-step-SAP/ZPO_SMART_COCKPIT/cds/ZI_PO_HEADER_RAL.ddls)
- CDS interface item : [ZI_PO_ITEM_RAL.ddls](/home/ralobo/step-cds-fiori/step-by-step-SAP/ZPO_SMART_COCKPIT/cds/ZI_PO_ITEM_RAL.ddls)
- CDS consommation header : [ZC_PO_LIST_RAL.ddls](/home/ralobo/step-cds-fiori/step-by-step-SAP/ZPO_SMART_COCKPIT/cds/ZC_PO_LIST_RAL.ddls)
- CDS consommation item : [ZC_PO_DETAIL_RAL.ddls](/home/ralobo/step-cds-fiori/step-by-step-SAP/ZPO_SMART_COCKPIT/cds/ZC_PO_DETAIL_RAL.ddls)
- Behavior definition interface : [ZI_PO_HEADER_RAL.bdef](/home/ralobo/step-cds-fiori/step-by-step-SAP/ZPO_SMART_COCKPIT/behavior/ZI_PO_HEADER_RAL.bdef)
- Behavior definition projection : [ZC_PO_LIST_RAL.bdef](/home/ralobo/step-cds-fiori/step-by-step-SAP/ZPO_SMART_COCKPIT/behavior/ZC_PO_LIST_RAL.bdef)
- Behavior pool : [ZBP_I_PO.abap](/home/ralobo/step-cds-fiori/step-by-step-SAP/ZPO_SMART_COCKPIT/abap/ZBP_I_PO.abap)
- Service definition : [ZUI_PO.srvd](/home/ralobo/step-cds-fiori/step-by-step-SAP/ZPO_SMART_COCKPIT/service/ZUI_PO.srvd)
- Service binding : [ZUI_PO.srvb](/home/ralobo/step-cds-fiori/step-by-step-SAP/ZPO_SMART_COCKPIT/service/ZUI_PO.srvb)

## 4. Modèle de données

### 4.1 Header

Le BO racine projette les données de `EKKO`.

Champs métiers exposés :

- `PurchaseOrder` <= `EKKO-EBELN`
- `CompanyCode` <= `EKKO-BUKRS`
- `Supplier` <= `EKKO-LIFNR`
- `PurchaseOrderTypeCode` <= `EKKO-BSART`
- `PurchasingOrganization` <= `EKKO-EKORG`
- `PurchasingGroup` <= `EKKO-EKGRP`
- `PurchaseOrderDate` <= `EKKO-BEDAT`
- `Currency` <= `EKKO-WAERS`
- `CreationDate` <= `EKKO-AEDAT`
- `DeletionIndicator` <= `EKKO-LOEKZ`

### 4.2 Item

Le BO enfant projette les données de `EKPO`.

Champs métiers exposés :

- `PurchaseOrder` <= `EKPO-EBELN`
- `PurchaseOrderItem` <= `EKPO-EBELP`
- `Material` <= `EKPO-MATNR`
- `Plant` <= `EKPO-WERKS`
- `PurchaseOrderQuantity` <= `EKPO-MENGE`
- `PurchaseOrderQuantityUnit` <= `EKPO-MEINS`
- `NetPrice` <= `EKPO-NETPR`
- `PurchaseOrderItemText` <= `EKPO-TXZ01`
- `DeletionIndicator` <= `EKPO-LOEKZ`

## 5. Comportement RAP

### 5.1 Type de BO

- BO root unmanaged avec draft
- Lock master sur le header
- Lock dependent sur les items
- `total etag` porté par `CreationDate`

### 5.2 Opérations déclarées

Le comportement RAP déclare techniquement des opérations de modification et des actions draft.

Pour la présente spécification, seule la partie suivante est considérée comme fonctionnelle et dans le périmètre :

- lecture header
- lecture item
- association `_Items`
- association `_Header`

### 5.3 Autorisations

Le BO est déclaré avec :

- `authorization master ( global, instance )` sur le header
- `authorization dependent by _Header` sur l'item

Dans l'état actuel du code, les méthodes d'autorisation ont été simplifiées pour ne pas bloquer la consommation et le diagnostic du service.

## 6. Implémentation ABAP actuelle

### 6.1 Classe de comportement

L'implémentation se trouve dans [ZBP_I_PO.abap](/home/ralobo/step-cds-fiori/step-by-step-SAP/ZPO_SMART_COCKPIT/abap/ZBP_I_PO.abap).

### 6.2 Lecture

Les opérations suivantes sont implémentées :

- `read` header
- `read` item
- `rba_items`
- `rba_header`

Ces lectures s'appuient sur des `SELECT` directs sur `EKKO` et `EKPO`.

## 7. Service OData

### 7.1 Service definition

Le service expose :

- `PurchaseOrder`
- `PurchaseOrderItem`

Objet : [ZUI_PO.srvd](/home/ralobo/step-cds-fiori/step-by-step-SAP/ZPO_SMART_COCKPIT/service/ZUI_PO.srvd)

### 7.2 Service binding

Le binding est de type :

- `odatav4_ui`

Objet : [ZUI_PO.srvb](/home/ralobo/step-cds-fiori/step-by-step-SAP/ZPO_SMART_COCKPIT/service/ZUI_PO.srvb)

## 8. Intégration Fiori Elements

### 8.1 UI exposée

La vue de consommation root [ZC_PO_LIST_RAL.ddls](/home/ralobo/step-cds-fiori/step-by-step-SAP/ZPO_SMART_COCKPIT/cds/ZC_PO_LIST_RAL.ddls) définit :

- `@UI.headerInfo`
- `@UI.lineItem`
- `@UI.identification`
- `@UI.facet`

La vue item [ZC_PO_DETAIL_RAL.ddls](/home/ralobo/step-cds-fiori/step-by-step-SAP/ZPO_SMART_COCKPIT/cds/ZC_PO_DETAIL_RAL.ddls) définit également les annotations de détail.

### 8.2 État actuel du preview

Le preview Fiori Elements affiche correctement :

- la liste des Purchase Orders
- la navigation vers les items
- les lectures OData

Le présent document ne couvre que ce périmètre de consultation.

## 9. Contraintes techniques connues

### 9.1 Compatibilité release RAP

Le code a été ajusté pour une release RAP stricte avec plusieurs contraintes :

- signatures `READ BY ASSOCIATION` explicites
- clés `readonly` dans la BDEF
- suppression des usages non disponibles dans certaines releases (`COMMIT WORK`, API de message non compatibles)

### 9.2 Autorisations

Les helpers d'autorisation existent dans le code, mais la logique active a été simplifiée temporairement pour éviter de bloquer la consommation et le diagnostic du service.

## 10. Ce qui fonctionne aujourd'hui

- Activation de la majorité des objets RAP du dépôt
- Lecture header
- Lecture item
- Associations `_Items` et `_Header`
- Draft déclaré dans la BDEF
- Service OData V4 consommable
- Preview Fiori Elements orienté consultation

## 11. Limites actuelles

- Les opérations de modification ne font pas partie du périmètre fonctionnel documenté ici
- La documentation présente uniquement la consommation de données
- Les parties BAPI et save unmanaged ne sont pas retenues comme usage validé pour l'instant

## 12. Recommandations

### 12.1 Pour continuer sur cette base

- conserver l'approche **unmanaged**
- republier systématiquement le service binding après changement de BDEF/projection
- vérifier le `$metadata` pour l'exposition correcte des entités et des associations

### 12.2 Pour industrialiser le BO

- stabiliser séparément le périmètre de modification avant de le documenter comme fonctionnel
- réintroduire un vrai contrôle d'autorisation PFCG
- valider le comportement Fiori Elements sur metadata publiée et non uniquement en preview

## 13. Étapes à suivre

### 13.1 Ordre d'activation recommandé dans ADT

Pour éviter les faux positifs et les erreurs de dépendance, activer dans l'ordre suivant :

1. CDS interface

- [ZI_PO_HEADER_RAL.ddls](/home/ralobo/step-cds-fiori/step-by-step-SAP/ZPO_SMART_COCKPIT/cds/ZI_PO_HEADER_RAL.ddls)
- [ZI_PO_ITEM_RAL.ddls](/home/ralobo/step-cds-fiori/step-by-step-SAP/ZPO_SMART_COCKPIT/cds/ZI_PO_ITEM_RAL.ddls)

2. CDS consommation

- [ZC_PO_LIST_RAL.ddls](/home/ralobo/step-cds-fiori/step-by-step-SAP/ZPO_SMART_COCKPIT/cds/ZC_PO_LIST_RAL.ddls)
- [ZC_PO_DETAIL_RAL.ddls](/home/ralobo/step-cds-fiori/step-by-step-SAP/ZPO_SMART_COCKPIT/cds/ZC_PO_DETAIL_RAL.ddls)

3. Behavior definitions

- [ZI_PO_HEADER_RAL.bdef](/home/ralobo/step-cds-fiori/step-by-step-SAP/ZPO_SMART_COCKPIT/behavior/ZI_PO_HEADER_RAL.bdef)
- [ZC_PO_LIST_RAL.bdef](/home/ralobo/step-cds-fiori/step-by-step-SAP/ZPO_SMART_COCKPIT/behavior/ZC_PO_LIST_RAL.bdef)

4. Behavior pool

- [ZBP_I_PO.abap](/home/ralobo/step-cds-fiori/step-by-step-SAP/ZPO_SMART_COCKPIT/abap/ZBP_I_PO.abap)

5. Service

- [ZUI_PO.srvd](/home/ralobo/step-cds-fiori/step-by-step-SAP/ZPO_SMART_COCKPIT/service/ZUI_PO.srvd)
- [ZUI_PO.srvb](/home/ralobo/step-cds-fiori/step-by-step-SAP/ZPO_SMART_COCKPIT/service/ZUI_PO.srvb)

### 13.2 Publication du service

Après toute modification de BDEF, projection behavior ou CDS de consommation :

1. Ouvrir [ZUI_PO.srvb](/home/ralobo/step-cds-fiori/step-by-step-SAP/ZPO_SMART_COCKPIT/service/ZUI_PO.srvb)
2. Faire `Publish` ou `Republish`
3. Ouvrir l'aperçu de l'entité racine `PurchaseOrder`
4. Faire un `Ctrl+F5` dans le navigateur

### 13.3 Vérification du metadata OData

Dans le `$metadata`, vérifier la présence des éléments suivants sur `PurchaseOrder` :

- `Common.DraftRoot`
- définition de l'entité `PurchaseOrder`
- définition de l'entité `PurchaseOrderItem`
- associations `_Items` et `_Header`

### 13.4 Tests fonctionnels minimaux

#### Test 1 : lecture header

Valider que la liste s'affiche avec au minimum :

- `PurchaseOrder`
- `CompanyCode`
- `Supplier`
- `PurchaseOrderTypeCode`
- `PurchaseOrderDate`

#### Test 2 : navigation header -> items

Depuis un Purchase Order existant, ouvrir le détail et vérifier l'affichage des items.

#### Test 3 : navigation item -> header

Depuis un item, vérifier que l'association `_Header` résout correctement l'en-tête.

#### Test 4 : draft metadata

Vérifier que le service publié expose bien le draft sur l'entité racine.
