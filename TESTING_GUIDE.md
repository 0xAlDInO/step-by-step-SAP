# Guide de Test - Purchase Order RAP Cockpit

Ce guide explique comment tester les opérations de Création (CREATE) et Mise à jour (UPDATE) de l'application refactorisée.

## 1. Test via l'aperçu Fiori Elements (ADT)

La méthode la plus simple consiste à utiliser l'aperçu intégré dans ABAP Development Tools :

1.  Ouvrez le **Service Binding** `ZUI_PO.srvb`.
2.  Dans la section "Service Details", sélectionnez l'entité `PurchaseOrder`.
3.  Cliquez sur le bouton **Preview**.
4.  Une fenêtre de navigateur s'ouvrira avec l'application Fiori Elements.
5.  **Test du Create** :
    *   Cliquez sur le bouton **Create**.
    *   Saisissez les informations d'en-tête (Société, Fournisseur, Type, etc.).
    *   Dans la table des items, ajoutez au moins une ligne avec un Matériau, une Division et une Quantité.
    *   Cliquez sur **Create** (en bas à droite).
    *   L'application devrait afficher un message de succès et le numéro du nouveau bon de commande généré par le BAPI.
6.  **Test de l'Update** :
    *   Sélectionnez un bon de commande existant dans la liste.
    *   Cliquez sur **Edit**.
    *   Modifiez un champ (ex: la date de commande ou la quantité d'un item).
    *   Cliquez sur **Save**.

## 2. Test via EML (Entity Manipulation Language)

Vous pouvez tester la logique du Behavior Pool directement dans ABAP en utilisant des instructions EML. Voici un exemple de script à exécuter dans l'éditeur ABAP (via une classe de test ou un rapport) :

### Exemple de Création
```abap
MODIFY ENTITIES OF zi_po_header_ral
  ENTITY PurchaseOrder
    CREATE SET FIELDS WITH VALUE #( (
      %cid                   = 'MY_CID_1'
      CompanyCode            = '1010'
      Supplier               = '0000100000'
      PurchaseOrderTypeCode  = 'NB'
      PurchasingOrganization = '1010'
      PurchasingGroup        = '001'
      Currency               = 'EUR'
      PurchaseOrderDate      = cl_abap_context_info=>get_system_date( )
    ) )
    CREATE BY \_Items SET FIELDS WITH VALUE #( (
      %cid_ref  = 'MY_CID_1'
      %target   = VALUE #( (
        %cid       = 'ITEM_CID_1'
        Material   = 'AS-100'
        Plant      = '1010'
        PurchaseOrderQuantity = 10
        PurchaseOrderQuantityUnit = 'PC'
        NetPrice   = 150
      ) )
    ) )
  MAPPED DATA(ls_mapped)
  FAILED DATA(ls_failed)
  REPORTED DATA(ls_reported).

COMMIT ENTITIES.
```

### Exemple de Mise à jour
```abap
MODIFY ENTITIES OF zi_po_header_ral
  ENTITY PurchaseOrder
    UPDATE SET FIELDS WITH VALUE #( (
      PurchaseOrder     = '4500000123'
      PurchaseOrderDate = cl_abap_context_info=>get_system_date( )
    ) )
  FAILED DATA(ls_failed)
  REPORTED DATA(ls_reported).

COMMIT ENTITIES.
```

## 3. Vérification dans le SAP GUI

Après chaque test, il est impératif de vérifier que les données sont correctement enregistrées dans le standard SAP :

1.  Lancez la transaction **ME23N** (Afficher Bon de Commande).
2.  Saisissez le numéro de bon de commande retourné par l'application.
3.  Vérifiez que l'en-tête et les items correspondent à votre saisie.
4.  Consultez l'onglet "Statut" pour voir si le document est correctement créé/modifié.

## 4. Vérification Technique

*   **Table Draft** : Si vous utilisez le mode Draft, vous pouvez vérifier le contenu des tables `zpo_header_d` et `zpo_item_d` pendant l'édition.
*   **Logs BAPI** : Si une erreur survient, les messages retournés par le BAPI sont propagés dans la structure `REPORTED`. Dans l'UI Fiori, ils apparaissent dans la pop-up de message.
