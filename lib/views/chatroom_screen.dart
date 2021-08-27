import 'package:chat_email_firebase/helper/authenticate.dart';
import 'package:chat_email_firebase/helper/helper_functions.dart';
import 'package:chat_email_firebase/services/auth.dart';
import 'package:chat_email_firebase/services/constants.dart';
import 'package:chat_email_firebase/services/database.dart';
import 'package:chat_email_firebase/views/conversation_screen.dart';
import 'package:chat_email_firebase/views/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chat_email_firebase/views/signin.dart';
import 'package:chat_email_firebase/widgets/widget.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({Key? key}) : super(key: key);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databasemethods = new DatabaseMethods();

  Stream<QuerySnapshot> chatRoomStreams = const Stream.empty();

  Widget buildFuture(context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.hasData) {
      // return Text(
      //   "${snapshot.data!.docs[index].data()}",
      //   style: TextStyle(color: Colors.white),
      // );
      return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            // return Text(
            //   "${snapshot.data!.docs[index].data()}",
            //   style: TextStyle(color: Colors.white),
            // );
            return ChatRoomsTile(
              userName:
                  (snapshot.data!.docs[index].data() as Map)["chatroomId"]
                  .toString()
                  .replaceAll("_", "")
                  .replaceAll(Constants.myName, ""),
              chatRoomId:
                  (snapshot.data!.docs[index].data() as Map)["chatroomId"],
            );
          });
    } else {
      return CircularProgressIndicator();
    }
  }

  Widget ChatRoomList() {
    return StreamBuilder(
      stream: chatRoomStreams,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return buildFuture(context, snapshot);
        } else {
          return Center(child: CircularProgressIndicator());
        }
        // return Text('Hello------', style: TextStyle(color: Colors.white));
      },
    );
  }

  @override
  void initState() {
    getUserInfo();
    print("-----------------------------");

    super.initState();
  }


  getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Constants.myName = prefs.getString("USERNAMEKEY")!;
    //Constants.myName = (await HelperFunction.getUserNameSharedPreference())!;
    setState(() {});
    print("-----------------${Constants.myName}");
    print("########" + Constants.myName);
    databasemethods.getChatRooms(Constants.myName).then((val) {
      setState(() {
        chatRoomStreams = val;
      });
      print("~~~~~~~~~~~~" + val);
    });

    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          title: Center(child: appBar(context, 'CHAT', 'ROOM')),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          brightness: Brightness.light,
          actions: [
            GestureDetector(
              onTap: () {
                authMethods.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Authenticate()));
              },
              child: Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.exit_to_app)),
            ),
          ],
        ),
        body: ChatRoomList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SearchScreen()));
          },
          child: Icon(Icons.search),
        ));
  }
}

class ChatRoomsTile extends StatelessWidget {
  final String userName;
  final String chatRoomId;
  const ChatRoomsTile(
      {Key? key, required this.userName, required this.chatRoomId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ConversationScreen(
                    userName: userName, chatRoomId: chatRoomId)));
      },
      child: Container(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.indigo[900],
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Center(
                    child: Text("${userName.substring(0, 1).toUpperCase()}",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Text(userName,
                    style: TextStyle(color: Colors.white, fontSize: 18))
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(70, 0, 28, 0),
              child: Divider(color: Colors.white, thickness: 0.8, height: 10),
            )
          ],
        ),
      ),
    );
  }
}
