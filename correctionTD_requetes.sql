-- Partie 1 : Modélisation et import des données 


SHOW DATABASES;

CREATE DATABASE football_analytics;

USE football_analytics;

-- Exercice 1.2 : Création de la table des résultats

CREATE TABLE IF NOT EXISTS results (
    date DATE COMMENT 'Date du match',
    home_team VARCHAR(100) COMMENT 'Équipe domicile',
    away_team VARCHAR(100) COMMENT 'Équipe extérieure',
    home_score INT COMMENT 'Score équipe domicile',
    away_score INT COMMENT 'Score équipe extérieure',
    tournament VARCHAR(200) COMMENT 'Nom du tournoi',
    city VARCHAR(100) COMMENT 'Ville du match',
    country VARCHAR(100) COMMENT 'Pays du match',
	neutral BOOLEAN
)
DUPLICATE KEY(date, home_team, away_team)
DISTRIBUTED BY HASH(home_team) BUCKETS 16
PROPERTIES (
    "replication_num" = "1"
);

-- Exercice 1.3 : Création de la table des buteurs

CREATE TABLE goalscorers (
    date DATE NOT NULL,
    home_team VARCHAR(100) NOT NULL,
    away_team VARCHAR(100) NOT NULL,
    team VARCHAR(100) NOT NULL,
    scorer VARCHAR(200) NOT NULL,
    minute INT,
    own_goal BOOLEAN,
    penalty BOOLEAN
)
DUPLICATE KEY(date, home_team, away_team, team, scorer)
DISTRIBUTED BY HASH(scorer) BUCKETS 10
PROPERTIES (
    "replication_num" = "1"
);

-- Exercice 1.4 : Création de la table des tirs au but
CREATE TABLE IF NOT EXISTS shootouts (
    date DATE,
    home_team VARCHAR(100),
    away_team VARCHAR(100),
    winner VARCHAR(100),
    first_shooter VARCHAR(100)
)
DUPLICATE KEY(date)
DISTRIBUTED BY HASH(date) BUCKETS 10
PROPERTIES (
    "replication_num" = "1"
);
-- Exercice 1.5 : Création de la table des anciens noms

CREATE TABLE IF NOT EXISTS former_names (
    current_name VARCHAR(100),
    former VARCHAR(100),
    start_date DATE,
    end_date DATE
)
DUPLICATE KEY(current_name, former)
DISTRIBUTED BY HASH(current_name) BUCKETS 3
PROPERTIES (
    "replication_num" = "1"
);

-- Exercice 1.7 : Validation des imports
SELECT COUNT(*)
FROM results;
SELECT COUNT(*)
FROM goalscorers;
SELECT COUNT(*)
FROM shootouts;
SELECT COUNT(*)
FROM former_names;

----- Partie 2 : Exploration individuelle des tables ---
-- match le plus fou de l'histoire 
USE football_analytics;
SHOW TABLES;

SELECT 
    match_date,
    home_team,
    away_team,
    home_score,
    away_score,
    (home_score + away_score) AS total_goals,
    tournament,
    city
FROM results
ORDER BY total_goals DESC
LIMIT 1;

