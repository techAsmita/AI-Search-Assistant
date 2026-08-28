import 'package:flutter/material.dart';
import 'package:perplexity_clone/theme/colors.dart';

class SideBar extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;
  final VoidCallback onNewChat;
  final VoidCallback onHistory;

  const SideBar({
    super.key,
    required this.isCollapsed,
    required this.onToggle,
    required this.onNewChat,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isCollapsed ? 72 : 220,
      color: AppColors.sideNav,
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Logo + Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppColors.accent,
                    size: 22,
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Perplexity",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                if (!isCollapsed)
                  IconButton(
                    onPressed: onToggle,
                    icon: const Icon(
                      Icons.chevron_left,
                      color: AppColors.iconGrey,
                      size: 20,
                    ),
                    tooltip: "Collapse sidebar",
                  ),
              ],
            ),
          ),

          if (isCollapsed)
            IconButton(
              onPressed: onToggle,
              icon: const Icon(
                Icons.chevron_right,
                color: AppColors.iconGrey,
                size: 20,
              ),
              tooltip: "Expand sidebar",
            ),

          const SizedBox(height: 24),

          // Main actions
          _buildNavItem(
            icon: Icons.add,
            label: "New Chat",
            tooltip: "Start a new chat",
            onTap: onNewChat,
            isCollapsed: isCollapsed,
          ),
          _buildNavItem(
            icon: Icons.history,
            label: "History",
            tooltip: "View past chats",
            onTap: onHistory,
            isCollapsed: isCollapsed,
          ),

          const Spacer(),

          // Minimal bottom items (no fake functionality)
          _buildNavItem(
            icon: Icons.help_outline,
            label: "Help",
            tooltip: "Help",
            onTap: () {},
            isCollapsed: isCollapsed,
          ),
          _buildNavItem(
            icon: Icons.settings_outlined,
            label: "Settings",
            tooltip: "Settings",
            onTap: () {},
            isCollapsed: isCollapsed,
          ),

          const SizedBox(height: 8),

          // Profile
          Padding(
            padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
            child: isCollapsed
                ? const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.searchBar,
                    child: Icon(
                      Icons.person_outline,
                      color: AppColors.iconGrey,
                      size: 18,
                    ),
                  )
                : Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.searchBar,
                        child: Icon(
                          Icons.person_outline,
                          color: AppColors.iconGrey,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Guest",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String tooltip,
    required VoidCallback onTap,
    required bool isCollapsed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            hoverColor: AppColors.accentSoft,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCollapsed ? 0 : 12,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: isCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Icon(icon, color: AppColors.iconGrey, size: 22),
                  if (!isCollapsed) ...[
                    const SizedBox(width: 14),
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
