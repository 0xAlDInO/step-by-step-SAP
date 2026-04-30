# Projet Intensif (1 Semaine) : Guide Technique Détaillé (Clic par Clic)
Ce document complète le projet en expliquant exactement **où cliquer** pour intégrer la logique BOPF et l'analytique.

---

## 1. Intégration de la Validation (Quantité > 0)
**Fichier source : `PROJET_MM_COMPLET/BOPF/CL_VAL_CHECK_QTY.abap`**

**Où cliquer dans Eclipse (ADT) :**
1.  Ouvrez votre CDS View `Z_I_PurchReq`.
2.  Une fois activée, SAP a généré un "Business Object" (BO). Pour le trouver :
    - Allez dans l'onglet **Project Explorer** (à gauche).
    - Cherchez le dossier **Business Object Content**.
    - Double-cliquez sur `Z_I_PURCHREQ` (le nom de votre CDS).
3.  Dans l'éditeur de BO qui s'ouvre :
    - Allez dans l'onglet **Nodes**.
    - Déroulez l'arborescence jusqu'à **ROOT**.
    - Faites un clic droit sur **Validations** > **New Validation**.
4.  Dans la fenêtre de création :
    - **Name** : `CHECK_QTY`
    - **Description** : Vérification quantité positive.
    - **Implementation Class** : Tapez `ZCL_VAL_CHECK_QTY`.
5.  Cliquez sur le lien bleu **Class ZCL_VAL_CHECK_QTY** qui vient d'apparaître.
    - Eclipse va vous proposer de créer la classe. Acceptez.
    - Copiez et collez le code du fichier `CL_VAL_CHECK_QTY.abap`.
    - **Activez** la classe (Ctrl+F3).
6.  Revenez sur l'onglet du BO et allez dans l'onglet **Validation Check Options** :
    - Cochez **Create** et **Update** (pour que la vérification se fasse à la création et à la modif).
7.  **Activez le BO** (Ctrl+F3).

---

## 2. Intégration de l'Action (Bouton Approuver)
**Fichier source : `PROJET_MM_COMPLET/BOPF/CL_ACT_APPROVE_PR.abap`**

**Où cliquer :**
1.  Toujours dans l'éditeur de votre Business Object `Z_I_PURCHREQ` :
    - Allez dans l'arborescence **ROOT**.
    - Faites un clic droit sur **Actions** > **New Action**.
2.  Dans la fenêtre :
    - **Name** : `APPROVE_PR`
    - **Implementation Class** : Tapez `ZCL_ACT_APPROVE_PR`.
3.  Cliquez sur le lien bleu pour créer la classe.
    - Copiez le code du fichier `CL_ACT_APPROVE_PR.abap`.
    - **Activez** (Ctrl+F3).
4.  **Important** : Pour que le bouton apparaisse sur Fiori, vérifiez que dans votre CDS `Z_I_PurchReq`, vous avez bien l'annotation :
    `@UI.identification: [ { position: 50, type: #FOR_ACTION, dataAction: 'APPROVE_PR', label: 'Approuver' } ]`
5.  **Activez le BO** (Ctrl+F3).

---

## 3. Création de la Vue Analytique (Graphiques)
**Fichier source : `PROJET_MM_COMPLET/CDS/Z_C_PurchReqAnalytics.cds`**

**Où cliquer :**
1.  Clic droit sur votre package > **New** > **Other...** > **Data Definition**.
2.  **Name** : `Z_C_PurchReqAnalytics`
3.  **Description** : Vue Cube Analytique MM.
4.  Copiez le code du fichier `Z_C_PurchReqAnalytics.cds`.
5.  **Activez** (Ctrl+F3).
6.  Pour visualiser :
    - Clic droit sur la vue > **Open With** > **Data Preview**.
    - Ou utilisez l'annotation `@OData.publish: true` pour créer un service et le voir dans Fiori sous forme de graphique.

---

## Résumé technique
- Les **Classes ABAP** portent la logique (le calcul, la vérification).
- Le **Business Object (BO)** fait le lien entre la CDS View et les Classes ABAP.
- Les **Annotations UI** dans la CDS décident où le bouton s'affiche sur l'écran Fiori.