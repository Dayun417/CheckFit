//
//  MyPageViewController.swift
//  CheckFit
//

import UIKit
import PhotosUI

final class MyPageViewController: BaseScreenViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        build()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        build()
    }

    private func build() {
        menuActions.removeAll()
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        stackView.addArrangedSubview(profileCard())

        let body = paddedStack(spacing: 20, insets: UIEdgeInsets(top: 22, left: 26, bottom: 122, right: 26))
        body.addArrangedSubview(UILabel("이번 달 활동", size: 22, weight: .black, color: AppTheme.muted, lines: 1))

        let stats = UIStackView()
        stats.axis = .horizontal
        stats.distribution = .fillEqually
        stats.spacing = 18
        stats.addArrangedSubview(activity("총 운동 시간", "\(HealthStore.shared.totalExerciseMinutes) 분"))
        stats.addArrangedSubview(activity("감량 체중", "-2.4 kg"))
        body.addArrangedSubview(stats)

        body.addArrangedSubview(menu([
            MenuItem(icon: "person", title: "내 정보 수정", accessory: nil, action: { [weak self] in self?.presentProfileEdit() }),
            MenuItem(icon: "bell", title: "알림 설정", accessory: nil, action: { [weak self] in self?.presentFullScreen(NotificationSettingsViewController()) })
        ]))
        body.addArrangedSubview(menu([
            MenuItem(icon: "megaphone", title: "공지사항", accessory: nil, action: { [weak self] in self?.presentFullScreen(AnnouncementsViewController()) }),
            MenuItem(icon: "info.circle", title: "버전 정보", accessory: "v1.2.0", action: nil)
        ]))
        stackView.addArrangedSubview(body)
    }

    private func presentProfileEdit() {
        let edit = ProfileEditViewController()
        edit.onSave = { [weak self] in self?.build() }
        present(edit, animated: true)
    }

    private func presentFullScreen(_ controller: UIViewController) {
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }

    private func profileCard() -> UIView {
        let card = UIView()
        card.applyCard(radius: 42)
        card.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        stack.addArrangedSubview(avatar(size: 82))
        stack.addArrangedSubview(UILabel("\(ProfileStore.shared.nickname) 님", size: 25, weight: .black, color: AppTheme.text, lines: 1))
        let emailLabel = UILabel("leedayun03417@gmail.com", size: 15, weight: .bold, color: AppTheme.muted, lines: 1)
        stack.addArrangedSubview(emailLabel)

        let stats = UIStackView()
        stats.axis = .horizontal
        stats.distribution = .fillEqually
        stats.spacing = 0
        let coinText = NumberFormatter.localizedString(from: NSNumber(value: HealthStore.shared.coins), number: .decimal)
        stats.addArrangedSubview(profileStat("코인", "● \(coinText)", .systemYellow))
        stats.addArrangedSubview(profileStat("연속 기록", attributed: boltStreakText(HealthStore.shared.currentStreak)))
        stats.addArrangedSubview(profileStat("완료 미션", "✓ \(HealthStore.shared.totalClaimedMissions)개", AppTheme.brand))
        stack.addArrangedSubview(stats)
        stack.setCustomSpacing(24, after: emailLabel)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 28),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -28),
            stats.widthAnchor.constraint(equalTo: stack.widthAnchor)
        ])
        return card
    }

    private func profileStat(_ title: String, _ value: String, _ color: UIColor) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 5
        stack.addArrangedSubview(UILabel(title, size: 13, weight: .black, color: AppTheme.muted, lines: 1))
        stack.addArrangedSubview(UILabel(value, size: 18, weight: .black, color: color, lines: 1))
        return stack
    }

    private func profileStat(_ title: String, attributed: NSAttributedString) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 5
        stack.addArrangedSubview(UILabel(title, size: 13, weight: .black, color: AppTheme.muted, lines: 1))
        let value = UILabel()
        value.attributedText = attributed
        value.numberOfLines = 1
        stack.addArrangedSubview(value)
        return stack
    }

    /// 홈 헤더의 번개 캡슐과 동일한 모양: 주황색 bolt 심볼 + 연속 일수.
    private func boltStreakText(_ streak: Int) -> NSAttributedString {
        let bolt = NSTextAttachment()
        bolt.image = UIImage(systemName: "bolt", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold))?
            .withTintColor(.systemOrange, renderingMode: .alwaysOriginal)
        let text = NSMutableAttributedString(attributedString: NSAttributedString(attachment: bolt))
        text.append(NSAttributedString(
            string: " \(streak)일",
            attributes: [.font: AppTheme.font(18, .black), .foregroundColor: UIColor.systemOrange]
        ))
        return text
    }

    private func activity(_ title: String, _ value: String) -> UIView {
        let card = UIView()
        card.applyCard(radius: 28)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 104).isActive = true
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        stack.addArrangedSubview(UILabel(title, size: 15, weight: .black, color: AppTheme.muted, lines: 1))
        stack.addArrangedSubview(UILabel(value, size: 22, weight: .black, color: AppTheme.text, lines: 1))
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -22)
        ])
        return card
    }

    private struct MenuItem {
        let icon: String
        let title: String
        let accessory: String?
        let action: (() -> Void)?
    }

    private var menuActions: [ObjectIdentifier: () -> Void] = [:]

    private func menu(_ items: [MenuItem]) -> UIView {
        let card = UIView()
        card.applyCard(radius: 28)
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        for item in items {
            let row = UIStackView()
            row.axis = .horizontal
            row.alignment = .center
            row.spacing = 16
            row.isLayoutMarginsRelativeArrangement = true
            row.layoutMargins = UIEdgeInsets(top: 18, left: 20, bottom: 18, right: 20)
            row.addArrangedSubview(UIImageView(symbol: item.icon, color: AppTheme.brand.withAlphaComponent(0.65), size: 22, weight: .medium))
            row.addArrangedSubview(UILabel(item.title, size: 16, weight: .black, color: AppTheme.text, lines: 1))
            row.addArrangedSubview(UIView())
            if let right = item.accessory {
                row.addArrangedSubview(UILabel(right, size: 13, weight: .medium, color: AppTheme.muted, lines: 1))
            } else {
                row.addArrangedSubview(UIImageView(symbol: "chevron.right", color: UIColor.systemGray3, size: 18, weight: .medium))
            }
            if let action = item.action {
                row.isUserInteractionEnabled = true
                row.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(menuRowTapped(_:))))
                menuActions[ObjectIdentifier(row)] = action
            }
            stack.addArrangedSubview(row)
        }

        stack.pinEdges(to: card)
        return card
    }

    @objc private func menuRowTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        menuActions[ObjectIdentifier(view)]?()
    }
}

