import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_theme.dart';

/// ---------------------------------------------------------------------------
/// HERO SLIDER — card-expansion slider hero. The front-most card in the right
/// side carousel expands to fill the screen and becomes the new background as
/// the slide advances. Eyebrow + title + description swap in with a staggered
/// reveal. Auto-plays and has manual prev/next controls. Fully responsive.
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
    with TickerProviderStateMixin {
  int _active = 0;
  int? _incoming; // slide currently expanding into the background
  bool _reverse = false; // prev (fade) vs next (card-expand)

  late final AnimationController _expandCtrl; // card -> fullscreen
  late final AnimationController _textCtrl; // staggered text entrance
  Timer? _autoplay;

  int get _n => kHeroSlides.length;
  bool get _busy => _incoming != null;

  @override
  void initState() {
    super.initState();
    _expandCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _textCtrl.forward();
    _startAutoplay();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final s in kHeroSlides) {
        precacheImage(NetworkImage(s.image), context);
      }
    });
  }

  void _startAutoplay() {
    _autoplay?.cancel();
    if (_n <= 1) return;
    _autoplay = Timer.periodic(
        const Duration(seconds: 6), (_) => _goNext(userTriggered: false));
  }

  @override
  void dispose() {
    _autoplay?.cancel();
    _expandCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _goNext({bool userTriggered = true}) async {
    if (_busy || !mounted || _n <= 1) return;
    if (userTriggered) _startAutoplay();
    setState(() {
      _reverse = false;
      _incoming = (_active + 1) % _n;
    });
    _textCtrl.value = 0;
    await _expandCtrl.forward(from: 0);
    if (!mounted) return;
    setState(() {
      _active = _incoming!;
      _incoming = null;
      _expandCtrl.value = 0;
    });
    _textCtrl.forward(from: 0);
  }

  Future<void> _goPrev() async {
    if (_busy || !mounted || _n <= 1) return;
    _startAutoplay();
    setState(() {
      _reverse = true;
      _incoming = (_active - 1 + _n) % _n;
    });
    _textCtrl.value = 0;
    await _expandCtrl.forward(from: 0);
    if (!mounted) return;
    setState(() {
      _active = _incoming!;
      _incoming = null;
      _expandCtrl.value = 0;
    });
    _textCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final screenH = MediaQuery.of(context).size.height;
        final compact = w < 760;
        final heroH = (compact
                ? screenH.clamp(720.0, 1100.0)
                : screenH.clamp(620.0, 920.0))
            .toDouble();

        // ── card geometry ────────────────────────────────────────────────
        final int visible =
            w >= 1280 ? 4 : (w >= 1024 ? 3 : (w >= 760 ? 2 : 1));
        final double cardH = w >= 1280
            ? 240
            : (w >= 1024
                ? 225
                : (w >= 760 ? 210 : (w >= 520 ? 180 : 160)));
        final cardW = cardH * 0.68;
        const cardGap = 14.0;
        final hpad = compact ? 22.0 : (w >= 1100 ? 56.0 : 32.0);

        // controls sit near the bottom edge; cards sit just above them.
        const controlsH = 46.0;
        final cardsBottom = controlsH + (compact ? 26.0 : 36.0);
        final totalCardsW = visible * cardW + (visible - 1) * cardGap;
        final firstCardLeft = w - hpad - totalCardsW;
        final firstCardRect = Rect.fromLTWH(
            firstCardLeft, heroH - cardsBottom - cardH, cardW, cardH);

        final active = kHeroSlides[_active];
        final textDest = _busy ? kHeroSlides[_incoming!] : active;

        return SizedBox(
          width: double.infinity,
          height: heroH,
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _BgImage(url: active.image),
                if (_incoming != null)
                  AnimatedBuilder(
                    animation: _expandCtrl,
                    builder: (context, _) {
                      final t =
                          Curves.easeInOutCubic.transform(_expandCtrl.value);
                      final incoming = kHeroSlides[_incoming!];
                      if (_reverse) {
                        // prev: full-screen fade with a gentle settle-scale
                        return Opacity(
                          opacity: t,
                          child: Transform.scale(
                            scale: lerpDouble(1.08, 1.0, t)!,
                            child: _BgImage(url: incoming.image),
                          ),
                        );
                      }
                      // next: the first card grows until it fills the screen
                      final rect = Rect.lerp(
                          firstCardRect, Offset.zero & Size(w, heroH), t)!;
                      final radius = lerpDouble(18, 0, t)!;
                      return Positioned.fromRect(
                        rect: rect,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(radius),
                          child: _BgImage(url: incoming.image),
                        ),
                      );
                    },
                  ),
                const _Scrim(),
                // top gold accent line
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 3,
                    child: ColoredBox(color: AppColors.gold),
                  ),
                ),
                if (widget.showNavBar)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _NavBar(
                        compact: compact, onNavigate: widget.onNavigate),
                  ),
                // left text block — sits above the cards/controls
                Positioned(
                  left: hpad,
                  right: compact ? hpad : w * 0.45,
                  bottom: cardsBottom + cardH + (compact ? 20 : 28),
                  top: widget.showNavBar ? 90 : 24,
                  child: Center(
                    child: _HeroText(
                      destination: textDest,
                      controller: _textCtrl,
                      compact: compact,
                      onNavigate: widget.onNavigate,
                    ),
                  ),
                ),
                // destination cards
                Positioned(
                  right: hpad,
                  bottom: cardsBottom,
                  height: cardH,
                  child: _CardRow(
                    activeIndex: _active,
                    cardWidth: cardW,
                    cardHeight: cardH,
                    gap: cardGap,
                    visible: visible,
                    expandCtrl: _expandCtrl,
                    animatingNext: _busy && !_reverse,
                    onTapFirst: _goNext,
                  ),
                ),
                // bottom controls: arrows / progress / counter
                Positioned(
                  left: hpad,
                  right: hpad,
                  bottom: compact ? 14 : 18,
                  child: _BottomControls(
                    index: _busy ? _incoming! : _active,
                    total: _n,
                    onPrev: _goPrev,
                    onNext: _goNext,
                    compact: compact,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// BACKGROUND
// ---------------------------------------------------------------------------

class _BgImage extends StatelessWidget {
  final String url;
  const _BgImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => const ColoredBox(color: AppColors.darkNavy),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const ColoredBox(color: AppColors.darkNavy),
    );
  }
}

