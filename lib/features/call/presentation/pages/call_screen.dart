import 'package:flutter/material.dart';

class CallScreen extends StatelessWidget {
  final Map<String, dynamic> callData;

  const CallScreen({super.key, required this.callData});

  @override
  Widget build(BuildContext context) {
    final callerName = callData['username'] ?? 'Unknown';
    final callType = callData['call_type'] ?? 'audio';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ongoing Call'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.person, size: 80, color: Colors.blue),
            ),
            const SizedBox(height: 24),
            Text(
              callerName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              callType == 'video' ? 'Video Call' : 'Audio Call',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mute Button
                FloatingActionButton(
                  onPressed: () {},
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.mic_off),
                ),
                const SizedBox(width: 32),

                // End Call Button
                FloatingActionButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.call_end, color: Colors.white),
                ),
                const SizedBox(width: 32),

                // Speaker Button
                FloatingActionButton(
                  onPressed: () {},
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.volume_up),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
