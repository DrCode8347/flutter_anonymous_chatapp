import 'package:flutter/material.dart';

class AnonymousTipsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Important Notes"),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTipCard(
              context,
              icon: Icons.message,
              title: "Messages are Temporary",
              description:
                  "Messages are automatically deleted after two weeks to ensure privacy. Take note of important details before they disappear.",
            ),
            _buildTipCard(
              context,
              icon: Icons.key,
              title: "Keep Your Private Key Secure",
              description:
                  "Your private key is your only way to access your account. If lost, your account and its content cannot be recovered.",
            ),
            _buildTipCard(
              context,
              icon: Icons.logout,
              title: "Think Before You Log Out",
              description:
                  "Logging out without your private key means you will lose access to your account permanently.",
            ),
            _buildTipCard(
              context,
              icon: Icons.device_hub,
              title: "One Device at a Time",
              description:
                  "Your private key is device-specific. To access your account on another device, you must import your key.",
            ),
            _buildTipCard(
              context,
              icon: Icons.report_problem,
              title: "Stay Respectful",
              description:
                  "We encourage respectful communication. Harmful or inappropriate content is not tolerated.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String description}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 30.0),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    description,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