/// 닉네임과 프로필 사진을 수정하는 화면.
final class ProfileEditViewController: UIViewController, PHPickerViewControllerDelegate {
    var onSave: (() -> Void)?

    private let nicknameField = UITextField()
    private let memoView = PlaceholderTextView()
    private let avatarImageView = UIImageView()
    private let faceLabel = UILabel("🐱", size: 48, weight: .regular)
    private var pickedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background

        let header = UIStackView()
        header.axis = .horizontal
        header.alignment = .center
        let cancel = UIButton(type: .system)
        cancel.setTitle("취소", for: .normal)
        cancel.setTitleColor(AppTheme.muted, for: .normal)
        cancel.titleLabel?.font = AppTheme.font(16, .bold)
        cancel.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)
        let save = UIButton(type: .system)
        save.setTitle("저장", for: .normal)
        save.setTitleColor(AppTheme.brand, for: .normal)
        save.titleLabel?.font = AppTheme.font(16, .black)
        save.addAction(UIAction { [weak self] _ in self?.saveTapped() }, for: .touchUpInside)
        header.addArrangedSubview(cancel)
        header.addArrangedSubview(UIView())
        header.addArrangedSubview(save)

        // 아바타 미리보기
        let avatarSize: CGFloat = 110
        let avatarWrap = UIView()
        avatarWrap.backgroundColor = UIColor(red: 0.56, green: 0.82, blue: 0.66, alpha: 1)
        avatarWrap.layer.cornerRadius = avatarSize / 2
        avatarWrap.clipsToBounds = true
        avatarWrap.translatesAutoresizingMaskIntoConstraints = false

        faceLabel.textAlignment = .center
        faceLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarWrap.addSubview(faceLabel)
        avatarWrap.addSubview(avatarImageView)

        if let image = ProfileStore.shared.avatarImage {
            avatarImageView.image = image
            faceLabel.isHidden = true
        } else {
            avatarImageView.isHidden = true
        }

        let changePhoto = UIButton(type: .system)
        changePhoto.setTitle("프로필 사진 변경", for: .normal)
        changePhoto.setTitleColor(AppTheme.brand, for: .normal)
        changePhoto.titleLabel?.font = AppTheme.font(15, .black)
        changePhoto.addAction(UIAction { [weak self] _ in self?.pickPhoto() }, for: .touchUpInside)

        // 닉네임
        let nicknameTitle = UILabel("닉네임", size: 14, weight: .black, color: AppTheme.muted, lines: 1)
        nicknameField.text = ProfileStore.shared.nickname
        nicknameField.font = AppTheme.font(18, .black)
        nicknameField.textColor = AppTheme.text
        nicknameField.backgroundColor = .white
        nicknameField.layer.cornerRadius = 16
        nicknameField.layer.borderWidth = 1.5
        nicknameField.layer.borderColor = UIColor(red: 0.89, green: 0.90, blue: 0.93, alpha: 1).cgColor
        nicknameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        nicknameField.leftViewMode = .always
        nicknameField.clearButtonMode = .whileEditing
        nicknameField.translatesAutoresizingMaskIntoConstraints = false
        nicknameField.heightAnchor.constraint(equalToConstant: 56).isActive = true

        let content = UIStackView()
        content.axis = .vertical
        content.alignment = .fill
        content.spacing = 14
        content.translatesAutoresizingMaskIntoConstraints = false
        content.addArrangedSubview(header)
        content.setCustomSpacing(28, after: header)

        let avatarRow = UIStackView(arrangedSubviews: [UIView(), avatarWrap, UIView()])
        avatarRow.distribution = .equalCentering
        avatarRow.alignment = .center
        content.addArrangedSubview(avatarRow)
        let photoRow = UIStackView(arrangedSubviews: [UIView(), changePhoto, UIView()])
        photoRow.distribution = .equalCentering
        content.addArrangedSubview(photoRow)
        content.setCustomSpacing(28, after: photoRow)
        content.addArrangedSubview(nicknameTitle)
        content.addArrangedSubview(nicknameField)

        // 메모
        let memoTitle = UILabel("메모", size: 14, weight: .black, color: AppTheme.muted, lines: 1)
        memoView.placeholder = "한 줄 메모를 남겨보세요"
        memoView.text = ProfileStore.shared.memo
        memoView.font = AppTheme.font(16, .semibold)
        memoView.textColor = AppTheme.text
        memoView.backgroundColor = .white
        memoView.layer.cornerRadius = 16
        memoView.layer.borderWidth = 1.5
        memoView.layer.borderColor = UIColor(red: 0.89, green: 0.90, blue: 0.93, alpha: 1).cgColor
        memoView.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
        memoView.isScrollEnabled = false
        memoView.translatesAutoresizingMaskIntoConstraints = false
        memoView.heightAnchor.constraint(greaterThanOrEqualToConstant: 110).isActive = true
        content.setCustomSpacing(20, after: nicknameField)
        content.addArrangedSubview(memoTitle)
        content.addArrangedSubview(memoView)

        let dismissTap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)

        view.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            content.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            content.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            avatarWrap.widthAnchor.constraint(equalToConstant: avatarSize),
            avatarWrap.heightAnchor.constraint(equalToConstant: avatarSize),
            faceLabel.centerXAnchor.constraint(equalTo: avatarWrap.centerXAnchor),
            faceLabel.centerYAnchor.constraint(equalTo: avatarWrap.centerYAnchor),
            avatarImageView.topAnchor.constraint(equalTo: avatarWrap.topAnchor),
            avatarImageView.bottomAnchor.constraint(equalTo: avatarWrap.bottomAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: avatarWrap.leadingAnchor),
            avatarImageView.trailingAnchor.constraint(equalTo: avatarWrap.trailingAnchor)
        ])
    }

    private func pickPhoto() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self?.pickedImage = image
                self?.avatarImageView.image = image
                self?.avatarImageView.isHidden = false
                self?.faceLabel.isHidden = true
            }
        }
    }

    private func saveTapped() {
        let name = nicknameField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if !name.isEmpty {
            ProfileStore.shared.nickname = name
        }
        if let image = pickedImage, let data = image.jpegData(compressionQuality: 0.85) {
            ProfileStore.shared.avatarImageData = data
        }
        ProfileStore.shared.memo = memoView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        onSave?()
        dismiss(animated: true)
    }
}

