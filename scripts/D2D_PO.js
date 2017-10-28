var baseUrlToLoad = 'http://yrocher.fcsystem.com/Symfony/WsGetJsonFromSql/WsGetJsonFromSql.php?apikey=595c015a-98c4-4097-9d89-c5b83ed28ff1&isonlyresult=TRUE';

fillContainers = function () {
    var whichNumPo = $('#whichNumPo').val();
    alert(whichNumPo);
    fillD2D_PO_EnteteSyntheseContainer(whichNumPo);
    fillD2D_PO_TracaAmontContainer(whichNumPo);
}

fillD2D_PO_EnteteSyntheseContainer = function (whichNumPo) {
    var urlToLoad = baseUrlToLoad + '&sqlrfilepath=D2D_PO_EnteteSynthese.sql&num_po=' + whichNumPo;
    $.ajax({
        url: urlToLoad,
        dataType: 'json',
        success: function (json) {
            example2 = $('#D2D_PO_EnteteSyntheseContainer').columns({
                data: json,
            });
        }
    });
}

fillD2D_PO_TracaAmontContainer = function (whichNumPo) {
    var urlToLoad = baseUrlToLoad + '&sqlrfilepath=D2D_PO_TracaAmont.sql&num_po=' + whichNumPo;
    $.ajax({
        url: urlToLoad,
        dataType: 'json',
        success: function (json) {
            example2 = $('#D2D_PO_TracaAmontContainer').columns({
                data: json,
            });
        }
    });
}
