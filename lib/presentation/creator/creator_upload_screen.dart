import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/api_content_types.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/widgets/gradient_cta_button.dart';
import '../../core/widgets/superstar_app_bar.dart';
import '../../data/repositories/content_repository_impl.dart';
import '../../data/repositories/superstar_repository_impl.dart';
import '../../presentation/providers/auth_provider.dart';

class CreatorUploadScreen extends ConsumerStatefulWidget {
  const CreatorUploadScreen({super.key});

  @override
  ConsumerState<CreatorUploadScreen> createState() => _CreatorUploadScreenState();
}

class _CreatorUploadScreenState extends ConsumerState<CreatorUploadScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _contentType = ApiContentTypes.photo;
  String _tier = 'SILVER';
  String? _imagePath;
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _imagePath = file.path);
  }

  Future<void> _submit() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    setState(() => _loading = true);
    try {
      final superstarId = await ref.read(superstarRepositoryProvider).resolveMySuperstarId(
            userId: user.id,
            superstarId: user.superstarId,
          );
      if (superstarId == null || superstarId.isEmpty) {
        throw Exception('No superstar profile linked to this account.');
      }

      final content = await ref.read(contentRepositoryProvider).create(
            title: _titleController.text.trim(),
            body: _bodyController.text.trim(),
            contentType: _contentType,
            tierRequired: _tier,
            tags: ['mobile'],
          );

      if (_imagePath != null) {
        await ref.read(contentRepositoryProvider).uploadMedia(
              contentId: content.id,
              filePath: _imagePath!,
              fileName: 'upload.jpg',
              mediaType: ApiContentTypes.mediaUploadType(_contentType),
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Content submitted for review')),
        );
        context.go('/creator/library');
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SuperstarAppBar(title: 'Upload Content'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Caption / body'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _contentType,
            decoration: const InputDecoration(labelText: 'Content type'),
            items: ApiContentTypes.all
                .map(
                  (v) => DropdownMenuItem(
                    value: v,
                    child: Text(ApiContentTypes.label(v)),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _contentType = v ?? ApiContentTypes.photo),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _tier,
            decoration: const InputDecoration(labelText: 'Tier required'),
            items: const [
              DropdownMenuItem(value: 'SILVER', child: Text('Silver')),
              DropdownMenuItem(value: 'GOLD', child: Text('Gold')),
              DropdownMenuItem(value: 'PLATINUM', child: Text('Platinum')),
            ],
            onChanged: (v) => setState(() => _tier = v ?? 'SILVER'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image_outlined),
            label: Text(_imagePath == null ? 'Attach image (optional)' : 'Image selected'),
          ),
          const SizedBox(height: 24),
          GradientCtaButton(
            label: 'Publish',
            isLoading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
