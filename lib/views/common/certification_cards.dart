import 'package:flutter/material.dart';
import 'package:vector_academy/controllers/misc/certificate_controller.dart';
import 'package:vector_academy/models/models.dart';
import 'package:vector_academy/utils/utils.dart';

class CertificationCards {
  CertificationCards._();

  static Widget buildCourseCertificationCard(
    BuildContext context,
    CertificateController certController,
    CourseCertificationItem item,
  ) {
    final status = item.status;
    final statusText = certController.statusLabel(status);
    final statusColor = certController.statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.subject.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (item.submission?.adminNotes != null &&
              item.submission!.adminNotes!.isNotEmpty &&
              status == CourseCertificationStatus.rejected) ...[
            const SizedBox(height: 8),
            Text(
              item.submission!.adminNotes!,
              style: TextStyle(color: Colors.red[700], fontSize: 13),
            ),
          ],
          if (status == CourseCertificationStatus.locked) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => certController.openUnlockCourse(item),
                icon: const Icon(Icons.lock_open_rounded),
                label: Text('Unlock ${subjectLabel.toLowerCase()}'),
              ),
            ),
          ],
          if (certController.canSubmit(item)) ...[
            const SizedBox(height: 12),
            Text(
              'Your profile name will be printed on your certificate.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            if (certController.hasPendingFile(item.subject.id)) ...[
              Row(
                children: [
                  Icon(Icons.insert_drive_file_rounded,
                      size: 18, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      certController.pendingFileName(item.subject.id) ??
                          'Selected file',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: certController.isSubmitting
                      ? null
                      : () => certController.uploadPendingProject(item),
                  icon: certController.isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    status == CourseCertificationStatus.rejected
                        ? 'Resubmit project'
                        : 'Submit project',
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: certController.isSubmitting
                      ? null
                      : () => certController.changeProjectFile(item),
                  child: const Text('Change file'),
                ),
              ),
            ] else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: certController.isSubmitting
                      ? null
                      : () => certController.pickProjectFile(item),
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Select project file'),
                ),
              ),
          ],
        ],
      ),
    );
  }

  static Widget buildCertificateCard(
    BuildContext context,
    CertificateController certController,
    Certificate certificate,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => certController.openCertificate(certificate),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[100]!),
            ),
            child: Row(
              children: [
                Icon(Icons.workspace_premium_rounded, color: Colors.green[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        certificate.subjectName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        certificate.certificateNumber,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.picture_as_pdf_rounded, color: Colors.red),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