-- Challenge 2.2 : Domination à domicile
-- Quelle équipe a le meilleur taux de victoires à domicile depuis 2010 (minimum 50 matchs) ?
SELECT 
    home_team,
    COUNT(*) AS matches_played,
    SUM(CASE WHEN home_score > away_score THEN 1 ELSE 0 END) AS wins,
    ROUND(SUM(CASE WHEN home_score > away_score THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS win_percentage
FROM results
WHERE match_date >= '2010-01-01'
GROUP BY home_team
HAVING COUNT(*) >= 50
ORDER BY win_percentage DESC
LIMIT 10;


-- challenge 2.3 : Top 10 des buteurs historiques
-- qui sont les 10 meilleurs buteurs de l'histoire du football international
SELECT 
    scorer,
    team,
    COUNT(*) AS total_goals,
    SUM(CASE WHEN penalty = 1 THEN 1 ELSE 0 END) AS penalties,
    COUNT(*) - SUM(CASE WHEN penalty = 1 THEN 1 ELSE 0 END) AS goals_from_play
FROM goalscorers
WHERE (own_goal = 0 OR own_goal IS NULL)
GROUP BY scorer, team
ORDER BY total_goals DESC
LIMIT 10;

-- challenge 2.4 : Maîtres des tirs au but
-- quelle équipe a gagné le plus de séances de tirs au but? 
SELECT
   scorer,
   team,
   COUNT(*) AS total_goals,
   SUM(CASE WHEN penalty = 1 THEN 1 ELSE 0 END) AS penalties,
   COUNT(*) - SUM(CASE WHEN penalty = 1 THEN 1 ELSE 0 END) AS goals_from_play
FROM goalscorers
WHERE (own_goal = 0 OR own_goal IS NULL)
GROUP BY scorer, team
ORDER BY total_goals DESC
LIMIT 10;

-- Challenge 2.4: Les rois du hat-trick
-- Quel joueur a marqué le plus de hat-tricks
WITH hat_tricks AS (
SELECT
team,
scorer,
match_date,
home_team,
away_team,
COUNT(*) as goals_in_match
FROM goalscorers
WHERE own_goal = 0 OR own_goal IS NULL
GROUP BY match_date, home_team, away_team, team, scorer
HAVING COUNT(*) >= 3
)
-- Étape 2 : Compter le nombre de triplés par équipe
SELECT
team,
COUNT(*) as total_hat_tricks
FROM hat_tricks
GROUP BY team
ORDER BY total_hat_tricks DESC
LIMIT 1;



----------------------------- Partie 3 ---------------
-- Challenge 3.1- Simples jointures
----- Trouvez tous les matchs où Cristiano Ronaldo a marqué pour le Portugal, avec les détails du match (date, adversaire, score, tournoi, minute du but).
SELECT 
    r.match_date,
    r.home_team,
    r.away_team,
    r.home_score,
    r.away_score,
    r.tournament,
    g.scorer,
    g.minute,
    g.penalty
FROM results r
INNER JOIN goalscorers g 
    ON r.match_date = g.match_date 
    AND r.home_team = g.home_team 
    AND r.away_team = g.away_team
WHERE g.scorer LIKE '%Ronaldo%' 
    AND g.team = 'Portugal'
ORDER BY r.match_date DESC;

-- Bonus : comparaison avec Messi
SELECT 'Cristiano Ronaldo' AS player,
    COUNT(*) AS total_goals
FROM goalscorers
WHERE scorer LIKE '%Ronaldo%' AND team = 'Portugal'
UNION ALL
SELECT 
    'Lionel Messi' AS player,
    COUNT(*) AS total_goals
FROM goalscorers
WHERE scorer LIKE '%Messi%' AND team = 'Argentina'; 


-- Challenge 3.2 - Tirs au but en Coupe du Monde
-- Listez tous les matchs de Coupe du Monde FIFA qui se sont terminés aux tirs au but.

SELECT 
    r.match_date,
    r.home_team,
    r.away_team,
    r.home_score,
    r.away_score,
    s.winner AS shootout_winner,
    r.tournament,
    r.city
FROM results r
INNER JOIN shootouts s 
    ON r.match_date = s.match_date 
    AND r.home_team = s.home_team 
    AND r.away_team = s.away_team
WHERE r.tournament LIKE '%FIFA World Cup%'
ORDER BY r.match_date DESC;

-- Bonus : Quelle équipe a remporté le plus de tirs au but en Coupe du Monde ?
SELECT 
    s.winner,
    COUNT(*) AS world_cup_shootout_wins
FROM results r
INNER JOIN shootouts s 
    ON r.match_date = s.match_date 
    AND r.home_team = s.home_team 
    AND r.away_team = s.away_team
WHERE r.tournament LIKE '%FIFA World Cup%'
GROUP BY s.winner
ORDER BY world_cup_shootout_wins DESC
LIMIT 1;

-- challenge 3.3 : Frequence des tirs au but par tournoi
SELECT 
    r.tournament,
    COUNT(r.match_date) AS total_matches,
    COUNT(s.winner) AS shootout_matches,
    ROUND(COUNT(s.winner) * 100.0 / COUNT(r.match_date), 2) AS shootout_percentage
FROM results r
LEFT JOIN shootouts s 
    ON r.match_date = s.match_date 
    AND r.home_team = s.home_team 
    AND r.away_team = s.away_team
WHERE r.tournament IN ('FIFA World Cup', 'UEFA Euro', 'Copa América')
GROUP BY r.tournament
ORDER BY shootout_percentage DESC;



-------------------------- Partie 4 : Triple joins analyse complete d un match ---
-- Affichez tous les détails des matchs de Coupe du Monde depuis 2018 : résultats, buteurs (avec minute), et vainqueur des tirs au but s'il y en a eu.
SELECT 
    r.match_date,
    r.home_team,
    r.away_team,
    r.home_score,
    r.away_score,
    r.tournament,
    r.city,
    g.scorer,
    g.minute,
    g.team AS scoring_team,
    g.penalty,
    s.winner AS shootout_winner
FROM results r
LEFT JOIN goalscorers g 
    ON r.match_date = g.match_date 
    AND r.home_team = g.home_team 
    AND r.away_team = g.away_team
LEFT JOIN shootouts s 
    ON r.match_date = s.match_date 
    AND r.home_team = s.home_team 
    AND r.away_team = s.away_team
WHERE r.tournament = 'FIFA World Cup'
    AND r.match_date >= '2018-01-01'
ORDER BY r.match_date, g.minute;

-- challenge 4.2 : Classement historique depuis 2000
-- Question : Créez un classement des meilleures équipes depuis l'an 2000, avec système de points FIFA (3 pts victoire, 1 pt nul, 0 défaite), en normalisant les noms d'équipes.

WITH team_stats AS (
    -- Matchs à domicile
    SELECT 
        COALESCE(fn.current_name, r.home_team) AS team,
        COUNT(*) AS matches,
        SUM(CASE 
            WHEN home_score > away_score THEN 3 
            WHEN home_score = away_score THEN 1 
            ELSE 0 
        END) AS points,
        SUM(home_score) AS goals_for,
        SUM(away_score) AS goals_against
    FROM results r
    LEFT JOIN former_names fn ON r.home_team = fn.former
    WHERE match_date >= '2000-01-01'
    GROUP BY COALESCE(fn.current_name, r.home_team)
    
    UNION ALL
    
    -- Matchs à l'extérieur
    SELECT 
        COALESCE(fn.current_name, r.away_team) AS team,
        COUNT(*) AS matches,
        SUM(CASE 
            WHEN away_score > home_score THEN 3 
            WHEN away_score = home_score THEN 1 
            ELSE 0 
        END) AS points,
        SUM(away_score) AS goals_for,
        SUM(home_score) AS goals_against
    FROM results r
    LEFT JOIN former_names fn ON r.away_team = fn.former
    WHERE match_date >= '2000-01-01'
    GROUP BY COALESCE(fn.current_name, r.away_team)
)
SELECT 
    team,
    SUM(matches) AS total_matches,
    SUM(points) AS total_points,
    ROUND(SUM(points) * 1.0 / SUM(matches), 2) AS points_per_match,
    SUM(goals_for) AS total_goals_for,
    SUM(goals_against) AS total_goals_against,
    (SUM(goals_for) - SUM(goals_against)) AS goal_difference
FROM team_stats
GROUP BY team
HAVING SUM(matches) >= 50
ORDER BY points_per_match DESC, goal_difference DESC
LIMIT 20;


-- challenge 4.3 Évolution du football au fil des décennies
-- Analysez l'évolution de la moyenne de buts par match au fil des décennies, avec une moyenne mobile sur 2 décennies.

WITH decade_stats AS (
    SELECT 
        FLOOR(YEAR(match_date) / 10) * 10 AS decade,
        AVG(home_score + away_score) AS avg_goals_per_match
    FROM results
    GROUP BY FLOOR(YEAR(match_date) / 10) * 10
)
SELECT 
    decade,
    ROUND(avg_goals_per_match, 2) AS avg_goals,
    ROUND(AVG(avg_goals_per_match) OVER (
        ORDER BY decade 
        ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_2_decades
FROM decade_stats
ORDER BY decade;


-------------------- Partie 5 ----------------------
-- Projet final - Dashboad analytique

-- Analyse 5.1: Fiche d'identité pour votre équipe favorite
-- Créez une analyse complète de votre équipe nationale préférée.
-- Ci-dessous la version avec l'équipe de France
WITH france_matches AS (
    SELECT 
        match_date,
        CASE WHEN home_team = 'France' THEN away_team ELSE home_team END AS opponent,
        CASE WHEN home_team = 'France' THEN home_score ELSE away_score END AS goals_for,
        CASE WHEN home_team = 'France' THEN away_score ELSE home_score END AS goals_against,
        CASE 
            WHEN home_team = 'France' AND home_score > away_score THEN 'Win'
            WHEN away_team = 'France' AND away_score > home_score THEN 'Win'
            WHEN home_score = away_score THEN 'Draw'
            ELSE 'Loss'
        END AS result,
        tournament
    FROM results
    WHERE home_team = 'France' OR away_team = 'France'
)
SELECT 
    'France' AS team,
    COUNT(*) AS total_matches,
    SUM(CASE WHEN result = 'Win' THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN result = 'Draw' THEN 1 ELSE 0 END) AS draws,
    SUM(CASE WHEN result = 'Loss' THEN 1 ELSE 0 END) AS losses,
    SUM(goals_for) AS total_goals_scored,
    SUM(goals_against) AS total_goals_conceded,
    ROUND(AVG(goals_for), 2) AS avg_goals_per_match,
    MAX(goals_for) AS biggest_win_score,
    MAX(goals_against) AS biggest_loss_score
FROM france_matches;

-- Bonus : top 10 buteurs de l'équipe
SELECT 
    g.scorer,
    COUNT(*) AS goals,
    SUM(CASE WHEN g.penalty = 1 THEN 1 ELSE 0 END) AS penalties
FROM goalscorers g
WHERE g.team = 'France'
    AND (g.own_goal = 0 OR g.own_goal IS NULL)
GROUP BY g.scorer
ORDER BY goals DESC
LIMIT 10;


-- Analyse 5.2 : Prediction - Favoris du prochain tournoi
-- Basé sur la forme récente (5 dernières années), identifiez les 10 équipes favorites pour le prochain tournoi majeur.
WITH recent_form AS (
    -- Matchs à domicile
    SELECT 
        COALESCE(fn.current_name, r.home_team) AS team,
        COUNT(*) AS matches,
        SUM(CASE 
            WHEN home_score > away_score THEN 3 
            WHEN home_score = away_score THEN 1 
            ELSE 0 
        END) AS points,
        SUM(home_score) AS goals_for,
        SUM(away_score) AS goals_against
    FROM results r
    LEFT JOIN former_names fn ON r.home_team = fn.former
    WHERE match_date >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR)
    GROUP BY COALESCE(fn.current_name, r.home_team)
    
    UNION ALL
    
    -- Matchs à l'extérieur
    SELECT 
        COALESCE(fn.current_name, r.away_team) AS team,
        COUNT(*) AS matches,
        SUM(CASE 
            WHEN away_score > home_score THEN 3 
            WHEN away_score = home_score THEN 1 
            ELSE 0 
        END) AS points,
        SUM(away_score) AS goals_for,
        SUM(home_score) AS goals_against
    FROM results r
    LEFT JOIN former_names fn ON r.away_team = fn.former
    WHERE match_date >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR)
    GROUP BY COALESCE(fn.current_name, r.away_team)
)
SELECT 
    team,
    SUM(matches) AS total_matches,
    ROUND(SUM(points) * 1.0 / SUM(matches), 2) AS points_per_match,
    (SUM(goals_for) - SUM(goals_against)) AS goal_difference,
    ROUND(SUM(goals_for) * 1.0 / SUM(matches), 2) AS goals_per_match,
    -- Score de forme composite (pondération : 50% points, 30% diff buts, 20% buts marqués)
    ROUND(
        (SUM(points) * 1.0 / SUM(matches)) * 0.5 +
        ((SUM(goals_for) - SUM(goals_against)) * 1.0 / SUM(matches)) * 0.3 +
        (SUM(goals_for) * 1.0 / SUM(matches)) * 0.2,
        2
    ) AS form_score
FROM recent_form
GROUP BY team
HAVING SUM(matches) >= 20
ORDER BY form_score DESC
LIMIT 10;
