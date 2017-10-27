SELECT
'<a href=test.html>'||login||'</a>' as login, 
password, 
nom, 
UPPER(prenom) as prenom,
email, 
description,
etat, 
langue, 
date
FROM utilisateurs
;
