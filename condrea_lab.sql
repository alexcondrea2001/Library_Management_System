--Creare secvente pentru pk-uri
 
CREATE SEQUENCE pk_autor
  INCREMENT BY 1
  START WITH 1
  MINVALUE 1
  MAXVALUE 9999999999999;
CREATE SEQUENCE pk_carte
  INCREMENT BY 1
  START WITH 1
  MINVALUE 1
  MAXVALUE 9999999999999;
CREATE SEQUENCE pk_cititor
  INCREMENT BY 1
  START WITH 1
  MINVALUE 1
  MAXVALUE 9999999999999;
CREATE SEQUENCE pk_imprumut
  INCREMENT BY 1
  START WITH 1
  MINVALUE 1
  MAXVALUE 9999999999999;
CREATE SEQUENCE uk_nume_autor
  INCREMENT BY 1
  START WITH 1
  MINVALUE 1
  MAXVALUE 9999999999999;
CREATE SEQUENCE uk_nume_carte
  INCREMENT BY 1
  START WITH 1
  MINVALUE 1
  MAXVALUE 9999999999999;
 
--Creare de trigeri pentru generarea automata de pk-uri
 
CREATE OR REPLACE TRIGGER bef_autor
BEFORE  INSERT ON autori
REFERENCING NEW AS NEW OLD AS OLD FOR EACH ROW
begin
    select PK_AUTOR.NEXTVAL into :new.pk_autor from dual;
end;
 
CREATE OR REPLACE TRIGGER bef_carte
BEFORE  INSERT ON carti
REFERENCING NEW AS NEW OLD AS OLD FOR EACH ROW
begin
    select PK_CARTE.NEXTVAL into :new.pk_carte from dual;
end;
 
CREATE OR REPLACE TRIGGER bef_cititor
BEFORE  INSERT ON cititori
REFERENCING NEW AS NEW OLD AS OLD FOR EACH ROW
begin
    select PK_cititor.NEXTVAL into :new.pk_cititor from dual;
end;
 
CREATE OR REPLACE TRIGGER bef_imprumut
BEFORE  INSERT ON imprumuturi
REFERENCING NEW AS NEW OLD AS OLD FOR EACH ROW
begin
    select PK_imprumut.NEXTVAL into :new.pk_imprumut from dual;
end;
 
 
--inserare cu autori

insert into autori values(1, 'Autor_1');

select * from autori
 
-- inserare cu cititori
 
insert into cititori values(1, 'Cititor_1', 25,'M','FB');

select * from cititori;
 
--inserare cu carti

insert into carti values(1,'Beletristica','Titlu_1',2,5,null);
insert into carti values(null,'Divertisment','Titlu_9',3,null,null);

select * from carti;
 
--inserare cu imprumuturi
insert into imprumuturi values(null, 4, 3, sysdate-5,sysdate+5, null,null);



delete from imprumuturi

select * from imprumuturi;
 
 
 

-- selectare nume autor
select nume_autor from autori;
 
--selectare titlu carte, domeniu
select titlu_carte, domeniu from carti;
 
--selectare nume cititor, varsta, sex, calificativ
select nume_cititor, varsta, sex, calificativ from cititori;



-----SELECT
 
-- 1. selectare titlu carte, nume autori
select carti.titlu_carte, au1.nume_autor as aut1, au2.nume_autor as aut2, au3.nume_autor as aut3  from carti, autori au1, autori au2, autori au3
where carti.pk_autor1 = au1.pk_autor
and   carti.pk_autor2 = au2.pk_autor(+)
and   carti.pk_autor3 = au3.pk_autor(+);
 
-- 2. selectare titlu carte, nume cititor, data start, data end, data return
select c.titlu_carte, cit.nume_cititor, i.data_start, i.data_end, i.data_return
from carti c, cititori cit, imprumuturi i
where cit.pk_cititor = i.pk_cititor 
and c.pk_carte = i.pk_carte;
 
-- 3. toate imprumuturile nereturnate pana in ziua de azi
select car.titlu_carte, cit.nume_cititor, imp.data_start, imp.data_end, imp.data_return
from carti car, cititori cit, imprumuturi imp
where car.pk_carte = imp.pk_carte
and cit.pk_cititor = imp.pk_cititor
and (imp.data_return IS NULL or imp.data_return > trunc(SYSDATE));
 
 
-- 4. toate imprumuturile nereturnate pana in ziua de azi, numarul de zile de cand au fost imprumutate, nr de zile de intarziere
SELECT
  i.pk_imprumut,
  c.nume_cititor,
  cart.titlu_carte,
  i.data_start,
  i.data_end,
  i.data_return,
  trunc(SYSDATE - i.data_start) AS zile_de_la_imprumut,
  CASE
    WHEN i.data_return IS NULL THEN TRUNC(GREATEST(SYSDATE - i.data_end, 0))
    ELSE TRUNC(GREATEST(i.data_return - i.data_end, 0))
  END AS zile_intarziere
