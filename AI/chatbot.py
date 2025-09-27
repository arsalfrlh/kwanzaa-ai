import random
import json
import torch
from model import NeuralNet
from train import tokeniz, bag_of_word

device = torch.device('cuda' if torch.cuda.is_available() else "cpu")

with open('intents.json', 'r') as f:
    intents = json.load(f)

FILE = "data.pth" #memuat file data.pth
data = torch.load(FILE)

input_size = data['input_size']
hidden_size = data['hidden_size']
output_size = data["output_size"]
all_words = data["all_words"]
tags = data["tags"]
model_state = data["model_state"]

model = NeuralNet(input_size, hidden_size, output_size).to(device) #memanggil class NeuralNet di file model.py
model.load_state_dict(model_state)
model.eval()

bot_name = "Kwanzaa AI"
print("Mulai Mengobrol dengan AI (ketik 'quit' untuk keluar)")

while True:
    setence = input("Anda: ")
    if setence.lower() == 'quit':
        break

    setence = tokeniz(setence)
    X = bag_of_word(setence, all_words)
    X = torch.from_numpy(X).unsqueeze(0).to(device)

    output = model(X)
    _, predicted = torch.max(output, dim=1)
    
    
    tag = tags[predicted.item()]
    probs = torch.softmax(output, dim=1)
    prob = probs[0][predicted.item()]

    if prob.item() > 0.75:
        for intent in intents['intents']:
            if tag == intent['tag']:
                print(f"{bot_name}: {random.choice(intent['responses'])}")
    else:
        print(f"{bot_name}: Maaf, saya tidak mengerti.")