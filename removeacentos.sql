CREATE OR REPLACE FUNCTION `facily-817c2.facily_wp_logistic_aux.fnc_REMOVE_ACENTOS`(texto STRING) AS (
((
  WITH lookups AS (
    SELECT 
    'ç,æ,œ,á,é,í,ó,ú,à,è,ì,ò,ù,ä,ë,ï,ö,ü,ã,õ,ÿ,â,ê,î,ô,û,å,ø,Ø,Å,Á,À,Â,Ä,È,É,Ê,Ë,Í,Î,Ï,Ì,Ò,Ó,Ô,Ö,Ú,Ù,Û,Ü,Ã,Õ,Ÿ,Ç,Æ,Œ,ñ,#' AS accents,
    'c,ae,oe,a,e,i,o,u,a,e,i,o,u,a,e,i,o,u,a,o,y,a,e,i,o,u,a,o,O,A,A,A,A,A,E,E,E,E,I,I,I,I,O,O,O,O,U,U,U,U,A,O,Y,C,AE,OE,n,' AS latins

  ),
  pairs AS (
    SELECT accent, latin FROM lookups, 
      UNNEST(SPLIT(accents)) AS accent WITH OFFSET AS p1, 
      UNNEST(SPLIT(latins)) AS latin WITH OFFSET AS p2
    WHERE p1 = p2
  )
   SELECT REPLACE(REPLACE(REPLACE( STRING_AGG(IFNULL(latin, char), ''),',',''),CHR(13),' '),CHR(10),' ')
  FROM UNNEST(SPLIT(texto, '')) char
  LEFT JOIN pairs
  ON char = accent
))
);