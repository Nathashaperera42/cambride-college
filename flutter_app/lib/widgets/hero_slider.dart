import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants/app_theme.dart';

/// ---------------------------------------------------------------------------
/// HERO SLIDER  —  full-bleed slider hero (Globe-Express style) adapted for
/// the Cambridge site. The active slide fills the background; the upcoming
/// slides appear as a card carousel on the right that conveyor-shifts left as
/// it advances. Eyebrow + title + counter swap in sync. Auto-plays and has
/// manual prev/next arrows. Fully responsive (desktop / tablet / mobile).
///
///  >>> TO EDIT CONTENT: just change the `kHeroSlides` list below. <<<
///  Add as many slides as you like — the carousel adapts automatically.
/// ---------------------------------------------------------------------------

class HeroSlide {
  final String image;
  final String category; // small label, e.g. "Speech & Drama"
  final String titleLine1; // big white line
  final String titleLine2; // big gold line
  final String description;
  const HeroSlide({
    required this.image,
    required this.category,
    required this.titleLine1,
    required this.titleLine2,
    required this.description,
  });
}

/// EDIT ME — add / remove / reorder slides here.
const List<HeroSlide> kHeroSlides = [
  HeroSlide(
    image:
        'https://res.cloudinary.com/dsypqpuci/image/upload/v1780727301/WhatsApp_Image_2026-03-26_at_17.06.35_2_fjzvhm.jpg',
    category: 'Speech & Drama',
    titleLine1: 'Speak With',
    titleLine2: 'Confidence',
    description:
        'Cambridge-trained faculty help every student find their voice, '
        'their poise and their presence on stage.',
  ),
  HeroSlide(
    image:
        'https://res.cloudinary.com/dsypqpuci/image/upload/v1780727351/WhatsApp_Image_2026-04-22_at_21.36.12_1_ar6ret.jpg',
    category: 'Cambridge English',
    titleLine1: 'Master The',
    titleLine2: 'Language',
    description:
        'fluency, comprehension and '
        'exam-ready confidence from the very first lesson.',
  ),
  HeroSlide(
    image:
        'https://res.cloudinary.com/dsypqpuci/image/upload/v1780727332/WhatsApp_Image_2026-04-22_at_21.35.14_c5x5r6.jpg',
    category: 'Drama & Performance',
    titleLine1: 'Take The',
    titleLine2: 'Stage',
    description:
        'From first audition to final curtain — performance training that '
        'develops creativity, teamwork and real stage craft.',
  ),
  HeroSlide(
    image:
        'https://res.cloudinary.com/dsypqpuci/image/upload/v1780423579/WhatsApp_Image_2026-03-26_at_17.02.35_uupaer.jpg',
    category: 'Elocution & Voice',
    titleLine1: 'Find Your',
    titleLine2: 'Voice',
    description:
        'Clear articulation, breath control and expression — the foundations '
        'of confident, captivating communication.',
  ),
  HeroSlide(
    image:
        'https://res.cloudinary.com/dsypqpuci/image/upload/v1780425759/WhatsApp_Image_2026-03-26_at_17.02.45_h3b4ct.jpg',
    category: 'Public Speaking',
    titleLine1: 'Lead The',
    titleLine2: 'Room',
    description:
        'Persuasive, polished and self-assured — turn nerves into natural '
        'authority in front of any audience.',
  ),
  HeroSlide(
    image:
        'https://res.cloudinary.com/dsypqpuci/image/upload/v1780463897/WhatsApp_Image_2026-03-26_at_17.02.36_dorml3.jpg',
    category: 'Annual Prize Giving',
    titleLine1: 'Celebrate',
    titleLine2: 'Success',
    description:
        'Recognising achievement, hard work and growth — a proud tradition '
        'at the heart of our learning community.',
  ),
];

/// Responsive layout configuration for a given width.
class _Cfg {
  final int visible; // cards fully visible
  final double cardW;
  final double cardH;
  final double gap;
  final double peek; // sliver of the next card revealed
  final bool stacked; // true => vertical (mobile) arrangement
  const _Cfg(
    this.visible,
    this.cardW,
    this.cardH,
    this.gap,
    this.peek,
    this.stacked,
  );
}

_Cfg _cfgFor(double w) {
  if (w >= 1280) return const _Cfg(4, 160, 240, 14, 36, false);
  if (w >= 1024) return const _Cfg(3, 155, 232, 14, 36, false);
  if (w >= 760)  return const _Cfg(2, 148, 222, 14, 32, false);
  if (w >= 520)  return const _Cfg(2, 140, 190, 12, 28, true);
  return         const _Cfg(1, 156, 194, 12, 80, true);
}

class HeroSlider extends StatefulWidget {
  /// Same navigation callback used elsewhere in the app.
  final ValueChanged<int> onNavigate;

  /// Set to `false` if you already render a global top navigation bar and only
  /// want the slider content (no duplicate nav).
  final bool showNavBar;

