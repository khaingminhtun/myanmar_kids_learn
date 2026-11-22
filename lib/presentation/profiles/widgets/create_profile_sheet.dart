import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/avatar_catalog.dart';
import '../../../core/widgets/avatar_badge.dart';

typedef ProfileDraft = ({String name, String avatarId});

class CreateProfileSheet extends StatefulWidget {
  const CreateProfileSheet({super.key});

  @override
  State<CreateProfileSheet> createState() => _CreateProfileSheetState();
}

class _CreateProfileSheetState extends State<CreateProfileSheet> {
  final TextEditingController _nameController = TextEditingController();
  AvatarOption _selected = AvatarCatalog.all.first;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop<ProfileDraft>(
      (name: _nameController.text.trim(), avatarId: _selected.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.inkSoft.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'ကိုယ်ပိုင် ပရိုဖိုင် ဖန်တီးမယ်',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'အမည် ထည့်နိုင်ပါတယ်။ မထည့်ရင် “ကလေး” လို့ ခေါ်ပါမယ်။',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _nameController,
              maxLength: 20,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'ကလေးအမည်',
                hintText: 'ဥပမာ — မောင်မောင်',
                prefixIcon: Icon(Icons.badge_rounded),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'တိရစ္ဆာန် ပုံလေး ရွေးပါ',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 12,
              children: [
                for (final avatar in AvatarCatalog.all)
                  _AvatarChoice(
                    avatar: avatar,
                    selected: avatar.id == _selected.id,
                    onTap: () => setState(() => _selected = avatar),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('ပရိုဖိုင် ဖန်တီးမယ်'),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('မလုပ်တော့ပါ'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarChoice extends StatelessWidget {
  const _AvatarChoice({
    required this.avatar,
    required this.selected,
    required this.onTap,
  });

  final AvatarOption avatar;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${avatar.label} ပုံ ရွေးမယ်',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AvatarBadge(
                avatarId: avatar.id,
                size: 64,
                selected: selected,
              ),
              const SizedBox(height: 4),
              Text(
                avatar.label,
                style: TextStyle(
                  fontFamily: 'NotoSansMyanmar',
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.orangeDeep : AppColors.inkSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