/// 마이페이지 > 알림 설정. 항목별 푸시 알림 on/off 화면.
final class NotificationSettingsViewController: UIViewController {
    private struct Toggle {
        let title: String
        let subtitle: String
        let defaultOn: Bool
    }

    private let sections: [(header: String, items: [Toggle])] = [
        ("미션 & 기록", [
            Toggle(title: "미션 알림", subtitle: "오늘의 미션과 보상을 알려드려요", defaultOn: true),
            Toggle(title: "연속 기록 리마인더", subtitle: "기록이 끊기지 않도록 챙겨드려요", defaultOn: true),
            Toggle(title: "물 마시기 알림", subtitle: "수분 섭취 시간을 알려드려요", defaultOn: false),
            Toggle(title: "식단 기록 알림", subtitle: "끼니마다 식단 기록을 도와드려요", defaultOn: false)
        ]),
        ("소식", [
            Toggle(title: "공지 & 이벤트", subtitle: "새로운 소식과 이벤트를 받아보세요", defaultOn: true),
            Toggle(title: "마케팅 정보 수신", subtitle: "혜택과 프로모션 정보를 받아보세요", defaultOn: false)
        ])
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background

        let bar = topBar(title: "알림 설정")
        view.addSubview(bar)

        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 24
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)

        for section in sections {
            let group = UIStackView()
            group.axis = .vertical
            group.spacing = 10
            group.addArrangedSubview(UILabel(section.header, size: 15, weight: .black, color: AppTheme.muted, lines: 1))

            let card = UIView()
            card.applyCard(radius: 24)
            let rows = UIStackView()
            rows.axis = .vertical
            rows.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(rows)
            for (index, toggle) in section.items.enumerated() {
                rows.addArrangedSubview(toggleRow(toggle))
                if index < section.items.count - 1 {
                    rows.addArrangedSubview(separator())
                }
            }
            rows.pinEdges(to: card)
            group.addArrangedSubview(card)
            content.addArrangedSubview(group)
        }

        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.topAnchor.constraint(equalTo: bar.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 22),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -40),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 24),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -24)
        ])
    }

    private func toggleRow(_ toggle: Toggle) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 14
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 16, left: 18, bottom: 16, right: 18)

        let texts = UIStackView()
        texts.axis = .vertical
        texts.spacing = 3
        texts.addArrangedSubview(UILabel(toggle.title, size: 16, weight: .black, color: AppTheme.text, lines: 1))
        texts.addArrangedSubview(UILabel(toggle.subtitle, size: 12, weight: .semibold, color: AppTheme.muted, lines: 2))
        row.addArrangedSubview(texts)
        row.addArrangedSubview(UIView())

        let toggleControl = UISwitch()
        toggleControl.isOn = toggle.defaultOn
        toggleControl.onTintColor = AppTheme.brand
        toggleControl.setContentHuggingPriority(.required, for: .horizontal)
        row.addArrangedSubview(toggleControl)
        return row
    }

    private func separator() -> UIView {
        let line = UIView()
        line.backgroundColor = AppTheme.softFill
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        let wrap = UIView()
        wrap.addSubview(line)
        NSLayoutConstraint.activate([
            line.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 18),
            line.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -18),
            line.topAnchor.constraint(equalTo: wrap.topAnchor),
            line.bottomAnchor.constraint(equalTo: wrap.bottomAnchor)
        ])
        return wrap
    }

    private func topBar(title: String) -> UIView {
        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        let back = IconButton(symbol: "chevron.left", color: AppTheme.text, pointSize: 24)
        back.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)
        back.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel(title, size: 19, weight: .black, color: AppTheme.text, lines: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(back)
        bar.addSubview(label)
        NSLayoutConstraint.activate([
            bar.heightAnchor.constraint(equalToConstant: 52),
            back.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 16),
            back.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            back.widthAnchor.constraint(equalToConstant: 32),
            label.centerXAnchor.constraint(equalTo: bar.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: bar.centerYAnchor)
        ])
        return bar
    }
}

