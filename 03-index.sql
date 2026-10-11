USE mediatheque;
-- Partie B

-- ============================
-- Exo 5

-- R1
EXPLAIN SELECT * FROM emprunt WHERE date_emprunt = '2024-03-12'; -- Request principale
SELECT COUNT(*) FROM emprunt WHERE date_emprunt = '2024-03-12'; -- Nombre de ligne

-- R2
EXPLAIN SELECT * FROM emprunt WHERE date_retour_reelle IS NULL; -- Request principale
SELECT COUNT(*) FROM emprunt WHERE date_retour_reelle IS NULL; -- Nombre de ligne

-- R3
EXPLAIN SELECT id, date_emprunt FROM emprunt WHERE adherent_id = 12 AND date_emprunt >= '2025-01-01'; -- Request principale
SELECT COUNT(*) FROM emprunt WHERE adherent_id = 12 AND date_emprunt >= '2025-01-01'; -- Nombre de ligne


-- A FAIRE : Noter dans rapport-index.md : type, key, rows, Extra


-- ============================
-- Exo 6

-- R1
CREATE INDEX idx_emprunt_date ON emprunt(date_emprunt);
-- JUSTIFICATION : La requête filtre uniquement sur date_emprunt,
-- un index sur cette colonne permet de retrouver directement les lignes concernées.
ANALYZE TABLE emprunt;
EXPLAIN SELECT * FROM emprunt WHERE date_emprunt = '2024-03-12';
-- A FAIRE : Noter la colonne "après" du rapport


-- R2
CREATE INDEX idx_emprunt_retour_reelle ON emprunt(date_retour_reelle);
-- JUSTIFICATION : La requête recherche les emprunts dont
-- date_retour_reelle est NULL.
-- L'index évite de parcourir toute la table.
ANALYZE TABLE emprunt;
EXPLAIN SELECT * FROM emprunt WHERE date_retour_reelle IS NULL;
-- A FAIRE : Noter la colonne "après" du rapport

-- R3
CREATE INDEX idx_emprunt_adherent_date ON emprunt(adherent_id, date_emprunt);
-- JUSTIFICATION : L'ordre des colonnes est important.
-- La requête filtre d'abord par adherent_id (=),
-- puis par date_emprunt (>=).
-- L'index suit exactement cet ordre de recherche.
ANALYZE TABLE emprunt;
EXPLAIN SELECT id, date_emprunt FROM emprunt WHERE adherent_id = 12 AND date_emprunt >= '2025-01-01';
-- A FAIRE : Noter la colonne "après" du rapport


-- ============================
-- Exo 7

EXPLAIN SELECT id FROM emprunt WHERE adherent_id = 12;
EXPLAIN SELECT id FROM emprunt WHERE date_emprunt >= '2025-01-01';
--  JUSTIFICATION : La première requête utilise l'index composite
-- car elle filtre sur la première colonne
-- de l'index (adherent_id).

-- La seconde ne peut pas utiliser correctement
-- l'index composite car elle filtre uniquement
-- sur la deuxième colonne (date_emprunt).

-- Un index composite est peut être utilisé à partir de son préfixe gauche.


-- ============================
-- Exo 8

EXPLAIN SELECT adherent_id, date_emprunt FROM emprunt WHERE adherent_id = 12;
EXPLAIN SELECT adherent_id, date_emprunt, exemplaire_id FROM emprunt WHERE adherent_id = 12;

-- JUSTIFICATION : La mention "Using index" apparaît pour la première requête 
-- car toutes les colonnes demandées sont présentes dans l'index.

-- Elle disparaît pour la seconde car exemplaire_id 
-- n'appartient pas à l'index.

-- Le serveur doit relire la table pour récupérer cette colonne.


-- ============================
-- Exo 9

EXPLAIN SELECT COUNT(*) FROM emprunt WHERE date_emprunt >= '2024-01-01' AND date_emprunt < '2025-01-01';
-- JUSTIFICATION : YEAR(date_emprunt) applique une fonction
-- sur la colonne et empêche la bonne utilisation de l'index.

-- La recherche par intervalle produit exactement le même résultat 
-- tout en permettant l'utilisation de l'index.

-- A FAIRE : Pas compris le "Montrer les 2 'EXPLAIN'"


-- ============================
-- Exo 10

-- Script avant et après la création de l'index de l'exo 6 (jsp pourquoi il est en exo 10 si on doit le faire avant et après le 6)
SELECT table_name, data_length, index_length FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'emprunt';


-- JUSTIFICATION : Les index améliorent les performances des recherches 
-- mais augmentent l'espace disque utilisé par la table.