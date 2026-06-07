import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_data.dart';
import '../core/constants/app_theme.dart';
import '../widgets/cards.dart';
import '../widgets/common.dart';

// ── Existing Cloudinary images ────────────────────────────────────────────────
const _kHero =
    'https://res.cloudinary.com/dsypqpuci/image/upload/v1780727301/WhatsApp_Image_2026-03-26_at_17.06.35_2_fjzvhm.jpg';

const _kGallery = [
  (
    'Teacher & Center Awards',
    'https://res.cloudinary.com/dsypqpuci/image/upload/v1780423579/WhatsApp_Image_2026-03-26_at_17.02.35_uupaer.jpg',
  ),
  (
    'Exam Day',
    'https://res.cloudinary.com/dsypqpuci/image/upload/v1780727351/WhatsApp_Image_2026-04-22_at_21.36.12_1_ar6ret.jpg',
  ),
  (
    'Certificates & Awards',
    'https://res.cloudinary.com/dsypqpuci/image/upload/v1780463897/WhatsApp_Image_2026-03-26_at_17.02.36_dorml3.jpg',
  ),
  (
    'Teacher Training & Webinars',
    'https://res.cloudinary.com/dsypqpuci/image/upload/v1780727332/WhatsApp_Image_2026-04-22_at_21.35.14_c5x5r6.jpg',
  ),
];

// ── Page ─────────────────────────────────────────────────────────────────────

class SpeechDramaPage extends StatelessWidget {
  const SpeechDramaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1 — Hero banner with photo
        const _HeroSection(),

        // 2 — Why Speech & Drama? feature cards
        Container(
          width: double.infinity,
          color: AppColors.white,
          child: ContentWrap(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
            child: Column(
              children: [
                const SectionTitle(
                  title: 'Why Speech & Drama?',
                  subtitle:
                      'Performance-based learning that builds lifelong '
                      'confidence and communication skills.',
                ),
                const SizedBox(height: 40),
                ResponsiveGrid(
                  columnsFor: (w) => w >= 900 ? 4 : (w >= 600 ? 2 : 1),
                  children: AppData.dramaFeatures
                      .map((f) => FeatureCard(feature: f))
                      .toList(),
                ),
              ],
            ),
          ),
        ),

        // 3 — Photo gallery grid
        Container(
          width: double.infinity,
          color: AppColors.lightBlueBg,
          child: const ContentWrap(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 64),
            child: Column(
              children: [
                SectionTitle(
                  title: 'Moments We Celebrate',
                  subtitle:
                      'A glimpse into the life, achievements and milestones '
                      'of our Speech & Drama students.',
                ),
                SizedBox(height: 40),
                _PhotoGrid(),
              ],
            ),
          ),
        ),

        // 4 — CTA / Annual Prize Giving
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(gradient: AppColors.goldGradient),
          child: ContentWrap(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
            child: Column(
              children: [
                Text(
                  'Annual Prize Giving — Speech & Drama 2025',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: AppColors.darkText),
                ),
                const SizedBox(height: 16),
                const Text(
                  "A celebration of our students' growth, creativity and stage "
                  'presence — recognizing achievement across all programs.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.darkText, height: 1.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Hero section ──────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF071440), Color(0xFF0B4DA2)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: ContentWrap(
        padding: EdgeInsets.symmetric(
            horizontal: 24, vertical: isMobile ? 48 : 72),
        child: isMobile
            ? Column(children: [
                _leftContent(isMobile: true),
                const SizedBox(height: 36),
                _heroPhoto(),
              ])
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 5, child: _leftContent(isMobile: false)),
                  const SizedBox(width: 48),
                  Expanded(flex: 4, child: _heroPhoto()),
                ],
              ),
      ),
    );
  }

  Widget _leftContent({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Eyebrow badge
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.45)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.workspace_premium_outlined,
                  color: AppColors.gold, size: 14),
              SizedBox(width: 6),
              Text(
                'Cambridge Certified Institution',
                style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Heading
        Text(
          'Speech & Drama\nExcellence',
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 34 : 46,
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 14),
          width: 56,
          height: 3,
          color: AppColors.gold,
        ),

        // Description
        const Text(
          'At the Performing Art Division of Governess College of English, '
          'students develop confidence, creativity, and powerful communication '
          'skills through professional Speech & Drama training and '
          'international performing arts opportunities.',
          style: TextStyle(
              color: Colors.white70, fontSize: 14, height: 1.75),
        ),
        const SizedBox(height: 28),

        // Feature chips
        const Wrap(
          spacing: 20,
          runSpacing: 12,
          children: [
            _FeatureChip(
                icon: Icons.auto_awesome_outlined,
                label: 'Creative Expression'),
            _FeatureChip(
                icon: Icons.mic_outlined, label: 'Confident Speaking'),
            _FeatureChip(
                icon: Icons.public, label: 'International Exams'),
            _FeatureChip(
                icon: Icons.theater_comedy_outlined,
                label: 'Stage Opportunities'),
          ],
        ),
      ],
    );
  }

  Widget _heroPhoto() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: CachedNetworkImage(
          imageUrl: _kHero,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
              color: AppColors.royalBlue.withValues(alpha: 0.3)),
          errorWidget: (_, __, ___) => Container(
              color: AppColors.royalBlue.withValues(alpha: 0.3),
              child: const Icon(Icons.image_outlined,
                  color: Colors.white38, size: 48)),
        ),
      ),
    );
  }
}

// ── Feature chip ──────────────────────────────────────────────────────────────

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.gold, size: 16),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Photo gallery grid ────────────────────────────────────────────────────────

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      final cols = constraints.maxWidth >= 600 ? 2 : 1;
      const gap = 16.0;
      final cardW =
          (constraints.maxWidth - gap * (cols - 1)) / cols;
      final cardH = cardW * 0.62;

      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: _kGallery.map((item) {
          final (label, url) = item;
          return _PhotoCard(
            label: label,
            imageUrl: url,
            width: cardW,
            height: cardH,
          );
        }).toList(),
      );
    });
  }
}

// ── Individual photo card with overlay ───────────────────────────────────────

class _PhotoCard extends StatelessWidget {
  final String label;
  final String imageUrl;
  final double width;
  final double height;

  const _PhotoCard({
    required this.label,
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  const ColoredBox(color: Color(0xFF1A2332)),
              errorWidget: (_, __, ___) =>
                  const ColoredBox(color: Color(0xFF1A2332)),
            ),

            // Bottom gradient overlay
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00000000),
                    Color(0x99000000),
                    Color(0xDD000000),
                  ],
                  stops: [0.4, 0.75, 1.0],
                ),
              ),
            ),

            // Label
            Positioned(
              bottom: 18,
              left: 18,
              right: 18,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
