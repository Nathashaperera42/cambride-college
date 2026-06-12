import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../core/constants/app_data.dart';
import '../core/constants/app_theme.dart';
import '../widgets/cards.dart';
import '../widgets/common.dart';
import '../widgets/hero_slider.dart'; // <-- NEW: the slider hero

class HomePage extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const HomePage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // If you already render a global top navigation bar, pass
        // `showNavBar: false` so it isn't duplicated.
        HeroSlider(onNavigate: onNavigate, showNavBar: false),
        _AboutSection(onNavigate: onNavigate),
        _MissionVisionSection(),
        _ProgramsSection(),
        _ExpertsSection(onNavigate: onNavigate),
        _TestimonialsSection(),
        _CtaBanner(onNavigate: onNavigate),
      ],
    );
  }
}

class _Eyebrow extends StatelessWidget {
  final String text;
  final bool onDark;
  const _Eyebrow(this.text, {this.onDark = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(
            letterSpacing: 1.6,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: onDark ? Colors.white70 : AppColors.royalBlue,
          ),
        ),
        const SizedBox(width: 10),
        Container(width: 42, height: 2, color: AppColors.gold),
      ],
    );
  }
}

class _ImageBox extends StatelessWidget {
  final double? width;
  final double height;
  final String? imageUrl;
  final IconData icon;
  final Gradient gradient;
  final double radius;

  const _ImageBox({
    this.width,
    required this.height,
    this.imageUrl,
    this.icon = Icons.image_outlined,
    this.gradient = AppColors.blueCardGradient,
  }) : radius = 16;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: imageUrl == null
            ? Container(
                decoration: BoxDecoration(gradient: gradient),
                child: Icon(icon, color: Colors.white24, size: 64),
              )
            : Image.network(
                imageUrl!,
                width: width,
                height: height,
                fit: BoxFit.cover,
                loadingBuilder: (c, child, progress) => progress == null
                    ? child
                    : Container(
                        decoration: BoxDecoration(gradient: gradient),
                      ),
                errorBuilder: (c, e, s) => Container(
                  color: AppColors.lightGray,
                  child: const Icon(Icons.broken_image_outlined,
                      color: AppColors.mutedText, size: 40),
                ),
              ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  const _StatBadge({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.royalBlue,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800)),
              const Text('+',
                  style: TextStyle(color: AppColors.gold, fontSize: 16)),
            ],
          ),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const _AboutSection({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final images = SizedBox(
      height: isMobile ? 260 : 360,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: _ImageBox(
                  width: isMobile ? w : w * 0.62,
                  height: isMobile ? 220 : 300,
                  icon: Icons.school_outlined,
                  imageUrl:
                      'https://res.cloudinary.com/dsypqpuci/image/upload/v1780423579/WhatsApp_Image_2026-03-26_at_17.02.35_uupaer.jpg',
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: _ImageBox(
                  width: isMobile ? w * 0.5 : w * 0.42,
                  height: isMobile ? 150 : 220,
                  icon: Icons.cast_for_education_outlined,
                  gradient: AppColors.goldCardGradient,
                  imageUrl:
                      'https://res.cloudinary.com/dsypqpuci/image/upload/v1780423579/WhatsApp_Image_2026-03-26_at_17.02.35_uupaer.jpg',
                ),
              ),
              Positioned(
                left: 0,
                bottom: isMobile ? 0 : 24,
                child: const _StatBadge(
                    value: '6', label: 'Years Of Experience'),
              ),
            ],
          );
        },
      ),
    );

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Eyebrow(AppData.aboutEyebrow),
        const SizedBox(height: 16),
        Text(AppData.aboutHeading,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontSize: isMobile ? 26 : 34, height: 1.25)),
        const SizedBox(height: 16),
        const Text(AppData.aboutBody,
            style: TextStyle(
                color: AppColors.mutedText, height: 1.7, fontSize: 15)),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.only(left: 16),
          decoration: const Border(
            left: BorderSide(color: AppColors.gold, width: 3),
          ).toBoxDecoration(),
          child: const Text('"${AppData.aboutQuote}"',
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: AppColors.darkText,
                  height: 1.6)),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Icon(Icons.calendar_month_outlined,
                color: AppColors.royalBlue),
            const SizedBox(width: 10),
            Text('6+ Years Of Experience',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 17)),
          ],
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.only(left: 34),
          child: Text(
            'Cambridge-trained faculty, modern methods and proven results.',
            style: TextStyle(color: AppColors.mutedText),
          ),
        ),
        const SizedBox(height: 24),
        PillButton(
            label: 'Learn More',
            trailingIcon: Icons.arrow_forward,
            onPressed: () => onNavigate(4)),
      ],
    );

    return Container(
      width: double.infinity,
      color: AppColors.white,
      child: ContentWrap(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
        child: isMobile
            ? Column(children: [images, const SizedBox(height: 56), text])
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: images),
                  const SizedBox(width: 48),
                  Expanded(child: text),
                ],
              ),
      ),
    );
  }
}

const String _kMissionVideoUrl =
    'https://res.cloudinary.com/dsypqpuci/video/upload/v1780471003/AQMEXxU5MvcjMxEpGv7sutHrMLZ7FwtPIyIqAU-pcRCemuSHEKz61thZTeaopfitBYj2tpiZxwxOmeuT9VA4hGduSNsXNDP2g2iIfh4cvOCtzg_-_Trim_nev04q.mp4';

