import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mercy_tv_app/API/api_integration.dart';
import 'package:mercy_tv_app/Controller/screenplayer_controller.dart';

class SuggestedVideoController extends GetxController {
  var videoData = <dynamic>[].obs;
  var currentlyPlayingIndex = 0.obs;
  var isLoading = true.obs;
  var errorMessage = "".obs;
  late ScrollController scrollController;
  bool _dataFetched = false;

  @override
  void onInit() {
    scrollController = ScrollController();
    if (!_dataFetched) {
      fetchSortedVideoData();
      _dataFetched = true;
    }
    super.onInit();
  }

  Future<void> fetchSortedVideoData() async {
    try {
      debugPrint('Fetching video data...');
      isLoading.value = true;
      List<dynamic> data = await ApiIntegration().getVideoData();
      if (data.isNotEmpty) {
        data.sort((a, b) => int.parse(b['video_id']).compareTo(int.parse(a['video_id'])));
        videoData.assignAll(data);
        debugPrint('Video data fetched: ${videoData.length} items');
      } else {
        errorMessage.value = "No video data received from API";
        debugPrint('No video data received');
      }
    } catch (e) {
      errorMessage.value = "Error loading videos: $e";
      debugPrint('Error fetching video data: $e');
    } finally {
      isLoading.value = false;
      debugPrint('Loading complete, isLoading: ${isLoading.value}');
    }
  }

  void moveLeft() {
    if (currentlyPlayingIndex.value > 0) {
      currentlyPlayingIndex.value--;
      debugPrint('Moved left to index: ${currentlyPlayingIndex.value}');
      update();
    }
  }

  void moveRight() {
    if (currentlyPlayingIndex.value < videoData.length - 1) {
      currentlyPlayingIndex.value++;
      debugPrint('Moved right to index: ${currentlyPlayingIndex.value}');
      update();
    }
  }

  void resetFocus() {
    currentlyPlayingIndex.value = 0;
    debugPrint('Focus reset to index: 0');
    update();
  }

  void playVideo(String? videoUrl) {
    if (videoUrl == null || videoUrl.isEmpty) {
      Get.snackbar("Error", "Invalid Video URL");
      return;
    }
    String fullUrl = videoUrl.startsWith('http') ? videoUrl : 'https://mercyott.com$videoUrl';
    bool isLive = fullUrl.contains(".m3u8");
    Get.find<ScreenPlayerController>().initializePlayer(fullUrl, live: isLive);
    // Explicitly keep controls visible
    Get.find<ScreenPlayerController>().showControls.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ScreenPlayerController>().update();
      Get.forceAppUpdate();
    });
  }

  @override
  void onClose() {
    Get.find<ScreenPlayerController>().disposePlayer();
    scrollController.dispose();
    super.onClose();
  }
}