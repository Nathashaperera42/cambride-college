import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';
import '../widgets/auth_modal.dart';
import 'home_screen.dart';
import 'courses_screen.dart';
import 'speech_drama_screen.dart';
import 'events_screen.dart';
import 'about_screen.dart';
import 'contact_screen.dart';

/// The public marketing site. Holds the sticky header, scrollable page body,
/// footer, and mobile drawer. Mounted at the "/" route.
class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key});

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell> {
  int _index = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();
  bool _showScrollTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final show = _scrollController.offset > 300;
      if (show != _showScrollTop) setState(() => _showScrollTop = show);
    });
  }

  void _navigate(int i) {
    setState(() => _index = i);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  Widget _buildPage() {
    switch (_index) {
      case 1:
        return const CoursesPage();
      case 2:
        return const SpeechDramaPage();
      case 3:
        return const EventsPage();
      case 4:
        return const AboutPage();
      case 5:
        return const ContactPage();
      case 0:
      default:
        return HomePage(onNavigate: _navigate);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show login modal when admin logs out and is redirected here.
    ref.listen(pendingLoginModalProvider, (_, show) {
      if (show) {
        ref.read(pendingLoginModalProvider.notifier).state = false;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) { if (mounted) showLoginModal(context); },
        );
      }
    });

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(currentIndex: _index, onNavigate: _navigate),
      floatingActionButton: AnimatedScale(
        scale: _showScrollTop ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: FloatingActionButton.small(
          onPressed: _scrollToTop,
          backgroundColor: const Color(0xFF1A3B8B),
          foregroundColor: Colors.white,
          tooltip: 'Back to top',
          child: const Icon(Icons.keyboard_arrow_up_rounded, size: 26),
        ),
      ),
      body: Column(
        children: [
          AppHeader(
            currentIndex: _index,
            onNavigate: _navigate,
            onOpenMenu: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _buildPage(),
                  AppFooter(onNavigate: _navigate),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
