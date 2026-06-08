//
//  MyPageViewController.swift
//  CheckFit
//

import UIKit

final class MyPageViewController: BaseScreenViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        build()
    }

    private func build() {
        stackView.addArrangedSubview(profileCard())

        let body = paddedStack(spacing: 20, insets: UIEdgeInsets(top: 22, left: 26, bottom: 122, right: 26))
        body.addArrangedSubview(UILabel("이번 달 활동", size: 22, weight: .black, color: AppTheme.muted, lines: 1))

        let stats = UIStackView()
        stats.axis = .horizontal
        stats.distribution = .fillEqually
        stats.spacing = 18
        stats.addArrangedSubview(activity("총 운동 시간", "420 분"))
        stats.addArrangedSubview(activity("감량 체중", "-2.4 kg"))
        body.addArrangedSubview(stats)

        body.addArrangedSubview(menu([
            ("person", "내 정보 수정", nil),
            ("bell", "알림 설정", nil),
            ("figure.strengthtraining.traditional", "운동 기록 보관함", nil),
            ("drop", "수분 섭취 목표 설정", nil)
        ]))
        body.addArrangedSubview(menu([
            ("moon", "다크 모드", "toggle"),
            ("megaphone", "공지사항", nil),
            ("info.circle", "버전 정보", "v1.2.0")
        ]))
        stackView.addArrangedSubview(body)
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
        stack.addArrangedSubview(UILabel("고먐미 님", size: 25, weight: .black, color: AppTheme.text, lines: 1))
        stack.addArrangedSubview(UILabel("leedayun03417@gmail.com", size: 15, weight: .bold, color: AppTheme.muted, lines: 1))

        let stats = UIStackView()
        stats.axis = .horizontal
        stats.distribution = .fillEqually
        stats.spacing = 0
        stats.addArrangedSubview(profileStat("코인", "● 1,250", .systemYellow))
        stats.addArrangedSubview(profileStat("연속 기록", "🔥 12일", .systemOrange))
        stats.addArrangedSubview(profileStat("완료 미션", "✓ 42개", AppTheme.brand))
        stack.addArrangedSubview(stats)

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

    private func menu(_ items: [(String, String, String?)]) -> UIView {
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
            row.addArrangedSubview(UIImageView(symbol: item.0, color: AppTheme.brand.withAlphaComponent(0.65), size: 22, weight: .medium))
            row.addArrangedSubview(UILabel(item.1, size: 16, weight: .black, color: AppTheme.text, lines: 1))
            row.addArrangedSubview(UIView())
            if item.2 == "toggle" {
                let toggle = UISwitch()
                toggle.onTintColor = AppTheme.brand
                row.addArrangedSubview(toggle)
            } else if let right = item.2 {
                row.addArrangedSubview(UILabel(right, size: 13, weight: .medium, color: AppTheme.muted, lines: 1))
            } else {
                row.addArrangedSubview(UIImageView(symbol: "chevron.right", color: UIColor.systemGray3, size: 18, weight: .medium))
            }
            stack.addArrangedSubview(row)
        }

        stack.pinEdges(to: card)
        return card
    }
}
