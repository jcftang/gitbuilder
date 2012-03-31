$.ajaxSetup({
	async: true,
});


$(document).ready(function(){
	urls.sort();
	for(var i in urls){
		setupRow(urls[i], i);
		summarizeUrls(urls[i], i);
	}
});
	
	
function summarizeUrls(link, i){
	if (typeof serverUrl !== 'undefined') {
		$.getJSON(serverUrl + "?url=" + link + "&callback=?", function(d){
			var d = d.html;
			fillCell(link, d, i);
			checkStatus();
		});
	} else {
		$.get(link,function(d){
			//summaryRow(link, d);
			fillCell(link, d, i);
			checkStatus();
		});
	}
}


function setupRow(link, i) {
	var url = "<a class='normalLink' href='" + link + "'>" + link + "</a>";
	var row = "<tr><td>" + url + "</td><td><div class='most_recent'><div id='num" + i + "'>...loading...</div></div></td></tr>";
	$("#links tbody").append(row);
}


function fillCell(link, d, i) {
	var mostrecent = $(d).filter("#most_recent").html().replace("Most Recent:","").replace(/<a href="#/g,'<a href="' + link + '#');
	var numX = "#num" + i;
	$(numX).html(mostrecent);
}


function checkStatus(){
	$("span").each(function(index) {
		if($(this).hasClass("status-err")){
			$(this).parent().addClass("label label-important")
		}
		if($(this).hasClass("status-ok")){
			$(this).parent().addClass("label label-success")
		}
		if($(this).hasClass("status-warn")){
			$(this).parent().addClass("label label-warning")
		}
			if($(this).hasClass("status-pending")){
			$(this).parent().addClass("label")
		}
	});
}
