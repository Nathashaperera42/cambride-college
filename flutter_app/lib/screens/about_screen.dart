import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_data.dart';
import '../core/constants/app_theme.dart';
import '../widgets/common.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        PageBanner(
          title: 'About Governess College of English',
          subtitle:
              'Empowering students with world-class English education and '
              'Cambridge-recognized qualifications.',
        ),
        _AboutBody(),
        _StatsBar(),
        _FacultySection(),
        _TeacherTrainingSection(),
      ],
    );
  }
}

// ── About body ────────────────────────────────────────────────────────────────

class _AboutBody extends StatelessWidget {
  const _AboutBody();

  static const _teacherImg =
      'https://res.cloudinary.com/dsypqpuci/image/upload/v1780423579/WhatsApp_Image_2026-03-26_at_17.02.35_uupaer.jpg';

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final textCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ABOUT US',
            style: TextStyle(
                color: AppColors.royalBlue,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                fontSize: 13)),
        const SizedBox(height: 12),
        Text(AppData.aboutTitle,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontSize: isMobile ? 26 : 34)),
        const SizedBox(height: 8),
        Container(width: 60, height: 3, color: AppColors.gold),
        const SizedBox(height: 20),
        const Text(AppData.aboutBody,
            style: TextStyle(
                color: AppColors.darkText, height: 1.7, fontSize: 15)),
        const SizedBox(height: 20),
        ...AppData.aboutPoints.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: AppColors.royalBlue, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(p,
                      style: const TextStyle(
                          color: AppColors.darkText, fontSize: 15)),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    final imageCol = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 360,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Teacher photo from Cloudinary
            CachedNetworkImage(
              imageUrl: _teacherImg,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                decoration: const BoxDecoration(
                    gradient: AppColors.blueCardGradient),
                child: const Center(
                  child: CircularProgressIndicator(
                      color: Colors.white54, strokeWidth: 2),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                    gradient: AppColors.blueCardGradient),
                child: const Center(
                  child: Icon(Icons.school, color: Colors.white24, size: 90),
                ),
              ),
            ),
            // Subtle dark overlay so the stat card text reads cleanly
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x99000000)],
                  stops: [0.45, 1.0],
                ),
              ),
            ),
            // Stat card overlay
            Positioned(
              left: 20,
              bottom: 20,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.royalBlue,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('10+',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800)),
                    Text('Years of\nExcellence',
                        style:
                            TextStyle(color: Colors.white70, height: 1.3)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Container(
      width: double.infinity,
      color: AppColors.white,
      child: ContentWrap(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
        child: isMobile
            ? Column(children: [textCol, const SizedBox(height: 32), imageCol])
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: textCol),
                  const SizedBox(width: 40),
                  Expanded(child: imageCol),
                ],
              ),
      ),
    );
  }
}

// ── Stats bar ─────────────────────────────────────────────────────────────────

