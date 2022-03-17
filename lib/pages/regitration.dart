import 'dart:io';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:register_demo/models/profile.dart';
import 'package:image_picker/image_picker.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final CollectionReference _profilesCollection =
      FirebaseFirestore.instance.collection('profilesCollection');

  final FirebaseStorage _storage = FirebaseStorage.instance;

  final _formKey = GlobalKey<FormState>();
  final Profile _profile = Profile();

  final ImagePicker _picker = ImagePicker();
  File? _selectedImageFile;

  getImage() async {
    final selectedFile = await _picker.getImage(source: ImageSource.camera);
    print(selectedFile?.path);

    setState(() {
      _selectedImageFile = File(selectedFile!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ลงทะเบียน')),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              //แก้ bottom overflow
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ชื่อ'),
                  TextFormField(
                    validator: RequiredValidator(errorText: 'กรุณากรอกชื่อ'),
                    onSaved: (String? firstName) {
                      _profile.firstName = firstName;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text('นามสกุล'),
                  TextFormField(
                    validator: RequiredValidator(errorText: 'กรุณากรอกนามสกุล'),
                    onSaved: (String? lastName) {
                      _profile.lastName = lastName;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text('Email'),
                  TextFormField(
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'กรุณากรอกอีเมล'),
                      EmailValidator(errorText: 'กรุณากรอกอีเมลที่ถูกต้อง'),
                    ]),
                    onSaved: (String? email) {
                      _profile.email = email;
                    },
                    keyboardType:
                        TextInputType.emailAddress, //เครื่องหมาย@ในkeybord
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text('รูปถ่าย'),
                  Container(
                    padding: const EdgeInsets.all(10),
                    //space camera
                    child: Ink(
                      color: Colors.grey[300],
                      child: InkWell(
                        onTap: () {
                          print('Open camera');
                          getImage();
                        },
                        child: _selectedImageFile != null
                            // Take camera
                            ? Image.file(_selectedImageFile!)
                            //not yet take camera
                            : Container(
                                height: 150,
                                child:
                                    const Center(child: Icon(Icons.camera_alt)),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        print('ลงทะเบียน');

                        //ดักข้อมูล ไม่ผ่านจะไม่เข้าsave
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          print(
                              '${_profile.firstName} ${_profile.lastName} ${_profile.email}');

                          showDialog(
                              context: context,
                              barrierDismissible:
                                  false, //user can not cancel uploading
                              builder: (BuildContext context) {
                                return Dialog(
                                  child: Container(
                                    padding: const EdgeInsets.all(15),
                                    child: Row(children: const [
                                      CircularProgressIndicator(),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text('กำลังบันทึกข้อมูล')
                                    ]),
                                  ),
                                );
                              });

                          //upload image to storage
                          if (_selectedImageFile != null) {
                            String fileName =
                                basename(_selectedImageFile!.path);
                            _storage
                                .ref()
                                .child('images/register/$fileName')
                                .putFile(_selectedImageFile!);
                          }

                          await _profilesCollection.add({
                            'first_name': _profile.firstName,
                            'lastName_name': _profile.lastName,
                            'email': _profile.email,
                            'imageRef': basename(_selectedImageFile!.path)
                          });

                          Navigator.pop(context);

                          _formKey.currentState!.reset();
                          setState(() {
                            _selectedImageFile = null;
                          });
                        }
                      },
                      child: const Text('ลงทะเบียน'),
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
