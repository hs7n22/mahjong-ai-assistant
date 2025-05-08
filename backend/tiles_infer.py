from ultralytics import YOLO
from typing import List


# 加载训练好的模型
model = YOLO("../runs/detect/train8/best.pt")
names = model.names  # 类别编号对应的标签字典


def predict_hand_tiles(image_path: str) -> List[str]:
    # 进行推理
    results = model(image_path)
    # 提取结果
    detections = results[0].boxes.data  # tensor: [x1,y1,x2,y2,conf,cls]
    # 将检测结果按 xmin 坐标排序（横向排列）
    detections_sorted = sorted(detections.tolist(), key=lambda x: x[0])  # x[0]是 xmin
    # 提取结构化牌型列表
    hand_tiles = [names[int(d[5])] for d in detections_sorted]
    return hand_tiles
