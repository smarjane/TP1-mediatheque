USE mediatheque;

-- f1
DELIMITER $$
CREATE FUNCTION f_nb_emprunts_en_cours(
    p_adherent_id INT UNSIGNED)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_nb INT;

    SELECT COUNT(*) INTO v_nb
      FROM emprunt
     WHERE adherent_id = p_adherent_id
       AND date_retour_reelle IS NULL;

    RETURN v_nb;
END $$
DELIMITER ;
-- test
SELECT f_nb_emprunts_en_cours(12);
SELECT nom, f_nb_emprunts_en_cours(id) FROM adherent;

-- f2
DELIMITER $$
CREATE FUNCTION f_penalites_dues(p_adherent_id INT UNSIGNED)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_total INT;

    SELECT COALESCE(SUM(montant), 0) INTO v_total
      FROM penalite
     WHERE adherent_id = p_adherent_id
       AND payee = 0;

    RETURN v_total;
END$$

DELIMITER ;

-- test
SELECT f_penalites_dues(12);
SELECT nom, f_penalites_dues(id) AS penalites FROM adherent;

-- f3
DELIMITER $$
CREATE FUNCTION f_jours_de_retard(p_emprunt_id INT UNSIGNED)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_prevue DATE;
    DECLARE v_reelle DATE;
    DECLARE v_jours  INT DEFAULT 0;

    SELECT date_retour_prevue, date_retour_reelle
      INTO v_prevue, v_reelle
      FROM emprunt
     WHERE id = p_emprunt_id;

    IF v_reelle IS NULL THEN
        SET v_jours = DATEDIFF(CURDATE(), v_prevue);
    ELSE
        SET v_jours = DATEDIFF(v_reelle, v_prevue);
    END IF;

    IF v_jours < 0 THEN
        SET v_jours = 0;
    END IF;

    RETURN v_jours;
END$$

DELIMITER ;

-- test
SELECT f_jours_de_retard(1);



SELECT nom, f_nb_emprunts_en_cours(id), f_penalites_dues(id) 
FROM adherent 
WHERE f_nb_emprunts_en_cours(id) >= 1;


