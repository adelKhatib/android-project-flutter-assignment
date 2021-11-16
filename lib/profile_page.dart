import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hello_me/user_aut_repository.dart';
import 'package:provider/provider.dart';
import 'user_metadata_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final userMetaData = context.watch<UserMetaDataRepository>();
    return ProfilePicture(userMetaData.avatar);
  }
}

class ProfilePicture extends StatefulWidget {
  final String fileName;

  const ProfilePicture(this.fileName, {Key? key}) : super(key: key);

  @override
  _ProfilePictureState createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const defaultAvatarFileName = 'pic.png';

  String? _imageUrl;

  Future<String> _getImageUrl(String name) {
    return _storage.ref('images').child(name).getDownloadURL();
  }

  Future<String> _uploadNewImage(File file, String name) {
    return _storage
        .ref('images')
        .child(name)
        .putFile(file)
        .then((snapshot) => snapshot.ref.getDownloadURL());
  }

  @override
  void initState() {
    super.initState();
    if (widget.fileName != '') {
      _getImageUrl(widget.fileName).then((value) => setState(() {
        _imageUrl = value;
      }));
    } else {
      _getImageUrl(defaultAvatarFileName).then((value) => setState(() {
        _imageUrl = value;
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = context.watch<AuthRepository>();
    final userMetaData = context.watch<UserMetaDataRepository>();
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
      color: Colors.white,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            fit: FlexFit.loose,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: _imageUrl == null
                      ? const SizedBox(
                      width: 60.0,
                      height: 60.0,
                      child: Center(child: CircularProgressIndicator()))
                      : Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(_imageUrl!),
                      radius: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 7,
            fit: FlexFit.loose,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      authRepo.user!.email.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                      softWrap: false,
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: ElevatedButton(
                      onPressed: () async {
                        // Pick an image with the file_picker library
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(type: FileType.image);

                        if (result != null) {
                          File file = File(result.files.single.path!);
                          setState(() {
                            _imageUrl = null;
                          });
                          final name = 'Avatar' +
                              md5
                                  .convert(utf8.encode(authRepo.user!.uid))
                                  .toString();
                          _imageUrl = await _uploadNewImage(file, name);
                          userMetaData.updateAvatar(authRepo.user, name);
                          setState(() {});
                        } else {
                          const snackBar = SnackBar(
                            content: Text('No image selected'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                      child: const Text('Change avatar'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
