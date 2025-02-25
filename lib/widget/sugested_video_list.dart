import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mercy_tv_app/Colors/custom_color.dart';
import 'package:mercy_tv_app/API/dataModel.dart';
import 'package:mercy_tv_app/Controller/SuggestedVideoController.dart';

class SuggestedVideoCard extends StatelessWidget {
  final void Function(ProgramDetails) onVideoTap;
  SuggestedVideoCard({super.key, required this.onVideoTap});

  final SuggestedVideoController controller = Get.find<SuggestedVideoController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      } else if (controller.errorMessage.isNotEmpty) {
        return Center(child: Text(controller.errorMessage.value));
      } else if (controller.videoData.isEmpty) {
        return const Center(child: Text('No videos available'));
      } else {
        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.videoData.length,
            itemBuilder: (context, index) {
              var video = controller.videoData[index];
              var program = video['program'] ?? {};

              ProgramDetails programDetails = ProgramDetails(
                imageUrl: program['image'],
                date: program['date'],
                time: program['time'],
                title: program['program'] ?? 'Unknown Program',
                videoUrl: video['url'] ?? '',
              );

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: VideoThumbnailCard(
                  programDetails: programDetails,
                  isPlaying: controller.currentlyPlayingIndex.value == index,
                  onTap: (details) {
                    controller.playVideo(details.videoUrl, index);
                    onVideoTap(details);
                  },
                ),
              );
            },
          ),
        );
      }
    });
  }
}

class VideoThumbnailCard extends StatelessWidget {
  final ProgramDetails programDetails;
  final bool isPlaying;
  final void Function(ProgramDetails) onTap;

  const VideoThumbnailCard({
    super.key,
    required this.programDetails,
    required this.isPlaying,
    required this.onTap,
  });

  String formatDateTime(String? date, String? time) {
    if (date == null || time == null) return "Unknown Date";
    try {
      DateTime parsedDate = DateTime.parse(date);
      List<String> timeParts = time.split(":");
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      String formattedDate = "${parsedDate.day} ${_getMonth(parsedDate.month)} ${parsedDate.year}";
      String formattedTime = _formatTime(hour, minute);
      return "$formattedDate | $formattedTime";
    } catch (e) {
      return "Invalid Date/Time";
    }
  }

  String _formatTime(int hour, int minute) {
    final String period = hour < 12 ? "AM" : "PM";
    final int displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final String minuteStr = minute.toString().padLeft(2, '0');
    return "$displayHour:$minuteStr $period";
  }

  static String _getMonth(int month) {
    const months = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(programDetails),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isPlaying ? Border.all(color: CustomColors.buttonColor, width: 3) : null,
            boxShadow: isPlaying
                ? [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.6),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: Image.network(
                    'https://mercyott.com/${programDetails.imageUrl ?? ''}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/video_thumb_1.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/transparent.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                left: 10,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      programDetails.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Mulish-Medium',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.history, color: CustomColors.buttonColor, size: 18),
                        const SizedBox(width: 5),
                        Text(
                          formatDateTime(programDetails.date, programDetails.time),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Mulish-Medium',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}