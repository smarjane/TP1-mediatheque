USE mediatheque;

DROP PROCEDURE IF EXISTS p_emprunter;

DELIMITER $$
CREATE PROCEDURE p_emprunter(
    IN  p_code_barre   VARCHAR(30),
    IN  p_adherent_id  INT UNSIGNED,
    OUT p_emprunt_id   INT UNSIGNED)
BEGIN
    DECLARE v_actif         TINYINT      DEFAULT NULL;
    DECLARE v_exemplaire_id INT UNSIGNED DEFAULT NULL;
    DECLARE v_disponible    TINYINT      DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- regle 1
    SELECT actif INTO v_actif
      FROM adherent
     WHERE id = p_adherent_id;

    IF v_actif IS NULL THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'Adhérent inconnu.';
    END IF;

    IF v_actif = 0 THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'Inscription non active.';
    END IF;

    -- regle 2
    SELECT id, disponible INTO v_exemplaire_id, v_disponible
      FROM exemplaire
     WHERE code_barre = p_code_barre;

    IF v_exemplaire_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'Code-barres inconnu';
    END IF;

    IF v_disponible = 0 THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'Exemplaire déjà emprunté.';
    END IF;

    -- regle 3
    IF f_nb_emprunts_en_cours(p_adherent_id) >= 5 THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'Qinq documents maximum par adhérent';
    END IF;

    -- regle 4
    IF f_penalites_dues(p_adherent_id) > 10 THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'Pas plus de 10 € de pénalités impayées';
    END IF;

    INSERT INTO emprunt (adherent_id, exemplaire_id)
    VALUES (p_adherent_id, v_exemplaire_id);

    SET p_emprunt_id = LAST_INSERT_ID();

    COMMIT;
END$$

DELIMITER ;


DROP PROCEDURE IF EXISTS p_rendre;

DELIMITER $$
CREATE PROCEDURE p_rendre(IN p_code_barre VARCHAR(30))
BEGIN
    DECLARE v_emprunt_id  INT UNSIGNED DEFAULT NULL;
    DECLARE v_adherent_id INT UNSIGNED DEFAULT NULL;
    DECLARE v_jours       INT          DEFAULT 0;
    DECLARE v_montant     DECIMAL(8,2) DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT em.id, em.adherent_id INTO v_emprunt_id, v_adherent_id
      FROM emprunt em
      JOIN exemplaire ex ON ex.id = em.exemplaire_id
     WHERE ex.code_barre = p_code_barre
       AND em.date_retour_reelle IS NULL;

    IF v_emprunt_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'pas emprunt en cours pour ce code-barres.';
    END IF;

    SET v_jours = f_jours_de_retard(v_emprunt_id);

    UPDATE emprunt
       SET date_retour_reelle = CURDATE()
     WHERE id = v_emprunt_id;

       IF v_jours > 0 THEN
        SET v_montant = v_jours * 0.20;

        INSERT INTO penalite (adherent_id, emprunt_id, montant, motif, date_creation)
        VALUES (v_adherent_id, v_emprunt_id, v_montant,
                CONCAT('Retard de ', v_jours, ' jours'), NOW());
    END IF;

    COMMIT;

    SELECT v_emprunt_id AS emprunt_id,
           v_jours      AS jours_de_retard,
           v_montant    AS montant_facture;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS p_bilan_adherent;

DELIMITER $$
CREATE PROCEDURE p_bilan_adherent(IN p_adherent_id INT UNSIGNED)
BEGIN
    SELECT id, nom, prenom,
           f_nb_emprunts_en_cours(id) AS nb_en_cours,
           f_penalites_dues(id)       AS penalites
      FROM adherent
     WHERE id = p_adherent_id;

    SELECT em.id AS emprunt_id, o.titre, em.date_retour_prevue,
           f_jours_de_retard(em.id) AS jours_de_retard
      FROM emprunt em
      JOIN exemplaire ex ON ex.id = em.exemplaire_id
      JOIN ouvrage    o  ON o.id  = ex.ouvrage_id
     WHERE em.adherent_id = p_adherent_id
       AND em.date_retour_reelle IS NULL;

    SELECT COUNT(*) AS nb_total_emprunts
      FROM emprunt
     WHERE adherent_id = p_adherent_id;
END$$

DELIMITER ;



-- test 
-- CALL p_emprunter(p_code_barre, p_adherent_id, @emprunt_id);

CALL p_emprunter('MED-00042', 12, @emprunt_id);
SELECT @emprunt_id;