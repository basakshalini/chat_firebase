import 'package:chat_email_firebase/helper/helper_functions.dart';
import 'package:chat_email_firebase/services/firebase_api.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:chat_email_firebase/helper/helper_functions.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chat_email_firebase/services/constants.dart';
import 'package:chat_email_firebase/services/database.dart';
import 'package:chat_email_firebase/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class SendAttachment extends StatefulWidget {
  const SendAttachment({Key? key}) : super(key: key);

  @override
  _SendAttachmentState createState() => _SendAttachmentState();
}

class _SendAttachmentState extends State<SendAttachment> {
  File? file;
  UploadTask? task;
  bool isFileUpload = false;
  bool isFileUploaded = false;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.single.path!;
    isFileUpload = true;
    setState(() => file = File(path));
  }

  Future uploadFile() async {
    if (file == null) return;

    final fileName = basename(file!.path);
    final destination = 'files/$fileName';

    task = FirebaseApi.uploadFile(destination, file!);

    setState(() {});

    if (task == null) return;
    isFileUploaded = true;
    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    print('Download-Link: $urlDownload');
  }

  //HelperFunction.getFileUrlPreference();

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);

            // if (percentage == 100.00) {
            //   setState(() {
            //     isFileUploaded = true;
            //   });
            //}
            return Center(
              child: Text(
                '$percentage %',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            );
          } else {
            return Container();
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    final fileName = file != null ? basename(file!.path) : 'No File Selected';
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Center(child: appBar(context, 'Send', 'Attachment')),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        brightness: Brightness.light,
      ),
      body: Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Image.asset('assets/images/send_att.png'),
            SizedBox(height: 35),
            Row(
              children: [
                RaisedButton(
                    color: isFileUpload ? Colors.greenAccent[400] : Colors.blue,
                    child: Text(
                      isFileUpload ? '1 File Selected' : 'Select a File',
                      style: TextStyle(
                          color: isFileUpload ? Colors.black : Colors.white),
                    ),
                    elevation: 8,
                    onPressed: () {
                      selectFile();
                    }),
                SizedBox(width: 30),
                Text(
                  fileName,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 17),
            Center(
              child: Text(
                isFileUpload ? 'Upload Your selected file here : ' : '',
                style: TextStyle(color: Colors.white),
              ),
            ),
            RaisedButton(
                color: isFileUploaded ? Colors.greenAccent[400] : Colors.blue,
                child: Text(
                  isFileUploaded ? 'File Uploaded Succesfully' : 'Upload File',
                  style: TextStyle(
                      color: isFileUploaded ? Colors.black : Colors.white),
                ),
                elevation: 8,
                onPressed: () {
                  uploadFile();
                }),
            SizedBox(height: 95),
            task != null ? buildUploadStatus(task!) : Container(),
          ],
        ),
      ),
    );
  }
}
