# Projet Intensif (1 Semaine) : Guide Technique Détaillé (Clic par Clic)
Ce document complète le projet en expliquant exactement **où cliquer** pour intégrer la logique BOPF et l'analytique.

---

## 1. Comment trouver le "Business Object" (BO) ?
Si vous avez bien mis l'annotation `@ObjectModel.modelCategory: #BUSINESS_OBJECT` et activé votre CDS, mais que vous ne voyez rien :

1.  **Le Réflexe "Rafraîchir"** : Cliquez sur votre projet dans l'explorateur à gauche et appuyez sur la touche **F5**. Eclipse a parfois besoin de cela pour afficher les nouveaux objets générés par SAP.
2.  **Vérifiez la Perspective** : Assurez-vous d'être bien dans la perspective **ABAP** (icône en haut à droite d'Eclipse).
3.  **Utilisez la recherche (Le plus sûr)** :
    - Appuyez sur `Ctrl + Shift + A`.
    - Tapez `Z_I_PURCHREQ`.
    - Vous devez voir un objet avec une icône de cube bleu nommé **Business Object** (et non pas la Data Definition).
4.  **En cas d'échec** : Regardez l'onglet **Problems** en bas d'Eclipse. Si l'activation de la CDS a échoué (erreur rouge), le BO ne sera jamais créé.

---

## 2. Intégration de la Validation (Quantité > 0)
**Fichier source : `PROJET_MM_COMPLET/BOPF/CL_VAL_CHECK_QTY.abap`**

1.  Ouvrez le BO `Z_I_PURCHREQ`.
2.  Dans l'onglet **Nodes** (bas de l'écran central) :
    - Déroulez **ROOT**.
    - Clic droit sur **Validations** > **New Validation**.
3.  **Name** : `CHECK_QTY`
4.  **Implementation Class** : `ZCL_VAL_CHECK_QTY`.
5.  Cliquez sur le lien bleu pour générer la classe, collez le code et **Activez** (Ctrl+F3).
6.  Sur le BO, onglet **Validation Check Options** : Cochez **Create** et **Update**.
7.  **Activez le BO** (bouton avec l'icône de petite flamme/éclair).

---

## 3. Intégration de l'Action (Bouton Approuver)
**Fichier source : `PROJET_MM_COMPLET/BOPF/CL_ACT_APPROVE_PR.abap`**

1.  Dans l'éditeur de BO, arborescence **ROOT**.
2.  Clic droit sur **Actions** > **New Action**.
3.  **Name** : `APPROVE_PR`.
4.  **Implementation Class** : `ZCL_ACT_APPROVE_PR`.
5.  Créez la classe, collez le code et activez.
6.  **Activez le BO**.

---

## 4. Pourquoi "SAP Fiori Elements App Preview" est absent ?
Si vous ne voyez pas cette option au clic droit sur le fichier `.cds` :

1.  **C'est normal si le service n'est pas "enregistré"** : L'option n'apparaît que si Eclipse détecte que le service OData est actif.
2.  **Solution** : Allez dans la transaction `/n/IWFND/MAINT_SERVICE` (SAP GUI).
    - Trouvez `Z_I_PURCHREQ_CDS`.
    - S'il n'y est pas, ajoutez-le.
    - S'il y est, cliquez sur **Load Metadata**.
3.  **Testez sans Eclipse** :
    - Dans la transaction `/n/IWFND/MAINT_SERVICE`, cliquez sur le bouton **SAP Gateway Client**.
    - Cliquez sur **EntitySets**. Choisissez votre vue.
    - Cliquez sur **Execute**. Si vous voyez vos données en format XML/JSON, le service est prêt pour Fiori.

---

## 5. Création de la Vue Analytique
**Fichier source : `PROJET_MM_COMPLET/CDS/Z_C_PurchReqAnalytics.cds`**

1.  Créez la Data Definition `Z_C_PurchReqAnalytics`.
2.  Activez.
3.  Clic droit sur le fichier dans l'explorateur > **Open With** > **Data Preview**. (C'est ici que vous verrez les colonnes de données avant qu'elles ne deviennent un graphique).