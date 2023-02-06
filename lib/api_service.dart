import 'package:http/http.dart'as http;
class ApiService{
   static const String ApiKey="KDbeUggJNrUgmi2NMzTDrmkv";
   static var baseUrl=Uri.parse("https://api.remove.bg/v1.0/removebg");

   static removeBg(String imagepath)async{
     print("api hit");
     var req= http.MultipartRequest("POST",baseUrl);
      req.headers.addAll({"X-API-key": ApiKey});
      req.files.add(await http.MultipartFile.fromPath('image_file', imagepath));
      final res=await req.send();

      if(res.statusCode==200)
        {
          http.Response img=await http.Response.fromStream(res);
          print("Response${img.body}");
          return img.bodyBytes;
        }else
          {
            return null;
          }
   }
}