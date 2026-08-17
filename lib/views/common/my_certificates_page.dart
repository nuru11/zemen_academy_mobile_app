import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_academy/controllers/controllers.dart';
import 'package:vector_academy/services/services.dart';
import 'package:vector_academy/views/common/certification_cards.dart';
import 'package:vector_academy/views/views.dart';

class MyCertificatesPage extends StatelessWidget {
  const MyCertificatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isAuthenticated =
        Get.isRegistered<AuthService>() &&
        Get.find<AuthService>().isAuthenticated;

    return GetBuilder<CertificateController>(
      builder: (certController) => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'My Certificates',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: certController.isLoading
                  ? null
                  : () => certController.loadCertificationData(),
              icon: const Icon(Icons.refresh_rounded, color: Colors.black87),
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: SafeArea(
          child: certController.isLoading && certController.certificates.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (certController.certificates.isEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAuthenticated
                                ? 'Approved certificates will appear here.'
                                : 'Sign up to track your certificates.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          if (!isAuthenticated) ...[
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => Get.toNamed(VIEWS.register.path),
                              child: const Text('Sign Up'),
                            ),
                          ],
                        ],
                      )
                    else
                      ...certController.certificates.map(
                        (certificate) => CertificationCards.buildCertificateCard(
                          context,
                          certController,
                          certificate,
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
