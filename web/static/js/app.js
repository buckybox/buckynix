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

import socket from "./socket"

import utils from "./utils"

// Set up our Elm App
const elmCustomersDiv = document.querySelector('#elm-customers');
if (elmCustomersDiv) {
  const app = Elm.App.embed(elmCustomersDiv);

  // Prefill search bar with URL query part
  var filter = utils.getParameterByName("query") || "";
  app.ports.jsEvents.send(["CustomerList.Search", filter]);

  // Hook {Ctrl,Cmd}+F to our search bar
  $(window).on('keydown', function(e) {
    if ((e.ctrlKey || e.metaKey) && (String.fromCharCode(e.which).toLowerCase() === 'f')) {
      e.preventDefault();
      $("input.search:first").get(0).select();
    }
  });

  // Fetch more results when we scroll to the bottom
  $(window).scroll(function() {
    if($(window).scrollTop() + $(window).height() == $(document).height()) {
      app.ports.jsEvents.send(["CustomerList.Fetch"]);
    }
  });
}

socket.connect()

let channel = socket.channel("notification:42", {})

channel.on("broadcast_notification", payload => {
  utils.notify(payload.body)
})

channel.join()
  .receive("ok", resp => { console.info("Joined successfully") })
  .receive("error", resp => { console.error("Unable to join", resp) })

// channel.push("new_msg", {body: "READY"})
channel.push("fetch_notification")
