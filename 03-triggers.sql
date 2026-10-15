-- Exo 4

-- Créer la table
CREATE TABLE IF NOT EXISTS journal_action (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  table_cible VARCHAR(40) NOT NULL,
  operation VARCHAR(10) NOT NULL,
  cle VARCHAR(40) NOT NULL,
  auteur VARCHAR(100) NOT NULL,
  horodatage DATETIME NOT NULL,
  details VARCHAR(255) NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB;


-- Trigger 1

DELIMITER $$

CREATE TRIGGER trg_emprunt_bi
BEFORE INSERT ON emprunt
FOR EACH ROW
BEGIN
    IF NEW.date_emprunt IS NULL THEN
        SET NEW.date_emprunt = CURDATE();
    END IF;

    IF NEW.date_retour_prevue IS NULL THEN
        SET NEW.date_retour_prevue = DATE_ADD(NEW.date_emprunt, INTERVAL 14 DAY);
    END IF;

    IF NEW.date_retour_prevue < NEW.date_emprunt THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La date de retour ne peut pas etre anterieure a la date d emprunt';
    END IF;
END$$

DELIMITER ;


-- Trigger 2

DELIMITER $$

CREATE TRIGGER trg_emprunt_ai
AFTER INSERT ON emprunt
FOR EACH ROW
BEGIN
    UPDATE exemplaire
       SET disponible = 0
     WHERE id = NEW.exemplaire_id;

    INSERT INTO journal_action
    (table_cible, operation, cle, auteur, horodatage, details)
    VALUES
    (
        'emprunt',
        'INSERT',
        NEW.id,
        CURRENT_USER(),
        NOW(),
        CONCAT('Creation emprunt adherent=', NEW.adherent_id,
               ', exemplaire=', NEW.exemplaire_id)
    );
END$$

DELIMITER ;


-- Trigger 3

USE mediatheque;

DELIMITER $$

CREATE TRIGGER trg_emprunt_au
AFTER UPDATE ON emprunt
FOR EACH ROW
BEGIN
    IF OLD.date_retour_reelle IS NULL
       AND NEW.date_retour_reelle IS NOT NULL THEN

        UPDATE exemplaire
           SET disponible = 1
         WHERE id = NEW.exemplaire_id;

        INSERT INTO journal_action
        (table_cible, operation, cle, auteur, horodatage, details)
        VALUES
        (
            'emprunt',
            'UPDATE',
            NEW.id,
            CURRENT_USER(),
            NOW(),
            CONCAT('Retour emprunt adherent=', NEW.adherent_id,
                   ', exemplaire=', NEW.exemplaire_id)
        );
    END IF;
END$$

DELIMITER ;
