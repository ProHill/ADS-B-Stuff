<?php
echo '<html>
<head>
<title>Receiver Range Plot</title>';

$data = file_get_contents("/srv/www/htdocs/flights/range.json");
$data = json_decode($data, true); 

$polarplots1 = $data["PolarPlotSlices"][1]["PolarPlots"];
$polarplots2 = $data["PolarPlotSlices"][2]["PolarPlots"];
$polarplots3 = $data["PolarPlotSlices"][3]["PolarPlots"];
$polarplots4 = $data["PolarPlotSlices"][4]["PolarPlots"];

echo '
<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css"></link>
<link rel="stylesheet" href="range.css">
<script src="http://maps.googleapis.com/maps/api/js"></script>
<script>
  function initialize() {
	var center = new google.maps.LatLng(41.895,-89.000); //center of map
	var rangecenter = new google.maps.LatLng(41.7184472,-88.2819623); //center of range rings
	var mapOptions = {
	  zoom: 6,
	  center: center,
	  disableDefaultUI: true,
	  mapTypeId: google.maps.MapTypeId.HYBRID
	}
  
	var map = new google.maps.Map(document.getElementById("range-map"), mapOptions);
  	var rangePlot1 = [
  	';
foreach($polarplots1 as $polarplot) {
	if ($polarplot["Latitude"] && $polarplot["Longitude"]) {
		echo 'new google.maps.LatLng(' . $polarplot["Latitude"] . ', ' . $polarplot["Longitude"] . '), ';
		}
	}	
echo ']; ';
echo '	
  	var rangePlot2 = [
  	';
foreach($polarplots2 as $polarplot) {
	if ($polarplot["Latitude"] && $polarplot["Longitude"]) {
		echo 'new google.maps.LatLng(' . $polarplot["Latitude"] . ', ' . $polarplot["Longitude"] . '), ';
		}
	}	
echo ']; ';
echo '	
  	var rangePlot3 = [
  	';
foreach($polarplots3 as $polarplot) {
	if ($polarplot["Latitude"] && $polarplot["Longitude"]) {
		echo 'new google.maps.LatLng(' . $polarplot["Latitude"] . ', ' . $polarplot["Longitude"] . '), ';
		}
	}	
echo ']; ';
echo '	
  	var rangePlot4 = [
  	';
foreach($polarplots4 as $polarplot) {
	if ($polarplot["Latitude"] && $polarplot["Longitude"]) {
		echo 'new google.maps.LatLng(' . $polarplot["Latitude"] . ', ' . $polarplot["Longitude"] . '), ';
		}
	}	
  	  	
  	
echo '
  ];
rangePolygon1 = new google.maps.Polygon({
    paths: rangePlot1,
    strokeColor: "#FFFFFF",
    strokeOpacity: 0.45,
    strokeWeight: 3,
    fillColor: "#FFFFFF",
    fillOpacity: 0.2
  });
	rangePolygon1.setMap(map);

rangePolygon2 = new google.maps.Polygon({
    paths: rangePlot2,
    strokeColor: "#00FF00",
    strokeOpacity: 0.45,
    strokeWeight: 3,
    fillColor: "#00FF00",
    fillOpacity: 0.2
  });
	rangePolygon2.setMap(map);

rangePolygon3 = new google.maps.Polygon({
    paths: rangePlot3,
    strokeColor: "#0000FF",
    strokeOpacity: 0.45,
    strokeWeight: 3,
    fillColor: "#0000FF",
    fillOpacity: 0.2
  });
	rangePolygon3.setMap(map);
	
rangePolygon4 = new google.maps.Polygon({
    paths: rangePlot4,
    strokeColor: "#FF0000",
    strokeOpacity: 0.45,
    strokeWeight: 3,
    fillColor: "#FF0000",
    fillOpacity: 0.2
  });
	rangePolygon4.setMap(map);

var rangeRings = [92600, 185200, 277800, 370400, 463000, 555600];
var index;
for	(index = 0; index < rangeRings.length; index++) {
    var rangeOptions = {
      strokeColor: "#000000",
      strokeOpacity: 0.8,
      strokeWeight: 1,
      fillOpacity: 0.0,
      map: map,
      center: rangecenter,
      radius: rangeRings[index]
	 };
	 rangeCircle = new google.maps.Circle(rangeOptions);
}


map.controls[google.maps.ControlPosition.LEFT_BOTTOM].push(
  document.getElementById("legend"));

}

google.maps.event.addDomListener(window, "load", initialize);
</script>
</head>
<body>
<section class="container main-content">
<div class="info column"><h1>Receiver Range</h1></div>
<div id="range-map"></div>
</section>
<div id="legend">
<table style="width: 225;">
<tr><th style="width: 25;">Color</th><th style="width: 200; text-align: right;">Altitude</th></tr>
<tr><td style="background-color: white; opacity: 0.4; width: 25;"></td><td style="width: 200; text-align: right;">0 - 9999 ft</td></tr>
<tr><td style="background-color: green; opacity: 0.4; width: 25;"></td><td style="width: 200; text-align: right;">10,000 - 19,999 ft</td></tr>
<tr><td style="background-color: blue; opacity: 0.4; width: 25;"></td><td style="width: 200; text-align: right;">20,000 - 29,999 ft</td></tr>
<tr><td style="background-color: red; opacity: 0.4; width: 25;"></td><td style="width: 200; text-align: right;">30,000+ ft</td></tr>
<tr><td colspan="2" style="text-align: center;"><font size="-1">Range rings are at 50 NM intervals</font></td></tr>
</table>
</div>
</body>
</html>';

?>
