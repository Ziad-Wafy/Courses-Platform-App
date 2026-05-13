import 'package:flutter/material.dart';

class VideoPlayerWidget extends StatelessWidget {
  final VoidCallback? onBackTap;

  const VideoPlayerWidget({super.key, this.onBackTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: GestureDetector(
              onTap:
                  onBackTap ??
                  () {
                    Navigator.pop(context);
                  },
              child: const Row(
                children: [
                  Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Back to Course",
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ],
              ),
            ),
          ),

          Container(
            height: 240,
            width: double.infinity,
            color: const Color(0xff1E2230),
            child: const Center(
              child: Icon(
                Icons.play_circle_fill,
                size: 70,
                color: Colors.white54,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Row(
                  children: [
                    Icon(Icons.skip_previous, color: Colors.white),
                    SizedBox(width: 18),
                    Icon(Icons.skip_next, color: Colors.white),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.volume_up, color: Colors.white),
                    SizedBox(width: 18),
                    Icon(Icons.fullscreen, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
