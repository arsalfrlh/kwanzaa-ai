<?php

namespace App\Http\Controllers;

use App\Models\Chat;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Validator;

class ChatApiController extends Controller
{
    public function index(Request $request){
        $user = $request->user();
        $data = Chat::with(['user'])->where('id_user',$user->id)->get();
        return response()->json(['message' => "Menampilkan hasil percakapan", 'success' => true, 'data' => $data]);
    }

    public function create(Request $request){
        $validator = Validator::make($request->all(),[
            'message' => 'required',
        ]);

        if($validator->fails()){
            return response()->json(['message' => $validator->errors()->all(), 'success' => false]);
        }

        $user = $request->user();
        $message = $request->message;
        try{
            $response = Http::post("http://127.0.0.1:5000/chat",[
                'message' => $message,
            ]);

            $json = $response->json();
            if($response->successful()){
                Chat::create([
                    'id_user' => $user->id,
                    'role' => "user",
                    'message' => $message,
                ]);

                Chat::create([
                    'id_user' => $user->id,
                    'role' => "bot",
                    'message' => $json['message'],
                    'tag' => $json['tag'],
                ]);
                
                $data = Chat::with(['user'])->where('id_user',$user->id)->get();
                return response()->json(['message' => 'Menampilkan hasil respon', 'success' => true, 'data' => $data]);
            }else{
                return response()->json(['message' => $json, 'success' => false]);
            }
        }catch(Exception $e){
            return response()->json(['message' => $e->getMessage(), 'success' => false]);
        }
    }
}
