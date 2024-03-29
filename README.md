# Alfaaz

Alfaaz is a all-in-one android app for connecting with people around you.

With alfaaz, you can chat and meet new people with similar interests, whether you're looking for friends, partners, or professional connections.

## 📜 Contents
- [About](https://github.com/rahulmangla28/Alfaaz/tree/master#-about)
- [Features](https://github.com/rahulmangla28/Alfaaz/tree/master#features)
- [Getting Started](https://github.com/rahulmangla28/Alfaaz/tree/master#getting-started)
    - [Project Setup](https://github.com/rahulmangla28/Alfaaz/tree/master#project-setup)
    - [Coding Style & Conventions](https://github.com/rahulmangla28/Alfaaz/tree/master#coding-style--conventions)
- [Development](https://github.com/rahulmangla28/Alfaaz/tree/master#development)
    - [Overview of Codebase](https://github.com/rahulmangla28/Alfaaz/tree/master#overview-of-codebase)
- [Technologies Used](https://github.com/rahulmangla28/Alfaaz/tree/master#-technologies-used)
- [App Permissions](https://github.com/payalmangla17/smile_engage/#permissions)
- [Screenshots](https://github.com/rahulmangla28/Alfaaz/tree/master#-screenshots)
- [Project References](https://github.com/rahulmangla28/Alfaaz/tree/master#-project-references)
- [Future enhancement](https://github.com/rahulmangla28/Alfaaz/tree/master#-future-enhancement)
- [Connect with me](https://github.com/rahulmangla28/Alfaaz/tree/master#-connect-with-me)

## 👀 About

Alfaaz is a video conferencing application with rich integrated chat feature where one can discuss on topics and connect with other members.
It implements the following features:
  - **Instant Messaging:**
    Communicate with others and have shared resources in an organised manner. Send GIF's, emojis, files, media in one to one or group chat.
  - **Online Meetings:**
    Connect with your mates easily by just clicking a button in the chat window.
  - **Collaborate:**
    Easily locate shared files, media in real time.
    
## ✨ Features

### 🤐	_Chat Functionality_
- Create Group / personal chats outside a meeting
- Pin messages.
- Delete / edit messages.
- Photo, Audio, Videos, etc.
- GIFs via GIPHY
- Chat reactions & Emojis.
- Reply on threads.
- Integrated Video rooms.
- User mentions.
- Mute Conversations

### 📹 _Video Conferencing Functionality_
- Toggle Video / Audio
- Share Screen
- Anonymous Join In
- Raise Hand
- Set Meeting Password
- Share files
- In meet private chat
- Record the meeting
- Share Links
- Minimised mode

## 🚀 Getting Started
### _Project Setup_
Please refer to the following [guide](https://github.com/rahulmangla28/Alfaaz/wiki) for **_project setup_**.
### _Coding Style & Conventions_
Please refer to following [wiki](https://github.com/rahulmangla28/Alfaaz/wiki#coding-style--conventions) for **_coding style & conventions_**.

## Development
### _Codebase Overview_
1. A bridge has been created to connect users to firebase server and stream chat server.
![image](https://user-images.githubusercontent.com/43950455/143718582-adbe3d65-e6cb-4fa2-ace8-025314e5ae04.png)

2. There are three important things to notice that are common to all Flutter application using StreamChat:
    - The Dart API client is initialized with your API Key
    - The current user is set by calling connectUser on the client
    - The client is then passed to the top-level StreamChat widget
      
3. The top level stream chat widget is returned in home_page.dart. StreamChat is an inherited widget and must be the parent of all Chat related widgets 4.To add data persistence ChatPersistenceClient is extended and passed as an instance to the StreamChatClient.
   
4. For more details, please refer [here](https://getstream.io/chat/flutter/tutorial/#add-stream-chat-to-your-flutter-application).

### _Directory structure of lib_

- [components](https://github.com/rahulmangla28/Alfaaz/tree/master/lib/components)
- [config](https://github.com/rahulmangla28/Alfaaz/tree/master/lib/config) : Configuration used in the application
- [pages](https://github.com/rahulmangla28/Alfaaz/tree/master/lib/pages) : The Widgets of all the pages / screens in the application
    - [authentication](https://github.com/rahulmangla28/Alfaaz/tree/master/lib/pages/authentication)
    - [chat](https://github.com/rahulmangla28/Alfaaz/tree/master/lib/pages/chat)
    - [home](https://github.com/rahulmangla28/Alfaaz/tree/master/lib/pages/home)
    - [introduction_animation](https://github.com/rahulmangla28/Alfaaz/tree/master/lib/pages/introduction_animation)
    - [meetings](https://github.com/rahulmangla28/Alfaaz/tree/master/lib/pages/meetings)
    - [models](https://github.com/rahulmangla28/Alfaaz/tree/master/lib/pages/models)
    - [ui](https://github.com/rahulmangla28/Alfaaz/tree/master/lib/pages/ui)
- [routes](https://github.com/rahulmangla28/Alfaaz/tree/master/lib/routes) : Routes to navigate inside the app
- [services](https://github.com/rahulmangla28/Alfaaz/tree/master/lib/services) : Services for user authentication and stream chat client
- [main.dart](https://github.com/rahulmangla28/Alfaaz/blob/master/lib/main.dart) : Entry point for the application

## 📑 Technologies Used
- [Flutter](https://flutter.dev/)
- Google Firebase for authentication and storage
    - [firebase_core](https://pub.dev/packages/firebase_core)
    - [firebase_auth](https://pub.dev/packages/firebase_auth)
    - [firebase_realtime_database](https://pub.dev/packages/firebase_database)
- Stream Chat SDK for Chat functionality
    - [stream_chat_flutter](https://pub.dev/packages/stream_chat_flutter)
    - [stream_chat_flutter_core](https://pub.dev/packages/stream_chat_flutter_core)
    - [stream_chat_persistence](https://pub.dev/packages/stream_chat_persistence)
    - [streaming_shared_preferences](https://pub.dev/packages/streaming_shared_preferences)
    - [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)
- Jitsi Meet SDK for video meetings & conferences
    - [Jitsi Meet](https://pub.dev/packages/jitsi_meet)
- Other dependencies in ```pubspec.yaml```

## 🔐 App Permissions

1. [Internet](https://developer.android.com/training/basics/network-ops/connecting)
2. [Camera](https://developer.android.com/guide/topics/media/camera)
3. [Microphone](https://medium.com/@martusheff/detect-microphone-input-volume-with-flutter-3e14d3aa3822#:~:text=Future%20startRecording()%20is,otherwise%2C%20false%20will%20be%20returned.)
4. [Storage](https://mukhtharcm.com/storage-permission-in-flutter/)

## 📸 Screenshots

Splash View | Welcome | Sign Up | Drawer
--- | --- | --- | --- |
<img src="https://github.com/rahulmangla28/Alfaaz/blob/master/Screenshots/ss1.jpg" height="350" width="200" > | <img src="https://github.com/rahulmangla28/Alfaaz/blob/master/Screenshots/ss3.jpg" height="350" width="200" > | <img src="https://github.com/rahulmangla28/Alfaaz/blob/master/Screenshots/ss5.jpg" height="350" width="200" > | <img src="https://github.com/rahulmangla28/Alfaaz/blob/master/Screenshots/ss7.jpg" height = "350" width="200" >

Start New Chat | Group Functionality | Sending Files | Chat Window
--- | --- | --- | --- |
<img src="https://github.com/rahulmangla28/Alfaaz/blob/master/Screenshots/ss8.jpg" height="350" width="200" > | <img src="https://github.com/rahulmangla28/Alfaaz/blob/master/Screenshots/ss11.jpg" height="350" width="200" > | <img src="https://github.com/rahulmangla28/Alfaaz/blob/master/Screenshots/ss10.jpg" height="350" width="200" > | <img src="https://github.com/rahulmangla28/Alfaaz/blob/master/Screenshots/ss12.jpg" height = "350" width="200" >


Meet View | Create Meet | Join Meet | Meet Chat
--- | --- | --- | --- |
<img src="https://github.com/rahulmangla28/Alfaaz/blob/master/Screenshots/ss6.jpg" height="350" width="200" > | <img src="https://github.com/rahulmangla28/Alfaaz/blob/master/Screenshots/ss13.jpg" height="350" width="200" > |<img src="https://github.com/rahulmangla28/Alfaaz/blob/master/Screenshots/ss14.jpg" height="350" width="200" > | <img src="https://github.com/rahulmangla28/Alfaaz/blob/master/Screenshots/ss15.jpg" height="350" width="200" >


## 💻 UI

Fully responsive UI and customizable over multiple screen sizes.

## 📝 Coding Style

Used Object Oriented Programming and Clean Code practices.


## 📋 Project References
- [Flutter API](https://api.flutter.dev/index.html)
- [Stream Chat API Docs](https://getstream.io/chat/docs/flutter-dart/)
- [Pub.dev Api Reference](https://pub.dev/)
- [Jitsi Meet](https://pub.dev/packages/jitsi_meet)
- [Flutter Examples](https://github.com/GetStream/flutter-samples)
- [Undraw](https://undraw.co/) for using the images for UI

## 💡 Future Enhancement
- Enabling Chat Lock feature
- Integrating swipe keyboard
- Integration of moderator
- Sending calendar invites for the meeting

## 🤝	 Connect with me
[![image](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/rahulmangla28/) [![image](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/rahulmangla28)
