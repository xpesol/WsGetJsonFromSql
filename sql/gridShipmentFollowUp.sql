SELECT

t.carrier as carrier,
t.bill_of_lading as bill_of_lading,
t.bill_ok,
t.container as container,
t.type_container,
t.num_po as num_po,
t.num_ligne_transport as num_ligne_transport,
t.pol,
t.pol_lib,
t.etd,
t.pod,
t.pod_lib,
t.eta,
t.arrival_pod,
t.fnd,
t.fnd_initial_date as fnd_initial_date,
t.fnd_proposed_date,
t.fnd_proposed_time,
t.fnd_confirmed_date,
t.fnd_confirmed_time,
t.fnd_arrival_date,
t.statut,
h.code_transporteur,
t.id_carrier,
t.id_trucker,
t.id_customs_broker,
t.dedouanement,
h.code_transporteur,
h.div_acheteur,
h.mode_transport,
ref_transport.nom,
t.vessel, 
t.linerterm,
fsb.id,
fsb.read,
fsb.save_by_ada,
TRIM(dd.num_bl), 
'1' as tracing_mode_transport,
CASE 
	WHEN awd_with_bl.whse_date IS NOT NULL THEN TO_CHAR(TO_DATE(awd_with_bl.whse_date, 'YYYYMMDD'), 'DD/MM/YYYY')
	WHEN awd_without_bl.whse_date IS NOT NULL THEN TO_CHAR(TO_DATE(awd_without_bl.whse_date, 'YYYYMMDD'), 'DD/MM/YYYY')
	ELSE ''
END as print_amended_whse_date, 
CASE 
	WHEN awd_with_bl.remarks IS NOT NULL THEN awd_with_bl.remarks
	WHEN awd_without_bl.remarks IS NOT NULL THEN awd_without_bl.remarks
	ELSE ''
END as amended_whse_remarks, 
ta.ata_date,
t.arrival_pod_time,
t.fnd_arrival_time, 
TRIM(t.doc_sent) AS doc_sent,
TRIM(t.doc_checked) AS doc_checked,
TRIM(t.tracking_number) AS tracking_number,
CASE WHEN t.incoterm = '02' THEN 'FCA'
ELSE ref_incoterm.libelle
END AS incoterm,
NULL,
h.uo_number,
CASE
	WHEN aph.contact_ada IS NULL OR LENGTH(aph.contact_ada)=0 THEN SUBSTR(SPLIT_PART(km.sender, ' ', 1),1, 1)||'.'||SUBSTR( km.sender, LENGTH(SPLIT_PART(km.sender, ' ', 1))+1, LENGTH(km.sender))
	ELSE SUBSTR(aph_user_detail.prenom, 1,1)||'. '||UPPER(aph_user_detail.nom)
END as print_contact_ada, 
ABS(TO_DATE(TO_CHAR(NOW(), 'YYYYMMDD'), 'YYYYMMDD')-TO_DATE(t.eta, 'YYYYMMDD') )  as diff_eta

FROM tracing_container_po_mer t
LEFT JOIN po_header h
ON t.num_po = h.num_po
LEFT JOIN ref_transport
ON h.mode_transport = ref_transport.code
LEFT JOIN floating_split_bl fsb
ON fsb.bl = t.bill_of_lading
LEFT JOIN ada_po_header as aph
ON SPLIT_PART(h.num_po, '_', 1) = LOWER(aph.num_po)
LEFT JOIN utilisateurs as aph_user_detail
ON aph.contact_ada = aph_user_detail.login
LEFT JOIN kdo_main as km
ON SPLIT_PART(h.num_po, '_', 1) = km.num_po_root

