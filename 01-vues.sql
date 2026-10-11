USE mediatheque;
-- partie A.1

CREATE VIEW v_catalogue AS
SELECT 
ou.titre AS ouvrage_titre, -- rev diff _ et .
ou.auteur AS ouvrage_auteur,
ou.annee_publication AS ouvrage_annee_publication,
ca.libelle AS categorie_libelle,
COUNT(e.id) AS nb_exemplaire, -- on count les id ds exemplaire et on renomme col en nm_exemplaire_id
SUM(e.disponible = 1) AS nb_exemplaire_disponible
FROM ouvrage ou
JOIN categorie ca ON ca.id = ou.categorie_id -- revoir left right etc et ordre  et translate de la ligen pr compr
LEFT JOIN exemplaire e ON e.ouvrage_id = ou.id -- ps meme ordre qd left
GROUP BY ou.id; -- group by qd sum et count revoir

CREATE VIEW v_adherent_public AS
SELECT 
ad.id,
ad.nom,
ad.prenom,
ad.ville,
ad.date_inscription,
ad.actif
FROM adherent ad;

CREATE VIEW v_emprunt_en_cours AS -- selectionner uqe cette view et sur 1er eclair pour tester car err sinon
SELECT
em.id AS emprunt_id,
em.date_emprunt AS date_emprunt,
DATEDIFF(CURDATE(), date_retour_prevue) AS jours_de_retard,
CONCAT(a.nom, a.prenom) AS nom_complet_adherent,
ou.titre AS titre_ouvrage,
ex.code_barre 
FROM emprunt em -- tjs choisir les 2 table pr le join en rapport avec les FK ds elles
JOIN adherent a ON a.id = em.adherent_id
JOIN exemplaire ex ON ex.id = em.exemplaire_id
JOIN ouvrage ou ON ou.id = ex.ouvrage_id
WHERE em.date_retour_reelle IS NULL;

CREATE VIEW v_retard AS -- rev slide 14
SELECT * FROM v_emprunt_en_cours WHERE jours_de_retard > 0;

-- Partie A.2

-- ajout du bout de code ci-desous dans tp1 
REVOKE SELECT (id, nom, prenom, email, telephone, date_naissance, ville, date_inscription, actif)
ON mediatheque.adherent
FROM 'stagiaire'@'localhost';

GRANT SELECT ON mediatheque.v_adherent_public TO 'stagiaire'@'localhost';
GRANT SELECT ON mediatheque.v_catalogue TO 'stagiaire'@'localhost';
GRANT SELECT ON mediatheque.v_emprunt_en_cours TO 'stagiaire'@'localhost';

-- test des 2 commandes OK


