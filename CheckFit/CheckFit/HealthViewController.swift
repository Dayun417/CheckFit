//
//  HealthViewController.swift
//  CheckFit
//

import UIKit

final class HealthViewController: BaseScreenViewController {
    private var selectedDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        build()
    }

    private func build() {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        stackView.addArrangedSubview(headerView())

        let body = paddedStack(spacing: 16, insets: UIEdgeInsets(top: 22, left: 26, bottom: 122, right: 26))
        body.addArrangedSubview(dietCard())
        body.addArrangedSubview(metricGrid())
        stackView.addArrangedSubview(body)
    }

    private func headerView() -> UIView {
        let header = UIView()
        header.backgroundColor = AppTheme.brand
        header.layer.cornerRadius = 36
        header.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        header.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 30
        stack.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(stack)

        let top = UIStackView()
        top.axis = .horizontal
        top.alignment = .center
        top.spacing = 16

        let dateGroup = UIStackView()
        dateGroup.axis = .horizontal
        dateGroup.alignment = .center
        dateGroup.spacing = 4
        dateGroup.addArrangedSubview(UILabel(AppDateText.mainTitle(for: selectedDate), size: 30, weight: .black, color: .white, lines: 1))
        dateGroup.addArrangedSubview(UIImageView(symbol: "chevron.down", color: .white, size: 17, weight: .bold))
        top.addArrangedSubview(dateGroup)
        top.addArrangedSubview(UIView())
        top.addArrangedSubview(makePill("🔥 1", background: UIColor.white.withAlphaComponent(0.22), fontSize: 16))
        top.addArrangedSubview(UIImageView(symbol: "bell", color: .white, size: 28, weight: .medium))
        top.addArrangedSubview(avatar(size: 48))
        stack.addArrangedSubview(top)

        let week = UIStackView()
        week.axis = .horizontal
        week.distribution = .fillEqually
        week.alignment = .top
        for item in AppDateText.week(containing: selectedDate, selectedDate: selectedDate) {
            week.addArrangedSubview(dayColumn(day: item.weekday, date: item.day, selected: item.isSelected) { [weak self] in
                self?.selectedDate = item.date
                self?.build()
            })
        }
        stack.addArrangedSubview(week)

        NSLayoutConstraint.activate([
            header.heightAnchor.constraint(equalToConstant: 250),
            stack.topAnchor.constraint(equalTo: header.topAnchor, constant: 44),
            stack.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 30),
            stack.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -30),
            stack.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -30)
        ])
        return header
    }

    private func dayColumn(day: String, date: String, selected: Bool, action: @escaping () -> Void) -> UIView {
        let control = UIControl()
        control.addAction(UIAction { _ in action() }, for: .touchUpInside)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.heightAnchor.constraint(equalToConstant: 79).isActive = true

        let column = UIStackView()
        column.axis = .vertical
        column.alignment = .center
        column.spacing = 14
        column.isUserInteractionEnabled = false
        column.translatesAutoresizingMaskIntoConstraints = false
        control.addSubview(column)
        column.addArrangedSubview(UILabel(day, size: 13, weight: .black, color: UIColor.white.withAlphaComponent(0.62), lines: 1))

        let circle = UIView()
        circle.backgroundColor = selected ? .white : .clear
        circle.layer.cornerRadius = 26
        circle.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel(date, size: 18, weight: .black, color: selected ? AppTheme.brand : .white, lines: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        circle.addSubview(label)
        NSLayoutConstraint.activate([
            circle.widthAnchor.constraint(equalToConstant: 52),
            circle.heightAnchor.constraint(equalToConstant: 52),
            label.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: circle.centerYAnchor)
        ])
        column.addArrangedSubview(circle)
        NSLayoutConstraint.activate([
            column.topAnchor.constraint(equalTo: control.topAnchor),
            column.leadingAnchor.constraint(equalTo: control.leadingAnchor),
            column.trailingAnchor.constraint(equalTo: control.trailingAnchor),
            column.bottomAnchor.constraint(equalTo: control.bottomAnchor)
        ])
        return control
    }

    private func dietCard() -> UIView {
        let card = UIView()
        card.applyCard(radius: 30)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        stack.addArrangedSubview(UILabel("식단", size: 17, weight: .black, color: AppTheme.muted, lines: 1))
        stack.addArrangedSubview(UILabel("0 kcal", size: 34, weight: .black, color: AppTheme.text, lines: 1))

        let nutrients = UIStackView()
        nutrients.axis = .horizontal
        nutrients.distribution = .fillEqually
        nutrients.addArrangedSubview(nutrient("탄 0%", AppTheme.brand))
        nutrients.addArrangedSubview(nutrient("단 0%", .systemTeal))
        nutrients.addArrangedSubview(nutrient("지 0%", .systemGreen))
        stack.addArrangedSubview(nutrients)

        let meals = UIStackView()
        meals.axis = .horizontal
        meals.distribution = .fillEqually
        meals.spacing = 14
        meals.addArrangedSubview(mealButton("아침", "sunrise", .systemOrange))
        meals.addArrangedSubview(mealButton("점심", "sun.max", .systemYellow))
        meals.addArrangedSubview(mealButton("저녁", "moon", .systemTeal))
        meals.addArrangedSubview(mealButton("간식", "apple.logo", .systemRed))
        stack.addArrangedSubview(meals)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 26),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 26),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -26),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24)
        ])
        return card
    }

    private func nutrient(_ text: String, _ color: UIColor) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 7
        let dot = UIView()
        dot.backgroundColor = color
        dot.layer.cornerRadius = 5
        dot.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: 10),
            dot.heightAnchor.constraint(equalToConstant: 10)
        ])
        row.addArrangedSubview(dot)
        row.addArrangedSubview(UILabel(text, size: 14, weight: .bold, color: AppTheme.muted, lines: 1))
        return row
    }

    private func mealButton(_ title: String, _ symbol: String, _ color: UIColor) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        let tile = UIButton(type: .system)
        tile.backgroundColor = AppTheme.softFill
        tile.tintColor = color
        tile.layer.cornerRadius = 18
        tile.setImage(UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
        tile.addAction(UIAction { [weak self] _ in self?.presentFoodSearch(meal: title) }, for: .touchUpInside)
        tile.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tile.widthAnchor.constraint(equalToConstant: 58),
            tile.heightAnchor.constraint(equalToConstant: 58)
        ])
        stack.addArrangedSubview(tile)
        stack.addArrangedSubview(UILabel(title, size: 13, weight: .bold, color: AppTheme.muted, lines: 1))
        return stack
    }

    private func metricGrid() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16

        let first = row()
        first.addArrangedSubview(metricCard(title: "체중", value: "45.6 kg", subtitle: "최근 기록 1개", symbol: "figure.stand", color: .systemPink) { [weak self] in
            self?.presentWeightDetail()
        })
        first.addArrangedSubview(metricCard(title: "단식", value: "?? 시간", subtitle: "체지방을 뿌셔봐요 ⏳", symbol: "hourglass", color: .systemPink, action: nil))
        stack.addArrangedSubview(first)

        let second = row()
        second.addArrangedSubview(metricCard(title: "운동", value: "12 분", subtitle: "56kcal 태웠어요", symbol: "figure.strengthtraining.traditional", color: AppTheme.brand) { [weak self] in
            self?.presentExerciseSearch()
        })
        second.addArrangedSubview(metricCard(title: "수분", value: "400 ml", subtitle: "목표까지 1,100ml", symbol: "drop", color: .systemBlue) { [weak self] in
            self?.presentWaterDetail()
        })
        stack.addArrangedSubview(second)
        return stack
    }

    private func row() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 16
        return row
    }

    private func metricCard(title: String, value: String, subtitle: String, symbol: String, color: UIColor, action: (() -> Void)?) -> UIView {
        let card = MetricCardView(title: title, value: value, subtitle: subtitle, symbol: symbol, color: color)
        card.heightAnchor.constraint(equalToConstant: 150).isActive = true
        if let action {
            card.onTap = action
        }
        return card
    }

    func presentExerciseSearch() {
        present(SearchListViewController.exercise(), animated: true)
    }

    func presentFoodSearch(meal: String) {
        present(SearchListViewController.food(meal: meal), animated: true)
    }

    func presentWaterDetail() {
        present(DetailViewController(kind: "수분", value: "400 ml", symbol: "drop.fill", color: .systemBlue, note: "목표 섭취량: 1500ml"), animated: true)
    }

    func presentWeightDetail() {
        present(DetailViewController(kind: "체중", value: "43.7 kg", symbol: "scalemass", color: AppTheme.weight, note: "최근 기록보다 -1.9kg"), animated: true)
    }
}