/// 마이페이지 > 공지사항. 운영 공지 목록 화면.
final class AnnouncementsViewController: UIViewController {
    private struct Notice {
        let badge: String
        let badgeColor: UIColor
        let title: String
        let date: String
        let body: String
    }

    private let notices: [Notice] = [
        Notice(badge: "안내", badgeColor: .systemBlue, title: "체크핏 v1.2.0 업데이트 안내", date: "2026.06.05",
               body: "콘텐츠 탭 영상 정렬이 개선되고, 알림 설정과 공지사항 화면이 새롭게 추가되었어요. 더 편하게 운동 루틴을 관리해보세요."),
        Notice(badge: "이벤트", badgeColor: .systemOrange, title: "6월 출석 챌린지 🔥", date: "2026.06.01",
               body: "6월 한 달 동안 연속 기록을 이어가면 추가 코인을 드려요. 미션 탭에서 오늘의 미션을 확인해보세요!"),
        Notice(badge: "점검", badgeColor: AppTheme.muted, title: "서버 정기 점검 안내", date: "2026.05.28",
               body: "더 안정적인 서비스를 위해 5월 30일 새벽 2시~4시 정기 점검이 진행됩니다. 이용에 참고 부탁드려요."),
        Notice(badge: "안내", badgeColor: .systemBlue, title: "개인정보 처리방침 개정 안내", date: "2026.05.20",
               body: "개인정보 처리방침 일부가 개정되었습니다. 자세한 내용은 설정 > 약관 및 정책에서 확인하실 수 있어요.")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background

        let bar = topBar(title: "공지사항")
        view.addSubview(bar)

        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 16
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)

