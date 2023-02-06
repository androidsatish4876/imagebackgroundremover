import 'dart:io';

import 'package:before_after/before_after.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imagebackgroundremover/api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScreenshotController screenshotController=ScreenshotController();
  var loaded=false;
  var imagepick=false;
  var removeImg=false;
  var isLoading=false;
  Uint8List? image;
  String imagepath="";
  pickImage()async{
    var file=await ImagePicker().pickImage(source: ImageSource.gallery,imageQuality: 100);
    if(file !=null)
      {
        imagepath=file.path;

        loaded=true;
        setState(() {
        });

      }else
        {}
  }
  dowloadImage()async{
    var per=await Permission.storage.request();


    var foldername="BgRemover";
    var filename="${DateTime.now().microsecondsSinceEpoch}.png";
    if(per.isGranted)
      {
        // final directory=new Directory('storage/emulated/0/${foldername}/');
        //
        // if(await directory.exists())
        //   {
        //     await directory.create(recursive: true).then((value) =>print('value  === ${value}'));
        //   }
        String dic= await getDownloadPath();
       //
       //  await screenshotController.captureAndSave(dic,delay: Duration(milliseconds:100 ),fileName: filename,pixelRatio: 512);
       //  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Download To ${dic}")));
        Directory? directory;
        try {
          if (Platform.isIOS) {
            directory = await getApplicationDocumentsDirectory();
          } else {
            directory = Directory('/storage/emulated/0/Download');
            // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
            // ignore: avoid_slow_async_io
            if (!await directory.exists()) directory = await getExternalStorageDirectory();
          }
        } catch (err, stack) {
          print("Cannot get download folder path");
        }
        _saveImage(image!, directory!, filename);


      }else
        {

        }
  }

  void _saveImage(Uint8List uint8List, Directory dir, String fileName,
      ) async {
    bool isDirExist = await Directory(dir.path).exists();
    if (!isDirExist) Directory(dir.path).create();
    String tempPath = '${dir.path}/$fileName';
    File image = File(tempPath);
    bool isExist = await image.exists();
    if (isExist) await image.delete();
    File(tempPath).writeAsBytes(uint8List).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Download To ${value}")));
    });
  }
  Future<String> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) directory = await getExternalStorageDirectory();
      }
    } catch (err, stack) {
      print("Cannot get download folder path");
    }
    return directory!.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.sort_rounded,color: Colors.white,),
          title: Text("Background Remover",style: TextStyle(color: Colors.white,fontSize: 16),),
          actions: [
            InkWell(
              onTap: (){
                dowloadImage();
              },
              child: Icon(Icons.download),
            )
          ],
        ),
      body: Center(
        child:removeImg? BeforeAfter(beforeImage: Image.file(File(imagepath)),
          afterImage:Screenshot(child: Image.memory(image!), controller: screenshotController),):loaded?
            GestureDetector(
                onTap: (){
                  pickImage();
                },
                child: Image.file(File(imagepath))):
        Container(

          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed:(){
                pickImage();
              },
              child: Text("Remove Background",style: TextStyle(color: Colors.white,fontSize: 14),),
            ),
          ),
        ) ,
      ),
      bottomNavigationBar: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed:loaded?()async{
            setState(() {
                        isLoading=true;
            });

            image= await ApiService.removeBg(imagepath);
           if(image !=null)
             {
               print("back${image}");
               removeImg=true;
               isLoading=false;
               setState(() {

               });
             }
          }:null,
          child: isLoading?CircularProgressIndicator(
            valueColor : AlwaysStoppedAnimation(Colors.white),

          ) :Text("Remove Background",style: TextStyle(color: Colors.white,fontSize: 14),),
        ),
      ),
    );
  }



}
