# Projet Intensif (1 Semaine) : Système de Gestion de Demandes d'Achat (MM)
Ce document simule une semaine de travail pour construire une application de gestion de Demandes d'Achat (PR).
**Le code complet est disponible dans le dossier `/PROJET_MM_COMPLET/`.**

---

## Organisation du Projet
Le code a été découpé par type d'objet pour respecter les standards SAP :
- **/TABLES/** : Définition de la base de données.
- **/CDS/** : Vues de données (Interface et Analytique) avec annotations UI.
- **/BOPF/** : Logique métier (Validations et Actions en ABAP).
- **/UI/** : Configuration de l'application Fiori.

---

## Jour 1 : Modélisation et Fondations
**Fichier : `PROJET_MM_COMPLET/TABLES/ZPURCH_REQ.abap`**
- Création de la table avec un `UUID` pour la compatibilité BOPF.
- Liaison avec les types standards SAP (`MATNR`, `WERKS`).

---

## Jour 2 : Le Cœur Transactionnel (BOPF - Validations)
**Fichier : `PROJET_MM_COMPLET/BOPF/CL_VAL_CHECK_QTY.abap`**
- Mise en place d'une classe de validation.
- Empêche la saisie d'une quantité inférieure ou égale à zéro.

---

## Jour 3 : Logique Métier Avancée (BOPF - Actions)
**Fichier : `PROJET_MM_COMPLET/BOPF/CL_ACT_APPROVE_PR.abap`**
- Implémentation du bouton "Approuver".
- Cette logique modifie le statut de la PR directement en base de données.

---

## Jour 4 : Interface Utilisateur (CDS & UI)
**Fichier : `PROJET_MM_COMPLET/CDS/Z_I_PurchReq.cds`**
- Ajout des annotations `@UI` pour créer les colonnes et le formulaire.
- Ajout de l'annotation `@Consumption.valueHelpDefinition` pour avoir la recherche F4 sur les articles.
**Fichier : `PROJET_MM_COMPLET/UI/manifest.json`**
- Configuration technique du projet Fiori.

---

## Jour 5 : Analytique
**Fichier : `PROJET_MM_COMPLET/CDS/Z_C_PurchReqAnalytics.cds`**
- Création d'une vue de type `CUBE` pour agréger les montants par site (`Plant`).

---

## Comment utiliser ce code ?
1.  **Table** : Créez la table dans Eclipse (ADT).
2.  **CDS** : Créez les Data Definitions.
3.  **BOPF** : À l'activation de la CDS, SAP génère le BO. Allez dans le BO pour créer la validation et l'action, puis collez le code des classes ABAP.
4.  **OData** : Activez le service via `/n/IWFND/MAINT_SERVICE`.
5.  **Fiori** : Testez via la preview ADT ou importez le dossier UI dans BAS.