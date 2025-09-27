class Chat{
    final int id;
    final int userID;
    final String role;
    final String message;
    final String name;
    final DateTime createAt;

    Chat({required this.id, required this.userID, required this.role, required this.message, required this.name, required this.createAt});
    factory Chat.fromJson(Map<String, dynamic> json){
      return Chat(
        id: json['id'],
        userID: json['id_user'],
        role: json['role'],
        message: json['message'],
        name: json['user']['name'],
        createAt: DateTime.parse(json['created_at'])
      );
    }
}