FROM
  imprumuturi i, cititori c, carti cart
WHERE
  i.pk_cititor = c.pk_cititor
  AND i.pk_carte = cart.pk_carte
  AND (i.data_return IS NULL OR SYSDATE > i.data_return);
  
  
-- 5. toate imprumuturile mai vechi de 2 saptamani

SELECT
  i.pk_imprumut,
  c.nume_cititor,
  cart.titlu_carte,
  i.data_start,
  i.data_return,
  trunc(SYSDATE - i.data_start) as zile_imprumut
FROM
  imprumuturi i, cititori c, carti cart
WHERE
  i.pk_cititor = c.pk_cititor
  AND i.pk_carte = cart.pk_carte
  AND trunc(SYSDATE - i.data_start) > 14;
  
-- 5_2. toate imprumuturile care dureaza mai mult de 2 saptamani

SELECT
  i.pk_imprumut,
  c.nume_cititor,
  cart.titlu_carte,
  i.data_start,
  i.data_end,
  trunc(i.data_end - i.data_start) as zile_imprumut
FROM
  imprumuturi i, cititori c, carti cart
WHERE
  i.pk_cititor = c.pk_cititor
  AND i.pk_carte = cart.pk_carte
  AND trunc(i.data_end - i.data_start) > 14;
  
-- 6. nr de carti care trebuie sa fie returnate in urmatoarea saptamana
SELECT
  TO_CHAR(TRUNC(SYSDATE + 7), 'DD-MON-YYYY') AS data_limita,
  COUNT(*) AS numar_carti_de_returnat
FROM
  imprumuturi i
WHERE
  data_return IS NULL
  AND TRUNC(SYSDATE + 7) >= TRUNC(i.data_end);
  
-- 7. nr de carti care nu sunt imprumutate --NVL - verifica daca un numar este null sau nu
SELECT
  c.*,
  CASE
    WHEN i.pk_imprumut IS NOT NULL AND TRUNC(i.data_return) <= TRUNC(SYSDATE) THEN 'Disponibila'
    WHEN i.pk_imprumut IS NULL THEN 'Disponibila'
    ELSE 'Imprumutata'
  END AS status_carte
FROM
  carti c
LEFT JOIN (
  SELECT
    pk_carte,
    MAX(pk_imprumut) AS ultimul_imprumut
  FROM
    imprumuturi
  WHERE
    TRUNC(data_return) > TRUNC(SYSDATE) OR data_return IS NULL
  GROUP BY
    pk_carte
) i_max ON c.pk_carte = i_max.pk_carte
LEFT JOIN
  imprumuturi i ON c.pk_carte = i.pk_carte
              AND i.pk_imprumut = i_max.ultimul_imprumut
WHERE
  TRUNC(SYSDATE) BETWEEN NVL(TRUNC(i.data_start), TRUNC(SYSDATE)) AND NVL(TRUNC(i.data_return), TRUNC(SYSDATE))
  OR i.pk_imprumut IS NULL;
  
  
-- 7_2

SELECT
  c.*,
  CASE
    WHEN i.pk_imprumut IS NOT NULL AND TRUNC(i.data_return) <= TRUNC(SYSDATE) THEN 'Disponibila'
    WHEN i.pk_imprumut IS NULL THEN 'Disponibila'
    ELSE 'Imprumutata'
  END AS status_carte,
  COUNT(CASE WHEN (i.pk_imprumut IS NULL OR (i.pk_imprumut IS NOT NULL AND TRUNC(i.data_return) <= TRUNC(SYSDATE))) THEN 1 END) OVER () AS count_disponibile
FROM
  carti c
LEFT JOIN (
  SELECT
    pk_carte,
    MAX(pk_imprumut) AS ultimul_imprumut
  FROM
    imprumuturi
  WHERE
    TRUNC(data_return) > TRUNC(SYSDATE) OR data_return IS NULL
  GROUP BY
    pk_carte
) i_max ON c.pk_carte = i_max.pk_carte
LEFT JOIN
  imprumuturi i ON c.pk_carte = i.pk_carte
              AND i.pk_imprumut = i_max.ultimul_imprumut
WHERE
  TRUNC(SYSDATE) BETWEEN NVL(TRUNC(i.data_start), TRUNC(SYSDATE)) AND NVL(TRUNC(i.data_return), TRUNC(SYSDATE))
  OR i.pk_imprumut IS NULL;