  const HeroSlider({
    super.key,
    required this.onNavigate,
    this.showNavBar = true,
  });

  @override
  State<HeroSlider> createState() => _HeroSliderState();
}

class _HeroSliderState extends State<HeroSlider>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 680),
  );

  int _index = 0;
  int _dir = 1; // +1 next, -1 prev
  Timer? _auto;

  int get _n => kHeroSlides.length;
  int _wrap(int i) => ((i % _n) + _n) % _n;
  int get _target => _wrap(_index + _dir);

  @override
  void initState() {
    super.initState();
    _startAuto();
  }

  @override
  void dispose() {
    _auto?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _startAuto() {
    _auto?.cancel();
    if (_n <= 1) return;
    _auto = Timer.periodic(const Duration(seconds: 6), (_) {
      if (mounted && !_ctrl.isAnimating) _advance(1);
    });
  }

  void _advance(int dir) {
    if (_ctrl.isAnimating || _n <= 1) return;
    setState(() => _dir = dir);
    _ctrl.forward(from: 0).then((_) {
      if (!mounted) return;
      setState(() => _index = _wrap(_index + dir));
      _ctrl.value = 0;
    });
  }

  void _manual(int dir) {
    _advance(dir);
    _startAuto(); // reset the auto-play timer after a manual tap
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cfg = _cfgFor(w);
        final screenH = MediaQuery.of(context).size.height;
        final heroH = (cfg.stacked
                ? screenH.clamp(720.0, 1100.0)
                : screenH.clamp(620.0, 920.0))
            .toDouble();

        return SizedBox(
          width: double.infinity,
          height: heroH,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              final t = _ctrl.value;
              return Stack(
                fit: StackFit.expand,
                children: [
                  _background(t),
                  // top gold accent line (like the reference)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 3,
                      child: ColoredBox(color: AppColors.gold),
                    ),
                  ),
                  Positioned.fill(
                    child: cfg.stacked
                        ? _stackedContent(t, cfg)
                        : _wideContent(t, cfg, w),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // ----- background -------------------------------------------------------

  Widget _background(double t) {
    final cur = kHeroSlides[_index];
    final tgt = kHeroSlides[_target];
    return Stack(
      fit: StackFit.expand,
      children: [
        _bgImage(cur.image),
        if (t > 0)
          Opacity(opacity: t.clamp(0.0, 1.0).toDouble(), child: _bgImage(tgt.image)),
        // left-to-right darkening for text legibility
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xF20A1B36), Color(0x990A1B36), Color(0x1A0A1B36)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // bottom vignette
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xCC061229), Color(0x00061229)],
              stops: [0.0, 0.55],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bgImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      loadingBuilder: (c, child, progress) =>
          progress == null ? child : const ColoredBox(color: AppColors.darkNavy),
      errorBuilder: (c, e, s) => const ColoredBox(color: AppColors.darkNavy),
    );
  }

  // ----- wide (desktop / tablet) layout -----------------------------------

  Widget _wideContent(double t, _Cfg cfg, double w) {
    final hpad = w >= 1100 ? 48.0 : 28.0;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Padding(
            padding: EdgeInsets.fromLTRB(hpad, 16, hpad, 26),
            child: Column(
              children: [
                if (widget.showNavBar) _navBar(false),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: _leftBlock(t, false)),
                      const SizedBox(width: 80),
                      _cardViewport(t, cfg),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                _controls(t, false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----- stacked (mobile) layout ------------------------------------------

  Widget _stackedContent(double t, _Cfg cfg) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showNavBar) _navBar(true),
            const Spacer(),
            _animatedText(t, true),
            const SizedBox(height: 22),
            _buttonsRow(),
            const SizedBox(height: 26),
            _cardViewport(t, cfg),
            const SizedBox(height: 18),
            _controls(t, true),
          ],
        ),
      ),
    );
  }

  // ----- left text block --------------------------------------------------

  Widget _leftBlock(double t, bool small) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _animatedText(t, small),
        const SizedBox(height: 28),
        _buttonsRow(),
      ],
    );
  }

  Widget _animatedText(double t, bool small) {
    final outOpacity = (1 - t).clamp(0.0, 1.0).toDouble();
    final inOpacity = t.clamp(0.0, 1.0).toDouble();
    return Stack(
      children: [
        Opacity(
          opacity: outOpacity,
          child: Transform.translate(
            offset: Offset(0, -18 * t),
            child: _textContent(kHeroSlides[_index], small),
          ),
        ),
        if (t > 0)
          Positioned.fill(
            child: Opacity(
              opacity: inOpacity,
              child: Transform.translate(
                offset: Offset(0, 18 * (1 - t)),
                child: _textContent(kHeroSlides[_target], small),
              ),
            ),
          ),
      ],
    );
  }

  Widget _textContent(HeroSlide s, bool small) {
    final titleSize = small ? 34.0 : 56.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 28, height: 2, color: AppColors.gold),
            const SizedBox(width: 10),
            Text(
              s.category,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          s.titleLine1,
          style: TextStyle(
            color: Colors.white,
            fontSize: titleSize,
            height: 1.02,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          s.titleLine2,
          style: TextStyle(
            color: AppColors.gold,
            fontSize: titleSize,
            height: 1.02,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: small ? 520 : 480),
          child: Text(
            s.description,
            maxLines: small ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buttonsRow() {
    return Wrap(
      spacing: 14,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _Hoverable(
          onTap: () => widget.onNavigate(5),
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow_rounded,
                color: AppColors.darkNavy, size: 26),
          ),
        ),
        _Hoverable(
          onTap: () => widget.onNavigate(1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white54),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'EXPLORE PROGRAMS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_outward, color: AppColors.gold, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ----- card carousel ----------------------------------------------------

  Widget _cardViewport(double t, _Cfg cfg) {
    final slot = cfg.cardW + cfg.gap;
    final tx = -slot * t * _dir; // conveyor offset
    final viewportW = cfg.visible * slot - cfg.gap + cfg.peek;

    final children = <Widget>[];
    // render one buffer card on each side so slides flow in/out smoothly
    for (int j = -1; j <= cfg.visible; j++) {
      final idx = _wrap(_index + 1 + j);
      children.add(Positioned(
        left: j * slot + tx,
        top: 0,
        width: cfg.cardW,
        height: cfg.cardH,
        child: _card(kHeroSlides[idx]),
      ));
    }

    return SizedBox(
      width: viewportW,
      height: cfg.cardH,
      child: ClipRect(
        child: Stack(clipBehavior: Clip.none, children: children),
      ),
    );
  }

  Widget _card(HeroSlide s) {
    return _Hoverable(
      onTap: () => widget.onNavigate(1),
      scale: 1.03,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              s.image,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              loadingBuilder: (c, child, p) =>
                  p == null ? child : const ColoredBox(color: AppColors.royalBlue),
              errorBuilder: (c, e, st) =>
                  const ColoredBox(color: AppColors.royalBlue),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xE6041025), Color(0x00041025)],
                  stops: [0.0, 0.62],
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      s.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 16,
              child: Text(
                '${s.titleLine1} ${s.titleLine2}'.toUpperCase(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----- bottom controls --------------------------------------------------

  Widget _controls(double t, bool small) {
    return Row(
      children: [
        _arrow(Icons.arrow_back, () => _manual(-1)),
        const SizedBox(width: 12),
        _arrow(Icons.arrow_forward, () => _manual(1)),
        const SizedBox(width: 22),
        Expanded(child: _progress()),
      ],
    );
  }

  Widget _arrow(IconData icon, VoidCallback onTap) {
    return _Hoverable(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white38),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _progress() {
    final frac =
        ((_index + 1 + _ctrl.value * _dir) / _n).clamp(0.06, 1.0).toDouble();
    return SizedBox(
      height: 2,
      child: LayoutBuilder(
        builder: (c, cc) => Stack(
          children: [
            Container(height: 2, color: Colors.white24),
            Container(height: 2, width: cc.maxWidth * frac, color: AppColors.gold),
          ],
        ),
      ),
    );
  }

  // ----- top nav (optional) ----------------------------------------------

  Widget _navBar(bool small) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _logo(),
          if (!small) ...[
            Expanded(
              child: Center(
                child: Wrap(
                  spacing: 26,
                  children: [
                    _navLink('Home', 0),
                    _navLink('Courses', 1),
                    _navLink('Programs', 2),
                    _navLink('Gallery', 3),
                    _navLink('About', 4),
                    _navLink('Contact', 5),
                  ],
                ),
              ),
            ),
            _navIcon(Icons.search),
            const SizedBox(width: 6),
            _navIcon(Icons.person_outline),
          ] else ...[
            const Spacer(),
            _Hoverable(
              onTap: () => widget.onNavigate(0),
              child: _navIcon(Icons.menu),
            ),
          ],
        ],
      ),
    );
  }

  Widget _logo() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gold, Color(0xFFE0B23A)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.school, color: AppColors.darkNavy, size: 18),
          ),
          const SizedBox(width: 10),
          const Text(
            'CAMBRIDGE', // <-- change to your institute name
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              fontSize: 15,
            ),
          ),
        ],
      );

  Widget _navLink(String label, int idx) => _Hoverable(
        onTap: () => widget.onNavigate(idx),
        scale: 1.0,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

  Widget _navIcon(IconData i) => Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.12),
        ),
        child: Icon(i, color: Colors.white, size: 18),
      );
}

/// Small hover-to-scale + click-cursor wrapper for the web.
class _Hoverable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  const _Hoverable({required this.child, this.onTap, this.scale = 1.06});

  @override
  State<_Hoverable> createState() => _HoverableState();
}

class _HoverableState extends State<_Hoverable> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hover ? widget.scale : 1.0,
          duration: const Duration(milliseconds: 180),
          child: widget.child,
        ),
      ),
    );
  }
}