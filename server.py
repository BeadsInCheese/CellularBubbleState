import random
import socket
import struct
import threading
import traceback
def handle_client(client_socket, other_client_socket):
    while True:
        try:
            # Receive data from the client
            data = client_socket.recv(4)  # 2 integers = 8 bytes (4 bytes each)
            print(data)
            if not data:
                break

            # Unpack the received data into two integers
            int1 = struct.unpack('i', data)
            print(f"Received integers: {int1}")
            # Receive data from the client
            data = client_socket.recv(4)  # 2 integers = 8 bytes (4 bytes each)
            print(data)
            if not data:
                break

            # Unpack the received data into two integers
            int2 = struct.unpack('i', data)
            print(f"Received integers: {int2}")

            # Send the data to the other client
            other_client_socket.sendall(struct.pack("i",int(int1[0])))
            other_client_socket.sendall(struct.pack("i",int(int2[0])))
        except Exception as e:
            print(traceback.format_exc())
            break

    client_socket.close()
def assign_roles(client1, client2):
    roles = [1, 2]  # 1 for Player 1, 2 for Player 2
    random.shuffle(roles)
    client1.sendall(struct.pack('i', int(roles[0])))
    client2.sendall(struct.pack('i', int(roles[1])))
    print(f"Assigned roles: Player {roles[0]} to Client 1, Player {roles[1]} to Client 2")
def main():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind(("0.0.0.0", 25565))
    server.listen(2)
    print("Server listening on port 4242")

    # Accept two clients
    client1, addr1 = server.accept()
    print(f"Client 1 connected: {addr1}")
    client2, addr2 = server.accept()
    print(f"Client 2 connected: {addr2}")
    assign_roles(client1,client2)
    # Start threads to handle each client
    threading.Thread(target=handle_client, args=(client1, client2)).start()
    threading.Thread(target=handle_client, args=(client2, client1)).start()

if __name__ == "__main__":
    main()
