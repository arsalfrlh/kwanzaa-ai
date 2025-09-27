<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Kwanzaa AI Chat</title>
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
  <style>
    body {
      background: #f0f2f5;
    }
    .chat-card {
      margin-top: 50px;
      border-radius: 15px;
      overflow: hidden;
      box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    }
    .chat-header {
      background: linear-gradient(45deg, #007bff, #00c6ff);
      color: #fff;
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 12px 20px;
      font-weight: bold;
    }
    .chat-body {
      height: 400px;
      overflow-y: auto;
      padding: 20px;
      background: #ffffff;
    }
    .message {
      padding: 10px 15px;
      border-radius: 20px;
      margin-bottom: 10px;
      max-width: 70%;
      word-wrap: break-word;
    }
    .message.user {
      background: #007bff;
      color: #fff;
      margin-left: auto;
      text-align: right;
    }
    .message.bot {
      background: #e9ecef;
      color: #000;
      margin-right: auto;
      text-align: left;
    }
    .chat-footer {
      background: #f8f9fa;
      padding: 15px;
      border-top: 1px solid #dee2e6;
    }
    .btn-send {
      border-radius: 50px;
      padding: 8px 20px;
    }
    .logout-btn {
      background: #dc3545;
      border: none;
      padding: 4px 12px;
      border-radius: 20px;
      color: #fff;
      font-size: 0.85rem;
      transition: 0.3s;
    }
    .logout-btn:hover {
      background: #c82333;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="card chat-card">
      <div class="chat-header">
        <span>Kwanzaa AI</span>
        <div class="d-flex align-items-center">
          <span class="mr-3">{{ Auth::user()->name }}</span>
          <a href="/logout" class="btn btn-danger" class="m-0 p-0">Logout</a>
        </div>
      </div>
      <div class="chat-body">
        @foreach ($data as $message)
          @if ($message->role == "user")
            <div class="message user">{{ $message->message }}</div>
          @else
            <div class="message bot">{{ $message->message }}</div>
          @endif
        @endforeach
      </div>
      <div class="chat-footer">
        <form action="/message/send" method="POST" class="d-flex">
          @csrf
          <input type="text" class="form-control mr-2" placeholder="Enter Message..." name="message" required>
          <button type="submit" class="btn btn-primary btn-send">Kirim</button>
        </form>
      </div>
    </div>
  </div>

  @if ($pesan = Session::get('success'))
    <script>
      Swal.fire({
        title: "{{ $pesan }}",
        icon: "success",
        confirmButtonColor: "#007bff"
      });
    </script>
  @endif

  @if ($pesan = Session::get('error'))
    <script>
      Swal.fire({
        title: "{{ $pesan }}",
        icon: "error",
        confirmButtonColor: "#dc3545"
      });
    </script>
  @endif
</body>
</html>
