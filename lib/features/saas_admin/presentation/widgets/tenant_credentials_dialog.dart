import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/tenant_create_result.dart';

Future<void> showTenantCredentialsDialog(
  BuildContext context,
  TenantCreateResult result,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Tenant created'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Save these credentials — they will not be shown again.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              _CredentialRow(
                label: 'School name',
                value: result.tenant.name,
              ),
              _CredentialRow(
                label: 'Tenant slug',
                value: result.tenant.slug,
              ),
              _CredentialRow(
                label: 'Admin email',
                value: result.adminUser.email,
              ),
              if (result.tempPassword != null)
                _CredentialRow(
                  label: 'Temporary password',
                  value: result.tempPassword!,
                  highlight: true,
                )
              else
                const Padding(
                  padding: EdgeInsetsDirectional.only(top: 8),
                  child: Text(
                    'Admin password was set manually during creation.',
                  ),
                ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Done'),
          ),
        ],
      );
    },
  );
}

class _CredentialRow extends StatelessWidget {
  const _CredentialRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 4),
                SelectableText(
                  value,
                  style: highlight
                      ? Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          )
                      : Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Copy $label',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label copied')),
              );
            },
            icon: const Icon(Icons.copy, size: 20),
          ),
        ],
      ),
    );
  }
}
