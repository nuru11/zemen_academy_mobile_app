import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_academy/controllers/controllers.dart';
import 'package:vector_academy/views/common/certification_cards.dart';

class MyCertificatesPage extends StatelessWidget {
  const MyCertificatesPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                      Text(
                        'Approved certificates will appear here.',
                        style: TextStyle(color: Colors.grey[600]),
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
