// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery-1.6.2.min

$.fn.CallStateUpdater = function () {
  var call_state = $(this);
  var getState = function () {
    var url = document.location.pathname;

    $.getJSON(url, function(data) {
      if (data.display_state != undefined) {
        call_state.text(data.display_state);
      }
      setTimeout(getState, 1000);
    });
  }

  getState();
  return $(this);
}

$(document).ready(function() {
  $("#call-state").CallStateUpdater();
});