SELECT
ph.num_po, 
pd.set_article_acheteur as "Sku#", 
pt.date_min as "Date départ",
'' as CQ, 
pt.mer_nom_port_embarquement||' '||pt.mer_nom_port_embarquement as "lieu départ", 
ph.mode_transport as "type de transport", 
pt.mer_port_arrivee||' '||pt.mer_nom_port_arrivee as "lieu arrivée", 
pt.date_arrivee_entrepot as "Date arrivée ETA ou ATA ou Arrival POD", 
'' as "qté embarquée"


FROM po_header as ph
LEFT JOIN po_transport as pt
ON ph.num_po = pt.num_po
LEFT JOIN po_detail as pd
ON pt.num_po = pd.num_po
WHERE TRIM(LOWER(SPLIT_PART(ph.num_po, '_', '1'))) = TRIM(LOWER(SPLIT_PART('[[num_po]]')))