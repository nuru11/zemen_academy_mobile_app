import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_academy/components/components.dart';
import 'package:vector_academy/controllers/controllers.dart';
import "package:vector_academy/models/models.dart";
import "package:vector_academy/utils/utils.dart";
import "package:vector_academy/services/services.dart";
import 'package:vector_academy/config/support_config.dart';
import 'package:vector_academy/views/views.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeDashboard extends StatelessWidget {
  HomeDashboard({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Get.put(HomeDashboardController());
    Get.put(NavigationDrawerController());
    Get.put(NotificationsController());

    return GetBuilder<HomeDashboardController>(
      builder: (controller) => Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer: _buildNavigationDrawer(context),
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context, controller),
              // _buildPromotionalBanner(context, controller),
              _buildHomeSearchBar(context, controller),
              if (controller.hasSearchQuery)
                Expanded(child: _buildGroupedSearchResults(context, controller))
              else
                Expanded(child: _buildSubjectSelection(context, controller)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeSearchBar(
    BuildContext context,
    HomeDashboardController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: SearchTextField(
        controller: controller.homeSearchController,
        hint: 'Search chapters, exams, videos, worksheets...',
        onChanged: controller.updateSearchQuery,
        onClear: controller.clearSearch,
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    HomeDashboardController controller,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            icon: Icon(Icons.menu, color: Colors.black87),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            mouseCursor: SystemMouseCursors.click,
          ),

          Spacer(),

          Row(
            children: [
              IconButton(
                onPressed: () async {
                  final dynamicTelegramLink = controller.appHeader?.link?.trim();
                  final targetTelegramLink =
                      (dynamicTelegramLink != null &&
                          dynamicTelegramLink.isNotEmpty)
                      ? dynamicTelegramLink
                      : supportTelegramUrl;

                  if (!await launchUrl(Uri.parse(targetTelegramLink))) {
                    throw Exception('Could not launch $targetTelegramLink');
                  }
                },
                icon: Icon(Icons.telegram, color: Colors.blue[600], size: 35,),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                mouseCursor: SystemMouseCursors.click,
              ),
              // SizedBox(width: 2),
              GetBuilder<NotificationsController>(
                builder: (notificationsController) => Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        Get.to(() => NotificationsPage());
                      },
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: Colors.black87,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      mouseCursor: SystemMouseCursors.click,
                    ),
                    if (notificationsController.unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.red[600],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${notificationsController.unreadCount > 9 ? "9+" : notificationsController.unreadCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildPromotionalBanner(
    BuildContext context,
    HomeDashboardController controller,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            controller.appHeader?.gradientStart != null
                ? Color(
                    int.parse(
                      (controller.appHeader!.gradientStart!).replaceAll(
                        '#',
                        '0xFF',
                      ),
                    ),
                  )
                : Colors.blue,
            controller.appHeader?.gradientEnd != null
                ? Color(
                    int.parse(
                      (controller.appHeader!.gradientEnd!).replaceAll(
                        '#',
                        '0xFF',
                      ),
                    ),
                  )
                : Colors.blue.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.appHeader?.text ?? 'Ethio Entrance Tricks!',
                  style: TextStyle(
                    color: controller.appHeader?.textColor != null
                        ? Color(
                            int.parse(
                              (controller.appHeader!.textColor!).replaceAll(
                                '#',
                                '0xFF',
                              ),
                            ),
                          )
                        : Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                if (controller.appHeader?.showTagLineText == true)
                  Text(
                    controller.appHeader?.tagLineText ?? 'For HighSchool Class',
                    style: TextStyle(
                      color: controller.appHeader?.tagLineTextColor != null
                          ? Color(
                              int.parse(
                                (controller.appHeader!.tagLineTextColor!)
                                    .replaceAll('#', '0xFF'),
                              ),
                            )
                          : Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                    ),
                  ),
              ],
            ),
          ),

          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: () async {
                if (!await launchUrl(
                  Uri.parse(
                    controller.appHeader?.link ??
                        supportTelegramUrl,
                  ),
                )) {}
              },
              icon: Icon(Icons.telegram, size: 40, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectSelection(
    BuildContext context,
    HomeDashboardController controller,
  ) {
    if (controller.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.blue,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Loading ${subjectsLabel.toLowerCase()}...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (controller.loadError != null) {
      return _buildSubjectsErrorState(context, controller);
    }

    if (controller.subjects.isEmpty) {
      return _buildSubjectsEmptyState(context, controller);
    }

    return RefreshIndicator(
      onRefresh: controller.loadSubjects,
      color: Colors.blue,
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPopularCoursesSection(context, controller),
                  Text(
                    '$subjectsLabel Selection',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.78,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final subject = controller.subjects[index];
                  return _CourseTile(
                    subject: subject,
                    onTap: () => controller.selectSubject(subject.id),
                  );
                },
                childCount: controller.subjects.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularCoursesSection(
    BuildContext context,
    HomeDashboardController controller,
  ) {
    final popularSubjects = controller.popularSubjects;
    if (popularSubjects.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 360;
    final isTablet = screenWidth >= 768;
    final cardWidth = (screenWidth * (isCompact ? 0.42 : 0.38))
        .clamp(148.0, isTablet ? 200.0 : 176.0)
        .toDouble();
    final cardHeight = cardWidth / 0.78;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Courses',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: cardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: popularSubjects.length,
              separatorBuilder: (_, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final subject = popularSubjects[index];
                return SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: _CourseTile(
                    subject: subject,
                    onTap: () => controller.selectSubject(subject.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsErrorState(
    BuildContext context,
    HomeDashboardController controller,
  ) {
    return RefreshIndicator(
      onRefresh: controller.loadSubjects,
      color: Colors.blue,
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            controller.loadError ?? 'Could not load courses',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: controller.loadSubjects,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsEmptyState(
    BuildContext context,
    HomeDashboardController controller,
  ) {
    return RefreshIndicator(
      onRefresh: controller.loadSubjects,
      color: Colors.blue,
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Icon(Icons.school_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No ${subjectsLabel.toLowerCase()} available for your $gradeLabel.toLowerCase()',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedSearchResults(
    BuildContext context,
    HomeDashboardController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Results',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Results for "${controller.searchQuery}"',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: !controller.hasAnySearchResult
                ? _buildSearchEmptyState()
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildChapterResultsSection(controller),
                      _buildExamResultsSection(controller),
                      _buildVideoResultsSection(controller),
                      _buildWorksheetResultsSection(controller),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchEmptyState() {
    return Center(
      child: Text(
        'No matches found. Try another keyword.',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildChapterResultsSection(HomeDashboardController controller) {
    if (controller.chapterResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSearchSectionCard(
      title: 'Chapters',
      icon: Icons.menu_book_rounded,
      children: controller.chapterResults.map((chapter) {
        final subjectName = controller.getSubjectNameForChapter(chapter.id);
        return _buildSearchResultTile(
          title: chapter.name,
          subtitle:
              '$subjectName â€¢ Chapter ${chapter.chapterNumber}${(chapter.description ?? '').isNotEmpty ? ' â€¢ ${chapter.description}' : ''}',
          icon: Icons.article_outlined,
          onTap: () => controller.openChapterSearchResult(chapter),
        );
      }).toList(),
    );
  }

  Widget _buildExamResultsSection(HomeDashboardController controller) {
    if (controller.examResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSearchSectionCard(
      title: 'Exams',
      icon: Icons.quiz_rounded,
      children: controller.examResults.map((exam) {
        return _buildSearchResultTile(
          title: exam.name,
          subtitle:
              '${exam.subject?.name ?? 'General'} â€¢ ${exam.examType.toUpperCase()}',
          icon: Icons.assignment_outlined,
          onTap: () => controller.openExam(exam.id),
        );
      }).toList(),
    );
  }

  Widget _buildVideoResultsSection(HomeDashboardController controller) {
    if (controller.videoResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSearchSectionCard(
      title: 'Videos',
      icon: Icons.play_circle_outline_rounded,
      children: controller.videoResults.map((video) {
        final chapterName = controller.getChapterNameById(video.chapter);
        final subjectName = controller.getSubjectNameForChapter(video.chapter);
        return _buildSearchResultTile(
          title: video.title,
          subtitle: '$subjectName â€¢ $chapterName',
          icon: Icons.ondemand_video_outlined,
          onTap: () => controller.openVideoSearchResult(video),
        );
      }).toList(),
    );
  }

  Widget _buildWorksheetResultsSection(HomeDashboardController controller) {
    if (controller.worksheetResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSearchSectionCard(
      title: 'Worksheets',
      icon: Icons.description_outlined,
      children: controller.worksheetResults.map((worksheet) {
        final chapterName = worksheet.chapter != null
            ? controller.getChapterNameById(worksheet.chapter!)
            : 'Unknown chapter';
        final subjectName = worksheet.chapter != null
            ? controller.getSubjectNameForChapter(worksheet.chapter!)
            : 'General';
        return _buildSearchResultTile(
          title: worksheet.title,
          subtitle: '$subjectName â€¢ $chapterName',
          icon: Icons.note_alt_outlined,
          onTap: () => controller.openWorksheetSearchResult(worksheet),
        );
      }).toList(),
    );
  }

  Widget _buildSearchSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.black87),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSearchResultTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[700]),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationDrawer(BuildContext context) {
    final coreService = Get.find<CoreService>();
    final isAuthenticated = coreService.authService.isAuthenticated;
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey[50]!],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue[600]!, Colors.blue[800]!],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAuthenticated ? 'Welcome back,' : 'Welcome,',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          isAuthenticated
                              ? (coreService.authService.user.value?.firstName ??
                                  'User')
                              : 'Guest',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          isAuthenticated
                              ? (coreService.authService.user.value?.phoneNumber ??
                                  '')
                              : 'Sign up to purchase courses',
                          style: TextStyle(fontSize: 12, color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 10),
                physics: BouncingScrollPhysics(),
                children: [
                  _buildSectionHeader('Main Navigation'),
                  _buildModernDrawerMenuItem(
                    icon: Icons.home_rounded,
                    title: 'Home',
                    subtitle: 'Dashboard & Overview',
                    onTap: () {
                      Get.find<MainNavigationController>().changeIndex(0);
                    },
                    isSelected:
                        Get.find<MainNavigationController>().currentIndex == 0,
                  ),
                  _buildModernDrawerMenuItem(
                    icon: Icons.school_rounded,
                    title: 'My Courses',
                    subtitle: 'Certification & project submissions',
                    onTap: () {
                      Navigator.of(context).pop();
                      Get.find<MainNavigationController>().changeIndex(1);
                      Get.find<CertificateController>().loadCertificationData();
                    },
                    isSelected:
                        Get.find<MainNavigationController>().currentIndex == 1,
                  ),
                  _buildModernDrawerMenuItem(
                    icon: Icons.article_rounded,
                    title: 'News',
                    subtitle: 'Latest Updates',
                    onTap: () {
                      Get.find<MainNavigationController>().changeIndex(2);
                    },
                    isSelected:
                        Get.find<MainNavigationController>().currentIndex == 2,
                  ),
                  _buildModernDrawerMenuItem(
                    icon: Icons.workspace_premium_rounded,
                    title: 'My Certificates',
                    subtitle: 'View approved certificates',
                    onTap: () {
                      Navigator.of(context).pop();
                      Get.find<MainNavigationController>().changeIndex(3);
                      Get.find<CertificateController>().loadCertificationData();
                    },
                    isSelected:
                        Get.find<MainNavigationController>().currentIndex == 3,
                  ),
                  _buildModernDrawerMenuItem(
                    icon: Icons.person_rounded,
                    title: 'Profile',
                    subtitle: 'Account & Settings',
                    onTap: () {
                      Navigator.of(context).pop();
                      Get.find<MainNavigationController>().changeIndex(4);
                    },
                    isSelected:
                        Get.find<MainNavigationController>().currentIndex == 4,
                  ),
                  // SizedBox(height: 20),
                  // _buildSectionHeader('Payments'),
                  // _buildModernDrawerMenuItem(
                  //   icon: Icons.payment_rounded,
                  //   title: 'Payments',
                  //   subtitle: 'View your payments',
                  //   onTap: () => Get.toNamed(VIEWS.payments.path),
                  // ),
                  // SizedBox(height: 20),
                  // _buildModernDrawerMenuItem(
                  //   icon: Icons.history_rounded,
                  //   title: 'Payment History',
                  //   subtitle: 'View your payment history',
                  //   onTap: () => Get.toNamed(VIEWS.paymentHistory.path),
                  // ),

                  SizedBox(height: 20),

                  _buildSectionHeader('Study Materials'),
                  _buildModernDrawerMenuItem(
                    icon: Icons.book_rounded,
                    title: subjectsLabel,
                    subtitle: 'Browse all ${subjectsLabel.toLowerCase()}',
                    onTap: () => Get.toNamed(VIEWS.subjects.path),
                  ),

                  SizedBox(height: 20),

                  _buildSectionHeader('Tools & Features'),

                  _buildModernDrawerMenuItem(
                    icon: Icons.download_rounded,
                    title: 'Downloads',
                    subtitle: 'Offline content',
                    onTap: () => Get.toNamed(VIEWS.downloads.path),
                  ),

                  SizedBox(height: 20),

                  _buildSectionHeader('Support'),
                  _buildModernDrawerMenuItem(
                    icon: Icons.help_outline_rounded,
                    title: 'FAQ',
                    subtitle: 'Frequently asked questions',
                    onTap: () => Get.toNamed(VIEWS.faq.path),
                  ),
                  _buildModernDrawerMenuItem(
                    icon: Icons.headset_mic_rounded,
                    title: 'Support',
                    subtitle: 'Get help & support',
                    onTap: () => Get.toNamed(VIEWS.support.path),
                  ),
                  _buildModernDrawerMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'About',
                    subtitle: 'App information',
                    onTap: () => Get.toNamed(VIEWS.about.path),
                  ),

                  SizedBox(height: 20),

                  if (isAuthenticated)
                    _buildModernDrawerMenuItem(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      subtitle: 'Sign out of your account',
                      onTap: () {
                        Get.find<NavigationDrawerController>().logout();
                      },
                      isDestructive: true,
                    )
                  else ...[
                    _buildModernDrawerMenuItem(
                      icon: Icons.person_add_alt_1_rounded,
                      title: 'Sign Up',
                      subtitle: 'Create an account',
                      onTap: () {
                        Navigator.of(context).pop();
                        Get.toNamed(VIEWS.register.path);
                      },
                    ),
                    _buildModernDrawerMenuItem(
                      icon: Icons.login_rounded,
                      title: 'Login',
                      subtitle: 'Already have an account',
                      onTap: () {
                        Navigator.of(context).pop();
                        Get.toNamed(VIEWS.login.path);
                      },
                    ),
                  ],

                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildModernDrawerMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isSelected = false,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.blue.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.1)
                : isSelected
                ? Colors.blue.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isDestructive
                ? Colors.red[600]
                : isSelected
                ? Colors.blue[600]
                : Colors.grey[600],
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isDestructive
                ? Colors.red[600]
                : isSelected
                ? Colors.blue[600]
                : Colors.grey[800],
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: isSelected
            ? Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.check, color: Colors.white, size: 12),
              )
            : Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey[400],
                size: 14,
              ),
        onTap: onTap,
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  const _CourseTile({required this.subject, required this.onTap});

  final Subject subject;
  final VoidCallback onTap;

  bool get _hasIcon => subject.icon != null && subject.icon!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chapterCount = subject.chapters.length;
    final accent = theme.colorScheme.primary;

    final card = Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: onSurfaceVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _hasIcon
                  ? CachedNetworkImage(
                      imageUrl: subject.icon!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: accent.withValues(alpha: 0.08),
                        child: const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          _thumbnailFallback(accent),
                    )
                  : _thumbnailFallback(accent),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subject.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 2),
          // Text(
          //   chapterCount == 1 ? '1 chapter' : '$chapterCount chapters',
          //   style: theme.textTheme.labelSmall?.copyWith(color: onSurfaceVariant),
          // ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: card,
      ),
    );
  }

  Widget _thumbnailFallback(Color accent) {
    return Container(
      color: accent.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          color: accent,
          size: 28,
        ),
      ),
    );
  }
}
