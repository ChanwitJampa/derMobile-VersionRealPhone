
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../env.dart';


enum LoginStatus { success, unauthorized, no_internet_connection,service_unavailable }

extension ParseToString on LoginStatus {
  String toShortString() {
    return this.toString().split('.').last;
  }
}

class LoginService{

  static late String token = "";

  Future<dynamic> attemptLogIn (String url,String username,String password) async {

    BaseOptions baseOp = new BaseOptions(
      baseUrl: url,
      connectTimeout: 5000
    );

    Dio _dio = Dio(baseOp);

    var params =  {
      "username": username,
      "password": password,
    };

    try{
      Response<String> response  = await _dio.post(url,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }
        ),
        data: jsonEncode(params),
      );
      return response ;
    }on DioError catch(e){
      if(e.type == DioErrorType.connectTimeout){

        return http.Response('Error', 408);
      }
    }
    return http.Response('Service unavaiable', 500);
  }

  Future<dynamic>  attemptSSOLogIn (String url,String username,String token) async {

    BaseOptions baseOp = new BaseOptions(
        baseUrl: url,
        connectTimeout: 5000
    );

    Dio _dio = Dio(baseOp);

    var params =  {
      "username": username,
      "token": token,
    };

    try{
      Response<String> response  = await _dio.post(url,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }
        ),
        data: jsonEncode(params),
      );
      return response ;
    }on DioError catch(e){
      if(e.type == DioErrorType.connectTimeout){

        return http.Response('Error', 408);
      }
    }
    return http.Response('Unauthorized', 401);
  }

}
