//
//  MissionViewController.swift
//  CheckFit
//

import UIKit

final class MissionViewController: BaseScreenViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        build()
    }

    private func build() {
        stackView.addArrangedSubview(header())
        let body = paddedStack(spacing: 16, insets: UIEdgeInsets(top: 26, left: 24, bottom: 122, right: 24))
        body.addArrangedSubview(UILabel("기본 미션", size: 27, weight: .black, color: AppTheme.text, lines: 1))
        body.addArrangedSubview(mission(symbol: "bolt", color: .systemOrange, caption: "연속 기록", title: "5일 달성하기", reward: "5", done: false, progress: 0.2))
        body.addArrangedSubview(mission(symbol: "fork.knife", color: .systemOrange, caption: "오늘 먹은", title: "식사 기록하기", reward: "5", done: true, progress: nil))
        body.addArrangedSubview(mission(symbol: "flame", color: .systemOrange, caption: "0/200 kcal", title: "움직이기", reward: "5", done: false, progress: nil))
        body.addArrangedSubview(mission(symbol: "drop", color: .systemBlue, caption: "하루 1L 이상", title: "물 마시기", reward: "3", done: false, progress: nil))
        stackView.addArrangedSubview(body)
    }

    private func header() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .equalSpacing
        row.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(row)
        row.addArrangedSubview(UILabel("미션", size: 30, weight: .black, color: AppTheme.text, lines: 1))
        row.addArrangedSubview(makePill("● 1,250", foreground: AppTheme.text, background: AppTheme.softFill, fontSize: 17))
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            row.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            row.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            row.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24)
        ])
        return view
    }

    private func mission(symbol: String, color: UIColor, caption: String, title: String, reward: String, done: Bool, progress: Float?) -> UIView {
        let card = UIView()
        card.applyCard(radius: 28)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 116).isActive = true

        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 16
        row.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(row)
        row.addArrangedSubview(symbolTile(symbol: symbol, color: color, size: 58, corner: 20))

        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 5
        textStack.addArrangedSubview(UILabel(caption, size: 14, weight: .black, color: AppTheme.muted, lines: 1))
        textStack.addArrangedSubview(UILabel(title, size: 19, weight: .black, color: AppTheme.text, lines: 1))
        if let progress {
            let bar = UIProgressView(progressViewStyle: .bar)
            bar.progress = progress
            bar.progressTintColor = AppTheme.brand
            bar.trackTintColor = AppTheme.softFill
            textStack.addArrangedSubview(bar)
        }
        row.addArrangedSubview(textStack)
        row.addArrangedSubview(UIView())
        row.addArrangedSubview(makePill("● \(reward)", foreground: AppTheme.text, background: AppTheme.softFill, fontSize: 16))
        row.addArrangedSubview(UIImageView(symbol: done ? "checkmark.circle.fill" : "checkmark.circle", color: done ? AppTheme.brand : UIColor.systemGray4, size: 31, weight: .medium))

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])
        return card
    }
}
