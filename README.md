# Apache Doris - Formation et TD

Ce dépôt contient une formation complète sur **Apache Doris**, une base de données analytique MPP (Massively Parallel Processing) en temps réel, accompagnée d'un TD pratique et de ses corrections.

## 📚 Contenu du projet

### Documents de formation
- **Formation Apache Doris** (`[Ateliers techniques] Formation Apache Doris.pdf`)
  Présentation complète d'Apache Doris : architecture, concepts clés, cas d'usage et fonctionnalités principales.

- **Fiche TD** (`[Ateliers techniques] Fiche TD Apache Doris.pdf`)
  Travaux dirigés pratiques incluant des exercices sur la modélisation, les requêtes SQL et l'analyse de données.

- **Procédure d'installation** (`[Ateliers techniques] Procédure d_installation d_Apache Doris .pdf`)
  Guide détaillé pour installer et configurer Apache Doris.

### Corrections
- **`correctionTD_requetes.sql`**
  Correction complète du TD avec toutes les requêtes SQL organisées par partie :
  - Partie 1 : Modélisation et import des données
  - Partie 2 : Exploration individuelle des tables
  - Partie 3 : Jointures simples
  - Partie 4 : Triple joins et analyses avancées
  - Partie 5 : Dashboard analytique et projet final

- **`correctionTD_bonus_python.ipynb`**
  Notebook Jupyter avec des analyses bonus en Python (visualisations, analyses avancées).

### Infrastructure
- **`docker-compose.yaml`**
  Configuration Docker Compose pour déployer rapidement un cluster Apache Doris (Frontend + Backend).

### Données
Le dossier [`data/`](data/) contient des jeux de données de football international :
- **`results.csv`** : Résultats de matchs internationaux
- **`goalscorers.csv`** : Liste des buteurs avec détails (minute, pénalty, CSC)
- **`shootouts.csv`** : Informations sur les tirs au but
- **`former_names.csv`** : Anciens noms d'équipes nationales
- **`Lien Kaggle (source).docx`** : Source des données

## 🚀 Installation et démarrage

### Prérequis
- Docker et Docker Compose installés
- 4 GB de RAM minimum
- Ports disponibles : `8030`, `9030`, `8040`, `9060`

### Lancer Apache Doris

1. **Cloner le dépôt**
   ```bash
   git clone <url-du-repo>
   cd APACHE-DORIS
   ```

2. **Adapter le docker-compose.yaml**

   Ouvrir le fichier [`docker-compose.yaml`](docker-compose.yaml) et modifier les chemins des volumes (lignes 65, 71, 77, 83) pour pointer vers votre répertoire local :
   ```yaml
   device: /mnt/c/Users/VOTRE_USER/Documents/apache-doris
   ```

3. **Démarrer le cluster**
   ```bash
   docker-compose up -d
   ```

4. **Vérifier le démarrage**

   Attendre environ 30 secondes puis vérifier que les services sont actifs :
   ```bash
   docker-compose ps
   ```

5. **Accéder à Apache Doris**

   - Interface Web : [http://localhost:8030](http://localhost:8030)
   - Connexion MySQL : `mysql -h 127.0.0.1 -P 9030 -u root`

## 📖 Utilisation

### Importer les données

1. Se connecter à Doris :
   ```bash
   mysql -h 127.0.0.1 -P 9030 -u root
   ```

2. Créer la base de données et les tables :
   ```sql
   source correctionTD_requetes.sql
   ```

3. Importer les fichiers CSV via l'interface web ou avec `LOAD DATA INFILE`.

### Suivre le TD

1. Consulter la fiche TD (`[Ateliers techniques] Fiche TD Apache Doris.pdf`)
2. Réaliser les exercices partie par partie
3. Consulter les corrections dans [`correctionTD_requetes.sql`](correctionTD_requetes.sql)
4. Explorer les analyses bonus dans le notebook Python

## 🎯 Objectifs pédagogiques

Ce TD permet d'apprendre à :
- Installer et configurer Apache Doris avec Docker
- Modéliser des données pour une base analytique (DUPLICATE KEY, distribution)
- Importer des données massives (millions de lignes)
- Effectuer des requêtes analytiques complexes (agrégations, jointures, CTEs)
- Utiliser les fonctions de fenêtrage (window functions)
- Normaliser des données historiques
- Créer des dashboards analytiques

## 🏆 Exemples d'analyses

Le TD couvre des analyses réelles sur des données de football :
- Match le plus fou de l'histoire (total de buts)
- Top 10 des buteurs historiques
- Domination à domicile par équipe
- Équipes les plus performantes aux tirs au but
- Évolution du football au fil des décennies
- Classement historique des équipes (système FIFA)
- Prédictions basées sur la forme récente

## 🛠️ Technologies

- **Apache Doris 3.0.8** : Base de données analytique MPP
- **Docker & Docker Compose** : Conteneurisation et orchestration
- **MySQL Protocol** : Interface de connexion
- **Python & Jupyter** : Analyses bonus et visualisations

## 📊 Structure des données

Le dataset, issu de Kaggle, couvre l'histoire du football international avec :
- Plus de 45 000 matchs internationaux
- Plus de 3 millions de lignes de données sur les buteurs
- Données historiques remontant aux premières compétitions
- Couverture mondiale (tous les continents)

## 📝 Notes

- Les chemins dans le `docker-compose.yaml` doivent être adaptés à votre environnement
- Pour Windows + WSL, utiliser le format `/mnt/c/Users/...`
- Le Backend (BE) s'enregistre automatiquement auprès du Frontend (FE)
- Les logs sont persistés dans les volumes Docker



## 📄 Licence

Projet à but pédagogique - MASTER SISE



**Bon apprentissage avec Apache Doris !** 🚀
