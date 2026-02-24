import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('정보'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // ── 앱 버전 ─────────────────────────────────────────────
          const _InfoRow(label: '버전', detail: '1.0.0'),

          const SizedBox(height: 28),

          // ── 법적 정보 ────────────────────────────────────────────
          const _SectionHeader(label: '법적 정보'),
          _NavTile(
            label: '서비스 이용약관',
            onTap: () => _showPolicy(
              context,
              title: '서비스 이용약관',
              content: _termsContent,
            ),
          ),
          _NavTile(
            label: '개인정보 처리방침',
            onTap: () => _showPolicy(
              context,
              title: '개인정보 처리방침',
              content: _privacyContent,
            ),
          ),
          _NavTile(
            label: '오픈소스 라이선스',
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'Sent',
              applicationVersion: '1.0.0',
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showPolicy(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PolicySheet(title: title, content: content),
    );
  }
}

// ── Policy Bottom Sheet ───────────────────────────────────────────

class _PolicySheet extends StatelessWidget {
  const _PolicySheet({required this.title, required this.content});
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: AppColors.border, width: 0.5),
              left: BorderSide(color: AppColors.border, width: 0.5),
              right: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 16, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 0.5, color: AppColors.border),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    content,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      height: 1.9,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Tiles ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w400)),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textDisabled, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.detail});
  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w400)),
          Text(detail,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 14)),
        ],
      ),
    );
  }
}

// ── Policy Texts ──────────────────────────────────────────────────

const _termsContent = '''제1조(목적)
이 약관은 Sent(이하 "회사"라 함)가 제공하는 투두, 메모, 친구, 채팅 등 앱 서비스(이하 "서비스"라 함)의 이용과 관련하여 회사와 회원 간의 권리, 의무 및 책임사항, 기타 필요한 사항을 규정함을 목적으로 합니다.

제2조(용어의 정의)
1. "회원"이란 본 약관에 따라 회사와 이용계약을 체결하고, 회사가 제공하는 서비스를 이용하는 자를 말합니다.
2. "서비스"란 회사가 제공하는 투두, 메모, 친구, 채팅 등 일체의 서비스를 의미합니다.
3. "OAuth"란 구글, 네이버, 카카오 등 외부 인증 서비스를 통해 로그인을 지원하는 방식을 의미합니다.

제3조(약관의 효력 및 변경)
1. 본 약관은 서비스를 이용하고자 하는 모든 회원에 대하여 그 효력을 발생합니다.
2. 회사는 관련 법령을 위반하지 않는 범위에서 약관을 변경할 수 있으며, 변경 시 서비스 내 공지사항을 통해 고지합니다.

제4조(이용계약의 성립)
1. 회원은 OAuth를 통해 로그인을 진행함으로써 회사와 서비스 이용계약을 체결합니다.
2. 회사는 회원의 가입 신청에 대하여 서비스 이용을 승낙함을 원칙으로 합니다.

제5조(회원의 의무)
1. 회원은 본 약관 및 관계 법령을 준수하여야 하며, 회사의 정상적인 서비스 운영을 방해하는 행위를 해서는 안 됩니다.
2. 회원은 타인의 개인정보를 무단으로 수집, 이용, 공개해서는 안 됩니다.

제6조(회사의 의무)
1. 회사는 관련 법령과 본 약관이 정하는 바에 따라 서비스를 안정적으로 제공합니다.
2. 회사는 회원의 개인정보를 안전하게 보호하기 위해 노력합니다.

제7조(서비스의 제공 및 중단)
1. 회사는 회원에게 투두, 메모, 친구, 채팅 등 서비스를 제공합니다.
2. 회사는 시스템 점검, 장애 발생 등 부득이한 사유가 있을 경우 서비스의 전부 또는 일부를 일시 중단할 수 있습니다.

제8조(계약 해지 및 이용 제한)
1. 회원은 언제든지 서비스 내 제공되는 메뉴를 통해 이용계약을 해지할 수 있습니다.
2. 회사는 회원이 본 약관을 위반할 경우 서비스 이용을 제한하거나 계약을 해지할 수 있습니다.

제9조(면책조항)
회사는 천재지변, 불가항력적 사유, 회원의 귀책사유 등으로 인해 발생한 서비스 이용 장애에 대해 책임을 지지 않습니다.

제10조(분쟁의 해결)
본 약관에 명시되지 않은 사항 및 해석에 관하여는 관련 법령 및 상관례에 따릅니다.''';

const _privacyContent = '''1. 수집하는 개인정보 항목
회사는 회원가입 및 서비스 제공을 위해 다음과 같은 개인정보를 수집합니다.
- 필수항목: 이메일, 닉네임(또는 display name), 프로필 사진
- 수집방법: 구글, 네이버, 카카오 OAuth 로그인 시 제공받음

2. 개인정보의 수집 및 이용 목적
회사는 수집한 개인정보를 다음의 목적을 위해 활용합니다.
- 회원 식별 및 관리
- 서비스 제공(투두, 메모, 친구, 채팅 기능)
- 고객 문의 응대 및 공지사항 전달

3. 개인정보의 보유 및 이용 기간
- 회원이 탈퇴할 경우, 해당 계정 및 개인정보는 즉시 비활성화(soft delete) 처리되며, 6개월간 보관 후 완전히 삭제(하드 딜리트)합니다.
- 보관 기간(6개월) 동안에는 관련 법령에 따라 분쟁 해결, 민원 처리, 부정 이용 방지 등의 목적으로만 정보를 보유하며, 해당 기간이 경과하면 복구할 수 없는 방법으로 완전히 삭제합니다.
- 단, 관련 법령에 따라 별도로 보존해야 하는 정보가 있을 경우, 해당 법령에서 정한 기간 동안 보관할 수 있습니다.

4. 개인정보의 제3자 제공
회사는 원칙적으로 이용자의 개인정보를 외부에 제공하지 않습니다. 다만, 법령에 의거하거나 이용자의 동의를 받은 경우에는 예외로 합니다.

5. 개인정보 처리의 위탁
회사는 원활한 서비스 제공을 위해 개인정보 처리를 외부 업체에 위탁하지 않습니다. (향후 위탁이 있을 경우, 위탁 업체명과 위탁 업무 내용을 별도 고지)

6. 정보주체의 권리와 행사 방법
이용자는 언제든지 자신의 개인정보를 조회, 수정, 삭제할 수 있으며, 회원탈퇴를 통해 개인정보의 삭제를 요청할 수 있습니다.

7. 개인정보의 파기 절차 및 방법
- 수집 및 이용 목적이 달성된 후에는 지체 없이 해당 정보를 파기합니다.
- 전자적 파일 형태의 정보는 복구 불가능한 방법으로 삭제하며, 종이 문서는 분쇄 또는 소각합니다.

8. 개인정보 보호책임자
- 이름: [담당자명]
- 연락처: [이메일 또는 연락처]

9. 고지의 의무
본 개인정보 처리방침은 서비스 내 공지사항을 통해 변경 사항을 고지하며, 변경된 내용은 즉시 시행됩니다.''';
