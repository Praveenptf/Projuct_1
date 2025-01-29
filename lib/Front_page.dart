import 'package:firrst_projuct/HomePage.dart';
import 'package:firrst_projuct/RegisterPage.dart';
import 'package:flutter/material.dart';

class FrontPage1 extends StatefulWidget {
  const FrontPage1({super.key});

  @override
  State<FrontPage1> createState() => _FrontPage1State();
}

class _FrontPage1State extends State<FrontPage1> {
  int _currentPageIndex = 0;
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: Column(
        children: [
          Expanded(
              child: PageView.builder(
            itemCount: onboardingList.length,
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return OnboardingCard(
                playAnimation: true,
                onboarding: onboardingList[index],
              );
            },
          )),
          (_currentPageIndex < onboardingList.length - 1)
              ? NextButton(onTap: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                })
              : Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.shade400,
                          Colors.deepPurple.shade800,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()));
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: const Center(
                          child: Text(
                            'Login In',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade400,
                    Colors.deepPurple.shade800,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterPage()));
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: const Center(
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class OnboardingAnimations {
  static AnimationController createSlideController(TickerProvider vsync) {
    return AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1000),
    );
  }

  static Animation<Offset> openSpotsSlideAnimation(
      AnimationController controller) {
    return Tween<Offset>(
      begin: const Offset(0.0, -0.8),
      end: const Offset(0.0, -0.05),
    ).animate(CurvedAnimation(
      parent: controller,
      curve: const ElasticOutCurve(1.2),
    ));
  }

  static Animation<double> fadeAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    ));
  }
}

class OnboardingCard extends StatefulWidget {
  final bool playAnimation;
  final Onboarding onboarding;
  const OnboardingCard(
      {required this.playAnimation, super.key, required this.onboarding});

  @override
  State<OnboardingCard> createState() => _OnboardingCardState();
}

class _OnboardingCardState extends State<OnboardingCard>
    with TickerProviderStateMixin {
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;

  Animation<Offset> get slideAnimation => _slideAnimation;
  AnimationController get slideAnimationController => _slideAnimationController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.playAnimation) {
      _slideAnimationController.forward();
    } else {
      _slideAnimationController.animateTo(
        1,
        duration: const Duration(milliseconds: 0),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _slideAnimationController =
        OnboardingAnimations.createSlideController(this);
    _slideAnimation =
        OnboardingAnimations.openSpotsSlideAnimation(_slideAnimationController);
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          const Spacer(),
          Image.asset(
            widget.onboarding.image,
            width: double.maxFinite,
            fit: BoxFit.fitWidth,
          ),
          const SizedBox(height: 20),
          Text(
            widget.onboarding.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.deepPurple.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            widget.onboarding.description,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.deepPurple.shade800,
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}

class NextButton extends StatelessWidget {
  final VoidCallback onTap;
  const NextButton({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
            color: Colorspop.kPrimary, shape: BoxShape.circle),
        child: const Icon(Icons.navigate_next, size: 30, color: Colors.white),
      ),
    );
  }
}

class Onboarding {
  String image;
  String title;
  String description;

  Onboarding(
      {required this.description, required this.image, required this.title});
}

List<Onboarding> onboardingList = [
  Onboarding(
      description: 'Explore Our Services and Book your Appointment Easily !',
      image: AppAssets.kOnboardingFirst,
      title: 'Welcome to Salon Info'),
];

class Colorspop {
  static const Color kPrimary = Color(0xFF6759FF);
  static const Color kBackground = Color(0xFFF9F9F9);
  static const Color kHint = Color(0xFFD1D3D4);
  static const Color kAccent4 = Color(0xFFB5EBCD);
}

class AppAssets {
  static String kOnboardingFirst = 'assets/onboarding_first.png';
}
