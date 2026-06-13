//
//  HealthViewController.swift
//  CheckFit
//

import UIKit

final class HealthViewController: BaseScreenViewController {
    private var selectedDate = Date()
    private weak var avatarView: UIView?
    private weak var memoBubble: UIView?

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()

        let topFill = UIView()
        topFill.backgroundColor = AppTheme.brand
        topFill.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topFill)
        NSLayoutConstraint.activate([
            topFill.topAnchor.constraint(equalTo: view.topAnchor),
            topFill.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topFill.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topFill.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])

        // 위로 당겨 오버스크롤할 때 초록 헤더 위가 흰색으로 보이지 않도록 채우는 초록 배경
        let bounceFill = UIView()
        bounceFill.backgroundColor = AppTheme.brand
        bounceFill.translatesAutoresizingMaskIntoConstraints = false
        scrollView.insertSubview(bounceFill, belowSubview: stackView)
        NSLayoutConstraint.activate([
            bounceFill.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            bounceFill.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            bounceFill.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: 24),
            bounceFill.heightAnchor.constraint(equalToConstant: 1000)
        ])

        build()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        build()
    }

    @objc private func streakPillTapped() {
        present(StreakViewController(), animated: true)
    }

    @objc private func bellTapped() {
        present(NotificationsViewController(), animated: true)
    }

    @objc private func profileTapped() {
        if memoBubble != nil { dismissMemoBubble(); return }
        showMemoBubble()
    }

    private func dismissMemoBubble() {
        memoBubble?.superview?.removeFromSuperview()   // 오버레이까지 제거
        memoBubble = nil
    }

    private func showMemoBubble() {
        guard let avatarView else { return }
        let memo = ProfileStore.shared.memo.trimmingCharacters(in: .whitespacesAndNewlines)
        let text = memo.isEmpty ? "작성된 메모가 없어요" : memo

        // 바깥을 터치하면 닫히도록 투명 오버레이
        let overlay = UIControl()
        overlay.frame = view.bounds
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.addAction(UIAction { [weak self] _ in self?.dismissMemoBubble() }, for: .touchUpInside)
        view.addSubview(overlay)

        let bubble = UIView()
        bubble.backgroundColor = .white
        bubble.layer.cornerRadius = 14
        bubble.layer.shadowColor = UIColor.black.cgColor
        bubble.layer.shadowOpacity = 0.14
        bubble.layer.shadowRadius = 12
        bubble.layer.shadowOffset = CGSize(width: 0, height: 6)
        bubble.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(bubble)

        // 말풍선 꼬리(아바타를 가리키는 삼각형)
        let pointer = TriangleView()
        pointer.color = .white
        pointer.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(pointer)

        let label = UILabel(text, size: 14, weight: memo.isEmpty ? .semibold : .bold,
                            color: memo.isEmpty ? AppTheme.muted : AppTheme.text, lines: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        bubble.addSubview(label)

        let avatarFrame = avatarView.convert(avatarView.bounds, to: view)
        NSLayoutConstraint.activate([
            pointer.topAnchor.constraint(equalTo: view.topAnchor, constant: avatarFrame.maxY + 4),
            pointer.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: avatarFrame.midX),
            pointer.widthAnchor.constraint(equalToConstant: 18),
            pointer.heightAnchor.constraint(equalToConstant: 9),

            bubble.topAnchor.constraint(equalTo: pointer.bottomAnchor, constant: -1),
            bubble.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            bubble.widthAnchor.constraint(lessThanOrEqualToConstant: 240),
            bubble.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 18),

            label.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -12),
            label.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -14)
        ])

        memoBubble = bubble

        // 작게 팝업되는 느낌
        bubble.alpha = 0
        pointer.alpha = 0
        bubble.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.18) {
            bubble.alpha = 1
            pointer.alpha = 1
            bubble.transform = .identity
        }
    }

    @objc private func dietHeaderTapped() {
        present(DietDetailViewController(date: selectedDate), animated: true)
    }

    @objc private func dateGroupTapped() {
        let calendar = CalendarPickerViewController(date: selectedDate)
        calendar.onSelect = { [weak self] date in
            self?.selectedDate = date
            self?.build()
        }
        present(calendar, animated: true)
    }

    private func build() {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        stackView.addArrangedSubview(headerView())

        let body = paddedStack(spacing: 16, insets: UIEdgeInsets(top: 8, left: 26, bottom: 122, right: 26))
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
        stack.spacing = 16
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
        let titleLabel = UILabel()
        titleLabel.attributedText = NSAttributedString(string: AppDateText.mainTitle(for: selectedDate), attributes: [
            .font: AppTheme.font(30, .bold),
            .foregroundColor: UIColor.white,
            .kern: -1.5
        ])
        dateGroup.addArrangedSubview(titleLabel)
        dateGroup.addArrangedSubview(UIImageView(symbol: "chevron.down", color: .white, size: 17, weight: .bold))
        dateGroup.isUserInteractionEnabled = true
        dateGroup.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dateGroupTapped)))
        top.addArrangedSubview(dateGroup)
        top.addArrangedSubview(UIView())
        let streakPill = UILabel()
        streakPill.textAlignment = .center
        streakPill.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        streakPill.layer.cornerRadius = 20
        streakPill.clipsToBounds = true
        streakPill.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            streakPill.heightAnchor.constraint(equalToConstant: 40),
            streakPill.widthAnchor.constraint(equalToConstant: 58)
        ])
        let bolt = NSTextAttachment()
        bolt.image = UIImage(systemName: "bolt", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold))?
            .withTintColor(.systemOrange, renderingMode: .alwaysOriginal)
        let streakText = NSMutableAttributedString(attributedString: NSAttributedString(attachment: bolt))
        streakText.append(NSAttributedString(
            string: " \(HealthStore.shared.currentStreak)",
            attributes: [.font: AppTheme.font(16, .black), .foregroundColor: UIColor.white]
        ))
        streakPill.attributedText = streakText
        streakPill.isUserInteractionEnabled = true
        streakPill.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(streakPillTapped)))
        top.addArrangedSubview(streakPill)
        let bell = UIImageView(symbol: "bell", color: .white, size: 28, weight: .medium)
        bell.isUserInteractionEnabled = true
        bell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bellTapped)))
        top.addArrangedSubview(bell)

        let avatarView = avatar(size: 40)
        avatarView.isUserInteractionEnabled = true
        avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileTapped)))
        self.avatarView = avatarView
        top.addArrangedSubview(avatarView)
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
            header.heightAnchor.constraint(equalToConstant: 196),
            stack.topAnchor.constraint(equalTo: header.topAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 30),
            stack.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -30),
            stack.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -22)
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
        column.spacing = 10
        column.isUserInteractionEnabled = false
        column.translatesAutoresizingMaskIntoConstraints = false
        control.addSubview(column)

        let dayLabel = UILabel(day, size: 13, weight: .black, color: UIColor.white.withAlphaComponent(0.62), lines: 1)
        dayLabel.textAlignment = .center
        column.addArrangedSubview(dayLabel)

        let circle = UIView()
        circle.backgroundColor = selected ? .white : .clear
        circle.layer.cornerRadius = 18
        circle.translatesAutoresizingMaskIntoConstraints = false
        let dateLabel = UILabel(date, size: 16, weight: .black, color: selected ? AppTheme.brand : .white, lines: 1)
        dateLabel.textAlignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        circle.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            circle.widthAnchor.constraint(equalToConstant: 36),
            circle.heightAnchor.constraint(equalToConstant: 36),
            dateLabel.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: circle.centerYAnchor)
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

        let dietTitle = UILabel("식단", size: 17, weight: .black, color: AppTheme.muted, lines: 1)
        let dietChevron = UIImageView(symbol: "chevron.right", color: AppTheme.muted, size: 13, weight: .bold)
        let dietHeader = UIStackView(arrangedSubviews: [dietTitle, dietChevron, UIView()])
        dietHeader.axis = .horizontal
        dietHeader.alignment = .center
        dietHeader.spacing = 6
        dietHeader.isUserInteractionEnabled = true
        dietHeader.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dietHeaderTapped)))
        stack.addArrangedSubview(dietHeader)

        let diet = HealthStore.shared.dietTotals(selectedDate)
        let carbCal = diet.carb * 4, proteinCal = diet.protein * 4, fatCal = diet.fat * 9
        let macroSum = max(carbCal + proteinCal + fatCal, 0.0001)
        let pct: (Double) -> Int = { diet.kcal > 0 ? Int(round($0 / macroSum * 100)) : 0 }
        let kcalText = NumberFormatter.localizedString(from: NSNumber(value: diet.kcal), number: .decimal)
        stack.addArrangedSubview(UILabel("\(kcalText) kcal", size: 34, weight: .black, color: AppTheme.text, lines: 1))

        let nutrients = UIStackView()
        nutrients.axis = .horizontal
        nutrients.alignment = .center
        nutrients.spacing = 9
        nutrients.addArrangedSubview(nutrient("탄수화물 \(pct(carbCal))%", AppTheme.brand))
        nutrients.addArrangedSubview(nutrient("단백질 \(pct(proteinCal))%", .systemTeal))
        nutrients.addArrangedSubview(nutrient("지방 \(pct(fatCal))%", .systemYellow))
        nutrients.addArrangedSubview(UIView())
        stack.addArrangedSubview(nutrients)

        let meals = UIStackView()
        meals.axis = .horizontal
        meals.distribution = .fillEqually
        meals.spacing = 14
        meals.addArrangedSubview(mealButton("아침", "sunrise", .systemOrange))
        meals.addArrangedSubview(mealButton("점심", "sun.max", .systemYellow))
        meals.addArrangedSubview(mealButton("저녁", "moon", .systemTeal))
        meals.addArrangedSubview(mealButton("간식", "", .systemRed, image: appleOutlineImage(size: 34, color: .systemRed, lineWidth: 2.2)))
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
        row.spacing = 6
        let dot = UIView()
        dot.backgroundColor = color
        dot.layer.cornerRadius = 4.5
        dot.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: 9),
            dot.heightAnchor.constraint(equalToConstant: 9)
        ])
        row.addArrangedSubview(dot)
        let label = UILabel(text, size: 13, weight: .bold, color: AppTheme.muted, lines: 1)
        label.minimumScaleFactor = 0.6
        row.addArrangedSubview(label)
        return row
    }


    private func mealButton(_ title: String, _ symbol: String, _ color: UIColor, image: UIImage? = nil) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8

        let tileWrap = UIView()
        tileWrap.translatesAutoresizingMaskIntoConstraints = false

        let recorded = HealthStore.shared.mealKcal(selectedDate, title)

        let tile = UIButton(type: .system)
        tile.backgroundColor = AppTheme.softFill
        tile.tintColor = color
        tile.layer.cornerRadius = 18
        if recorded > 0 {
            // 기록된 끼니: 아이콘 대신 누적 칼로리를 보여준다.
            tile.setAttributedTitle(NSAttributedString(string: "\(recorded)", attributes: [
                .font: AppTheme.font(19, .black), .foregroundColor: AppTheme.brand
            ]), for: .normal)
        } else if let image {
            tile.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            tile.setImage(UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)), for: .normal)
        }
        tile.addAction(UIAction { [weak self] _ in self?.presentFoodSearch(meal: title) }, for: .touchUpInside)
        tile.translatesAutoresizingMaskIntoConstraints = false
        tileWrap.addSubview(tile)

        NSLayoutConstraint.activate([
            tile.widthAnchor.constraint(equalToConstant: 58),
            tile.heightAnchor.constraint(equalToConstant: 58),
            tile.topAnchor.constraint(equalTo: tileWrap.topAnchor, constant: 5),
            tile.leadingAnchor.constraint(equalTo: tileWrap.leadingAnchor),
            tile.trailingAnchor.constraint(equalTo: tileWrap.trailingAnchor),
            tile.bottomAnchor.constraint(equalTo: tileWrap.bottomAnchor)
        ])

        // 아직 기록 전인 끼니에만 + 배지를 단다.
        if recorded == 0 {
            let plus = UIButton(type: .system)
            plus.backgroundColor = AppTheme.brand
            plus.tintColor = .white
            plus.layer.cornerRadius = 11
            plus.layer.borderWidth = 2
            plus.layer.borderColor = UIColor.white.cgColor
            plus.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)), for: .normal)
            plus.addAction(UIAction { [weak self] _ in self?.presentFoodSearch(meal: title) }, for: .touchUpInside)
            plus.translatesAutoresizingMaskIntoConstraints = false
            tileWrap.addSubview(plus)
            NSLayoutConstraint.activate([
                plus.widthAnchor.constraint(equalToConstant: 22),
                plus.heightAnchor.constraint(equalToConstant: 22),
                plus.topAnchor.constraint(equalTo: tileWrap.topAnchor),
                plus.trailingAnchor.constraint(equalTo: tile.trailingAnchor, constant: 4)
            ])
        }

        stack.addArrangedSubview(tileWrap)
        stack.addArrangedSubview(UILabel(title, size: 13, weight: .bold, color: AppTheme.muted, lines: 1))
        return stack
    }

    private func metricGrid() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16

        let store = HealthStore.shared
        let weightText = String(format: "%.1f kg", store.weight)
        let waterText = "\(store.waterAmount) ml"
        let remaining = max(0, store.waterGoal - store.waterAmount)
        let waterSubtitle = remaining > 0
            ? "목표까지 \(NumberFormatter.localizedString(from: NSNumber(value: remaining), number: .decimal))ml"
            : "목표 달성 🎉"

        let exMinutes = store.exerciseMinutes(for: Date())
        let exKcal = store.exerciseKcal(for: Date())
        let exerciseSubtitle = exKcal > 0 ? "\(exKcal)kcal 태웠어요" : "운동을 시작해보세요"

        // 단식 중이면 경과 시간, 아니면 0시간.
        let fastingValue: String
        if let start = store.fastingStart {
            fastingValue = "\(max(0, Int(Date().timeIntervalSince(start) / 3600))) 시간"
        } else {
            fastingValue = "0 시간"
        }

        let first = row()
        first.addArrangedSubview(metricCard(title: "체중", value: weightText, subtitle: "최근 기록 1개", symbol: "figure.stand", color: .systemPink) { [weak self] in
            self?.presentWeightDetail()
        })
        first.addArrangedSubview(metricCard(title: "단식", value: fastingValue, subtitle: "체지방을 뿌셔봐요", symbol: "hourglass", color: .systemOrange) { [weak self] in
            self?.presentFastingDetail()
        })
        stack.addArrangedSubview(first)

        let second = row()
        second.addArrangedSubview(metricCard(title: "운동", value: "\(exMinutes) 분", subtitle: exerciseSubtitle, symbol: "figure.strengthtraining.traditional", color: AppTheme.brand) { [weak self] in
            self?.presentExerciseDetail()
        })
        let waterProgress = store.waterGoal > 0 ? CGFloat(store.waterAmount) / CGFloat(store.waterGoal) : 0
        second.addArrangedSubview(metricCard(title: "수분", value: waterText, subtitle: waterSubtitle, symbol: "drop", color: .systemBlue, fillProgress: waterProgress) { [weak self] in
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

    private func metricCard(title: String, value: String, subtitle: String, symbol: String, color: UIColor, fillProgress: CGFloat? = nil, action: (() -> Void)?) -> UIView {
        let card = MetricCardView(title: title, value: value, subtitle: subtitle, symbol: symbol, color: color, fillProgress: fillProgress)
        card.heightAnchor.constraint(equalToConstant: 150).isActive = true
        if let action {
            card.onTap = action
        }
        return card
    }

    func presentExerciseSearch() {
        present(SearchListViewController.exercise(), animated: true)
    }

    func presentExerciseDetail() {
        let minutes = HealthStore.shared.exerciseMinutes(for: Date())
        let kcal = HealthStore.shared.exerciseKcal(for: Date())
        present(DetailViewController(kind: "운동", value: "\(minutes) 분", symbol: "figure.strengthtraining.traditional", color: AppTheme.brand, note: kcal > 0 ? "\(kcal)kcal 태웠어요" : ""), animated: true)
    }

    func presentFastingDetail() {
        present(DetailViewController(kind: "단식", value: "0 시간", symbol: "hourglass", color: .systemOrange, note: ""), animated: true)
    }

    func presentFoodSearch(meal: String) {
        present(FoodSearchViewController(meal: meal), animated: true)
    }

    func presentWaterDetail() {
        let store = HealthStore.shared
        present(DetailViewController(kind: "수분", value: "\(store.waterAmount) ml", symbol: "drop.fill", color: .systemBlue, note: "목표 섭취량: \(store.waterGoal)ml"), animated: true)
    }

    func presentWeightDetail() {
        present(DetailViewController(kind: "체중", value: "43.7 kg", symbol: "scalemass", color: AppTheme.weight, note: "최근 기록보다 -1.9kg"), animated: true)
    }
}

final class MetricCardView: UIView {
    var onTap: (() -> Void)?

    init(title: String, value: String, subtitle: String, symbol: String, color: UIColor, fillProgress: CGFloat? = nil) {
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
        top.addArrangedSubview(UIView())
        stack.addArrangedSubview(top)
        stack.addArrangedSubview(UILabel(value, size: 22, weight: .black, color: AppTheme.text, lines: 1))
        stack.addArrangedSubview(UILabel(subtitle, size: 12, weight: .semibold, color: AppTheme.muted, lines: 2))
        stack.addArrangedSubview(UIView())

        let iconRow = UIStackView()
        iconRow.axis = .horizontal
        iconRow.addArrangedSubview(UIView())
        if let fillProgress {
            iconRow.addArrangedSubview(WaterDropIconView(progress: fillProgress, color: color, size: 30))
        } else {
            let icon = UIImageView(symbol: symbol, color: color, size: 30, weight: .semibold)
            iconRow.addArrangedSubview(icon)
        }
        stack.addArrangedSubview(iconRow)

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

/// 물방울 모양 아이콘. progress(0~1)만큼 아래에서부터 물이 차오른다.
final class WaterDropIconView: UIView {
    private let emptyIcon: UIImageView
    private let fillIcon: UIImageView
    private let fillClip = UIView()
    private var clipHeight: NSLayoutConstraint!
    private let dim: CGFloat

    var progress: CGFloat = 0 {
        didSet { clipHeight.constant = dim * max(0, min(1, progress)) }
    }

    init(progress: CGFloat, color: UIColor, size: CGFloat) {
        dim = size + 4
        emptyIcon = UIImageView(symbol: "drop", color: color, size: size)
        fillIcon = UIImageView(symbol: "drop.fill", color: color, size: size)
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(emptyIcon)
        fillClip.translatesAutoresizingMaskIntoConstraints = false
        fillClip.clipsToBounds = true
        addSubview(fillClip)
        fillClip.addSubview(fillIcon)

        clipHeight = fillClip.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: dim),
            heightAnchor.constraint(equalToConstant: dim),

            emptyIcon.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyIcon.centerYAnchor.constraint(equalTo: centerYAnchor),

            fillClip.leadingAnchor.constraint(equalTo: leadingAnchor),
            fillClip.trailingAnchor.constraint(equalTo: trailingAnchor),
            fillClip.bottomAnchor.constraint(equalTo: bottomAnchor),
            clipHeight,

            fillIcon.centerXAnchor.constraint(equalTo: centerXAnchor),
            fillIcon.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // 이니셜라이저 안 프로퍼티 대입은 didSet을 호출하지 않으므로 직접 반영한다.
        self.progress = progress
        clipHeight.constant = dim * max(0, min(1, progress))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 알림 화면 (홈 알림종)

/// 홈 헤더의 알림종을 누르면 나오는 알림 목록 화면.
final class NotificationsViewController: UIViewController {
    private struct Noti {
        let icon: String
        let color: UIColor
        let title: String
        let subtitle: String
        let time: String
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        modalPresentationStyle = .fullScreen
        build()
    }

    init() { super.init(nibName: nil, bundle: nil); modalPresentationStyle = .fullScreen }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func notifications() -> [Noti] {
        let store = HealthStore.shared
        var items: [Noti] = []
        items.append(Noti(icon: "bolt.fill", color: .systemOrange,
                          title: "연속 기록 \(store.currentStreak)일째 🔥",
                          subtitle: "오늘도 기록을 이어가 보세요!", time: "방금 전"))
        items.append(Noti(icon: "flag.fill", color: AppTheme.brand,
                          title: "오늘의 미션이 도착했어요",
                          subtitle: "미션을 완료하고 코인을 받아보세요.", time: "30분 전"))
        let remaining = max(0, store.waterGoal - store.waterAmount)
        if remaining > 0 {
            items.append(Noti(icon: "drop.fill", color: .systemBlue,
                              title: "수분 섭취 알림",
                              subtitle: "목표까지 \(remaining)ml 남았어요. 물 한 잔 어때요?", time: "1시간 전"))
        }
        if store.dietEntries(for: Date()).isEmpty {
            items.append(Noti(icon: "fork.knife", color: .systemRed,
                              title: "식단 기록 알림",
                              subtitle: "오늘 먹은 음식을 기록해보세요.", time: "오늘"))
        }
        items.append(Noti(icon: "bag.fill", color: AppTheme.brand,
                          title: "상점을 확인해보세요",
                          subtitle: "모은 코인으로 '연속 기록 이어주기' 아이템을 받을 수 있어요.", time: "어제"))
        return items
    }

    private func build() {
        let back = IconButton(symbol: "chevron.left", color: AppTheme.text, pointSize: 22)
        back.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)
        back.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(back)

        let title = UILabel("알림", size: 24, weight: .black, color: AppTheme.text, lines: 1)
        title.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(title)

        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let list = UIStackView()
        list.axis = .vertical
        list.spacing = 12
        list.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(list)

        for noti in notifications() {
            list.addArrangedSubview(card(noti))
        }

        NSLayoutConstraint.activate([
            back.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            back.widthAnchor.constraint(equalToConstant: 36),
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            title.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 10),

            scroll.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 16),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            list.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            list.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -30),
            list.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 20),
            list.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -20)
        ])
    }

    private func card(_ noti: Noti) -> UIView {
        let card = UIView()
        card.applyCard(radius: 20)
        card.translatesAutoresizingMaskIntoConstraints = false

        let tile = symbolTile(symbol: noti.icon, color: noti.color, size: 46, corner: 14)

        let titleRow = UIStackView(arrangedSubviews: [
            UILabel(noti.title, size: 15, weight: .black, color: AppTheme.text, lines: 1),
            UIView(),
            UILabel(noti.time, size: 12, weight: .bold, color: AppTheme.muted, lines: 1)
        ])
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        let subtitle = UILabel(noti.subtitle, size: 13, weight: .semibold, color: AppTheme.muted, lines: 0)
        let textCol = UIStackView(arrangedSubviews: [titleRow, subtitle])
        textCol.axis = .vertical
        textCol.spacing = 4

        let row = UIStackView(arrangedSubviews: [tile, textCol])
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 14
        row.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        return card
    }
}
