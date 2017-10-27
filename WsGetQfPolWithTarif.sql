SELECT

TRIM(rs.country_code || rs.town_code) as code_port,
TRIM(rp.nom) as nom_pays,
TRIM(rs.town_name) as nom_port, 
CAST( is_pol AS VARCHAR), 
CAST( is_pod AS VARCHAR)

FROM ref_tarifs_ports

LEFT JOIN ref_sailing_terminals as rs
ON ref_tarifs_ports.id_sailing_terminal = rs.id

LEFT JOIN ref_pays as rp
ON rp.code = rs.country_code

LEFT JOIN ref_transport_mode as rt
ON ref_tarifs_ports.id_transport_mode = rt.id

LEFT JOIN ref_global_parameters as rgp
ON rgp.usd_to_euro_rate IS NOT NULL

WHERE 1=1
AND LOWER(rt.designation) = 'sea'
AND ( LENGTH('$getPortCode') = 0 OR LOWER(TRIM(rs.country_code || rs.town_code)) LIKE LOWER(TRIM('$getPortCode'))||'%'  )
AND ( LENGTH('$getCountryName') = 0 OR LOWER(rp.nom) LIKE LOWER(TRIM('$getCountryName'))||'%'  )
AND ( LENGTH('$getPortName') = 0 OR LOWER(rs.town_name) LIKE LOWER(TRIM('$getPortName'))||'%'  )
AND ( LENGTH('$getisPol') = 0 OR LOWER(CAST(is_pol as VARCHAR)) = LOWER(TRIM('$getisPol')) ) 
AND ( LENGTH('$getisPod') = 0 OR LOWER(CAST(is_pod as VARCHAR)) = LOWER(TRIM('$getisPod')) ) 
AND '$getApiKey' = '$apiKey'
ORDER by TRIM(rs.country_code || rs.town_code)
;
