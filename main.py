import socket
import cv2 
import mediapipe as mp 
from google.protobuf.json_format import MessageToDict 

server_ip = '127.0.0.1'
server_port = 4242
client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# from: https://www.geeksforgeeks.org/right-and-left-hand-detection-using-python/
mp_hands = mp.solutions.hands 
hands = mp_hands.Hands( 
    static_image_mode=False, 
    model_complexity=1, 
    min_detection_confidence=0.75, 
    min_tracking_confidence=0.75, 
    max_num_hands=2) 

cap = cv2.VideoCapture(0) 
while True: 
    success, img = cap.read() 
    img = cv2.flip(img, 1) 
    imgRGB = cv2.cvtColor(img, cv2.COLOR_BGR2RGB) 
    results = hands.process(imgRGB) 
    if results.multi_hand_landmarks: 
        if len(results.multi_handedness) != 2: 
            for i in results.multi_handedness: 
                label = MessageToDict(i)['classification'][0]['label']
                if label == 'Left': 
                    client_socket.sendto(b'\x00', (server_ip, server_port))
                if label == 'Right':
                    client_socket.sendto(b'\x01', (server_ip, server_port))
    # cv2.imshow('Image', img) 
    if cv2.waitKey(1) & 0xff == ord('q'): 
        break
cap.release()
cv2.destroyAllWindows()
