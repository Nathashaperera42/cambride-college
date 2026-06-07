import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_data.dart';
import '../core/constants/app_theme.dart';
import '../widgets/common.dart';

// ── Event data with Cloudinary images ────────────────────────────────────────

class _EventItem {
  final String title;
  final String description;
  final String imageUrl;
  const _EventItem(this.title, this.description, this.imageUrl);
}

const _kEvents = [
  _EventItem(
    'Cambridge YLE Flyers – Batch 12',
    'Congratulations to our latest batch of Cambridge YLE Flyers graduates! '
        'Students demonstrated exceptional vocabulary, reading, writing and '
        'listening skills in this prestigious international examination.',
    'https://res.cloudinary.com/dsypqpuci/image/upload/v1780727301/WhatsApp_Image_2026-03-26_at_17.06.35_2_fjzvhm.jpg',
  ),
  _EventItem(
    'British Lanka Festival 2025 at Mikeila Resort Chilaw in May',
    'Governess College proudly participated in the British Lanka Performing '
        'Arts Festival, where our students showcased their Speech & Drama '
        'talents on an international stage, earning recognition and awards.',
    'https://res.cloudinary.com/dsypqpuci/image/upload/v1780727351/WhatsApp_Image_2026-04-22_at_21.36.12_1_ar6ret.jpg',
  ),
  _EventItem(
    'The Centre Managers Conference 2025',
    'Our principal attended the prestigious Cambridge Centre Managers '
        'Conference, bringing back the latest updates on curriculum '
        'developments, examination standards and best teaching practices.',
    'https://res.cloudinary.com/dsypqpuci/image/upload/v1780727332/WhatsApp_Image_2026-04-22_at_21.35.14_c5x5r6.jpg',
  ),
];

// ── Page ─────────────────────────────────────────────────────────────────────

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1 — Hero
        const _EventsHero(),

        // 2 — Event cards
        Container(
          width: double.infinity,
          color: AppColors.white,
          child: ContentWrap(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
            child: Column(
              children: [
                const SectionTitle(
                  title: 'Latest Events & News',
                  subtitle:
                      'Stay up to date with our activities, achievements '
                      'and upcoming programs.',
                ),
                const SizedBox(height: 40),
                LayoutBuilder(builder: (_, constraints) {
                  final cols = constraints.maxWidth >= 860
                      ? 3
                      : constraints.maxWidth >= 540
                          ? 2
                          : 1;
                  const gap = 24.0;
                  final cardW =
                      (constraints.maxWidth - gap * (cols - 1)) / cols;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: _kEvents
                        .map((e) =>
                            _EventCard(event: e, width: cardW))
                        .toList(),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Hero section ──────────────────────────────────────────────────────────────

class _EventsHero extends StatelessWidget {
  const _EventsHero();

  static const _heroImg =
      'https://res.cloudinary.com/dsypqpuci/image/upload/v1780425759/WhatsApp_Image_2026-03-26_at_17.02.45_h3b4ct.jpg';

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF071440), Color(0xFF0B3A8F)],
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
                _photo(),
              ])
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 5, child: _leftContent(isMobile: false)),
                  const SizedBox(width: 48),
                  Expanded(flex: 4, child: _photo()),
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.3)),
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
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Title
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: isMobile ? 34 : 46,
              fontWeight: FontWeight.w800,
              height: 1.12,
            ),
            children: const [
              TextSpan(
                  text: 'Discover Events\nThat ',
                  style: TextStyle(color: Colors.white)),
              TextSpan(
                  text: 'Inspire',
                  style: TextStyle(color: AppColors.gold)),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          width: 56,
          height: 3,
          color: AppColors.gold,
        ),

        // Description
        const Text(
          'From exciting gatherings to engaging workshops, explore the events '
          'we have planned. Join us and be part of inspiring moments and '
          'meaningful connections.',
          style: TextStyle(
              color: Colors.white70, fontSize: 14, height: 1.75),
        ),
        const SizedBox(height: 32),

        // Contact items
        _contactItem(Icons.phone_outlined, 'Call us directly',
            AppData.phone2),
        const SizedBox(height: 14),
        _contactItem(
            Icons.email_outlined, 'Email us', AppData.email),
        const SizedBox(height: 14),
        _contactItem(Icons.location_on_outlined, 'Visit us',
            'Walaw Waththa, Madampe 61230'),
      ],
    );
  }

  Widget _contactItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.35)),
          ),
          child: Icon(icon, color: AppColors.gold, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _photo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: CachedNetworkImage(
          imageUrl: _heroImg,
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

// ── Event card ────────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final _EventItem event;
  final double width;
  const _EventCard({required this.event, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: event.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    const ColoredBox(color: Color(0xFF1A2332)),
                errorWidget: (_, __, ___) =>
                    const ColoredBox(color: Color(0xFF1A2332)),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkNavy,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.mutedText,
                      height: 1.6,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 11),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Explore More',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
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
