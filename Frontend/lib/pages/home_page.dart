import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:chatbot/models/chat.dart';
import 'package:chatbot/pages/login_page.dart';
import 'package:chatbot/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();
  final messageController = TextEditingController();
  List<Chat> messageList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchMessage();
  }

  Future<void> fetchMessage()async{
    setState(() {
      isLoading = true;
    });
    messageList = await apiService.getAllMessage();
    setState(() {
      isLoading = false;
    });
  }

  void _sendMessage(BuildContext context)async{
    if(messageController.text.isNotEmpty){
      showDialog(
        context: context, 
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(),));

      final response = await apiService.sendMessage(messageController.text);
      Navigator.of(context, rootNavigator: true).pop();

      if(response['success'] == true){
        setState(() {
          messageController.text = "";
        });
        await fetchMessage();
      }else{
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: "Error",
          desc: response['message'].toString(),
          btnOkOnPress: (){},
          btnOkColor: Colors.red,
        ).show();
      }
    }
  }

  void logout(BuildContext context){
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: "Logout",
      desc: "Apakah Anda Yakin ingin Logout",
      btnOkOnPress: ()async{
        await apiService.logout();
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      btnOkColor: Colors.orange,
      btnCancelOnPress: (){},
      btnCancelColor: Colors.green,
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xFF00BF6D),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            BackButton(
              onPressed: () => logout(context),
            ),
            CircleAvatar(
              backgroundImage:
                  NetworkImage("https://avatars.githubusercontent.com/u/144583426?v=4"),
            ),
            SizedBox(width: 16.0 * 0.75),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Kwanzaa AI",
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  "Active Now",
                  style: TextStyle(fontSize: 12),
                )
              ],
            )
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_phone),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {},
          ),
          const SizedBox(width: 16.0 / 2),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchMessage,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messageList.length,
                itemBuilder: (context, index) => Pesan(
                  chat: messageList[index],
                  ))
            ),
            ChatInputField(
            message: messageController,
            sendMessage: () => _sendMessage(context),),
          ],
        ),
      )
    );
  }
}

class ChatInputField extends StatefulWidget {
  final TextEditingController message;
  final VoidCallback sendMessage;
  ChatInputField({required this.message, required this.sendMessage});

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 16.0 / 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -4),
            blurRadius: 32,
            color: const Color(0xFF087949).withOpacity(0.08),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.mic, color: Color(0xFF00BF6D)),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Row(
                    children: [
                      const SizedBox(width: 16.0 / 4),
                      Expanded(
                        child: TextField(
                          controller: widget.message,
                          decoration: InputDecoration(
                            hintText: "Type message",
                            suffixIcon: SizedBox(
                              width: 65,
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: widget.sendMessage,
                                    child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0 / 2),
                                    child: Icon(
                                      Icons.send,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color!
                                          .withOpacity(0.64),
                                    ),
                                  ),
                                  )
                                ],
                              ),
                            ),
                            filled: true,
                            fillColor:
                                const Color(0xFF00BF6D).withOpacity(0.08),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0 * 1.5, vertical: 16.0),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class Pesan extends StatelessWidget {
  final Chat chat;
  Pesan({required this.chat});

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('HH:mm').format(chat.createAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Align(
        alignment: chat.role == "user"
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7, // max 70% lebar layar
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0 * 0.75,
              vertical: 16.0 / 2,
            ),
            decoration: BoxDecoration(
              color: chat.role == "user"
                  ? Color(0xFF00BF6D)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end, // waktu di kanan bawah
              children: [
                Text(
                  chat.message,
                  style: TextStyle(
                    color: chat.role == "user"
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 10,
                    color: chat.role == "user"
                        ? Colors.white70
                        : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
