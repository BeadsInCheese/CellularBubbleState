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
                print("connection issue disconnecting")
                client_socket.close()
                other_client_socket.close()
                break

            # Unpack the received data into two integers
            int1 = struct.unpack('i', data)
            print(f"Received integers: {int1}")
            # Receive data from the client
            data = client_socket.recv(4)  # 2 integers = 8 bytes (4 bytes each)
            print("data: "+str(data))
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
            print("connection issue disconnecting")
            client_socket.close()
            other_client_socket.close()
            break

    client_socket.close()
def assign_roles(client1, client2):
    roles = [1, 2]  # 1 for Player 1, 2 for Player 2
    random.shuffle(roles)
    client1.sendall(struct.pack('i', int(roles[0])))
    client2.sendall(struct.pack('i', int(roles[1])))
    print(f"Assigned roles: Player {roles[0]} to Client 1, Player {roles[1]} to Client 2")
lobbys={}

def handleRequest(client_socket):
    print("recieving key")
    data = client_socket.recv(5)
    key=data.decode('utf-8')
    print(f"Received: lobby key "+key)
    if(key in lobbys.keys()):
        client_socket.sendall(struct.pack('i', 1))
        lobbys[key].sendall(struct.pack('i', 1))
        assign_roles(client_socket, lobbys[key])
        threading.Thread(target=handle_client, args=(client_socket, lobbys[key])).start()
        threading.Thread(target=handle_client, args=( lobbys[key],client_socket)).start()
        lobbys.pop(key, None)
    else:
        lobbys[key]=client_socket
        
def main():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind(("0.0.0.0", 25565))
    server.listen(2)
    print("Server listening on port 25565")


    while True:

        # Accept two clients
        client1, addr1 = server.accept()
        print(f"Client: {addr1}")
        threading.Thread(target=handleRequest,args=[client1]).start()


if __name__ == "__main__":
    main()
