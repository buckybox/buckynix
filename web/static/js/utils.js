var utils = (function() {
  var module = {};

  module.getParameterByName = function(name) {
    var match = RegExp('[?&]' + name + '=([^&]*)').exec(window.location.search);
    return match && decodeURIComponent(match[1].replace(/\+/g, ' '));
  };

  module.notify = function(message) {
    const title = "Bucky Nix",
          options = {
            body: message
          };

    if (!("Notification" in window)) {
      console.error("This browser does not support system notifications");
    }

    // Let's check whether notification permissions have already been granted
    else if (Notification.permission === "granted") {
      var notification = new Notification(title, options);
    }

    // Otherwise, we need to ask the user for permission
    else if (Notification.permission !== 'denied') {
      Notification.requestPermission(function (permission) {
        if (permission === "granted") {
          var notification = new Notification(title, options);
        }
      });
    }
  };

  return module;
}());

export default utils;