LEFT JOIN 
( 
  SELECT 
  DISTINCT ON (dd.num_bl)
  dd.num_bl
  FROM delivery_detail dd
  LEFT JOIN delivery_header dh
  ON dh.id = dd.id_header
  LEFT JOIN ref_entrepot re
  ON re.code_wms = dd.pays_bld||dd.reseau_bld
  WHERE dh.nom_livraison is not null
  AND re.flux_tire IS NOT TRUE
	AND TO_DATE( dh.date_depart, 'YYYYMMDD') > (NOW()-INTERVAL '3 month')

) as dd
ON UPPER(TRIM(dd.num_bl)) = UPPER(TRIM(t.bill_of_lading))
LEFT JOIN tracing_ata ta
ON ta.vessel = t.vessel
AND ta.bill_of_lading = t.bill_of_lading
LEFT JOIN  po_transport pt
ON pt.num_po = t.num_po
LEFT JOIN (
  SELECT 
  num_po, 
  bl, 
  whse_date, 
  remarks 
  FROM amended_whse_date 
  WHERE bl IS NOT NULL AND bl <>''
) as awd_with_bl
ON t.num_po = awd_with_bl.num_po
AND t.bill_of_lading = awd_with_bl.bl

LEFT JOIN (
  SELECT 
  num_po, 
  whse_date, 
  remarks 
  FROM amended_whse_date 
  WHERE bl IS NULL OR bl =''
) as awd_without_bl
ON t.num_po = awd_without_bl.num_po

LEFT JOIN pre_shpt_doc_sent as psds
ON SUBSTR(t.num_po, 1, 10) = psds.num_po_root
LEFT JOIN ref_incoterm
ON ref_incoterm.code = h.incoterm


WHERE 1=1
AND TO_DATE(t.eta, 'YYYYMMDD') > (NOW()-INTERVAL '3 years')
AND t.container <> ''
AND ( LENGTH('')=0 OR t.num_po IN (
									SELECT num_po 
									FROM po_detail 
									WHERE set_article_acheteur like '%' 
								) 
	)
	
AND (('')IN('') OR t.statut IN ('')) 


union

SELECT
ra.label as carrier,
(ra.digit_code || '-' || t.awb) as bill_of_lading,
t.docs_ok as bill_ok,
t.hawb as container,
'' as type_container,
t.num_po as num_po,
t.num_ligne_transport as num_ligne_transport,
t.aol,
ref_aeroports_aol.label,
t.aeroport_etd,
t.aod,
ref_aeroports_aod.label,
t.aeroport_eta,
t.aeroport_date_arrivee,
t.fnd,
po_transport.date_arrivee_entrepot as fnd_initial_date,
t.fnd_proposed_date,
t.fnd_proposed_time,
t.fnd_confirmed_date,
t.fnd_confirmed_time,
t.fnd_arrival_date,
t.statut,
h.code_transporteur,
t.id_airline as id_carrier,
t.id_trucker,
t.id_customs_broker,
t.dedouanement,
h.code_transporteur,
h.div_acheteur,
h.mode_transport,
ref_transport.nom,
NULL, 
rl.designation as linerterm,
fsb.id,
fsb.read,
fsb.save_by_ada,
TRIM(dd.num_bl), 
'4' as tracing_mode_transport,
CASE
  WHEN awd_with_bl.whse_date IS NOT NULL THEN TO_CHAR(TO_DATE(awd_with_bl.whse_date, 'YYYYMMDD'), 'DD/MM/YYYY')
  WHEN awd_without_bl.whse_date IS NOT NULL THEN TO_CHAR(TO_DATE(awd_without_bl.whse_date, 'YYYYMMDD'), 'DD/MM/YYYY')
  ELSE ''
END as print_amended_whse_date,
CASE
  WHEN awd_with_bl.remarks IS NOT NULL THEN awd_with_bl.remarks
  WHEN awd_without_bl.remarks IS NOT NULL THEN awd_without_bl.remarks
  ELSE ''
END as amended_whse_remarks,
ta.ata_date,
t.aeroport_heure_arrivee,
t.fnd_arrival_time, 
'' AS doc_sent,
'' AS doc_checked,
'' AS tracking_number,
ref_incoterm.libelle,
t.date_envoi_ot_doc,
h.uo_number,
CASE
	WHEN aph.contact_ada IS NULL OR LENGTH(aph.contact_ada)=0 THEN SUBSTR(SPLIT_PART(km.sender, ' ', 1),1, 1)||'.'||SUBSTR( km.sender, LENGTH(SPLIT_PART(km.sender, ' ', 1))+1, LENGTH(km.sender))
	ELSE SUBSTR(aph_user_detail.prenom, 1,1)||'. '||UPPER(aph_user_detail.nom)
