const functions = require('firebase-functions');

const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

const FIRST_AUTO_MESSAGE = "We Matched This is an auto response, if you want to chat just message here"

var braintree = require("braintree");
var gateway = braintree.connect({
    environment:  braintree.Environment.Sandbox,
    merchantId:   'zf7kdynvtvgz33rv',
    publicKey:    'vy4xxr6v6gdx4w6c',
    privateKey:   'ff0843dafd3accd230808f6827d8a0ba'
});
exports.pay = functions.https.onRequest((request, res) => {
  var nonce = request.body.payment_method_nonce
  var amount = request.body.amount

  gateway.transaction.sale({
    amount: amount,
    paymentMethodNonce: nonce,
    options: {
      submitForSettlement: true,
    }
  }).then(function (result) {
    if (result.success) {
      console.log('Transaction ID: ' + result.transaction.id);
    } else {
      console.error(result.message);
    }
    res.send(result)
  }).catch(function (err) {
    console.error(err);
  });
})


exports.chatChannelMessageCreate = functions.database.ref('/chat_channels/{channel_id}/channel_last_message').onCreate(event => {
    const channel_id = event.params.channel_id;
    
    console.log("created channel", channel_id);

    if(!event.data.val()){                                                                                                   
       console.log('A Notification has been deleted from the database : ', user_id);
    }
                                                                                                   
   return sendMessage(channel_id);
});

exports.chatChannelMessageUpdate = functions.database.ref('/chat_channels/{channel_id}/channel_last_message').onUpdate(event => {
    const channel_id = event.params.channel_id;
    
    console.log("created channel", channel_id);

    if(!event.data.val()){                                                                                                   
       console.log('A Notification has been deleted from the database : ', user_id);
    }
                                                                                                   
   return sendMessage(channel_id);
});

function sendMessage(channel_id){
    
    console.log('notification sending start');
    
    console.log("channel_id: ", channel_id);
    
    return admin.database().ref(`/chat_channels/${channel_id}`).once('value', (snapshot) => {

        var channel = snapshot.val();
        console.log("user: ", channel);

        var last_message = channel.channel_last_message;
        var channel_users =  Object.keys(channel.channel_users);

        channel_users.forEach(function(user_id) {

            if (user_id == last_message.sender_id) return;

            return admin.database().ref(`/user_fcm_tokens/${user_id}`).once('value', (snapshot) => {

                var tokensObject = snapshot.val()

                var tokens = Object.keys(tokensObject);

                tokens.forEach(function(token) {

                    var badge_number = tokensObject[token];

                    badge_number ++;

                    var sender_name = last_message.sender_name;
                    var content = last_message.content;
                    if (content == FIRST_AUTO_MESSAGE) sender_name = "Spankrr";

                    var payload = {
                        notification: {
                            title: "From " + sender_name,
                            body:  content,
                            sound: "default",
                            badge: badge_number.toString()
                        }
                    };

                    admin.database().ref(`/user_fcm_tokens/${user_id}/${token}`).set(badge_number);

                    return admin.messaging().sendToDevice(token, payload)
                    .then(response => {                                                                                
                        console.log('This was the notification Feature');
                    });
                });
            });
        });
    });
}
