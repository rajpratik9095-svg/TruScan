import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.support_agent, size: 60, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'How can we help you?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We\'re here to help you with any questions',
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // FAQ Section
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            _buildFAQItem(
              'How do I scan a product?',
              'Go to the Scanner tab and point your camera at the product barcode. The app will automatically detect and scan the barcode.',
            ),
            _buildFAQItem(
              'Why is my scanned product not found?',
              'Some products may not be in our database yet. You can help by adding product information manually.',
            ),
            _buildFAQItem(
              'How do I track my diet?',
              'Go to the Diet tab to log your meals, track calories, and monitor your nutritional intake.',
            ),
            _buildFAQItem(
              'How do I change my password?',
              'Go to Profile > Edit Profile > Change Password section to update your password.',
            ),
            _buildFAQItem(
              'Is my data synced across devices?',
              'Yes! When you\'re logged in, your data is automatically synced to the cloud and available on all your devices.',
            ),
            
            const SizedBox(height: 24),

            // Contact Section
            const Text(
              'Contact Us',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            _buildContactItem(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'support@truescan.app',
              onTap: () => _launchEmail('support@truescan.app'),
            ),
            _buildContactItem(
              icon: Icons.chat_outlined,
              title: 'Live Chat',
              subtitle: 'Available 9 AM - 6 PM',
              onTap: () {
                Get.snackbar('Coming Soon', 'Live chat will be available soon',
                    backgroundColor: AppTheme.primaryGradientStart, colorText: Colors.white);
              },
            ),
            _buildContactItem(
              icon: Icons.phone_outlined,
              title: 'Phone Support',
              subtitle: '+91 1800-XXX-XXXX',
              onTap: () => _launchPhone('+911800000000'),
            ),
            
            const SizedBox(height: 24),

            // Report Issue
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.bug_report, size: 40, color: Colors.orange),
                  const SizedBox(height: 12),
                  const Text(
                    'Found a Bug?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Help us improve by reporting issues',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _launchEmail('bugs@truescan.app'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange),
                    ),
                    child: const Text('Report Issue', style: TextStyle(color: Colors.orange)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // App Version
            Center(
              child: Column(
                children: [
                  Text(
                    'TrueScan v1.0.0',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Made with ❤️ in India',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(answer, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryGradientStart.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryGradientStart),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    try {
      await launchUrl(uri);
    } catch (e) {
      Get.snackbar('Error', 'Could not open email app',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    try {
      await launchUrl(uri);
    } catch (e) {
      Get.snackbar('Error', 'Could not open phone app',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