-- 8. toate imprumuturile pentru un cititor dat
SELECT cit.nume_cititor, cit.pk_cititor, COUNT (*) AS nr_imprumuturi
from cititori cit, imprumuturi i
where cit.pk_cititor = i.pk_cititor
group by cit.nume_cititor, cit.pk_cititor;

-- 8_2. toate imprumuturile pentru un cititor dat
select t.titlu_carte, c.nume_cititor
from carti t , imprumuturi im, cititori c
where t.pk_carte = im.pk_carte
and c.pk_cititor = im.pk_cititor
and c.nume_cititor= 'Andrei';


-- 9. Toate imprumuturile care nu au fost returnate la termen de catre un cititor dat (data_return > data_end or data_return is null and sysdate>data_end) 

select t.titlu_carte, c.nume_cititor 
from carti t, imprumuturi im, cititori c
where t.pk_carte = im.pk_carte
and c.pk_cititor = im.pk_cititor
and c.nume_cititor = 'Andrei'
and (im.data_return > im.data_end or im.data_return is null);

-- 10. Cititorii care au mai mult de un imprumut in ziua curenta: nume cititor, titlu_carte, data_start, data_end 
SELECT
  n.pk_cititor,
  n.nume_cititor,
  COUNT(im.pk_imprumut) AS numar_imprumuturi
FROM
  cititori n
JOIN
  imprumuturi im ON n.pk_cititor = im.pk_cititor
GROUP BY
  n.pk_cititor, n.nume_cititor
HAVING
  COUNT(im.pk_imprumut) > 1;
  
-- 11.	Numele cititorilor si numarul de imprumuturi efectuate de acel cititor in decursul timpului: nume_autor, numar_imprumuturi
SELECT
  n.nume_cititor,
  COUNT(im.pk_imprumut) AS numar_imprumuturi
FROM
  cititori n
LEFT JOIN
  imprumuturi im ON n.pk_cititor = im.pk_cititor
GROUP BY
  n.nume_cititor
ORDER BY
  numar_imprumuturi DESC, n.nume_cititor;
  
-- 12.	Lista cu primii 3 cititori in ordinea numarului de imprumuturi
select n.nume_cititor, count(im.pk_imprumut)numar_imprumuturi
from cititori n, imprumuturi im
where n.pk_cititor = im.pk_cititor
group by n.nume_cititor
order by numar_imprumuturi desc
fetch first 3 rows only;


-- 12_2.
SELECT
  n.nume_cititor,
  COUNT(im.pk_imprumut) AS numar_imprumuturi
FROM
  cititori n
LEFT JOIN
  imprumuturi im ON n.pk_cititor = im.pk_cititor
GROUP BY
  n.nume_cititor
ORDER BY
  numar_imprumuturi DESC
FETCH FIRST 3 ROWS ONLY;

-- 13. Lista cu primii 3 cititori care au cele mai multe intarzieri la returnarea cartilor
select c.nume_cititor, SUM(CASE WHEN TRUNC(i.data_return) > TRUNC(i.data_end) OR i.data_return IS NULL THEN 1 ELSE 0 END) AS numar_intarzieri
from cititori c, imprumuturi i
where c.pk_cititor=i.pk_cititor
group by c.nume_cititor
order by numar_intarzieri DESC
FETCH FIRST 3 ROWS ONLY;

-- 14. Lista primilor 3 cititori cu calificative negative. Calificativul unui cititor este dat de raportul dintre numarul de carti imprumutate 
-- si numarul de intarzieri la returnare. Este posibil ca un cititor sa aiba multe intarzieri (deci este in capul listei la numar de intarzieri), 
-- dar si multe imprumuturi, deci calificativul acestui cititor este mai bun decat al unui alt cititor cu o singura intarziere dar si un singur imprumut.

select c.nume_cititor, SUM(CASE WHEN TRUNC(i.data_return) > TRUNC(i.data_end) OR i.data_return IS NULL THEN 1 ELSE 0 END) AS numar_int, 
COUNT(i.pk_imprumut) AS numar_imprumuturi, (SUM(CASE WHEN TRUNC(i.data_return) > TRUNC(i.data_end) OR i.data_return IS NULL THEN 1 ELSE 0 END)/COUNT(i.pk_imprumut))*10 AS CALIFICATIV
from cititori c, imprumuturi i
where c.pk_cititor=i.pk_cititor
group by c.nume_cititor
order by CALIFICATIV DESC
FETCH FIRST 3 ROWS ONLY;

