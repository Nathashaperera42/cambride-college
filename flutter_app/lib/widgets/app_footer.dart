import 'package:flutter/material.dart';
import '../core/constants/app_data.dart';
import '../core/constants/app_theme.dart';
import 'brand_logo.dart';
import 'common.dart';

class AppFooter extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const AppFooter({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final columns = <Widget>[
      SizedBox(
        width: isMobile ? double.infinity : 280,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BrandLogo(onDark: true),
            SizedBox(height: 16),
            Text(
              'Forming Global Leaders through Cambridge English Qualifications.',
              style: TextStyle(color: Colors.white70, height: 1.6, fontSize: 14),
            ),
            SizedBox(height: 12),
            Text(
              'Governess College of English is a Cambridge qualification '
              'registration center.',
              style: TextStyle(color: AppColors.footerLink, fontSize: 13, height: 1.5),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                _FooterSocial(icon: Icons.facebook),
                SizedBox(width: 10),
                _FooterSocial(icon: Icons.music_note),
                SizedBox(width: 10),
                _FooterSocial(icon: Icons.play_circle_fill),
              ],
            ),
          ],
        ),
      ),
      _FooterLinks(
        title: 'Quick Links',
        items: AppData.navItems
            .map((n) => _LinkData(n.label, () => onNavigate(n.index)))
            .toList(),
      ),
      _FooterLinks(
        title: 'Our Courses',
        items: [
          _LinkData('Young Learners English', () => onNavigate(1)),
          _LinkData('Key English Test', () => onNavigate(1)),
          _LinkData('Preliminary English', () => onNavigate(1)),
          _LinkData('First Certificate', () => onNavigate(1)),
          _LinkData('Adults Spoken English', () => onNavigate(1)),
        ],
      ),
      SizedBox(
        width: isMobile ? double.infinity : 240,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact Us',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
            SizedBox(height: 16),
            _ContactRow(icon: Icons.phone, text: AppData.phone1),
            _ContactRow(icon: Icons.email_outlined, text: AppData.email),
            _ContactRow(icon: Icons.location_on_outlined, text: AppData.address),
          ],
        ),
      ),
    ];

    return Container(
      width: double.infinity,
      color: AppColors.footerBg,
      child: ContentWrap(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          children: [
            Wrap(
              spacing: 40,
              runSpacing: 32,
              children: columns,
            ),
            const SizedBox(height: 32),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 20),
            const Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Text(
                  '© 2026 Governess College of English. All rights reserved.',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                Text(
                  'Cambridge English Qualifications Registration Center',
                  style: TextStyle(color: AppColors.footerLink, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkData {
  final String label;
  final VoidCallback? onTap;
  const _LinkData(this.label, this.onTap);
}

class _FooterLinks extends StatelessWidget {
  final String title;
  final List<_LinkData> items;
  const _FooterLinks({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16)),
          const SizedBox(height: 16),
          ...items.map(
            (l) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: l.onTap,
                hoverColor: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    l.label,
                    style: TextStyle(
                      color: l.onTap != null
                          ? Colors.white70
                          : Colors.white38,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.footerLink),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 14, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _FooterSocial extends StatelessWidget {
  final IconData icon;
  const _FooterSocial({required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      hoverColor: Colors.white.withValues(alpha: 0.12),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}
