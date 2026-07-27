import 'package:flutter/material.dart';
import '../../../../models/section_keys.dart';
import '../widgets/about_section.dart';
import '../widgets/benefits_section.dart';
import '../widgets/features_section.dart';
import '../widgets/footer.dart';
import '../widgets/hero_section.dart';
import '../widgets/how_to_use_section.dart';
import '../widgets/navbar.dart';
import '../widgets/stats_section.dart';

class ElearningLandingPage extends StatefulWidget {
  const ElearningLandingPage({super.key});

  @override
  State<ElearningLandingPage> createState() => _ElearningLandingPageState();
}

class _ElearningLandingPageState extends State<ElearningLandingPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: HeroSection()),
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.1),
            pinned: true,
            floating: false,
            expandedHeight: 0,
            toolbarHeight: 80,
            flexibleSpace: null,
            title: Navbar(parentContext: context),
            centerTitle: false,
            automaticallyImplyLeading: false,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(key: SectionKeys.homeKey, child: const AboutSection()),
              Container(
                key: SectionKeys.featuresKey,
                child: const FeaturesSection(),
              ),
              Container(
                key: SectionKeys.benefitsKey,
                child: const BenefitsSection(),
              ),
              const StatsSection(),
              Container(
                key: SectionKeys.howToUseKey,
                child: const HowToUseSection(),
              ),
              const Footer(),
            ]),
          ),
        ],
      ),
    );
  }
}
