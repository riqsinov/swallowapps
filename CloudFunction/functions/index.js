const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp(functions.config().firebase);

exports.pushNotification = functions.database.ref("DHT11/Data")
    .onUpdate((evt) => {
      const options = {priority: "high", timeToLive: 60*60*24};
      let userTokens = [];
      admin.database().ref("DHT11/users").once("value")
          .then((snapshot) => {
            // console.log(snapshot.val());
            userTokens = Object.keys(snapshot.val());
            console.log(userTokens);
          });

      return admin.database().ref("DHT11/Data")
          .limitToLast(1)
          .once("value")
          .then((temperature) => {
            const data = temperature.val();
            if (data[Object.keys(data)].Temperature>31) {
              const hotPayload = {
                notification: {
                  title: "Temperature and Humidity is Out of Range",
                  body: "Please go back to the Building ",
                  click_action: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                  data1: "Data Value",
                },
              };
              return admin.messaging()
                  .sendToDevice(userTokens, hotPayload, options);
            } else if (data[Object.keys(data)].Temperature<26) {
              const coldPayload = {
                notification: {
                  title: "Temperature and Humidity is Out of Range",
                  body: "Please go back to the Building ",
                  click_action: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                  data1: "Data Value",
                },
              };
              return admin.messaging()
                  .sendToDevice(userTokens, coldPayload, options);
            } else if (data[Object.keys(data)].Humidity<80) {
              const coldPayload = {
                notification: {
                  title: "Temperature and Humidity is Out of Range",
                  body: "Please go back to the Building ",
                  click_action: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                  data1: "Data Value",
                },
              };
              return admin.messaging()
                  .sendToDevice(userTokens, coldPayload, options);
            } else if (data[Object.keys(data)].Humidity>90) {
              const hotPayload = {
                notification: {
                  title: "Temperature and Humidity is Out of Range",
                  body: "Please go back to the Building ",
                  click_action: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                  data1: "Data Value",
                },
              };
              return admin.messaging()
                  .sendToDevice(userTokens, hotPayload, options);
            }
          });
    });
