//
//  ContentViewController.swift
//  CheckFit
//

import UIKit

final class ContentViewController: BaseScreenViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        build()
    }

    private func build() {
        let body = paddedStack(spacing: 18, insets: UIEdgeInsets(top: 24, left: 22, bottom: 122, right: 22))
        body.addArrangedSubview(UILabel("콘텐츠", size: 30, weight: .black, color: AppTheme.text, lines: 1))
        body.addArrangedSubview(searchField())
        body.addArrangedSubview(chips())
        body.addArrangedSubview(video("집에서 하는 15분 지방 연소 전신 운동", "핏블리 Fitvely", "15:20", "1.2M", "figure.strengthtraining.traditional"))
        body.addArrangedSubview(video("초보자를 위한 요가 기초 스트레칭", "서리 요가", "25:10", "450K", "figure.cooldown"))
        stackView.addArrangedSubview(body)
    }

    private func searchField() -> UITextField {
        let field = UITextField()
        field.placeholder = "어떤 운동을 하고 싶으신가요?"
        field.font = AppTheme.font(15, .semibold)
        field.backgroundColor = AppTheme.softFill
        field.layer.cornerRadius = 24
        field.leftView = UIImageView(symbol: "magnifyingglass", color: AppTheme.muted, size: 18, weight: .medium)
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return field
    }

    private func chips() -> UIView {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(row)
        for chip in ["전체", "전신", "요가", "복근", "스트레칭"] {
            row.addArrangedSubview(makePill(chip, foreground: chip == "전체" ? .white : AppTheme.muted, background: chip == "전체" ? AppTheme.brand : AppTheme.softFill, fontSize: 15))
        }
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            row.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            row.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            row.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor),
            scroll.heightAnchor.constraint(equalToConstant: 48)
        ])
        return scroll
    }

    private func video(_ title: String, _ channel: String, _ duration: String, _ views: String, _ symbol: String) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12

        let thumbnail = UIView()
        thumbnail.backgroundColor = UIColor(red: 0.07, green: 0.13, blue: 0.14, alpha: 1)
        thumbnail.layer.cornerRadius = 24
        thumbnail.clipsToBounds = true
        thumbnail.translatesAutoresizingMaskIntoConstraints = false
        let icon = UIImageView(symbol: symbol, color: UIColor.white.withAlphaComponent(0.65), size: 58, weight: .medium)
        thumbnail.addSubview(icon)
        let time = makePill("◷ \(duration)", background: UIColor.black.withAlphaComponent(0.70), fontSize: 13)
        thumbnail.addSubview(time)
        NSLayoutConstraint.activate([
            thumbnail.heightAnchor.constraint(equalTo: thumbnail.widthAnchor, multiplier: 0.54),
            icon.centerXAnchor.constraint(equalTo: thumbnail.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: thumbnail.centerYAnchor),
            time.trailingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: -12),
            time.bottomAnchor.constraint(equalTo: thumbnail.bottomAnchor, constant: -12)
        ])
        stack.addArrangedSubview(thumbnail)
        stack.addArrangedSubview(UILabel(title, size: 20, weight: .black, color: AppTheme.text, lines: 2))

        let meta = UIStackView()
        meta.axis = .horizontal
        meta.distribution = .equalSpacing
        meta.addArrangedSubview(UILabel(channel, size: 14, weight: .bold, color: AppTheme.muted, lines: 1))
        meta.addArrangedSubview(UILabel("눈 \(views)", size: 14, weight: .bold, color: AppTheme.muted, lines: 1))
        stack.addArrangedSubview(meta)
        return stack
    }
}