END as print_contact_ada, 
ABS(TO_DATE(TO_CHAR(NOW(), 'YYYYMMDD'), 'YYYYMMDD')-TO_DATE(t.aeroport_eta, 'YYYYMMDD') )  as diff_eta
FROM tracing_air_po_hawb t
LEFT JOIN po_header h
ON t.num_po = h.num_po
LEFT JOIN ref_airlines ra
ON t.id_airline = ra.id_airline
LEFT JOIN ref_aeroports ref_aeroports_aod
ON substring(t.aod from 1 for 2) = ref_aeroports_aod.code_pays
AND substring(t.aod from 3 for 3) = ref_aeroports_aod.code_aeroport
LEFT JOIN ref_aeroports ref_aeroports_aol
ON substring(t.aol from 1 for 2) = ref_aeroports_aol.code_pays
AND substring(t.aol from 3 for 3) = ref_aeroports_aol.code_aeroport
LEFT JOIN po_transport
ON t.num_po = po_transport.num_po
AND t.num_ligne_transport = po_transport.num_ligne_transport
LEFT JOIN ref_linerterms as rl
ON po_transport.mer_linerterm = rl.id::text
LEFT JOIN ref_transport
ON h.mode_transport = ref_transport.code
LEFT JOIN floating_split_bl fsb
ON fsb.bl = ra.digit_code||'-'||TRIM(t.awb)
LEFT JOIN ada_po_header as aph
ON SPLIT_PART(h.num_po, '_', 1) = LOWER(aph.num_po)
LEFT JOIN utilisateurs as aph_user_detail
ON aph.contact_ada = aph_user_detail.login
LEFT JOIN kdo_main as km
ON SPLIT_PART(h.num_po, '_', 1) = km.num_po_root
LEFT JOIN 
( 
  SELECT 
  DISTINCT ON (dd.num_bl)
  dd.num_bl
  FROM delivery_detail dd
  LEFT JOIN delivery_header dh
  ON dh.id = dd.id_header
  LEFT JOIN ref_entrepot re
  ON re.code_wms = dd.pays_bld||dd.reseau_bld
  WHERE dh.nom_livraison is not null
  AND re.flux_tire IS NOT TRUE
  AND TO_DATE( dh.date_depart, 'YYYYMMDD') > (NOW()-INTERVAL '3 month')
  
) as dd
ON UPPER(TRIM(dd.num_bl)) = UPPER(ra.digit_code||'-'||TRIM(t.awb))
LEFT JOIN tracing_ata ta
ON ta.id_airline = ra.digit_code
AND ta.awb = t.awb
LEFT JOIN ref_incoterm
ON ref_incoterm.code = h.incoterm
LEFT JOIN (
  SELECT
  num_po,
  bl,
  whse_date,
  remarks
  FROM amended_whse_date
  WHERE bl IS NOT NULL AND bl <>''
) as awd_with_bl
ON t.num_po = awd_with_bl.num_po
AND (ra.digit_code || '-' || t.awb) = awd_with_bl.bl

LEFT JOIN (
  SELECT
  num_po,
  whse_date,
  remarks
  FROM amended_whse_date
  WHERE bl IS NULL OR bl =''
) as awd_without_bl
ON t.num_po = awd_without_bl.num_po

WHERE 1=1
AND t.hawb <> ''
AND TO_DATE(t.aeroport_eta, 'YYYYMMDD') > NOW()-INTERVAL '3 years'

AND (   LENGTH('')=0 
        OR t.num_po IN (
            SELECT num_po 
            FROM po_detail 
            WHERE set_article_acheteur like '%' 
        ) 
)
	AND (('')IN('') OR t.statut IN ('')) 
 
ORDER BY
diff_eta ASC,
eta DESC,
carrier,
bill_of_lading,
container,
num_po,
num_ligne_transport
;	
