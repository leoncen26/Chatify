//import 'package:chatify_app/services/navigation_service.dart';
import 'dart:async';

import 'package:chatify_app/models/conversation.dart';
import 'package:chatify_app/models/message.dart';
import 'package:chatify_app/providers/auth_provider.dart';
import 'package:chatify_app/services/cloud_storage_service.dart';
import 'package:chatify_app/services/database_service.dart';
import 'package:chatify_app/services/media_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationPage extends StatefulWidget {
  final String conversationID;
  final String receiverID;
  final String receiverImage;
  final String receiverName;

  ConversationPage(this.conversationID, this.receiverID, this.receiverImage,
      this.receiverName,
      {super.key});

  @override
  State<StatefulWidget> createState() {
    return _ConversationPageState();
  }
}

class _ConversationPageState extends State<ConversationPage> {
  double? _deviceHeight, _deviceWidth;
  AuthProvider? _auth;

  GlobalKey<FormState>? _formKey;
  String? messageText;
  ScrollController? listViewController;

  _ConversationPageState() {
    _formKey = GlobalKey<FormState>();
    listViewController = ScrollController();
    messageText = '';
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(31, 31, 31, 1.0),
        // leading: IconButton(
        //   onPressed: NavigationService.instance.goBack,
        //   icon: const Icon(
        //     Icons.arrow_back_ios_new,
        //   ),
        // ),
        title: Text(widget.receiverName),
        centerTitle: true,
      ),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _conversationPageUI(),
      ),
    );
  }

  Widget _conversationPageUI() {
    return Builder(builder: (BuildContext context) {
      _auth = Provider.of<AuthProvider>(context);
      return Stack(
        clipBehavior: Clip.none,
        children: [
          _messageListView(),
          Align(
            alignment: Alignment.bottomCenter,
            child: _messageField(context),
          )
        ],
      );
    });
  }

  Widget _messageListView() {
    return Container(
      height: _deviceHeight! * 0.75,
      width: _deviceWidth,
      child: StreamBuilder<Conversation>(
        stream:
            DatabaseService.instance.getConversations(widget.conversationID),
        builder: (BuildContext context, AsyncSnapshot<Conversation> snapshot) {
          Timer(
            const Duration(milliseconds: 50),
            () {
              listViewController!
                  .jumpTo(listViewController!.position.maxScrollExtent);
            },
          );
          var conversationData = snapshot.data;
          if (conversationData != null) {
            if (conversationData.messages.isNotEmpty) {
              return ListView.builder(
                controller: listViewController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 20,
                ),
                itemCount: conversationData.messages.length,
                itemBuilder: (BuildContext context, int index) {
                  var message = conversationData.messages[index];
                  bool isOwnMessage = message.senderID == _auth!.user!.uid;
                  return _messageListViewChild(isOwnMessage, message);
                },
              );
            } else {
              return const Align(
                alignment: Alignment.center,
                child: Text('Lets Start a conversation'),
              );
            }
          } else {
            return const SpinKitWanderingCubes(
              color: Colors.blue,
              size: 50.0,
            );
          }
        },
      ),
    );
  }

  Widget _messageListViewChild(bool isOwnMessage, Message message) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment:
              isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            !isOwnMessage ? _userImage() : Container(),
            SizedBox(
              width: _deviceWidth! * 0.02,
            ),
            message.type == MessageType.Text
                ? _textMessageBubble(
                    isOwnMessage,
                    message.content,
                    message.timestamp,
                  )
                : _imageMessageBubble(
                    isOwnMessage,
                    message.content,
                    message.timestamp,
                  ),
          ],
        ));
  }

  Widget _userImage() {
    double imageRadius = _deviceHeight! * 0.05;
    return Container(
      height: imageRadius,
      width: imageRadius,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(500),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(
            widget.receiverImage,
          ),
        ),
      ),
    );
  }

  Widget _textMessageBubble(
      bool isOwnMessage, String message, Timestamp timestamp) {
    List<Color> colorSheme = isOwnMessage
        ? const [Colors.blue, Color.fromRGBO(42, 117, 188, 1.0)]
        : const [
            Color.fromRGBO(69, 69, 69, 1.0),
            Color.fromRGBO(43, 43, 43, 1.0)
          ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: _deviceHeight! * 0.08 + (message.length / 20 * 5.0),
      width: _deviceWidth! * 0.75,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colorSheme,
          stops: const [0.30, 0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          Text(
            timeago.format(timestamp.toDate()),
            style: const TextStyle(
              color: Colors.white70,
            ),
          )
        ],
      ),
    );
  }

  Widget _imageMessageBubble(
      bool isOwnMessage, String imageURL, Timestamp timestamp) {
    List<Color> colorSheme = isOwnMessage
        ? const [Colors.blue, Color.fromRGBO(42, 117, 188, 1.0)]
        : const [
            Color.fromRGBO(69, 69, 69, 1.0),
            Color.fromRGBO(43, 43, 43, 1.0)
          ];
    DecorationImage imageUrl =
        DecorationImage(fit: BoxFit.cover, image: NetworkImage(imageURL));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      // height: _deviceHeight! * 0.08 + (imageURL.length / 20 * 5.0),
      // width: _deviceWidth! * 0.75,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colorSheme,
          stops: const [0.30, 0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: _deviceHeight! * 0.30,
            width: _deviceWidth! * 0.40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: imageUrl,
            ),
          ),
          Text(
            timeago.format(timestamp.toDate()),
            style: const TextStyle(
              color: Colors.white70,
            ),
          )
        ],
      ),
    );
  }

  Widget _messageField(BuildContext context) {
    return Container(
      height: _deviceHeight! * 0.08,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(43, 43, 43, 1.0),
        borderRadius: BorderRadius.circular(100),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: _deviceWidth! * 0.04,
        vertical: _deviceHeight! * 0.03,
      ),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _messageTextField(),
            _sendMessageButton(context),
            _imageMessageButton(),
          ],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _deviceWidth! * 0.55,
      child: TextFormField(
        validator: (input) {
          if (input!.isEmpty) {
            return 'Please enter a message';
          } else {
            return null;
          }
        },
        onChanged: (input) {
          _formKey!.currentState!.save();
        },
        onSaved: (input) {
          setState(() {
            messageText = input;
          });
        },
        cursorColor: Colors.white,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Type A Message',
        ),
        autocorrect: false,
      ),
    );
  }

  Widget _sendMessageButton(BuildContext context) {
    return Container(
      height: _deviceHeight! * 0.05,
      width: _deviceHeight! * 0.05,
      child: IconButton(
        onPressed: () {
          if (_formKey!.currentState!.validate()) {
            DatabaseService.instance.sendMessage(
              widget.conversationID,
              Message(
                content: messageText!,
                timestamp: Timestamp.now(),
                senderID: _auth!.user!.uid,
                type: MessageType.Text,
              ),
            );
            _formKey!.currentState!.reset();
            FocusScope.of(context).unfocus();
          }
        },
        icon: const Icon(
          Icons.send,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _imageMessageButton() {
    return Container(
      height: _deviceHeight! * 0.05,
      width: _deviceHeight! * 0.05,
      child: FloatingActionButton(
        onPressed: () async {
          var image = await MediaService.instance.getImage();
          if (image != null) {
            var result = await CloudStorageService.instance
                .uploadMediaMessage(_auth!.user!.uid, image);
            var imageUrl = await result.ref.getDownloadURL();
            await DatabaseService.instance.sendMessage(
              widget.conversationID,
              Message(
                senderID: _auth!.user!.uid,
                content: imageUrl,
                timestamp: Timestamp.now(),
                type: MessageType.Image,
              ),
            );
          }
        },
        child: Icon(
          Icons.camera_enhance,
        ),
      ),
    );
  }
}