        for notice in notices {
            content.addArrangedSubview(noticeCard(notice))
        }

        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.topAnchor.constraint(equalTo: bar.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 22),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -40),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 24),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -24)
        ])
    }

    private func noticeCard(_ notice: Notice) -> UIView {
        let card = UIView()
        card.applyCard(radius: 24)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        let topRow = UIStackView()
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = 10
        let badge = makePill(notice.badge, foreground: .white, background: notice.badgeColor, fontSize: 12)
        badge.setContentHuggingPriority(.required, for: .horizontal)
        topRow.addArrangedSubview(badge)
        topRow.addArrangedSubview(UIView())
        topRow.addArrangedSubview(UILabel(notice.date, size: 12, weight: .bold, color: AppTheme.muted, lines: 1))
        stack.addArrangedSubview(topRow)

        stack.addArrangedSubview(UILabel(notice.title, size: 17, weight: .black, color: AppTheme.text, lines: 2))
        stack.addArrangedSubview(UILabel(notice.body, size: 13, weight: .semibold, color: AppTheme.muted, lines: 0))

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])
        return card
    }

    private func topBar(title: String) -> UIView {
        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        let back = IconButton(symbol: "chevron.left", color: AppTheme.text, pointSize: 24)
        back.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)
        back.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel(title, size: 19, weight: .black, color: AppTheme.text, lines: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(back)
        bar.addSubview(label)
        NSLayoutConstraint.activate([
            bar.heightAnchor.constraint(equalToConstant: 52),
            back.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 16),
            back.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            back.widthAnchor.constraint(equalToConstant: 32),
            label.centerXAnchor.constraint(equalTo: bar.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: bar.centerYAnchor)
        ])
        return bar
    }
}
