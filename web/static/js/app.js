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

import utils from "./utils"

// Set up our Elm App(s)
const elmUserListAppDiv = document.querySelector('#elm-user-list-app');
if (elmUserListAppDiv) {
  const elmUserListApp = Elm.UserListApp.embed(elmUserListAppDiv);

  // Prefill search bar with URL query part
  const filter = utils.getParameterByName("filter") || "";
  elmUserListApp.ports.jsEvents.send(["UserList.Search", filter]);

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
      app.ports.jsEvents.send(["UserList.Fetch"]);
    }
  });
}

const elmUserTransactionListApp = document.querySelector('#elm-user-transaction-list-app');
if (elmUserTransactionListApp) {
  Elm.UserTransactionListApp.embed(elmUserTransactionListApp, {userId: "123"});
}

const elmDeliveryListAppDiv = document.querySelector('#elm-delivery-list-app');
if (elmDeliveryListAppDiv) {
  const elmDeliveryListApp = Elm.DeliveryListApp.embed(elmDeliveryListAppDiv)

  const today = new Date().toISOString().split("T")[0];
  const from = utils.getParameterByName("filter\\[from\\]") || today;
  const to = utils.getParameterByName("filter\\[to\\]") || today;
  elmDeliveryListApp.ports.jsEvents.send(["DeliveryList.Fetch", from, to]);
}

// Set up channels / web sockets
import socket from "./socket"

socket.connect()

const channel = socket.channel("notification:42", {})

channel.on("push_notification", payload => {
  utils.notify(payload.body)

  const notificationCount = $("#notification-count")
  if (notificationCount) {
    notificationCount.html(payload.count)
  }
})

channel.join()
  .receive("ok", resp => { console.info("Joined successfully") })
  .receive("error", resp => { console.error("Unable to join", resp) })

// channel.push("new_msg", {body: "READY"})