final class MetricCardView: UIView {
    var onTap: (() -> Void)?

    init(title: String, value: String, subtitle: String, symbol: String, color: UIColor) {
        super.init(frame: .zero)
        applyCard(radius: 26)
        translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 7
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        let top = UIStackView()
        top.axis = .horizontal
        top.alignment = .center
        top.distribution = .equalSpacing
        top.addArrangedSubview(UILabel(title, size: 15, weight: .black, color: AppTheme.muted, lines: 1))
        let dot = UIView()
        dot.backgroundColor = .systemPink
        dot.layer.cornerRadius = 6
        dot.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: 12),
            dot.heightAnchor.constraint(equalToConstant: 12)
        ])
        top.addArrangedSubview(dot)
        stack.addArrangedSubview(top)
        stack.addArrangedSubview(UILabel(value, size: 22, weight: .black, color: AppTheme.text, lines: 1))
        stack.addArrangedSubview(UILabel(subtitle, size: 12, weight: .semibold, color: AppTheme.muted, lines: 2))
        stack.addArrangedSubview(UIView())

        let icon = UIImageView(symbol: symbol, color: color, size: 30, weight: .semibold)
        icon.contentMode = .right
        stack.addArrangedSubview(icon)

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func tapped() {
        onTap?()
    }
}
