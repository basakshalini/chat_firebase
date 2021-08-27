// import 'dart:js';

// import 'dart:html';
import 'package:chat_email_firebase/services/firebase_api.dart';
import 'package:chat_email_firebase/views/send_attachment.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:chat_email_firebase/services/constants.dart';
import 'package:chat_email_firebase/services/database.dart';
import 'package:chat_email_firebase/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class ConversationScreen extends StatefulWidget {
  final String userName;
  final String chatRoomId;
  const ConversationScreen(
      {Key? key, required this.userName, required this.chatRoomId})
      : super(key: key);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController messageController = new TextEditingController();
  //Widget ChatMessageList() {}

  late Stream<QuerySnapshot> chatMessageStream;

  // String convertTimeStampToHumanHour(int timeStamp) {
  //   int now = DateTime.now().hour;
  //   print(now.toString() + "##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
  //   var dateToTimeStamp = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
  //   return DateFormat('HH:mm').format(dateToTimeStamp);
  // }

  Widget buildFuture(context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.hasData) {
      // return Text(
      //   '${snapshot.data!.docs.length}',
      //   style: TextStyle(color: Colors.white),
      // );
      return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            // return Text(
            //   '${snapshot.data!.docs[index].data()}',
            //     style: TextStyle(color: Colors.white),
            //     );
            Map<dynamic, dynamic> mssg =
                snapshot.data!.docs[index].data() as Map;
            DateTime date = DateTime.fromMillisecondsSinceEpoch(mssg["time"]);
            // var formattedDate = DateFormat('h:mma').format(date);
            // final DateTime timeStamp =
            //     DateTime.fromMillisecondsSinceEpoch(mssg["time"]);
            // double date = mssg["time"] / 1000 as double;
            // double formatTime = (((date / 60) / 60) / 24);

            //print(date.hour.toString());
            print(date.hour.toString() + ":" + date.minute.toString());

            return MessageTile(
              message: mssg["messages"],
              isSendByMe: mssg["sendBy"] == Constants.myName,
              time: date.hour.toString() + ":" + date.minute.toString(),
              //time: mssg["time"],

              // time: mssg["time"],
              //var formattedDate = DateFormat('MM/dd, hh:mm a').format(date);
            );
          });
    } else {
      return CircularProgressIndicator();
    }
  }

  Widget ChatMessageList() {
    return StreamBuilder(
      stream: chatMessageStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        //return buildFuture(context, snapshot);
        if (snapshot.hasData) {
          return buildFuture(context, snapshot);
        } else {
          // ignore: prefer_const_constructors
          return Center(child: CircularProgressIndicator());
        }
        // return Text('Hello------', style: TextStyle(color: Colors.white));
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> messagesMap = {
        "messages": messageController.text,
        "sendBy": Constants.myName,
        "time": DateTime.now().millisecondsSinceEpoch
      };
      databaseMethods.addConversationMessages(widget.chatRoomId, messagesMap);
      messageController.text = "";
    }
  }

  @override
  void initState() {
    databaseMethods.getConversationMessages(widget.chatRoomId).then((val) {
      setState(() {
        chatMessageStream = val;
      });
      //print(val + '<--------');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.indigo[900], title: Text(widget.userName)),
      body: Container(
        child: Stack(
          children: [
            ChatMessageList(),
            Container(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.indigo[900],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                      )),
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      Expanded(
                          child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 24),
                        child: TextField(
                            //maxLines: 20,
                            controller: messageController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Type Message...',
                              hintStyle: TextStyle(color: Colors.white),
                              // focusedBorder: UnderlineInputBorder(
                              //     borderSide: BorderSide(color: Colors.white)),
                              // enabledBorder: UnderlineInputBorder(
                              //     borderSide: BorderSide(color: Colors.white))),
                            )),
                      )),
                      SizedBox(
                        width: 50,
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 5, 8, 8),
                        child: Row(children: [
                          GestureDetector(
                            onTap: () {
                              print('I am Pressed in GD=================');
                            },
                            child: Container(
                              child: IconButton(
                                icon: Icon(
                                  Icons.attach_file,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SendAttachment()));
                                  //showModalBottomSheet(
                                  // backgroundColor: Colors.transparent,
                                  // context: context,
                                  // builder: (builder) =>
                                  //     //bottomSheet(context)
                                  //     );
                                  //bottomSheet(context);
                                  // PopupMenuButton(
                                  //     itemBuilder: (context) => [
                                  //           PopupMenuItem(
                                  //             child: Text("First",
                                  //                 style: TextStyle(
                                  //                     color: Colors.white)),
                                  //             value: 1,
                                  //           ),
                                  //           PopupMenuItem(
                                  //             child: Text("Second"),
                                  //             value: 2,
                                  //           )
                                  //         ]);
                                  print('I am Pressed=================');
                                },
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              sendMessage();
                            },
                          ),
                        ]),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool isSendByMe;
  final String time;
  const MessageTile({
    Key? key,
    required this.message,
    required this.isSendByMe,
    required this.time,
    //required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: isSendByMe ? 0 : 24, right: isSendByMe ? 24 : 0),
      margin: EdgeInsets.symmetric(vertical: 10),
      width: MediaQuery.of(context).size.width - 100,
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
            // gradient: LinearGradient(
            //     colors: isSendByMe
            //         ? [const Color(0xff007EF4), const Color(0xff2A75BC)]
            //         : [const Color(0x1AFFFFFF), const Color(0X1AFFFFFF)]),
            color: isSendByMe ? Colors.blue : Colors.teal[400],
            borderRadius: isSendByMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomLeft: Radius.circular(23),
                  )
                : BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomRight: Radius.circular(23),
                  )),
        child: Column(
          children: [
            Text(message, style: TextStyle(color: Colors.white, fontSize: 16)),
            Padding(
              padding: isSendByMe
                  ? const EdgeInsets.only(left: 160)
                  : const EdgeInsets.only(right: 160),
              child: Text(time,
                  // ":" +
                  // time.toString().substring(2, 4),
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.white, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}

Widget bottomSheet(BuildContext context) {
  return Container(
    height: 200,
    width: 159,
    child: Card(
      color: Colors.black,
      margin: EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            RaisedButton(
                color: Colors.indigo[700],
                child: Text(
                  'Select a File',
                  style: TextStyle(color: Colors.white),
                ),
                elevation: 8,
                onPressed: () {
                  //selectFile()
                }),
            SizedBox(height: 15),
            RaisedButton(
                color: Colors.indigo[700],
                child: Text(
                  'Upload File',
                  style: TextStyle(color: Colors.white),
                ),
                elevation: 8,
                onPressed: () {})
          ],
        ),
      ),
    ),
  );
}

Widget iconCreation(IconData icon, Color color, String text) {
  return InkWell(
    onTap: () {},
    child: Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color,
          child: Icon(
            icon,
            size: 29,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 5),
        Text(
          text,
          style: TextStyle(fontSize: 12),
        ),
      ],
    ),
  );
}


//Business Customers