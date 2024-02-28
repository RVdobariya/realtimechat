import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:realtimechat/main.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DatabaseReference dbRef;
  TextEditingController name = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  ImagePicker iii = ImagePicker();

  Future<void> getImage() async {}

  @override
  void initState() {
    dbRef = FirebaseDatabase.instance.ref().child("chat").child("ravi-ravi2");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(getStorage.read("token")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: FirebaseAnimatedList(
                  sort: (DataSnapshot a, DataSnapshot b) {
                    if (a.value != null && b.value != null) {
                      DateTime ats = DateTime.parse((a.value as Map<dynamic, dynamic>)['timestamp']).toLocal();
                      DateTime bts = DateTime.parse((b.value as Map<dynamic, dynamic>)['timestamp']).toLocal();
                      return ats.isBefore(bts) ? 1 : 0;
                    }
                    return 0;
                  },
                  reverse: true,
                  query: dbRef,
                  itemBuilder: (context, snapShot, animation, index) {
                    var data = snapShot.value as Map;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 5),
                      child: Row(
                        mainAxisAlignment: data['user'] == getStorage.read("token") ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          Flexible(
                              child: Padding(
                            padding: data['user'] == getStorage.read("token")
                                ? const EdgeInsets.only(left: 40.0, top: 5, bottom: 5)
                                : const EdgeInsets.only(right: 40.0, top: 5, bottom: 5),
                            child: Container(
                              height: data['type'] == "video" || data['type'] == "image"
                                  ? 200
                                  : data['type'] == "pdf"
                                      ? 80
                                      : null,
                              decoration: BoxDecoration(
                                color: data['user'] == getStorage.read("token") ? Colors.deepPurple.withOpacity(0.5) : Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.only(
                                    bottomRight: const Radius.circular(12),
                                    bottomLeft: const Radius.circular(12),
                                    topLeft: data['user'] == getStorage.read("token") ? const Radius.circular(12) : const Radius.circular(0),
                                    topRight: data['user'] != getStorage.read("token") ? const Radius.circular(12) : const Radius.circular(0)),
                              ),
                              child: Padding(
                                padding: data['type'] == "text" || data['type'] == "pdf" ? const EdgeInsets.all(8.0) : EdgeInsets.zero,
                                child: data['type'] == "text"
                                    ? Text(data['message'])
                                    : data['type'] != "text" && data['type'] != "pdf"
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.only(
                                                bottomRight: const Radius.circular(12),
                                                bottomLeft: const Radius.circular(12),
                                                topLeft: data['user'] == getStorage.read("token") ? const Radius.circular(12) : const Radius.circular(0),
                                                topRight: data['user'] != getStorage.read("token") ? const Radius.circular(12) : const Radius.circular(0)),
                                            child: Image.network(data['message']))
                                        : Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              color: data['user'] == getStorage.read("token")
                                                  ? Colors.deepPurpleAccent.withOpacity(0.3)
                                                  : Colors.black.withOpacity(0.3),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Text("${data['name']}"),
                                                  Spacer(),
                                                  const Icon(
                                                    Icons.download_for_offline_outlined,
                                                    size: 35,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                              ),
                            ),
                          ))
                        ],
                      ),
                    );
                  }),
            ),
            TextField(
              focusNode: _focusNode,
              controller: name,
              decoration: InputDecoration(
                  suffixIcon: GestureDetector(
                    onTap: () async {
                      String messageId = dbRef.push().key!;
                      var data = {
                        "message": name.text,
                        "type": "text",
                        "user": "${getStorage.read("token")}",
                        "timestamp": DateTime.now().toString(),
                      };

                      name.clear();
                      await dbRef.child(messageId).set(data);
                    },
                    child: const Icon(Icons.send),
                  ),
                  prefixIcon: GestureDetector(
                      onTap: () async {
                        _focusNode.unfocus();
                        showModalBottomSheet(
                            constraints: const BoxConstraints(minHeight: 100, maxHeight: 100),
                            context: context,
                            builder: (_) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      XFile? image = await iii.pickVideo(source: ImageSource.gallery);
                                      if (image != null) {
                                        Navigator.pop(context);
                                        Reference reference = FirebaseStorage.instance.ref().child('chatImage/${image.name}');
                                        UploadTask uploadTask = reference.putFile(File(image.path));
                                        TaskSnapshot snapshot = await uploadTask;
                                        String imageUrl = await snapshot.ref.getDownloadURL();
                                        if (imageUrl != "") {
                                          var data = {
                                            "message": imageUrl,
                                            "type": "video",
                                            "user": "${getStorage.read("token")}",
                                            "timestamp": DateTime.now().toString(),
                                          };
                                          name.clear();
                                          await dbRef.push().set(data);
                                        }
                                      } else {
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Icon(
                                      Icons.video_file,
                                      size: 50,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      XFile? image = await iii.pickImage(source: ImageSource.gallery);
                                      if (image != null) {
                                        Navigator.pop(context);
                                        Reference reference = FirebaseStorage.instance.ref().child('chatImage/${image.name}');
                                        UploadTask uploadTask = reference.putFile(File(image.path));
                                        TaskSnapshot snapshot = await uploadTask;
                                        uploadTask.snapshotEvents.listen((event) {
                                          double percentage = 100 * (event.bytesTransferred.toDouble());
                                          debugPrint("THe percentage $percentage");
                                        });

                                        String imageUrl = await snapshot.ref.getDownloadURL();
                                        if (imageUrl != "") {
                                          var data = {
                                            "message": imageUrl,
                                            "type": "image",
                                            "user": "${getStorage.read("token")}",
                                            "timestamp": DateTime.now().toString(),
                                          };
                                          name.clear();
                                          await dbRef.push().set(data);
                                        }
                                      } else {
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Icon(
                                      Icons.image,
                                      size: 50,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      XFile? image = await iii.pickMedia();
                                      if (image != null) {
                                        Navigator.pop(context);
                                        Reference reference = FirebaseStorage.instance.ref().child('chatImage/${image.name}');
                                        UploadTask uploadTask = reference.putFile(File(image.path));
                                        TaskSnapshot snapshot = await uploadTask;
                                        uploadTask.snapshotEvents.listen((event) {
                                          double percentage = 100 * (event.bytesTransferred.toDouble());
                                          debugPrint("THe percentage $percentage");
                                        });

                                        String imageUrl = await snapshot.ref.getDownloadURL();
                                        if (imageUrl != "") {
                                          var data = {
                                            "message": imageUrl,
                                            "type": "pdf",
                                            "name": image.name,
                                            "user": "${getStorage.read("token")}",
                                            "timestamp": DateTime.now().toString(),
                                          };
                                          name.clear();
                                          await dbRef.push().set(data);
                                        }
                                      } else {
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Icon(
                                      Icons.picture_as_pdf,
                                      size: 50,
                                    ),
                                  )
                                ],
                              );
                            });
                      },
                      child: const Icon(Icons.add_circle)),
                  hintText: "Type Something"),
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  sendFile({bool video = false, bool imageFile = false}) async {
    ImagePicker iii = ImagePicker();
    XFile? image;
    if (video == true) {
      image = await iii.pickMedia();
    } else if (imageFile == true) {
      image = await iii.pickImage(source: ImageSource.gallery);
    }

    if (image != null) {
      Reference reference = FirebaseStorage.instance.ref().child('chatImage/${image.name}');
      UploadTask uploadTask = reference.putFile(File(image.path));

      uploadTask.snapshotEvents.listen((event) {
        double percentage = 100 * (event.bytesTransferred.toDouble());
        debugPrint("THe percentage $percentage");
      });
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();
      if (imageUrl != "" && imageFile == true) {
        var data = {
          "message": imageUrl,
          "type": "image",
          "user": "${getStorage.read("token")}",
          "timestamp": DateTime.now().toString(),
        };
        name.clear();
        await dbRef.push().set(data);
      } else {
        var data = {
          "message": imageUrl,
          "type": "video",
          "user": "${getStorage.read("token")}",
          "timestamp": DateTime.now().toString(),
        };
        name.clear();
        await dbRef.push().set(data);
      }
    } else {
      Navigator.pop(context);
    }
  }
}
