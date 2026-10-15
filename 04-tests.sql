USE mediatheque;

-- Exo 5
SET @code = (
    SELECT code_barre
    FROM exemplaire
    WHERE disponible = 1
      AND etat <> 'hors_service'
    ORDER BY id
    LIMIT 1
);

SET @adherent = (
    SELECT a.id
    FROM adherent a
    WHERE a.actif = 1
      AND f_nb_emprunts_en_cours(a.id) = 0
      AND f_penalites_dues(a.id) = 0
    ORDER BY a.id
    LIMIT 1
);


-- T1
CALL p_emprunter(@code, @adherent, @id);
SELECT @id;
SELECT code_barre, disponible FROM exemplaire WHERE code_barre = @code;
SELECT operation, cle, auteur, details FROM journal_action ORDER BY id DESC LIMIT 3;

-- T2
  -- CALL p_emprunter(@code, @adherent + 1, @id);
-- Erreur : Exemplaire deja emprunte

-- T3
  -- CALL p_emprunter(@code, (SELECT id FROM adherent WHERE actif = 0 LIMIT 1), @id);
-- Erreur : Inscription inactive

-- T4
  -- CALL p_emprunter('MED-99999', 1, @id);
-- Erreur : Code-barres inconnu

-- T5
-- Faire 5 emprunts (devrais marcher) puis le 6eme ne devrais pas :
  -- CALL p_emprunter(@code6, @adherent_quota, @id);
-- Erreur : Quota de 5 emprunts atteint

-- T6
  -- SET @mauvais_payeur = (
  --     SELECT adherent_id
  --     FROM penalite
  --     WHERE payee = 0
  --     GROUP BY adherent_id
  --     HAVING SUM(montant) > 10
  --     LIMIT 1
  -- );
  -- CALL p_emprunter(@code, @mauvais_payeur, @id);
-- Erreur : Penalites impayees superieures a 10 EUR

-- T7
SET @exemplaire_libre = (
    SELECT id
    FROM exemplaire
    WHERE disponible = 1
      AND etat <> 'hors_service'
    ORDER BY id
    LIMIT 1
);

INSERT INTO emprunt
(exemplaire_id, adherent_id, date_emprunt, date_retour_prevue)
VALUES
(@exemplaire_libre, 2, NULL, NULL);

SELECT *
FROM emprunt
WHERE exemplaire_id = @exemplaire_libre
ORDER BY id DESC
LIMIT 1;

-- T8
SET @code_retard = (
    SELECT ex.code_barre
    FROM emprunt em
    JOIN exemplaire ex ON ex.id = em.exemplaire_id
    WHERE em.date_retour_reelle IS NULL
      AND em.date_retour_prevue < CURDATE()
    ORDER BY em.date_retour_prevue
    LIMIT 1
);

CALL p_rendre(@code_retard);

SELECT adherent_id, montant, motif
FROM penalite
ORDER BY id DESC
LIMIT 1;

-- T9
  -- CALL p_rendre(@code_retard);
-- Erreur : Aucun emprunt en cours pour ce code-barres


-- Conclusion

-- 1 : Les dates, la disponibilite et la journalisation restent garanties par les triggers. Les controles metier de la procedure ne le sont plus.
-- 2 : La regle de disponibilite pourrait etre deplacee vers une procedure. On perdrait la garantie lors d'un INSERT direct dans emprunt.
