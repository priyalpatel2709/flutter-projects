import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;


  void firebaceInit(){
    FirebaseMessaging.onMessage.listen((message) {
      print(message.notification?.title.toString());
      print(message.notification?.body.toString());
    });
  }


  void reqOfNotifiction() async {
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true);

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          print('aapi didhi 6 la');
        }else if(settings.authorizationStatus == AuthorizationStatus.provisional){
          print('kone khbar bc');
        }
         else {
          print('na aapi bc');
        }
  }

  Future <String> getToken() async{
    String? token = await messaging.getToken();
    return token!;
  }

}