-- 15.	Cartile cele mai solicitate pentru imprumut (cu numarul cel mai mare de imprumuturi)
select c.titlu_carte, COUNT(i.pk_imprumut) AS numar_imprumuturi
from carti c, imprumuturi i
where c.pk_carte=i.pk_carte
group by c.titlu_carte
order by numar_imprumuturi DESC;

-- 16.	Cei mai bine cititi autori  (autorii ai caror carti au fost cel mai mult solicitate)
select a.nume_autor, COUNT(i.pk_imprumut) AS numar_solicitari
from autori a, imprumuturi i, carti c
where c.pk_carte=i.pk_carte
and ((a.pk_autor = c.pk_autor1) or (a.pk_autor = c.pk_autor2) or (a.pk_autor = c.pk_autor3))
group by a.nume_autor
order by numar_solicitari DESC;



----UPDATE

-- 1. Sa se scrie instructiuni update care modifica numele unui autor si titlul unei carti.

update autori set nume_autor = 'Nichita Stanescu' where nume_autor ='Tudor Arghezi'

update carti set titlu_carte = 'Plumb' where titlu_carte ='Povesti'

-- 2. Sa se scrie instructiunea update care trece toate impumuturile de la un cititor pe numele altui cititor.

update imprumuturi set pk_cititor =  where pk_cititor = 

-- 3. Completeaza cu data curenta campul �data_return� din tabela�imprumuturi� pentru un cititor dat si o carte data (cititorul a returnat cartea la biblioteca).

update imprumuturi set data_return = sysdate where ((pk_cititor = ) and (pk_carte = ))

-- 4. Prelungeste perioada imprumutului cu 3 saptamani pentru toate cartile din domeniul stiinte.

UPDATE imprumuturi
SET data_end = data_end + 21 -- Adaug? 3 s?pt?m�ni
WHERE pk_carte IN (
    SELECT pk_carte
    FROM carti
    WHERE domeniu = 'Stiinte'
);

-- 5. Toate titlurile cartilor sa fie scrise cu majuscule

UPDATE carti SET titlu_carte = UPPER(titlu_carte);

-- 6. Titlurile cartilor scrise de un autor (prim_autor) sa inceapa cu majuscula si apoi sa continue cu litera mica

UPDATE carti
SET titlu_carte = INITCAP(titlu_carte)
WHERE pk_autor1 IN (
    SELECT pk_autor
    FROM autori
    WHERE nume_autor = 'Ion Creanga'
);



----DELETE


-- 1. Imprumuturile pentru un anumit cititor

DELETE FROM imprumuturi
WHERE pk_cititor IN (
    SELECT pk_cititor 
    from cititori 
    where nume_cititor ='Cosmin'
    );

-- 2. Un cititor din baza de date. Se folosesc 2 metode:

delete from imprumuturi
where pk_cititor = 3;

delete from cititori
where pk_cititor = 3;



----FUNCTII


-- 2. Calculeaza numarul de carti pentru un autor dat

CREATE OR REPLACE FUNCTION nr_carti_per_autor(nume_autor IN VARCHAR2) RETURN NUMBER IS
  v_numar_carti NUMBER := 0;
BEGIN
  SELECT COUNT(*)
  INTO v_numar_carti
  FROM carti c
  WHERE
    nume_autor IN (
      SELECT nume_autor
      FROM autori a
      WHERE a.pk_autor = c.pk_autor1
         OR a.pk_autor = c.pk_autor2
         OR a.pk_autor = c.pk_autor3
    );

  RETURN v_numar_carti;
END nr_carti_per_autor;



SELECT nr_carti_per_autor('Ion Creanga') FROM dual;


----TRIGGERI

-- 1. Pe baza modelului sa se scrie un trigger care sa completeze automat coloana pk_carte la inserarea unei carti in tabela "carti".


CREATE SEQUENCE pk_carte
  INCREMENT BY 1
  START WITH 1
  MINVALUE 1
  MAXVALUE 9999999999999;

CREATE OR REPLACE TRIGGER bef_carti
BEFORE INSERT ON carti
FOR EACH ROW
BEGIN
  SELECT pk_carte.NEXTVAL INTO :new.pk_carte FROM dual;
END;


--2. CREATE OR REPLACE TRIGGER bef_imprumuturi


CREATE OR REPLACE TRIGGER bef_imprumuturi
BEFORE INSERT ON imprumuturi
FOR EACH ROW
BEGIN
  :new.data_start := SYSDATE;
  :new.data_end := SYSDATE + INTERVAL '21' DAY; -- Adaugam 3 saptamani la data_start
END;



    
    commit

    
    
    
  






