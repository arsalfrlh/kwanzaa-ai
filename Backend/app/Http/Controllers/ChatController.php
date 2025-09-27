<?php

namespace App\Http\Controllers;

use App\Models\Chat;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Http;

class ChatController extends Controller
{
    public function index(){
        $data = Chat::with('user')->where('id_user', Auth::user()->id)->get();
        return view('main.index', ['data' => $data]);
    }

    public function sendMessage(Request $request){
        $request->validate([
            'message' => 'required',
        ]);

        $message = $request->message;
        try{
            $response = Http::post("http://127.0.0.1:5000/chat",[
                'message' => $message,
            ]);

            $json = $response->json();
            if($response->successful()){
                Chat::create([
                    'id_user' => Auth::user()->id,
                    'role' => "user",
                    'message' => $message,
                ]);

                Chat::create([
                    'id_user' => Auth::user()->id,
                    'role' => "bot",
                    'message' => $json['message'],
                    'tag' => $json['tag']
                ]);

                return redirect()->back();
            }else{
                return redirect()->back()->with("error",$json);
            }
        }catch(Exception $e){
            return redirect()->back()->with('error', $e->getMessage());
        }
    }
}