class _MissionVisionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final cards = ResponsiveGrid(
      columnsFor: (w) => w >= 720 ? 2 : 1,
      children: const [
        _MvCard(
          icon: Icons.visibility_outlined,
          title: AppData.visionTitle,
          body: AppData.visionBody,
        ),
        _MvCard(
          icon: Icons.flag_outlined,
          title: AppData.missionTitle,
          body: AppData.missionBody,
        ),
      ],
    );

    return SizedBox(
      width: double.infinity,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          const Positioned.fill(
            child: _VideoBackground(url: _kMissionVideoUrl),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xCC062A5C),
                    Color(0x99083B7A),
                    Color(0xE6062A5C),
                  ],
                ),
              ),
            ),
          ),
          ContentWrap(
            padding: EdgeInsets.symmetric(
                horizontal: 24, vertical: isMobile ? 56 : 88),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Eyebrow(AppData.missionEyebrow, onDark: true),
                const SizedBox(height: 16),
                Text(AppData.missionSectionTitle,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                            color: Colors.white,
                            fontSize: isMobile ? 26 : 40,
                            fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isMobile ? 520 : 640),
                  child: Text(AppData.missionSubtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: isMobile ? 14 : 16,
                          height: 1.7)),
                ),
                const SizedBox(height: 40),
                cards,
                const SizedBox(height: 40),
                _StatsBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoBackground extends StatefulWidget {
  final String url;
  const _VideoBackground({required this.url});

  @override
  State<_VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<_VideoBackground> {
  late VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _ready = true);
          _controller.play();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const ColoredBox(color: AppColors.darkNavy);
    }
    return ColoredBox(
      color: AppColors.darkNavy,
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}

class _MvCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _MvCard(
      {required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
            top: BorderSide(color: AppColors.gold, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.royalBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 14),
          Text(title,
              style: const TextStyle(
                  color: AppColors.darkNavy,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(body,
              style: const TextStyle(
                  color: AppColors.mutedText, height: 1.6, fontSize: 14)),
        ],
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.darkNavy,
        borderRadius: BorderRadius.circular(14),
        border: const Border(
            top: BorderSide(color: AppColors.gold, width: 3)),
      ),
      child: ResponsiveGrid(
        columnsFor: (w) => w >= 640 ? 4 : 2,
        spacing: 12,
        runSpacing: 20,
        children: AppData.aboutStats.map((s) {
          return Column(
            children: [
              Text(s.value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(s.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ProgramsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.lightBlueBg,
      child: ContentWrap(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
        child: Column(
          children: [
            const SectionTitle(
              title: AppData.qualSectionTitle,
              subtitle: AppData.qualSectionSubtitle,
            ),
            const SizedBox(height: 40),
            ResponsiveGrid(
              columnsFor: (w) => w >= 1000 ? 4 : (w >= 640 ? 2 : 1),
              children: AppData.programs
                  .map((c) => CourseCard(course: c))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpertsSection extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const _ExpertsSection({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final images = SizedBox(
      height: isMobile ? 240 : 320,
      child: LayoutBuilder(builder: (context, c) {
        final w = c.maxWidth;
        return Stack(
          children: [
            Positioned(
                left: 0,
                top: 0,
                child: _ImageBox(
                    width: w * 0.46,
                    height: isMobile ? 220 : 300,
                    icon: Icons.person_outline,
                    imageUrl:
                        'https://res.cloudinary.com/dsypqpuci/image/upload/v1780423579/WhatsApp_Image_2026-03-26_at_17.02.35_uupaer.jpg')),
            Positioned(
                right: 0,
                bottom: 0,
                child: _ImageBox(
                    width: w * 0.46,
                    height: isMobile ? 180 : 250,
                    icon: Icons.person_outline,
                    gradient: AppColors.goldCardGradient,
                    imageUrl:
                        'https://res.cloudinary.com/dsypqpuci/image/upload/v1780423579/WhatsApp_Image_2026-03-26_at_17.02.35_uupaer.jpg')),
          ],
        );
      }),
    );

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Eyebrow(AppData.expertsEyebrow),
        const SizedBox(height: 16),
        Text(AppData.expertsTitle,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontSize: isMobile ? 24 : 32, height: 1.25)),
        const SizedBox(height: 20),
        ...AppData.whyUs.map(
          (f) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle,
                    color: AppColors.royalBlue, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkNavy)),
                      Text(f.description,
                          style: const TextStyle(
                              color: AppColors.mutedText, height: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        PillButton(
            label: 'Discover Courses',
            trailingIcon: Icons.arrow_forward,
            onPressed: () => onNavigate(1)),
      ],
    );

    return Container(
      width: double.infinity,
      color: AppColors.white,
      child: ContentWrap(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
        child: isMobile
            ? Column(children: [images, const SizedBox(height: 40), text])
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: images),
                  const SizedBox(width: 48),
                  Expanded(child: text),
                ],
              ),
      ),
    );
  }
}

class _TestimonialsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.lightBlueBg,
      child: ContentWrap(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
        child: Column(
          children: [
            const SectionTitle(
              title: AppData.testimonialsTitle,
              subtitle: AppData.testimonialsSubtitle,
            ),
            const SizedBox(height: 40),
            ResponsiveGrid(
              columnsFor: (w) => w >= 900 ? 3 : 1,
              children: AppData.testimonials
                  .map((t) => TestimonialCard(testimonial: t))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CtaBanner extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const _CtaBanner({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: ContentWrap(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Let's Discuss Your Goals &\nStart Your Cambridge Journey",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        fontSize: isMobile ? 24 : 34),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Book a free consultation with our Cambridge-trained '
                    'faculty and find the right course for you.',
                    style: TextStyle(color: Colors.white70, height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  PillButton(
                      label: 'Get a Consultation',
                      gold: true,
                      trailingIcon: Icons.arrow_forward,
                      onPressed: () => onNavigate(5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small extension so the quote block can use a left-border decoration.
extension on Border {
  BoxDecoration toBoxDecoration() => BoxDecoration(border: this);
}