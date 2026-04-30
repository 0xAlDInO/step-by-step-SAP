# Projet Intensif (1 Semaine) : Guide Technique Détaillé (Clic par Clic)
Ce document complète le projet en expliquant exactement **où cliquer** pour intégrer la logique BOPF et l'analytique.

---

## 1. Comment trouver le "Business Object" (BO) ?
Si vous ne voyez pas le BO après avoir activé la CDS View :
1.  **Astuce Rapide** : Utilisez le raccourci clavier `Ctrl + Shift + A`.
2.  Tapez le nom de votre CDS : `Z_I_PurchReq`.
3.  Dans la liste des résultats, cherchez l'icône qui ressemble à un petit cube bleu/gris nommé **Business Object** `Z_I_PURCHREQ`.
4.  **Si vous utilisez l'explorateur (Project Explorer)** :
    - Déroulez votre projet ABAP.
    - Cherchez le dossier **Core Data Services** > **Business Object Content**.
    - Il est là ! S'il n'y est pas, c'est que votre CDS View n'a pas été activée avec l'annotation `@ObjectModel.modelCategory: #BUSINESS_OBJECT`.

---

## 2. Intégration de la Validation (Quantité > 0)
**Fichier source : `PROJET_MM_COMPLET/BOPF/CL_VAL_CHECK_QTY.abap`**

1.  Ouvrez le BO `Z_I_PURCHREQ` (voir étape 1).
2.  Dans l'onglet **Nodes** (en bas de l'écran central) :
    - Déroulez l'arborescence jusqu'à **ROOT**.
    - Faites un clic droit sur le dossier **Validations** > **New Validation**.
3.  Dans la fenêtre :
    - **Name** : `CHECK_QTY`
    - **Implementation Class** : `ZCL_VAL_CHECK_QTY`.
4.  Cliquez sur le lien bleu **Class ZCL_VAL_CHECK_QTY** pour générer le code ABAP.
    - Copiez le contenu du fichier `CL_VAL_CHECK_QTY.abap`.
    - **Activez** (Ctrl+F3).
5.  Revenez sur le BO, onglet **Validation Check Options** : Cochez **Create** et **Update**.
6.  **Activez le BO** (bouton en haut à gauche ou Ctrl+F3).

---

## 3. Intégration de l'Action (Bouton Approuver)
**Fichier source : `PROJET_MM_COMPLET/BOPF/CL_ACT_APPROVE_PR.abap`**

1.  Dans l'éditeur de BO, arborescence **ROOT**.
2.  Clic droit sur **Actions** > **New Action**.
3.  **Name** : `APPROVE_PR`.
4.  **Implementation Class** : `ZCL_ACT_APPROVE_PR`.
5.  Créez la classe via le lien bleu, collez le code et activez.
6.  **Activez le BO**.

---

## 4. Comment lancer la "Fiori App Preview" ?
Si le "Open With > SAP Fiori Elements App Preview" n'apparaît pas au clic droit sur la CDS :
1.  **Vérifiez l'activation OData** : Avez-vous bien mis l'annotation `@OData.publish: true` dans `Z_I_PurchReq` ?
2.  **L'icône jaune** : Une fois activée, une petite icône jaune (attention) apparaît à côté du mot `define view`. Passez la souris dessus, elle dira "Service Service Z_I_PURCHREQ_CDS is not registered".
3.  **Alternative pour tester** :
    - Allez dans la transaction `/n/IWFND/MAINT_SERVICE` dans SAP GUI.
    - Cherchez votre service `Z_I_PURCHREQ_CDS`.
    - Cliquez sur **SAP Gateway Client**.
    - Cliquez sur **Execute**. Si vous recevez un XML, le service fonctionne !
4.  **Dans Eclipse** : Essayez de faire un clic droit **non pas sur le texte**, mais sur le **nom du fichier** `Z_I_PurchReq.cds` dans le Project Explorer à gauche > **Open With** > **SAP Fiori Elements App Preview**.

---

## 5. Création de la Vue Analytique
**Fichier source : `PROJET_MM_COMPLET/CDS/Z_C_PurchReqAnalytics.cds`**

1.  Créez une nouvelle Data Definition nommée `Z_C_PurchReqAnalytics`.
2.  Collez le code du fichier correspondant.
3.  **Activez** (Ctrl+F3).
4.  Pour voir les données : Clic droit sur le fichier > **Open With** > **Data Preview**.