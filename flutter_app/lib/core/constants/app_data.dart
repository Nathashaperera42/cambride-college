import 'package:flutter/material.dart';
import '../../models/models.dart';

/// All textual content for the site lives here so pages stay clean.
class AppData {
  AppData._();

  // Brand / contact
  static const String brandName = 'Governess College';
  static const String brandSub = 'of English';
  static const String tagline = 'FORMING GLOBAL LEADERS';

  static const String phone1 = '076 - 1229238';
  static const String phone2 = '076 - 7468886';
  static const String email = 'collegegoverness@gmail.com';
  static const String address = 'Waslow Waratha, Madampitiya 81220, Sri Lanka';

  static const String facebookUrl = 'https://www.facebook.com/profile.php?id=61561191773895';
  static const String instagramUrl = 'https://www.instagram.com/governesscollege';
  static const String youtubeUrl = 'https://www.youtube.com/@governesscollege';
  static const String whatsappUrl = 'https://wa.me/94761229238';

  // Mission & Vision
  static const String missionEyebrow = 'OUR MISSION & VISION';
  static const String missionSectionTitle =
      'Discover The Core Principles That Guide Us';
  static const String missionSubtitle =
      'Forming confident, globally-minded communicators through Cambridge '
      'English Qualifications — wherever your journey leads.';
  static const String visionTitle = 'Our Vision';
  static const String visionBody =
      'To form confident, globally-minded communicators who open doors '
      'worldwide through Cambridge-recognized English qualifications.';
  static const String missionTitle = 'Our Mission';
  static const String missionBody =
      'To deliver world-class English education with expert faculty, '
      'personalized attention and a supportive learning environment.';

  static const String aboutEyebrow = 'ABOUT US';
  static const String aboutHeading =
      'We Form Global Leaders Through Cambridge English';
  static const String aboutQuote =
      'Empowering minds with English communication skills for a successful '
      'global future.';

  static const String expertsEyebrow = 'WHY CHOOSE US';
  static const String expertsTitle =
      'Discover Why Students Choose Governess College';

  // Navigation
  static const List<NavItem> navItems = [
    NavItem('Home', 0),
    NavItem('Courses', 1),
    NavItem('Speech & Drama', 2),
    NavItem('Events', 3),
    NavItem('About Us', 4),
    NavItem('Contact Us', 5),
  ];

  // Hero
  static const String heroBadge = 'Cambridge Certified Institution';
  static const String heroTitleLine1 = 'We Form';
  static const String heroTitleLine2 = 'Global Leaders';
  static const String heroSubtitle =
      'Unlock your potential with Cambridge-recognized English '
      'qualifications that open doors worldwide.';

  static const List<StatItem> heroStats = [
    StatItem(value: '2,500+', label: 'Students'),
    StatItem(value: '6+', label: 'Years'),
    StatItem(value: '99%', label: 'Success'),
  ];

  static const List<String> heroTags = [
    'Age 3 - 60',
    'Cambridge Certified',
    'Global Recognition',
  ];

  // Cambridge English Qualifications row
  static const String qualSectionTitle = 'Cambridge English Qualifications';
  static const String qualSectionSubtitle =
      'We are a Cambridge English Qualifications registration center for the '
      'British Council, providing globally recognized certifications that open '
      'doors worldwide.';

  static const List<Feature> qualFeatures = [
    Feature(
      icon: Icons.workspace_premium_outlined,
      title: 'Official Cambridge Center',
      description: 'Authorized registration center for British Council.',
    ),
    Feature(
      icon: Icons.public,
      title: 'Global Recognition',
      description: 'Qualifications accepted worldwide.',
    ),
    Feature(
      icon: Icons.groups_outlined,
      title: 'Expert Faculty',
      description: 'Cambridge-trained instructors.',
    ),
    Feature(
      icon: Icons.insights_outlined,
      title: 'Proven Results',
      description: '98% success rate in examinations.',
    ),
  ];

  static const List<MapEntry<String, String>> examList = [
    MapEntry('KET (Key English Test)', '120+ Students'),
    MapEntry('PET (Preliminary)', '100+ Students'),
    MapEntry('FCE (First Certificate)', '50+ Students'),
  ];

