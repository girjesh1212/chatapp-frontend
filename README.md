# chatapp

This is a simple chat application which takes text input from the user and send it to server using websocket. The server then returns same message back to the client.

So basically, it is an app to chat with server which just mimics the message.

## Getting Started

1. Go to lib/config/config.dart and set `socketBaseUrl` and `strapiBaseUrl`. Default is set to localhost.

2. Start with `flutter clean`

3. Build the project using `flutter build web`

4. Copy the content of build/web into the "web" directory of its backend server. (<https://github.com/girjesh1212/chatapp-backend.git>)

5. Now start the backend server.

6. The app should be live on port 3000
