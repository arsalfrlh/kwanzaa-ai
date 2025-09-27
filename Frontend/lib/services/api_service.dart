import 'dart:convert';

import 'package:chatbot/models/chat.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = "http://10.0.2.2:8000/api";

  Future<Map<String, dynamic>> login(String email, String password)async{
    try{
      final response = await http.post(Uri.parse("$baseUrl/login"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "email": email,
        "password": password,
      }));

      if(response.statusCode == 200){
        return json.decode(response.body);
      }else{
        return{
          "success": false,
          "message": json.decode(response.body),
        };
      }
    }catch(e){
      return{
        "success": false,
        "message": e,
      };
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password)async{
    try{
      final response = await http.post(Uri.parse("$baseUrl/register"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "name": name,
        "email": email,
        "password": password,
      }));

      if(response.statusCode == 200){
        return json.decode(response.body);
      }else{
        return{
          "success": false,
          "message": json.decode(response.body),
        };
      }
    }catch(e){
      return{
        "success": false,
        "message": e,
      };
    }
  }

  Future<void> logout()async{
    final key = await SharedPreferences.getInstance();
    final token = key.getString("token");

    try{
      await http.post(Uri.parse("$baseUrl/logout"),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token"
      });
      final key = await SharedPreferences.getInstance();
      await key.remove("token");
      await key.remove("statusLogin");
    }catch(e){
      throw Exception(e);
    }
  }

  Future<List<Chat>> getAllMessage()async{
    final key = await SharedPreferences.getInstance();
    final token = key.getString("token");

    try{
      final response = await http.get(Uri.parse("$baseUrl/message"),
      headers: {
        "Authorization": "Bearer $token"
      });

      if(response.statusCode == 200){
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((item) => Chat.fromJson(item)).toList();
      }else{
        throw Exception(json.decode(response.body));
      }
    }catch(e){
      throw Exception(e);
    }
  }

  Future<Map<String, dynamic>> sendMessage(String message)async{
    final key = await SharedPreferences.getInstance();
    final token = key.getString('token');

    try{
      final response = await http.post(Uri.parse("$baseUrl/message/send"),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token"
      },
      body: json.encode({
        "message": message,
      }));

      if(response.statusCode == 200){
        return json.decode(response.body);
      }else{
        return{
          "success": false,
          "message": json.decode(response.body),
        };
      }
    }catch(e){
      return{
        "success": false,
        "message": e,
      };
    }
  }
}
