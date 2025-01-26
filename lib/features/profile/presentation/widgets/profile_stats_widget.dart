import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_profile_model.dart';
import '../pages/followers_page.dart';
import '../pages/following_page.dart';

class ProfileStatsWidget extends StatelessWidget {
  final UserProfile profile;

  const ProfileStatsWidget({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            context,
            'Çizimler',
            profile.drawingsCount,
            Icons.brush_outlined,
            onTap: null,
          ),
          _buildDivider(),
          _buildStatItem(
            context,
            'Takipçi',
            profile.followersCount,
            Icons.people_outline,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FollowersPage(userId: profile.id),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildStatItem(
            context,
            'Takip',
            profile.followingCount,
            Icons.person_add_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FollowingPage(userId: profile.id),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    int count,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.deepPurple,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }
}
