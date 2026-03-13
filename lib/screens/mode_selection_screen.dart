import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundDark,
              Color(0xFF0C2227),
              AppTheme.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      const NeonGlowText('Select Game Mode',
                          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                      const Text('Choose your battlefield', style: TextStyle(color: AppTheme.primaryColor)),
                      const SizedBox(height: 32),
                      _buildModeCard(
                        context,
                        title: 'Offline Mode',
                        tag: 'Solo / Local',
                        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC1OLFHSSPJ3P4CjTQ7m_HmjJipCyT4ZQZ2qhiBKw3x1Nood-tU4qNdKCETEfBWropq3zloUMpekUJmW3vub-aoxeDLGzNDyxF83zFsaIMqjkWLj7yfVTy1wOTE4DscY143fvtmbdlmcrjnUAqFBiiMnzrviEA0RA74P_Pq5EzFn-HVefh-bD5irmKDL0P2mUTfDKi3IgGpgvvFfVN-gFcUi2zvnWLTYdxiLRdp3ipd6T04ypJgHaIn8sCvve0i4T4rMfDe3Pyg8wUU',
                        description: 'Perfect your strategy against our advanced AI or challenge a friend sitting right next to you.',
                        actionButton: ElevatedButton.icon(
                          onPressed: () => context.push('/emojis'),
                          icon: const Icon(Icons.smart_toy, color: Colors.black),
                          label: const Text('Play Offline', style: TextStyle(color: Colors.black)),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shadowColor: AppTheme.primaryColor,
                            elevation: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildOnlineModeCard(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          const Expanded(
            child: Text(
              'Tic-Tac-Toe',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(width: 48), // Balance for centering
        ],
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String tag,
    required String imageUrl,
    required String description,
    required Widget actionButton,
  }) {
    return GlassPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.black26,
                child: Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey[900])),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    tag.toUpperCase(),
                    style: const TextStyle(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(description, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 16),
                actionButton,
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOnlineModeCard(BuildContext context) {
    return _buildModeCard(
      context,
      title: 'Online Mode',
      tag: 'Multiplayer',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCCZxb8ESLYs-WzP47j0cCUy7OmmKUuJ2NJBcLidops1hPqVzK8Ll06uEKNGQElqWUF5XSApl4snCBxrATJBmebcku5CRuCX3ESzfOl4rrHsmaUena2pSo7TPMnbRGYxTqxzaI3Nr-l8lX6o2OKCtRX1or0dsNi8YOCgQ0Q-ki_175CyFoIqvRFSBgYxUZo2ojw1hC9EWzFsrhSuYUXDhX5uwoUtsrhRFcHaw8ggVyphGxdmufmN3VmidQ42TNWEiw1SzU2038iZPTv',
      description: 'Compete with grandmasters worldwide. Climb the global leaderboard and earn exclusive rewards.',
      actionButton: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.login, color: AppTheme.primaryColor),
                  label: const Text('Login', style: TextStyle(color: AppTheme.primaryColor)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.person_add, color: Colors.grey),
                  label: const Text('Register', style: TextStyle(color: Colors.grey)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('AUTHENTICATION REQUIRED FOR RANKED PLAY', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1.5)),
        ],
      ),
    );
  }
}
