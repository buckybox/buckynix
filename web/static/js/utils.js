const utils = (function() {
  const module = {};

  module.getParameterByName = function(name) {
    const match = RegExp('[?&]' + name + '=([^&]*)').exec(window.location.search);
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

    // check whether notification permissions have already been granted
    else if (Notification.permission === "granted") {
      const notification = new Notification(title, options);
    }

    // we need to ask the user for permission
    else if (Notification.permission !== 'denied') {
      Notification.requestPermission(function (permission) {
        if (permission === "granted") {
          const notification = new Notification(title, options);
        }
      });
    }
  };

  return module;
}());

export default utils