class _Scrim extends StatelessWidget {
  const _Scrim();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              const Color(0xF20A1B36).withValues(alpha: 0.85),
              const Color(0x990A1B36),
              Colors.transparent,
            ],
            stops: const [0.0, 0.45, 0.85],
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.35),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.5),
              ],
              stops: const [0.0, 0.35, 1.0],
            ),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// NAV BAR
// ---------------------------------------------------------------------------

class _NavBar extends StatelessWidget {
  final bool compact;
  final ValueChanged<int> onNavigate;
  const _NavBar({required this.compact, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    const items = ['Home', 'Courses', 'Programs', 'Gallery', 'About', 'Contact'];
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 22 : (compact ? 22 : 56), vertical: 22),
      child: Row(
        children: [
          _logo(),
          if (!compact) ...[
            Expanded(
              child: Center(
                child: Wrap(
                  spacing: 26,
                  children: [
                    for (var i = 0; i < items.length; i++)
                      _navLink(items[i], i),
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
              onTap: () => onNavigate(0),
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
                colors: [AppColors.gold, AppColors.goldDark],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.school, color: AppColors.darkNavy, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            'CAMBRIDGE',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              fontSize: 15,
            ),
          ),
        ],
      );

  Widget _navLink(String label, int idx) => _Hoverable(
        onTap: () => onNavigate(idx),
        scale: 1.0,
        child: Text(
          label,
          style: GoogleFonts.inter(
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

// ---------------------------------------------------------------------------
// LEFT TEXT BLOCK (staggered entrance)
// ---------------------------------------------------------------------------

class _HeroText extends StatelessWidget {
  final HeroSlide destination;
  final AnimationController controller;
  final bool compact;
  final ValueChanged<int> onNavigate;

  const _HeroText({
    required this.destination,
    required this.controller,
    required this.compact,
    required this.onNavigate,
  });

  Animation<double> _interval(double start, double end) => CurvedAnimation(
      parent: controller, curve: Interval(start, end, curve: Curves.easeOut));

  Widget _reveal(Animation<double> anim, Widget child, {double dy = 30}) {
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) => Opacity(
        opacity: anim.value.clamp(0.0, 1.0),
        child: Transform.translate(
            offset: Offset(0, dy * (1 - anim.value)), child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleSize = compact ? 36.0 : 58.0;
    final titleStyle = GoogleFonts.poppins(
      fontSize: titleSize,
      fontWeight: FontWeight.w800,
      height: 1.05,
      letterSpacing: 0.5,
      color: Colors.white,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _reveal(
          _interval(0.0, 0.35),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 28, height: 2, color: AppColors.gold),
              const SizedBox(width: 10),
              Text(
                destination.category,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          dy: 18,
        ),
        const SizedBox(height: 14),
        ClipRect(
          child: _reveal(
            _interval(0.1, 0.5),
            Text(destination.titleLine1, style: titleStyle),
            dy: 60,
          ),
        ),
        ClipRect(
          child: _reveal(
            _interval(0.2, 0.6),
            Text(destination.titleLine2,
                style: titleStyle.copyWith(color: AppColors.gold)),
            dy: 60,
          ),
        ),
        const SizedBox(height: 16),
        _reveal(
          _interval(0.35, 0.75),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: compact ? 520 : 480),
            child: Text(
              destination.description,
              maxLines: compact ? 2 : 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _reveal(
          _interval(0.5, 0.9),
          Wrap(
            spacing: 14,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _Hoverable(
                onTap: () => onNavigate(5),
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
                onTap: () => onNavigate(1),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white54),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'EXPLORE PROGRAMS',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_outward,
                          color: AppColors.gold, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// CARD ROW
// ---------------------------------------------------------------------------

class _CardRow extends StatelessWidget {
  final int activeIndex; // cards show activeIndex+1 .. activeIndex+visible
  final double cardWidth;
  final double cardHeight;
  final double gap;
  final int visible;
  final AnimationController expandCtrl;
  final bool animatingNext;
  final VoidCallback onTapFirst;

  const _CardRow({
    required this.activeIndex,
    required this.cardWidth,
    required this.cardHeight,
    required this.gap,
    required this.visible,
    required this.expandCtrl,
    required this.animatingNext,
    required this.onTapFirst,
  });

  @override
  Widget build(BuildContext context) {
    final n = kHeroSlides.length;
    return AnimatedBuilder(
      animation: expandCtrl,
      builder: (context, _) {
        final t = animatingNext
            ? Curves.easeInOutCubic.transform(expandCtrl.value)
            : 0.0;
        final shift = (cardWidth + gap) * t; // remaining cards slide left
        final children = <Widget>[];
        for (var i = 0; i < visible + 1; i++) {
          final dest = kHeroSlides[(activeIndex + 1 + i) % n];
          final isFirst = i == 0;
          children.add(
            Transform.translate(
              offset: Offset(-shift, 0),
              child: Opacity(
                // First card fades as the expanding overlay takes over;
                // the extra trailing card fades in as it enters.
                opacity: isFirst
                    ? (1 - t).clamp(0.0, 1.0)
                    : (i == visible ? t : 1.0),
                child: GestureDetector(
                  onTap: isFirst ? onTapFirst : null,
                  child: _DestinationCard(
                    destination: dest,
                    width: cardWidth,
                    height: cardHeight,
                  ),
                ),
              ),
            ),
          );
          if (i < visible) children.add(SizedBox(width: gap));
        }
        return ClipRect(
          child: Row(mainAxisSize: MainAxisSize.min, children: children),
        );
      },
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final HeroSlide destination;
  final double width;
  final double height;

  const _DestinationCard({
    required this.destination,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _BgImage(url: destination.image),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00041025), Color(0xE6041025)],
                  stops: [0.45, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(width: 18, height: 2, color: AppColors.gold),
                  const SizedBox(height: 8),
                  Text(
                    destination.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${destination.titleLine1}\n${destination.titleLine2}',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
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

// ---------------------------------------------------------------------------
// BOTTOM CONTROLS
// ---------------------------------------------------------------------------

class _BottomControls extends StatelessWidget {
  final int index;
  final int total;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final bool compact;

  const _BottomControls({
    required this.index,
    required this.total,
    required this.onPrev,
    required this.onNext,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleButton(icon: Icons.arrow_back_ios_new, onTap: onPrev),
        const SizedBox(width: 12),
        _CircleButton(icon: Icons.arrow_forward_ios, onTap: onNext),
        const SizedBox(width: 22),
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) => Stack(
              children: [
                Container(height: 2, color: Colors.white24),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOutCubic,
                  height: 2,
                  width: c.maxWidth * ((index + 1) / total),
                  color: AppColors.gold,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 22),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, anim) => SlideTransition(
            position: Tween(begin: const Offset(0, 0.6), end: Offset.zero)
                .animate(anim),
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Text(
            (index + 1).toString().padLeft(2, '0'),
            key: ValueKey(index),
            style: GoogleFonts.poppins(
              fontSize: compact ? 24 : 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _Hoverable(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        ),
        child: Icon(icon, size: 14, color: Colors.white),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HOVER HELPER
// ---------------------------------------------------------------------------

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
