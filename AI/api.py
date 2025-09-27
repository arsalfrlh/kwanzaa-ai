from flask import Flask, request, jsonify
import torch
import random, json
from model import NeuralNet
from train import tokeniz, bag_of_word

# install flask "pip install flask"
# opsinal untuk produktion "pip install flask flask-cors"
# base ulr http://127.0.0.1:5000
# curl -X POST http://127.0.0.1:5000/chat -H "Content-Type: application/json" -d "{"message":"Hello"}"
# running API AI "pyton api.py"

app = Flask(__name__)

device = torch.device('cuda' if torch.cuda.is_available() else "cpu")

with open('intents.json', 'r') as f:
    intents = json.load(f)

FILE = "data.pth"
data = torch.load(FILE)
input_size = data['input_size']
hidden_size = data['hidden_size']
output_size = data["output_size"]
all_words = data["all_words"]
tags = data["tags"]
model_state = data["model_state"]

model = NeuralNet(input_size, hidden_size, output_size).to(device)
model.load_state_dict(model_state)
model.eval()

bot_name = "Kwanzaa AI"

@app.route("/chat", methods=["POST"])
def chat():
    req = request.get_json()
    sentence = req.get("message")

    sentence = tokeniz(sentence)
    X = bag_of_word(sentence, all_words)
    X = torch.from_numpy(X).unsqueeze(0).to(device)

    output = model(X)
    _, predicted = torch.max(output, dim=1)
    probs = torch.softmax(output, dim=1)
    prob = probs[0][predicted.item()]
    tag = tags[predicted.item()]

    if prob.item() > 0.75:
        for intent in intents['intents']:
            if tag == intent['tag']:
                return jsonify({
                    "message": random.choice(intent['responses']),
                    "tag": tag
                })
    return jsonify({"message": "Maaf, saya tidak mengerti.", "tag": None})

if __name__ == "__main__":
    app.run(port=5000)
