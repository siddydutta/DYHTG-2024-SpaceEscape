import socket
import cv2 
import mediapipe as mp 

server_ip = '127.0.0.1'
server_port = 4242
client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

mp_hands = mp.solutions.hands 
hands = mp_hands.Hands( 
    static_image_mode=False, 
    model_complexity=1, 
    min_detection_confidence=0.75, 
    min_tracking_confidence=0.75, 
    max_num_hands=1) 


def get_hand_position(hand_landmarks, img_width):
    # x-coordinate of the middle finger tip (landmark 12)
    x = hand_landmarks.landmark[12].x * img_width

    center_start = img_width * 0.4
    center_end = img_width * 0.6

    if x < center_start:
        return 'left'
    elif x > center_end:
        return 'right'
    return 'center'


cap = cv2.VideoCapture(0) 
while True: 
    success, img = cap.read() 
    img = cv2.flip(img, 1) 
    imgRGB = cv2.cvtColor(img, cv2.COLOR_BGR2RGB) 
    results = hands.process(imgRGB) 
    if results.multi_hand_landmarks:
        for hand_landmarks in results.multi_hand_landmarks:
            label = get_hand_position(hand_landmarks, img.shape[1])
            if label == 'left':
                client_socket.sendto(b'\x00', (server_ip, server_port))
            elif label == 'right':
                client_socket.sendto(b'\x01', (server_ip, server_port))
            else:
                pass

    # cv2.imshow('Image', img) 
    if cv2.waitKey(1) & 0xff == ord('q'): 
        break

cap.release()
cv2.destroyAllWindows()
