const {onDocumentCreated, onDocumentUpdated} =
require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.onConversationCreated = onDocumentCreated(
    {
      region: "asia-southeast2",
      document: "Conversations/{conversationID}",
    },
    (event) => {
      const snapshot = event.data;
      const data = snapshot && snapshot.data();
      const conversationID = event.params.conversationID;

      if (!data || !Array.isArray(data.members)) {
        console.error("Data tidak valid atau members bukan array:", data);
        return null;
      }

      const members = data.members;

      for (let index = 0; index < members.length; index++) {
        const currentUserID = members[index];
        const remainingUserIDs = members.filter((u) => u !== currentUserID);

        remainingUserIDs.forEach((m) => {
          return admin
              .firestore()
              .collection("Users")
              .doc(m)
              .get()
              .then((_doc) => {
                const userData = _doc.data();
                if (!userData) return null;

                return admin
                    .firestore()
                    .collection("Users")
                    .doc(currentUserID)
                    .collection("Conversations")
                    .doc(m)
                    .set({
                      conversationID: conversationID,
                      image: userData.image || null,
                      name: userData.name || null,
                      unseenCount: 0,
                    }, {merge: true});
              })
              .catch((err) => {
                console.error(`Gagal mengambil user ${m}:`, err);
                return null;
              });
        });
      }

      return null;
    },
);

exports.onConversationUpdated = onDocumentUpdated(
    {
      region: "asia-southeast2",
      document: "Conversations/{conversationID}",
    },
    (event) => {
      const snapshot = event.data && event.data.after;
      const data = snapshot && snapshot.data();

      if (!data ||!Array.isArray(data.members)||!Array.isArray(data.messages)) {
        console.error("Data members/messages tidak valid:", data);
        return null;
      }

      const members = data.members;
      const lastMessage = data.messages[data.messages.length - 1];

      if (!lastMessage || !lastMessage.message || !lastMessage.timestamp) {
        console.error("lastMessage tidak lengkap:", lastMessage);
        return null;
      }

      for (let index = 0; index < members.length; index++) {
        const currentUserID = members[index];
        const remainingUserIDs = members.filter((u) => u !== currentUserID);

        remainingUserIDs.forEach((u) => {
          const updateData = {
            lastMessage: lastMessage.message,
            timestamp: lastMessage.timestamp,
            unseenCount: admin.firestore.FieldValue.increment(1),
          };

          if (lastMessage.type) {
            updateData.type = lastMessage.type;
          }

          return admin
              .firestore()
              .collection("Users")
              .doc(currentUserID)
              .collection("Conversations")
              .doc(u)
              .update(updateData)
              .then(() => {
                console.log(`✅ Updated conversation for ${currentUserID} ⇄ 
                  ${u}`);
              })
              .catch((err) => {
                console.error(`❌ Gagal update ${currentUserID} ⇄ ${u}:`, err);
                return null;
              });
        });
      }

      return null;
    },
);
