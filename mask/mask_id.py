#!/usr/bin/env python3
import sys
import cv2
import numpy as np
import pytesseract
from pathlib import Path
TESSERACT_CONFIG = r'--oem 3 --psm 6'
IMG_EXTS = {'.jpg', '.jpeg', '.png', '.bmp', '.tiff'}
BLUE_LOWER = np.array([90, 50, 50])
BLUE_UPPER = np.array([130, 255, 255])
def pixelate_region(img, x, y, w, h, scale=0.1):
    if x < 0: x = 0
    if y < 0: y = 0
    if x + w > img.shape[1]: w = img.shape[1] - x
    if y + h > img.shape[0]: h = img.shape[0] - y
    if w <= 0 or h <= 0:
        return
    roi = img[y:y+h, x:x+w]
    if roi.size == 0 or roi.shape[0] == 0 or roi.shape[1] == 0:
        return
    try:
        small = cv2.resize(roi, None, fx=scale, fy=scale, interpolation=cv2.INTER_LINEAR)
        pixelated = cv2.resize(small, (w, h), interpolation=cv2.INTER_NEAREST)
        img[y:y+h, x:x+w] = pixelated
    except cv2.error:
        blurred = cv2.GaussianBlur(roi, (23, 23), 0)
        img[y:y+h, x:x+w] = blurred
def is_blue_text(img, x, y, w, h):
    if x < 0 or y < 0 or x + w > img.shape[1] or y + h > img.shape[0]:
        return False
    roi = img[y:y+h, x:x+w]
    hsv = cv2.cvtColor(roi, cv2.COLOR_BGR2HSV)
    mask = cv2.inRange(hsv, BLUE_LOWER, BLUE_UPPER)
    blue_ratio = np.count_nonzero(mask) / (w * h)
    return blue_ratio > 0.1
def is_label_text(text):
    labels = ["姓名", "性别", "民族", "出生", "住址", "公民身份号码"]
    return any(label in text for label in labels)
def process_image(src_path: Path, dst_path: Path):
    img = cv2.imread(str(src_path))
    if img is None:
        print(f"⚠️  Unable to read: {src_path}")
        return
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    _, thresh = cv2.threshold(gray, 150, 255, cv2.THRESH_BINARY)
    data = pytesseract.image_to_data(
        thresh,
        config=TESSERACT_CONFIG,
        output_type=pytesseract.Output.DICT
    )
    n_boxes = len(data['level'])
    masked_count = 0
    for i in range(n_boxes):
        text = data['text'][i].strip()
        if not text:
            continue
        x, y = data['left'][i], data['top'][i]
        w, h = data['width'][i], data['height'][i]
        # skip blue text or label keywords
        if is_blue_text(img, x, y, w, h) or is_label_text(text):
            continue
        pixelate_region(img, x, y, w, h)
        print(f"🔒 Masked content: `{text}` at {x, y, w, h}")
        masked_count += 1
    cv2.imwrite(str(dst_path), img)
    status = f"→ Done (masked {masked_count} regions)" if masked_count > 0 else "→ No content masked"
    print(f"{status}: {src_path} → {dst_path}")
def main():
    if len(sys.argv) != 2:
        print("Usage: python mask_id.py <image_path>")
        sys.exit(1)
    src_path = Path(sys.argv[1])
    if not src_path.exists() or src_path.suffix.lower() not in IMG_EXTS:
        print("Error: File not found or unsupported image extension.")
        sys.exit(1)
    # create output filename by appending "_mask" before the extension
    dst_path = src_path.with_name(src_path.stem + "_mask" + src_path.suffix)
    process_image(src_path, dst_path)
if __name__ == '__main__':
    main()
