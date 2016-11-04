// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

// Set up our Elm App
const elmCustomersDiv = document.querySelector('#elm-customers');
if (elmCustomersDiv) {
  const app = Elm.App.embed(elmCustomersDiv);

  $("#search_query").on('input', function() {
    var query = $(this).val();
    app.ports.jsEvents.send(["CustomerList.Search", query]);
  });

  $(window).scroll(function() {
    if($(window).scrollTop() + $(window).height() == $(document).height()) {
      app.ports.jsEvents.send(["CustomerList.Fetch"]);
    }
  });
}
