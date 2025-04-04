import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'main.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen = screenWidth > 600; // เช็คว่าเป็นแท็บเล็ตหรือเดสก์ท็อป

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            padding: EdgeInsets.only(bottom: isWideScreen ? 50 : 80),
            child: PageView(
              controller: controller,
              onPageChanged: (index) {
                setState(() => isLastPage = index == 2);
              },
              children: [
                buildPage(
                    color: Colors.lightBlue.shade100,
                    urlImage: 'images/a-removebg-preview.png',
                    title: 'HELLO',
                    subtitle: " ",
                    screenHeight: screenHeight),
                buildPage(
                    color: Colors.green.shade100,
                    urlImage: 'images/B.png',
                    title: 'WELLCOME',
                    subtitle: ' ',
                    screenHeight: screenHeight),
                buildPage(
                    color: Colors.pink.shade100,
                    urlImage: 'images/C.png',
                    title: "LET'S START",
                    subtitle: ' ',
                    screenHeight: screenHeight),
              ],
            ),
          );
        },
      ),
      bottomSheet: isLastPage
          ? buildGetStartedButton()
          : buildNavigation(screenHeight, isWideScreen),
    );
  }

  Widget buildPage({
    required Color color,
    required String urlImage,
    required String title,
    required String subtitle,
    required double screenHeight,
  }) {
    return Container(
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: screenHeight * 0.4, // ปรับขนาดรูปภาพตามหน้าจอ
            child: Image.asset(
              urlImage,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: TextStyle(
              color: Colors.teal.shade700,
              fontSize: screenHeight * 0.04, // ปรับขนาดข้อความอัตโนมัติ
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.05),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: screenHeight * 0.025, // ปรับขนาดข้อความ
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGetStartedButton() {
    return TextButton(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.teal.shade700,
        minimumSize: const Size.fromHeight(70),
      ),
      child: const Text(
        'Get Started',
        style: TextStyle(fontSize: 24),
      ),
      onPressed: () async {
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('showHome', true);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SplashScreen()),
        );
      },
    );
  }

  Widget buildNavigation(double screenHeight, bool isWideScreen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWideScreen ? 200 : 100),
      height: screenHeight * 0.1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            child: const Text('SKIP'),
            onPressed: () => controller.jumpToPage(2),
          ),
          Center(
            child: SmoothPageIndicator(
              controller: controller,
              count: 3,
              effect: WormEffect(
                spacing: 16,
                dotColor: Colors.black26,
                activeDotColor: Colors.teal.shade700,
              ),
              onDotClicked: (index) => controller.animateToPage(index,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn),
            ),
          ),
          TextButton(
            child: const Text('NEXT'),
            onPressed: () => controller.nextPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut),
          )
        ],
      ),
    );
  }
}
