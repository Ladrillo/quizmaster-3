$(document).ready(function () {
	$('div.gabri-button').mouseenter(function () {
        $('div.gabri-button').fadeTo('fast', 0.65);
    });
    $('div.gabri-button').mouseleave(function () {
        $('div.gabri-button').fadeTo('fast', 1);
    });
})