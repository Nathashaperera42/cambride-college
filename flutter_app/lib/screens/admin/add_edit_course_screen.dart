import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/course_api_model.dart';
import '../../providers/course_provider.dart';
import '../../routes/route_names.dart';
import 'admin_shell.dart';

const _kPrimary = Color(0xFF5558CF);
const _kTitleColor = Color(0xFF1A1D3D);
const _kBorderColor = Color(0xFFE8E8F0);

class AddEditCourseScreen extends ConsumerStatefulWidget {
  final CourseApiModel? course;
  const AddEditCourseScreen({super.key, this.course});

  @override
  ConsumerState<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends ConsumerState<AddEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _shortDescCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _featuresCtrl;
  late final TextEditingController _ageGroupCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _levelCtrl;
  late String _category;
  late bool _isPublished;
  late bool _isFeatured;
  late bool _gold;
  bool _loading = false;

  bool get _isEdit => widget.course != null;

  static const _categories = ['YLE', 'KET', 'PET', 'FCE', 'Speech & Drama', 'Spoken English', 'General', 'Other'];

  @override
  void initState() {
    super.initState();
    final c = widget.course;
    _titleCtrl = TextEditingController(text: c?.title ?? '');
    _descCtrl = TextEditingController(text: c?.description ?? '');
    _shortDescCtrl = TextEditingController(text: c?.shortDescription ?? '');
    _priceCtrl = TextEditingController(text: c != null ? c.price.toStringAsFixed(2) : '');
    _featuresCtrl = TextEditingController(text: c?.features.join('\n') ?? '');
    _ageGroupCtrl = TextEditingController(text: c?.ageGroup ?? '');
    _durationCtrl = TextEditingController(text: c?.duration ?? '');
    _levelCtrl = TextEditingController(text: c?.level ?? '');
    _category = c?.category ?? 'General';
    _isPublished = c?.isPublished ?? true;
    _isFeatured = c?.isFeatured ?? false;
    _gold = c?.gold ?? false;
  }

  @override
  void dispose() {
    for (final c in [_titleCtrl, _descCtrl, _shortDescCtrl, _priceCtrl, _featuresCtrl, _ageGroupCtrl, _durationCtrl, _levelCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = {
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'shortDescription': _shortDescCtrl.text.trim(),
      'price': double.tryParse(_priceCtrl.text.trim()) ?? 0,
      'category': _category,
      'features': _featuresCtrl.text.trim(),
      'ageGroup': _ageGroupCtrl.text.trim(),
      'duration': _durationCtrl.text.trim(),
      'level': _levelCtrl.text.trim(),
      'isPublished': _isPublished,
      'isFeatured': _isFeatured,
      'gold': _gold,
    };

    final notifier = ref.read(courseProvider.notifier);
    final success = _isEdit
        ? await notifier.updateCourse(widget.course!.id, data)
        : await notifier.createCourse(data);

    setState(() => _loading = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit ? 'Course updated!' : 'Course created!'),
        backgroundColor: Colors.green,
      ));
      context.go(Routes.adminCourses);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ref.read(courseProvider).error ?? 'An error occurred.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      activeRoute: Routes.adminCourses,
      breadcrumbs: ['Admin', 'Courses', _isEdit ? 'Edit' : 'Add'],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: _kBorderColor)),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_isEdit ? 'Edit Course' : 'Add New Course',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _kTitleColor)),
                    const SizedBox(height: 24),
                    _field(_titleCtrl, 'Course Title *', required: true),
                    const SizedBox(height: 14),
                    _field(_shortDescCtrl, 'Short Description'),
                    const SizedBox(height: 14),
                    _field(_descCtrl, 'Full Description *', required: true, maxLines: 4),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(child: _field(_priceCtrl, 'Price (Rs.) *', required: true, number: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _dropdown('Category', _categories, _category, (v) => setState(() => _category = v!))),
                    ]),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(child: _field(_ageGroupCtrl, 'Age Group')),
                      const SizedBox(width: 12),
                      Expanded(child: _field(_durationCtrl, 'Duration')),
                      const SizedBox(width: 12),
                      Expanded(child: _field(_levelCtrl, 'Level')),
                    ]),
                    const SizedBox(height: 14),
                    _field(_featuresCtrl, 'Features (one per line)', maxLines: 5,
                        hint: 'Speaking\nListening\nReading'),
                    const SizedBox(height: 20),
                    const Text('Options', style: TextStyle(fontWeight: FontWeight.w600, color: _kTitleColor)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 16, children: [
                      _toggle('Published', _isPublished, (v) => setState(() => _isPublished = v)),
                      _toggle('Featured', _isFeatured, (v) => setState(() => _isFeatured = v)),
                      _toggle('Gold Card Style', _gold, (v) => setState(() => _gold = v)),
                    ]),
                    const SizedBox(height: 28),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      OutlinedButton(
                        onPressed: () => context.go(Routes.adminCourses),
                        style: OutlinedButton.styleFrom(foregroundColor: _kTitleColor, side: const BorderSide(color: _kBorderColor), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(backgroundColor: _kPrimary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: _loading
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(_isEdit ? 'Save Changes' : 'Create Course', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ]),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, {bool required = false, bool number = false, int maxLines = 1, String? hint}) =>
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: number
            ? const TextInputType.numberWithOptions(decimal: true)
            : (maxLines > 1 ? TextInputType.multiline : TextInputType.text),
        textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kBorderColor)),
          filled: true, fillColor: const Color(0xFFF8F8FC),
        ),
        validator: required
            ? (v) {
                if (v == null || v.trim().isEmpty) return '$label is required';
                if (number) {
                  final n = double.tryParse(v.trim());
                  if (n == null) return 'Enter a valid number';
                  if (n < 0) return 'Price cannot be negative';
                }
                return null;
              }
            : null,
      );

  Widget _dropdown(String label, List<String> items, String value, ValueChanged<String?> onChanged) =>
      DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kBorderColor)),
          filled: true, fillColor: const Color(0xFFF8F8FC),
        ),
        items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
        onChanged: onChanged,
      );

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Switch(value: value, onChanged: onChanged, activeThumbColor: _kPrimary),
        Text(label, style: const TextStyle(fontSize: 13, color: _kTitleColor)),
      ]);
}
