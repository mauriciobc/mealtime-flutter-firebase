import 'package:flutter/material.dart';
import 'package:mealtime/models/household_model.dart';

class MemberListTile extends StatelessWidget {
  final HouseholdMember member;
  final bool isCurrentUser;
  final bool canChangeRole;
  final Function(String)? onRoleChanged;

  const MemberListTile({
    super.key,
    required this.member,
    this.isCurrentUser = false,
    this.canChangeRole = false,
    this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isCurrentUser
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceVariant,
        child: isCurrentUser
            ? Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.onPrimary,
              )
            : Text(
                member.displayName?.isNotEmpty == true
                    ? member.displayName![0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
      title: Text(
        member.displayName ?? 'Membro',
        style: TextStyle(
          fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (member.email != null)
            Text(
              member.email!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          Text(
            'Entrou em ${_formatDate(member.joinedAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRoleChip(context),
          if (canChangeRole) ...[
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: onRoleChanged,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'member',
                  child: Text('Membro'),
                ),
                const PopupMenuItem(
                  value: 'admin',
                  child: Text('Administrador'),
                ),
              ],
              child: Icon(
                Icons.more_vert,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoleChip(BuildContext context) {
    final isAdmin = member.role == 'admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isAdmin ? 'Admin' : 'Membro',
        style: TextStyle(
          color: isAdmin
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'hoje';
    } else if (difference.inDays == 1) {
      return 'ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 semana atrás' : '$weeks semanas atrás';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 mês atrás' : '$months meses atrás';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 ano atrás' : '$years anos atrás';
    }
  }
}