  // Programs / courses
  static const List<Course> programs = [
    Course(
      title: 'YLE Starters',
      level: 'Pre-A1 Level',
      ageGroup: '6–8 years',
      duration: '8–10 months',
      category: 'YLE',
      price: 45.00,
      description:
          'Building foundational vocabulary, sentence structure, and oral '
          'confidence through fun, picture-based activities.',
      shortDescription:
          'Building foundational vocabulary, sentence structure, and oral confidence.',
      features: [
        'Listening: identifying objects, people, and actions',
        'Speaking: naming pictures, answering short questions, using full sentences',
        'Reading & Writing: recognizing words, writing simple sentences, spelling common words',
        'Fun tasks: picture-based activities, songs, storytelling, role-play',
      ],
    ),
    Course(
      title: 'KET (Key English Test)',
      level: 'A2 Level',
      ageGroup: '10–14 years',
      duration: '10–12 months',
      category: 'KET',
      price: 55.00,
      gold: true,
      description:
          'Basic level English qualification demonstrating ability to '
          'communicate confidently in simple, everyday situations.',
      shortDescription:
          'Build everyday English communication skills to succeed in real-life situations at A2 level.',
      features: [
        'Reading: real-world texts, notices, and signs',
        'Writing: short emails, messages, and notes',
        'Listening: short conversations and announcements',
        'Speaking: personal information and everyday topics',
      ],
    ),
    Course(
      title: 'PET (Preliminary English Test)',
      level: 'B1 Level',
      ageGroup: '12–17 years',
      duration: '10–12 months',
      category: 'PET',
      price: 65.00,
      description:
          'Intermediate level qualification for everyday English communication '
          'in work, study and travel situations.',
      shortDescription:
          'Demonstrate practical English for work, study, and travel at an intermediate B1 level.',
      features: [
        'Reading: articles, notices, and real-world texts',
        'Writing: short messages, articles, and essays',
        'Listening: conversations and radio broadcasts',
        'Speaking: discussion, opinion giving, and picture description',
      ],
    ),
    Course(
      title: 'FCE (First Certificate in English)',
      level: 'B2 Level',
      ageGroup: '14+ years',
      duration: '12–18 months',
      category: 'FCE',
      price: 80.00,
      gold: true,
      description:
          'Upper-intermediate qualification for academic and professional '
          'purposes, widely recognized by universities and employers worldwide.',
      shortDescription:
          'Achieve B2-level proficiency recognized by top universities and employers around the world.',
      features: [
        'Reading & Use of English: complex texts and grammar in context',
        'Writing: essays, reports, reviews, and formal letters',
        'Listening: lectures, discussions, and interviews',
        'Speaking: collaborative tasks and sustained discussion',
      ],
    ),
  ];

  // Testimonials
  static const String testimonialsTitle = 'Voices of Trust';
  static const String testimonialsSubtitle =
      'Hear what parents and professionals say about our Cambridge English '
      'programs — trusted, globally recognized, and life-changing.';

  static const List<Testimonial> testimonials = [
    Testimonial(
      name: 'Sarah Mitchell',
      role: 'Parent',
      rating: 5,
      review:
          'My daughter improved her English significantly. The Cambridge '
          'certification opened doors for her university applications.',
    ),
    Testimonial(
      name: 'Himandi & Sithuki\'s Parent',
      role: 'Parent',
      rating: 5,
      review:
          'Thanks to Governess College of English and Teacher Ishara, my '
          'daughter\'s confidence and English skills have greatly improved.',
    ),
    Testimonial(
      name: 'Proud Parent of Graduates',
      role: 'Parent',
      rating: 5,
      review:
          'As a proud parent of graduates, I highly recommend Governess College '
          'of English for improving all four language skills.',
    ),
  ];

  // About page
  static const String aboutTitle = 'About Governess College of English';
  static const String aboutBody =
      'At Governess College of English, we believe in the power of '
      'communication. Our mission is to help students of all ages develop '
      'strong English language skills, build confidence and achieve their '
      'personal and professional goals.';