class _StatsBar extends StatelessWidget {
  const _StatsBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.lightBlueBg,
      child: ContentWrap(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            gradient: AppColors.blueCardGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ResponsiveGrid(
            columnsFor: (w) => w >= 700 ? 4 : 2,
            spacing: 16,
            runSpacing: 24,
            children: AppData.aboutStats.map((s) {
              return Column(
                children: [
                  Icon(s.icon, color: Colors.white, size: 30),
                  const SizedBox(height: 10),
                  Text(s.value,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800)),
                  Text(s.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── Faculty credentials ───────────────────────────────────────────────────────

class _FacultySection extends StatelessWidget {
  const _FacultySection();

  static const _facultyImg =
      'https://res.cloudinary.com/dsypqpuci/image/upload/v1780423579/WhatsApp_Image_2026-03-26_at_17.02.35_uupaer.jpg';

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    const cards = Column(
      children: [
        // Cambridge Credentials card
        _CredentialCard(
          color: Color(0xFFEEF5FF),
          iconColor: Color(0xFF1A56DB),
          icon: Icons.school_outlined,
          title: 'Cambridge Credentials',
          subtitle: 'Internationally Recognized',
          items: [
            _CredItem(
              icon: Icons.verified_outlined,
              iconColor: Color(0xFF059669),
              label: 'CELTA Certification',
              detail:
                  'Certificate in English Language Teaching to Adults — '
                  'the globally recognized Cambridge teaching qualification.',
            ),
            _CredItem(
              icon: Icons.verified_outlined,
              iconColor: Color(0xFF059669),
              label: 'DELTA Qualification',
              detail:
                  'Diploma in English Language Teaching to Adults — '
                  'advanced professional qualification for experienced teachers.',
            ),
          ],
        ),
        SizedBox(height: 20),

        // Professional Experience card
        _CredentialCard(
          color: Color(0xFFFFF7ED),
          iconColor: Color(0xFFEA580C),
          icon: Icons.group_outlined,
          title: 'Professional Experience',
          subtitle: 'Global Expertise',
          items: [
            _CredItem(
              icon: Icons.public,
              iconColor: Color(0xFF2563EB),
              label: 'International Training',
              detail:
                  'Trained by Cambridge Assessment English specialists with '
                  'exposure to global teaching methodologies.',
            ),
            _CredItem(
              icon: Icons.star_outline,
              iconColor: Color(0xFF2563EB),
              label: 'Master Trainer Status',
              detail:
                  'Recognized as a Master Trainer by the Sri Lanka – UK '
                  'performing arts network.',
            ),
          ],
        ),
      ],
    );

    final photo = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: CachedNetworkImage(
          imageUrl: _facultyImg,
          fit: BoxFit.cover,
          placeholder: (_, __) =>
              const ColoredBox(color: Color(0xFFDDE7F5)),
          errorWidget: (_, __, ___) => Container(
            color: const Color(0xFFDDE7F5),
            child: const Icon(Icons.person_outline,
                size: 64, color: Colors.black26),
          ),
        ),
      ),
    );

    return Container(
      width: double.infinity,
      color: AppColors.white,
      child: ContentWrap(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(
              title: 'Meet Our Faculty',
              subtitle:
                  'Our educators hold internationally recognised Cambridge '
                  'qualifications and decades of combined teaching experience.',
            ),
            const SizedBox(height: 40),
            isMobile
                ? Column(children: [
                    cards,
                    const SizedBox(height: 28),
                    photo,
                  ])
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(flex: 5, child: cards),
                      const SizedBox(width: 32),
                      Expanded(flex: 3, child: photo),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

// ── Credential card ───────────────────────────────────────────────────────────

class _CredentialCard extends StatelessWidget {
  final Color color;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<_CredItem> items;

  const _CredentialCard({
    required this.color,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: iconColor)),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedText)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: item.iconColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.icon,
                          color: item.iconColor, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.label,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.darkNavy)),
                          const SizedBox(height: 3),
                          Text(item.detail,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.mutedText,
                                  height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _CredItem {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String detail;
  const _CredItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.detail,
  });
}

// ── Teacher training overview ─────────────────────────────────────────────────

class _TeacherTrainingSection extends StatelessWidget {
  const _TeacherTrainingSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.lightBlueBg,
      child: ContentWrap(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
        child: Column(
          children: [
            // Eyebrow
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.royalBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Faculty Excellence',
                style: TextStyle(
                    color: AppColors.royalBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Teacher Training Overview',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                  ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Our teachers undergo rigorous professional development to deliver '
              'the highest quality Cambridge-aligned instruction.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.mutedText, fontSize: 15, height: 1.6),
            ),
            const SizedBox(height: 40),

            // Cards
            ResponsiveGrid(
              columnsFor: (w) => w >= 860 ? 3 : (w >= 540 ? 2 : 1),
              children: const [
                _TrainingCard(
                  iconColor: Color(0xFF2563EB),
                  icon: Icons.school_outlined,
                  title: 'Cambridge Certification',
                  body:
                      'All faculty hold Cambridge CELTA or DELTA certificates, '
                      'ensuring internationally validated teaching standards '
                      'in every classroom.',
                ),
                _TrainingCard(
                  iconColor: Color(0xFFEA580C),
                  icon: Icons.auto_stories_outlined,
                  title: 'Continuous Development',
                  body:
                      'Regular workshops, webinars and peer observations keep '
                      'our team current with the latest Cambridge curriculum '
                      'updates and pedagogical research.',
                ),
                _TrainingCard(
                  iconColor: Color(0xFF059669),
                  icon: Icons.groups_outlined,
                  title: 'Peer Collaboration',
                  body:
                      'Teachers engage in collaborative lesson planning and '
                      'reflective practice sessions to share best strategies '
                      'and continuously improve outcomes.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainingCard extends StatelessWidget {
  final Color iconColor;
  final IconData icon;
  final String title;
  final String body;

  const _TrainingCard({
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 18),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: AppColors.darkNavy)),
          const SizedBox(height: 10),
          Text(body,
              style: const TextStyle(
                  color: AppColors.mutedText, fontSize: 14, height: 1.65)),
        ],
      ),
    );
  }
}
