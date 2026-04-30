# Guide d'Introduction : Création d'une Application Fiori MM
Ce guide vous accompagne pas à pas dans la création d'une application de Demandes d'Achat, de la base de données jusqu'à l'affichage Fiori.

---

## Étape 1 : Installation des outils (ADT)
Puisque vous ne pouvez pas créer de CDS Views dans le SAP GUI classique, vous devez utiliser Eclipse avec les extensions ABAP.

1.  **Téléchargez Eclipse** : Allez sur [eclipse.org](https://www.eclipse.org/downloads/) et installez "Eclipse IDE for Java Developers".
2.  **Installez ADT (ABAP Development Tools)** :
    - Ouvrez Eclipse.
    - Allez dans le menu `Help` > `Install New Software...`.
    - Dans le champ "Work with", collez cette URL : `https://tools.hana.ondemand.com/latest`.
    - Cochez la case **ABAP Development Tools**.
3.  **Connectez-vous à votre système SAP** :
    - Cliquez sur `File` > `New` > `ABAP Project`.

---

## Étape 2 : Création de la Table de Base de Données
**Fichier de référence : `PROJET_MM_COMPLET/TABLES/ZPURCH_REQ.abap`**

1.  Dans Eclipse, faites un clic droit sur votre package > `New` > `Other...` > `Database Table`.
2.  **Nom** : `ZPURCH_REQ`
3.  Copiez le contenu du fichier `ZPURCH_REQ.abap` et activez.

---

## Étape 3 : Création de la CDS View
**Fichier de référence : `PROJET_MM_COMPLET/CDS/Z_I_PurchReq.cds`**

1.  Clic droit sur votre package > `New` > `Other...` > `Data Definition`.
2.  **Nom** : `Z_I_PurchReq`
3.  Copiez le contenu du fichier `Z_I_PurchReq.cds` et activez.
    *Note : SAP va générer automatiquement les objets BOPF.*

---

## Étape 4 : Activation du Service OData
1.  Ouvrez votre **SAP GUI**.
2.  Lancez la transaction : `/n/IWFND/MAINT_SERVICE`.
3.  Cliquez sur **Add Service**.
4.  Cherchez `Z_I_PURCHREQ_CDS`.
5.  Ajoutez-le (Bouton "Add Selected Services").

---

## Étape 5 : Preview Fiori
1.  Dans Eclipse, faites un clic droit sur votre CDS View `Z_I_PurchReq`.
2.  Cherchez **Open With** > **SAP Fiori Elements App Preview**.
3.  Connectez-vous et cliquez sur **Go**.

---

Pour aller plus loin (Actions, Validations, Analytics), consultez le guide avancé : `PROJET_MM_FIORI_FULL.md`.