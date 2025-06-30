// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_declarations, avoid_print, prefer_const_constructors, use_build_context_synchronously
import 'package:carnival_app1/global/common/toast.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../admin_home.dart';

class NotificationsToCaptains extends StatefulWidget {
  @override
  _NotificationsToCaptainsState createState() => _NotificationsToCaptainsState();
}

class _NotificationsToCaptainsState extends State<NotificationsToCaptains> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  Future<void> sendNotification(String title, String messageBody) async {

    if (title.trim().isEmpty || messageBody.trim().isEmpty) {
      showToast(message: 'Ο τίτλος και το κείμενο δεν μπορούν να είναι κενά.');
      return;
    }

    final credentials = ServiceAccountCredentials.fromJson({
      "type": "service_account",
      "project_id": "carnivaldatabase-1f814",
      "private_key_id": "ecc31a7a60c1b5cc17f57e68b3a488d955c84e38",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC/I5TaClnfhBeQ\nRMilQDs9+j+ZsNG/52hdWdqP8VJjEzxuSRhSAMlyONcZcCuXxX3BFK5Age1WL1c1\nM0jDt9E/v/Rs4lS2Kk3hh630YLWuulbYq8/trkm9Y6nuby0zHc1Q7dcNjRQPM95B\nOddHpLpDf/drZJcyg95C0oOfyDMwh/xvW8824Nh/9vXfP0smEMOLSqFsJ4hvRYgm\n7FNND5k+RiFEnKh9q384fMSH+tlrNnHeF9zRx/P3rdWMVUKU6U2A7tj47Yg5xcWb\nemgQp5r3mCswtVFVNoAicVddvW+wu+2aKa4WUBlhMWwnU57P7iLQS+HPqjwEGrjT\nhR6nK4iVAgMBAAECggEADzhDmYsadfBcOfooKfRv4zMCjnfkc8324vwNKcoS/92f\nwb5jR+BVKhm5kwZ6CidJKK8/YtaVsfeqD4vqXt9Ls7JSwbrR+QFsWymFIgDzZpri\n4HTp5SisKX7+oIRMypW0bB3MMoGJ194O9A2phURqKobNikkjuvuCHrsJjRcRcGs4\nRXu903GzP9ZKIxifXzuM7vz0KJ0GjkSZrNeNB2r+Jc0f6GCvc21bJWOjuCFM61i+\nRq24XIgDrfrQjxEBjX/PSepePmqhyiA199rOdJ/CVnd0JGXCaU6DUNd+V6621FoY\nEu3Z5MKS1AjTreOuqT5EkrQ3bjl+1VrAVbubaXcXnwKBgQDwtNROGEX0NDfzZ5V1\nboLVnoNCK3VNeZzYUKNeGW+b35geVffqX4gRBlNYa5d548T30t2JWk5F9sF+iS4x\nQ5br+cpUWITqbY5TDXVYEq9iFu+VLX5AtNN7jnYD81/fPe2mndpgqMlKPMO/8Q4Z\nuv2yUSke2W/BDWkB/W2Y4jQ4RwKBgQDLSIWgBBB4WIX7p3sDICuvpWhRg4B0V0w3\n+JBwaG7VB/vnCypIOuUTjXEDuwK0lduamLTLASIanUpOI5NafBsICcvXUkrtYPrI\n6kGuRoNliD6xWBybxXPWkgdid5VXMlM5LNR/tHzxy5R3OHxjBBE+F7xNDtu5sH2V\nKPNisM3CQwKBgB0QKGY5hhDDUVIhWqlwK3nxhrWxm5s8KNTxf5g4CALRD4PyK1nw\nKPStR9jwPLzp5Hlry3XvIm5OKfTGSX6HQ6zAX06p1XqcuceLY3S75NM6I7lmYc0c\nSECt5c/6TcQdrRkmDB0JpCxDg/sj9ujibAlgxU9FP7oWjWxBFj+UaGu3AoGBALCT\noza2sRPIWUGaXjj91dSxyiacIpVsSxGHQPfTTwqO79nmkejB97//KX8DD7uLPIFS\nSiDYMCaMIEI1lsaPbO+TitPTcLA3gD/LdBgMuhAUw9hKYDdS0Wc921pF45wlY7MT\nZNY1Eh76JlFU6H8dxlh4R6Fr2aK3Uq6hLqC4UVJ/AoGAMzmzaSICPEdK/a/GdNI1\n4hmIVFVZGhYrEWk+M32kzmGZvsbXnfrRZFhsgDU+Hz04ia9uBgX83up6QGI6+NTi\nXE92lOWCsIz88lOVuzIKSltBFOw50gYocmgi2Ka0BScp+Nasvvsp3bN5Mr77R0Kg\nsgkzJNl7GPYRuAm2S5qdBmE=\n-----END PRIVATE KEY-----\n",
      "client_email": "cloud-messaging-admin@carnivaldatabase-1f814.iam.gserviceaccount.com",
      "client_id": "115134741732331447936",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/cloud-messaging-admin%40carnivaldatabase-1f814.iam.gserviceaccount.com"
    });


    final client = await clientViaServiceAccount(
      credentials,
      ['https://www.googleapis.com/auth/firebase.messaging'],
    );

    try {

      final fcmUrl = 'https://fcm.googleapis.com/v1/projects/carnivaldatabase-1f814/messages:send';

      final message = jsonEncode({
        'message': {
          'topic': 'captains',
          'notification': {
            'title': title,
            'body': messageBody,
          },
        },
      });

      final response = await client.post(
        Uri.parse(fcmUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: message,
      );

      if (response.statusCode == 200) {

        await FirebaseFirestore.instance.collection('notifications_to_captains').add({
          'title': title,
          'body': messageBody,
          'timestamp': FieldValue.serverTimestamp(),
        });

        showToastGood(message: 'Επιτυχής αποστολή ειδοποίησης!');

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => AdminHomePage(),
          ),
              (route) => false,
        );
      } else {
        print('Failed to send notification: ${response.body}');
        showToast(message: 'Αποτυχία αποστολής ειδοποίησης. Προσπαθήστε ξανά.');
      }
    } catch (e) {
      print('Error sending notification: $e');
      showToast(message: 'Παρουσιάστηκε σφάλμα κατά την αποστολή. Προσπαθήστε ξανά.');
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Αποστολή προς αρχηγούς'),
        backgroundColor: Colors.teal,
        shadowColor: Colors.tealAccent,
        elevation: 5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Τίτλος ειδοποίησης',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(
                labelText: 'Κείμενο',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text;
                final messageBody = _bodyController.text;
                sendNotification(title, messageBody);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Αποστολή'),
            ),
          ],
        ),
      ),
    );
  }
}
