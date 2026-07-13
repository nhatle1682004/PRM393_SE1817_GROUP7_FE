import os
from typing import Any

import cv2
import numpy as np
import torch
import torch.nn as nn
from fastapi import FastAPI, File, HTTPException, UploadFile


class CNN(nn.Module):
    def __init__(self, num_classes: int):
        super().__init__()
        self.features = nn.Sequential(
            nn.Conv2d(3, 16, 3, padding=1), nn.BatchNorm2d(16), nn.ReLU(), nn.MaxPool2d(2, 2),
            nn.Conv2d(16, 32, 3, padding=1), nn.BatchNorm2d(32), nn.ReLU(), nn.MaxPool2d(2, 2),
            nn.Conv2d(32, 64, 3, padding=1), nn.BatchNorm2d(64), nn.ReLU(), nn.MaxPool2d(2, 2),
            nn.Conv2d(64, 128, 3, padding=1), nn.BatchNorm2d(128), nn.ReLU(), nn.MaxPool2d(2, 2),
            nn.Conv2d(128, 256, 3, padding=1), nn.BatchNorm2d(256), nn.ReLU(), nn.MaxPool2d(2, 2),
            nn.Conv2d(256, 512, 3, padding=1), nn.BatchNorm2d(512), nn.ReLU(), nn.MaxPool2d(2, 2),
        )
        self.classifier = nn.Sequential(
            nn.Flatten(),
            nn.Linear(512 * 3 * 3, 512),
            nn.ReLU(),
            nn.Dropout(0.5),
            nn.Linear(512, num_classes),
        )

    def forward(self, x):
        x = self.features(x)
        return self.classifier(x)


class WastePredictor:
    def __init__(self, model_path: str):
        if not os.path.exists(model_path):
            raise FileNotFoundError(f"Model file not found: {model_path}")

        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        checkpoint = torch.load(model_path, map_location=self.device)
        self.class_names = checkpoint["class_names"]
        self.model = CNN(num_classes=len(self.class_names))
        self.model.load_state_dict(checkpoint["model_state_dict"])
        self.model.to(self.device)
        self.model.eval()

    def preprocess(self, image: np.ndarray) -> torch.Tensor:
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        image = cv2.resize(image, (224, 224))
        image = image.astype(np.float32) / 255.0
        mean = np.array([0.485, 0.456, 0.406], dtype=np.float32)
        std = np.array([0.229, 0.224, 0.225], dtype=np.float32)
        image = (image - mean) / std
        image = np.transpose(image, (2, 0, 1))
        return torch.from_numpy(image).unsqueeze(0).float().to(self.device)

    def predict(self, image: np.ndarray) -> dict[str, Any]:
        tensor = self.preprocess(image)
        with torch.no_grad():
            output = self.model(tensor)
            probabilities = torch.nn.functional.softmax(output, dim=1)[0]
            confidence, index = torch.max(probabilities, dim=0)
            top_count = min(3, len(self.class_names))
            top_confidences, top_indexes = torch.topk(probabilities, k=top_count)

        return {
            "label": self.class_names[index.item()],
            "confidence": float(confidence.item()),
            "topPredictions": [
                {
                    "label": self.class_names[top_indexes[i].item()],
                    "confidence": float(top_confidences[i].item()),
                }
                for i in range(top_count)
            ],
        }


model_path = os.getenv("MODEL_PATH", "saved_models/best_model.pth")
predictor = WastePredictor(model_path)
app = FastAPI(title="Waste Classification AI")


@app.get("/health")
def health():
    return {
        "status": "ok",
        "modelPath": model_path,
        "classes": predictor.class_names,
    }


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    data = await file.read()
    buffer = np.frombuffer(data, np.uint8)
    image = cv2.imdecode(buffer, cv2.IMREAD_COLOR)
    if image is None:
        raise HTTPException(status_code=400, detail="Invalid image file")

    return predictor.predict(image)
