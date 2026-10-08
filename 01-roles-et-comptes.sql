-- Partie 1 slide 15 et 26
DROP USER IF EXISTS 'app_media'@'localhost';
DROP USER IF EXISTS 'biblio_marie'@'localhost';
DROP USER IF EXISTS 'stagiaire'@'localhost';
DROP USER IF EXISTS 'analyste'@'localhost';

DROP ROLE IF EXISTS 'role_catalogue';
DROP ROLE IF EXISTS 'role_prets';
DROP ROLE IF EXISTS 'role_adherents';

CREATE ROLE 'role_catalogue';
CREATE ROLE 'role_prets';
CREATE ROLE 'role_adherents';

GRANT SELECT ON mediatheque.ouvrage TO 'role_catalogue';
GRANT SELECT ON mediatheque.exemplaire TO 'role_catalogue';
GRANT SELECT ON mediatheque.categorie TO 'role_catalogue';

GRANT SELECT, INSERT, UPDATE ON mediatheque.emprunt TO 'role_prets';
GRANT SELECT, INSERT, UPDATE ON mediatheque.reservation TO 'role_prets';
GRANT SELECT, INSERT, UPDATE ON mediatheque.penalite TO 'role_prets';
GRANT UPDATE(disponible) ON mediatheque.exemplaire TO 'role_prets';

GRANT SELECT, INSERT, UPDATE ON mediatheque.adherent TO 'role_adherents';

-- verification slide 9 ctrl entrée 1 a 1 rapel
SHOW GRANTS FOR 'role_catalogue';
SHOW GRANTS FOR 'role_prets';
SHOW GRANTS FOR 'role_adherents';

-- Partie 2 slide 11, 17, 20 
-- creation des compte
CREATE USER 'app_media'@'localhost'
  IDENTIFIED BY 'App!Media2026';
CREATE USER 'biblio_marie'@'localhost'
  IDENTIFIED BY 'Biblio!Marie2026';
CREATE USER 'stagiaire'@'localhost'
  IDENTIFIED BY 'Stagiaire!2026';
CREATE USER 'analyste'@'localhost'
  IDENTIFIED BY 'Analyste!2026';

-- affectation des roles (prd un paquet tt fait deja créer 3 paquet role_catalogue... avec leur droit dedans en gros c "ce compte recoi tout le contenu de se paquet")
GRANT 'role_catalogue' TO 'app_media'@'localhost';
GRANT 'role_prets' TO 'app_media'@'localhost';

GRANT role_catalogue  TO 'biblio_marie'@'localhost';
GRANT role_prets      TO 'biblio_marie'@'localhost';
GRANT role_adherents  TO 'biblio_marie'@'localhost';

GRANT role_catalogue TO 'stagiaire'@'localhost';

GRANT role_catalogue TO 'analyste'@'localhost';

-- Privilege direct (droit ecrit a la main jsute pr ce compte, use ps de paquet ecrit moi mm le droit precis colle directement sur le compte)
GRANT SELECT (id, nom, prenom, actif) 
ON mediatheque.adherent 
TO 'app_media'@'localhost';

GRANT SELECT (id, nom, prenom, ville, date_inscription, actif) 
ON mediatheque.adherent 
TO 'stagiaire'@'localhost';

GRANT SELECT ON mediatheque.emprunt TO 'analyste'@'localhost';

-- activer role a chaque connexion
SET DEFAULT ROLE ALL TO
  'app_media'@'localhost',
  'biblio_marie'@'localhost',
  'stagiaire'@'localhost',
  'analyste'@'localhost';
  
-- partie 3 
SHOW GRANTS FOR 'app_media'@'localhost';
SHOW GRANTS FOR 'biblio_marie'@'localhost';
SHOW GRANTS FOR 'stagiaire'@'localhost';
SHOW GRANTS FOR 'analyste'@'localhost';

SELECT grantee, table_name, column_name, privilege_type
FROM information_schema.column_privileges
WHERE table_schema = 'mediatheque';

GRANT SELECT ON mediatheque.reservation TO 'analyste'@'localhost';
SHOW GRANTS FOR 'analyste'@'localhost';

REVOKE SELECT ON mediatheque.reservation FROM 'analyste'@'localhost';
SHOW GRANTS FOR 'analyste'@'localhost';


-- demander revoir p2 et p3