  static const List<String> aboutPoints = [
    'Personalized attention',
    'Modern teaching methods',
    'Supportive learning environment',
    'Focus on speaking, listening, reading & writing',
  ];

  static const List<StatItem> aboutStats = [
    StatItem(value: '1000+', label: 'Students Trained', icon: Icons.school_outlined),
    StatItem(value: '10+', label: 'Expert Instructors', icon: Icons.cast_for_education_outlined),
    StatItem(value: '20+', label: 'Courses Offered', icon: Icons.menu_book_outlined),
    StatItem(value: '100%', label: 'Student Satisfaction', icon: Icons.verified_outlined),
  ];

  static const List<Feature> whyUs = [
    Feature(
      icon: Icons.groups_outlined,
      title: 'Expert Instructors',
      description: 'Learn from experienced and passionate communication professionals.',
    ),
    Feature(
      icon: Icons.menu_book_outlined,
      title: 'Comprehensive Courses',
      description: 'A wide range of courses designed to build confidence and fluency.',
    ),
    Feature(
      icon: Icons.chat_bubble_outline,
      title: 'Practical Learning',
      description: 'Interactive sessions and real-life practice for effective communication.',
    ),
    Feature(
      icon: Icons.public,
      title: 'Global Opportunities',
      description: 'We prepare you to connect, communicate and succeed worldwide.',
    ),
  ];

  static const List<Feature> offeredCourses = [
    Feature(
      icon: Icons.chat_bubble_outline,
      title: 'Spoken English',
      description: 'Improve your speaking skills and speak confidently.',
    ),
    Feature(
      icon: Icons.edit_outlined,
      title: 'Grammar & Writing',
      description: 'Master English grammar and writing with ease.',
    ),
    Feature(
      icon: Icons.people_outline,
      title: 'Communication Skills',
      description: 'Enhance your overall communication for success.',
    ),
    Feature(
      icon: Icons.mic_none_outlined,
      title: 'Public Speaking',
      description: 'Overcome fear and become an effective public speaker.',
    ),
    Feature(
      icon: Icons.work_outline,
      title: 'Business English',
      description: 'Learn English for workplace and professional growth.',
    ),
  ];

  // Speech & Drama
  static const String dramaTitle = 'Speech & Drama';
  static const String dramaSubtitle =
      'Build confidence, expression and stage presence through our Speech & '
      'Drama programs — from storytelling to public performance.';

  static const List<Feature> dramaFeatures = [
    Feature(
      icon: Icons.theater_comedy_outlined,
      title: 'Stage Confidence',
      description: 'Overcome stage fright and perform with poise.',
    ),
    Feature(
      icon: Icons.record_voice_over_outlined,
      title: 'Voice & Diction',
      description: 'Clear pronunciation, projection and expression.',
    ),
    Feature(
      icon: Icons.auto_stories_outlined,
      title: 'Storytelling',
      description: 'Creative narration and dramatic interpretation.',
    ),
    Feature(
      icon: Icons.emoji_events_outlined,
      title: 'Annual Prize Giving',
      description: 'Showcase talent at our annual Speech & Drama event.',
    ),
  ];

  // Events
  static const String eventsTitle = 'Events & Achievements';
  static const String eventsSubtitle =
      'Celebrating milestones, ceremonies and student achievements throughout '
      'the year.';

  static const List<Course> events = [
    Course(
      title: 'Annual Prize Giving — Speech & Drama 2025',
      description:
          'Our flagship annual ceremony recognizing outstanding students across '
          'Speech & Drama and Cambridge qualifications.',
      features: ['Awards Ceremony', 'Student Performances', 'Certificates'],
    ),
    Course(
      title: 'Cambridge Exam Preparation Workshops',
      description:
          'Focused workshops preparing students for KET, PET and FCE '
          'examinations.',
      features: ['Mock Exams', 'Expert Guidance', 'Skill Building'],
      gold: true,
    ),
    Course(
      title: 'Graduation Ceremony',
      description:
          'Honoring graduates who successfully completed their Cambridge '
          'English qualifications.',
      features: ['Recognition', 'Family Celebration', 'Networking'],
    ),
  ];
}
