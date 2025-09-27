import json
import torch
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader
import nltk
import numpy as np
from nltk.stem.porter import PorterStemmer
from model import NeuralNet #nama file "model.py" dan class Neuralnet

#buat env sendiri python "-m venv myenv"
#jalankan env sendiri "myenv\Scripts\activate"
#install pytorch "pip install torch torchvision torchaudio"
#install nltk "pip install torch torchvision nltk | pip install nltk"
#install sklearn "pip install scikit-learn"

nltk.download('punkt')
stemmer = PorterStemmer()

def tokeniz(sentence):
    return nltk.word_tokenize(sentence) #kalimat menjadi kata → "Hello, how are you?" → ["Hello", "how", "are", "you"]

def stem(word):
    return stemmer.stem(word.lower()) #ubah kata ke bentuk dasar → "running" → "run"

def bag_of_word(tokenize_setence, word):
    sentence_word = [stem(w) for w in tokenize_setence] #dlm list| memanggil function stem| perulangan tokeniz_setence(parameter)
    bag = np.zeros(len(word), dtype=np.float32) #len panjang index dlm list word
    for idx, w in enumerate(word):
        if w in sentence_word:
            bag[idx] = 1
    return bag
    
with open('intents.json', 'r') as f: #file intents.json di simpan ke variabel f
    intents = json.load(f) #intents berisi file intent.json

all_words = []
tags = []
xy = []

for intent in intents['intents']: #perulangan di variabel intents(json) dlm array key list "intents"
    tag = intent['tag'] #tag ini menyimpan array key tags
    tags.append(tag) #menambahkan semua tags dri json ke dlm variabel list tags
    for pattern in intent['patterns']: #perulangan di variabel list intents dlm array key list "patterns"
        w = tokeniz(pattern) #memangil function tokeniz| parameter berisi list dlm json array key list (patterns)
        all_words.extend(w)
        xy.append((w, tag)) #menambakan list ke xy| w kata2 yg di pecah(json)| tag judul dari percakapan (json)

inogre_word = ['?','!','.',','] #list
all_words = [stem(w) for w in all_words if w not in inogre_word] #list all_word| memanggil function stem berisi w yg sudah di kata2nya di pecah| perulangan dari list all_words| dan dilakukannya jika w tidak ada list inogre_word
all_words = sorted(set(all_words))

X_train = []
y_train = []

for (pattern_setence, tag) in xy: #xy adlah list xy.append((w, tag))
    bag = bag_of_word(pattern_setence, all_words) #memanggil function bag_of_word dan variabel bagnya menyimpan nilai hasil return| berisi parameter hasil dari perulangan(pattern_setence)| dan parameter all_word
    X_train.append(bag) #menambahkan data berisi variabel bag kdlm list
    y_train.append(tags.index(tag))

X_train = np.array(X_train)
y_train = np.array(y_train)

class ChatDataset(Dataset):
    def __init__(self):
        self.n_samples = len(X_train) #variabel n_samples berisi panjang list dari X_train
        self.x_data = X_train
        self.y_train = y_train

    def __getitem__(self, index):
        return self.x_data[index], self.y_train[index]
    
    def __len__(self):
        return self.n_samples
    
batch_size = 8
hidden_size = 8
output_size = len(tags) #variabel output_size berisi panjang list dari tags
input_size = len(all_words) #variabel input_size berisi panjang list dari all_words
learning_rate = 0.001
num_epochs = 500

dataset = ChatDataset() #variabel dataset menyimpan class ChatDataset
train_loader = DataLoader(dataset=dataset, batch_size=batch_size, shuffle=True)

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model = NeuralNet(input_size, hidden_size, output_size).to(device) #memanngil class yg ada di model.py

criterion = nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)

for epoch in range(num_epochs):
    for (words, labels) in train_loader: #perulangan yg hasilnya tuple dan di simpan ke 2 variabel
        words = words.to(device)
        labels = labels.to(dtype=torch.long).to(device)

        outputs = model(words)
        loss = criterion(outputs, labels)

        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

    if(epoch+1) % 100 == 0:
        print(f'Epoch [{epoch+1}/{num_epochs}], Loss: {loss.item():.4f}')


print("Training Selesai")

data = { #membuat data set| json
    "model_state": model.state_dict(),
    "input_size": input_size,
    "hidden_size": hidden_size,
    "output_size": output_size,
    "all_words": all_words,
    "tags": tags
}

FILE = "data.pth"
torch.save(data, FILE)
print(f"Model di simpan ke {FILE}")