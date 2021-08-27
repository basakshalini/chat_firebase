import 'package:chat_email_firebase/helper/helper_functions.dart';
import 'package:chat_email_firebase/services/constants.dart';
import 'package:chat_email_firebase/services/database.dart';
import 'package:chat_email_firebase/views/conversation_screen.dart';
import 'package:chat_email_firebase/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

//late String _myName;

class _SearchScreenState extends State<SearchScreen> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController searchEditingController = new TextEditingController();

  late QuerySnapshot searchSnapshot;

  Widget searchList() {
    return searchSnapshot != null
        ? ListView.builder(
            itemCount: searchSnapshot.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return SearchTile(
                  userName: (searchSnapshot.docs[index].data() as Map)["name"],
                  userEmail:
                      (searchSnapshot.docs[index].data() as Map)["email"]);
            })
        : Container();
  }

  initiateSearch() {
    databaseMethods.getUserByUsername(searchEditingController.text).then((val) {
      // print(val.toString());
      setState(() {
        searchSnapshot = val;
      });
    });
  }

  createChatroomAndStartConvo({required String userName}) {
    print("${Constants.myName}");
    if (userName != Constants.myName) {
      String chatRoomID = getChatRoomid(userName, Constants.myName);
      List<String> users = [userName, Constants.myName];
      Map<String, dynamic> chatroomMap = {
        "users": users,
        "chatroomId": chatRoomID,
      };
      DatabaseMethods().createChatRoom(chatRoomID, chatroomMap);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ConversationScreen(userName: userName, chatRoomId: chatRoomID,)));
    } else {
      print("you cannot send message to yourself");
    }
  }

  Widget SearchTile({required String userName, required String userEmail}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: TextStyle(color: Colors.white),
              ),
              Text(
                userEmail,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              createChatroomAndStartConvo(userName: userName);
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(30)),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Message'),
            ),
          )
        ],
      ),
    );
  }

  getChatRoomid(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}


  @override
  void initState() {
    initiateSearch();
    // getUserInfo();
    super.initState();
  }

  // getUserInfo() async {
  //   _myName = await HelperFunction.getUserNameSharedPreference() as String;
  //   setState(() {
      
  //   });
    
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        toolbarHeight: 80,
        title: appBar(context, 'Search', 'Screen'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        brightness: Brightness.light,
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(children: [
          Row(
            children: [
              Expanded(
                  child: TextField(
                controller: searchEditingController,
                style: TextStyle(color: Colors.white),
                decoration: textFieldInputDecoration('Search Here...'),
              )),
              SizedBox(
                width: 50,
              ),
              GestureDetector(
                onTap: () {
                  initiateSearch();
                },
                child: Container(
                  height: 40,
                  width: 40,
                  padding: EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/images/search_white.png',
                    color: Colors.white,
                    height: 30,
                    width: 20,
                  ),
                ),
              ),
            ],
          ),
          searchList(),
        ]),
      ),
    );
  }
}

