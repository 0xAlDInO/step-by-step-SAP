# Guide Complet : Création d'une Application Fiori Transactionnelle (MM)
Ce guide vous accompagne pas à pas dans la création d'une application de gestion de stock, de la base de données jusqu'à l'affichage Fiori, en utilisant le modèle OData V2 Autopublish.

---

## Étape 1 : Installation des outils (ADT)
Puisque vous ne pouvez pas créer de CDS Views dans le SAP GUI classique, vous devez utiliser Eclipse avec les extensions ABAP.

1.  **Téléchargez Eclipse** : Allez sur [eclipse.org](https://www.eclipse.org/downloads/) et installez "Eclipse IDE for Java Developers".
2.  **Installez ADT (ABAP Development Tools)** :
    - Ouvrez Eclipse.
    - Allez dans le menu `Help` > `Install New Software...`.
    - Dans le champ "Work with", collez cette URL : `https://tools.hana.ondemand.com/latest`.
    - Cochez la case **ABAP Development Tools**.
    - Cliquez sur `Next` et acceptez les licences. Eclipse va redémarrer.
3.  **Connectez-vous à votre système SAP** :
    - Cliquez sur `File` > `New` > `ABAP Project`.
    - Choisissez votre système dans la liste (ceux configurés dans votre SAP Logon).
    - Entrez vos identifiants (Client, User, Password).

---

## Étape 2 : Création de la Table de Base de Données (Z-Table)
Nous allons créer une table pour stocker notre stock d'articles.

1.  Dans Eclipse, faites un clic droit sur votre package (ou `$TMP`) > `New` > `Other...` > `Database Table`.
2.  **Nom** : `ZSTOCK_MM`
3.  **Description** : Table de gestion de stock
4.  Copiez et collez le code suivant :

```abap
@EndUserText.label : 'Table de Stock MM'
@AbapCatalog.enhancementCategory : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #LIMITED
define table zstock_mm {
  key client      : abap.clnt not null;
  key matnr       : matnr not null;
  stock_qty       : abap.quan(13,3);
  meins           : meins;
  last_changed_at : timestampl;
}
```
5.  Cliquez sur l'icône **Activate** (la petite bougie/éclair en haut).

---

## Étape 3 : Création de la CDS View (Modèle Transactionnel)
C'est ici que la magie opère. Nous allons créer une vue qui expose la table et permet les modifications (BOPF).

1.  Clic droit sur votre package > `New` > `Other...` > `Data Definition`.
2.  **Nom** : `Z_I_StockMM`
3.  **Description** : Vue Interface Stock MM
4.  Remplacez le code par celui-ci :

```abap
@AbapCatalog.sqlViewName: 'ZSTOCKMM_I'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gestion de Stock'

/* Annotation pour activer BOPF (le moteur transactionnel) */
@ObjectModel.modelCategory: #BUSINESS_OBJECT
@ObjectModel.compositionRoot: true
@ObjectModel.transactionalDbLayerViews: 'Z_I_StockMM'
@ObjectModel.writeActivePersistence: 'ZSTOCK_MM'

/* Annotation pour l'auto-publication du service OData */
@OData.publish: true

define view Z_I_StockMM
  as select from zstock_mm
{
    @UI.facet: [ { id: 'idStock', type: #IDENTIFICATION_REFERENCE, label: 'Détails Stock' } ]

    @UI.lineItem: [ { position: 10, label: 'Article' } ]
    @UI.identification: [ { position: 10, label: 'Article' } ]
    @ObjectModel.readOnly: false
    key matnr as Material,

    @UI.lineItem: [ { position: 20, label: 'Quantité' } ]
    @UI.identification: [ { position: 20, label: 'Quantité' } ]
    @Semantics.quantity.unitOfMeasure: 'Unit'
    stock_qty as Quantity,

    @UI.lineItem: [ { position: 30, label: 'Unité' } ]
    @UI.identification: [ { position: 30, label: 'Unité' } ]
    @Semantics.unitOfMeasure: true
    meins as Unit,

    last_changed_at as LastChanged
}
```
5.  **Activez** la vue (Ctrl+F3).
    *Note : À l'activation, SAP va générer automatiquement des objets BOPF en arrière-plan car nous avons mis `@ObjectModel.modelCategory: #BUSINESS_OBJECT`.*

---

## Étape 4 : Activation du Service OData
Même avec `@OData.publish: true`, il faut dire à SAP d'exposer ce service sur le réseau.

1.  Ouvrez votre **SAP GUI** classique.
2.  Lancez la transaction : `/n/IWFND/MAINT_SERVICE`.
3.  Cliquez sur le bouton **Add Service**.
4.  Dans **System Alias**, mettez `LOCAL` (ou le nom de votre système).
5.  Dans **Technical Service Name**, cherchez `Z_I_STOCKMM_CDS`.
6.  Sélectionnez-le et cliquez sur **Add Selected Services**.
7.  Validez les popups (laissez le package en `$TMP` si besoin).
8.  Revenez en arrière et vérifiez que le service `Z_I_STOCKMM_CDS` est bien dans la liste avec une icône verte.

---

## Étape 5 : Création de l'affichage Fiori (Preview)
Comme vous n'avez pas encore BAS (Business Application Studio), nous allons utiliser la prévisualisation rapide d'Eclipse.

1.  Dans Eclipse, retournez sur votre CDS View `Z_I_StockMM`.
2.  Regardez dans la barre d'outils ou faites un clic droit sur le nom de la vue dans l'explorateur.
3.  Cherchez **Open With** > **SAP Fiori Elements App Preview**.
4.  Une fenêtre de navigateur va s'ouvrir.
5.  Connectez-vous avec vos identifiants SAP.
6.  Cliquez sur le bouton **Go** pour voir les données.
7.  Puisque nous avons activé le mode transactionnel, vous devriez voir des boutons **Create**, **Edit** et **Delete**.

---

## Résumé du flux
1.  **Table Z** : Stockage physique des données.
2.  **CDS View** : Structure logique + Annotations (BOPF pour le CRUD, OData pour l'exposition).
3.  **Service Maintain** : Activation du "tuyau" entre ABAP et le Web.
4.  **Fiori Elements** : Génération automatique de l'écran à partir des annotations CDS.

Félicitations ! Vous avez créé votre première application de gestion de stock MM.