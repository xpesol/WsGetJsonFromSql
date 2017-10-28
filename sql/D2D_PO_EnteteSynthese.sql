--sku		campagne comm		qté cdée		Reliquat		10/05/2017		10/06/2017		12/07/2017		15/08/2017
SELECT
pd.set_article_acheteur as "sku", 
'' as "campagne comm", 
SUM(pd.total_units) as "qtee cdee", 
'' as "Reliquat"
FROM po_header as ph
LEFT JOIN po_transport as pt
ON ph.num_po = pt.num_po
LEFT JOIN po_detail as pd
ON pt.num_po = pd.num_po
WHERE 1=1
AND LOWER(SPLIT_PART(ph.num_po, '_', 1)) = LOWER(SPLIT_PART('[[num_po]]', '_', 1))
GROUP BY SPLIT_PART(ph.num_po, '_', 1), pd.set_article_acheteur
