//
//  SearchAndDetailViewControllers.swift
//  CheckFit
//

import UIKit

final class SearchListViewController: UIViewController {
    private let placeholder: String
    private let tabs: [String]
    private let rows: [String]
    private let actionTitle: String

    static func exercise() -> SearchListViewController {
        SearchListViewController(
            placeholder: "운동 이름을 검색해주세요",
            tabs: ["분류", "전체", "자주 했어요", "즐겨찾기", "직접 등록"],
            rows: ["러닝(빠르게 달리기)", "리버스 컬 (덤벨)", "마이마운틴", "검도", "플라잉요가", "스피닝", "폴댄스"],
            actionTitle: "기록하기"
        )
    }

    static func food(meal: String) -> SearchListViewController {
        SearchListViewController(
            placeholder: "음식명, 브랜드명으로 검색",
            tabs: ["자주 드셨어요", "즐겨찾기", "직접 등록"],
            rows: ["삶은 달걀  65kcal", "사과  104kcal", "바나나  114kcal", "방울토마토  3kcal", "흰쌀밥  336kcal", "블루베리  9kcal", "계란후라이  95kcal"],
            actionTitle: "\(meal)에 기록하기"
        )
    }

    private init(placeholder: String, tabs: [String], rows: [String], actionTitle: String) {
        self.placeholder = placeholder
        self.tabs = tabs
        self.rows = rows
        self.actionTitle = actionTitle
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        build()
    }

    private func build() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let top = UIStackView()
        top.axis = .horizontal
        top.alignment = .center
        top.spacing = 10
        top.isLayoutMarginsRelativeArrangement = true
        top.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 10, right: 16)
        let back = IconButton(symbol: "chevron.left", color: AppTheme.text, pointSize: 24)
        back.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)
        top.addArrangedSubview(back)
        top.addArrangedSubview(searchField())
        stack.addArrangedSubview(top)

        let tabRow = UIStackView()
        tabRow.axis = .horizontal
        tabRow.spacing = 16
        tabRow.isLayoutMarginsRelativeArrangement = true
        tabRow.layoutMargins = UIEdgeInsets(top: 8, left: 22, bottom: 12, right: 22)
        for (index, tab) in tabs.enumerated() {
            tabRow.addArrangedSubview(UILabel(tab, size: 14, weight: .black, color: index == 0 || index == 1 ? AppTheme.brand : AppTheme.muted, lines: 1))
        }
        stack.addArrangedSubview(tabRow)

        let filter = UILabel("연관순⌄     장비⌄                                즐겨찾기", size: 12, weight: .bold, color: AppTheme.muted, lines: 1)
        let filterWrap = UIView()
        filterWrap.backgroundColor = AppTheme.background
        filter.translatesAutoresizingMaskIntoConstraints = false
        filterWrap.addSubview(filter)
        NSLayoutConstraint.activate([
            filter.topAnchor.constraint(equalTo: filterWrap.topAnchor, constant: 14),
            filter.leadingAnchor.constraint(equalTo: filterWrap.leadingAnchor, constant: 22),
            filter.trailingAnchor.constraint(equalTo: filterWrap.trailingAnchor, constant: -22),
            filter.bottomAnchor.constraint(equalTo: filterWrap.bottomAnchor, constant: -14)
        ])
        stack.addArrangedSubview(filterWrap)

        let list = UIStackView()
        list.axis = .vertical
        for row in rows {
            list.addArrangedSubview(rowView(row))
        }
        stack.addArrangedSubview(list)
        stack.addArrangedSubview(UIView())

        let action = UIButton(type: .system)
        action.setTitle(actionTitle, for: .normal)
        action.titleLabel?.font = AppTheme.font(16, .black)
        action.tintColor = AppTheme.brand
        action.backgroundColor = AppTheme.brand.withAlphaComponent(0.10)
        action.layer.cornerRadius = 18
        action.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)

        let actionWrap = UIView()
        action.translatesAutoresizingMaskIntoConstraints = false
        actionWrap.addSubview(action)
        NSLayoutConstraint.activate([
            action.topAnchor.constraint(equalTo: actionWrap.topAnchor, constant: 12),
            action.leadingAnchor.constraint(equalTo: actionWrap.leadingAnchor, constant: 20),
            action.trailingAnchor.constraint(equalTo: actionWrap.trailingAnchor, constant: -20),
            action.bottomAnchor.constraint(equalTo: actionWrap.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            action.heightAnchor.constraint(equalToConstant: 54)
        ])
        stack.addArrangedSubview(actionWrap)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func searchField() -> UITextField {
        let field = UITextField()
        field.placeholder = placeholder
        field.backgroundColor = AppTheme.softFill
        field.layer.cornerRadius = 22
        field.font = AppTheme.font(14, .semibold)
        field.leftView = UIImageView(symbol: "magnifyingglass", color: AppTheme.muted, size: 17, weight: .medium)
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 46).isActive = true
        return field
    }

    private func rowView(_ text: String) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 14
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 15, left: 22, bottom: 15, right: 22)
        let isFood = text.contains("kcal")
        row.addArrangedSubview(symbolTile(symbol: isFood ? "fork.knife" : "figure.run", color: isFood ? .systemOrange : AppTheme.brand, size: 50, corner: 18))
        row.addArrangedSubview(UILabel(text, size: 15, weight: .black, color: AppTheme.text, lines: 1))
        row.addArrangedSubview(UIView())
        row.addArrangedSubview(UIImageView(symbol: isFood ? "plus.circle.fill" : "star", color: isFood ? AppTheme.brand : UIColor.systemGray3, size: 22, weight: .medium))
        return row
    }
}

final class DetailViewController: UIViewController {
    private let kind: String
    private let value: String
    private let symbol: String
    private let color: UIColor
    private let note: String
    private var selectedDate = Date()
    private var waterAmount = 0
    private var waterRangeIndex = 0
    private var waterGoal = 1500
    private var waterStep = 100
    private weak var waterScrollView: UIScrollView?
    private var waterPendingOffset: CGPoint = .zero
    private var weightRangeIndex = 0
    private weak var weightScrollView: UIScrollView?
    private var weightPendingOffset: CGPoint = .zero
    private let weightValue: CGFloat = 43.7

    init(kind: String, value: String, symbol: String, color: UIColor, note: String) {
        self.kind = kind
        self.value = value
        self.symbol = symbol
        self.color = color
        self.note = note
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        build()
    }

    private func build() {
        if kind == "수분" {
            waterPendingOffset = waterScrollView?.contentOffset ?? .zero
        } else if kind == "체중" {
            weightPendingOffset = weightScrollView?.contentOffset ?? .zero
        }
        view.subviews.forEach { $0.removeFromSuperview() }
        if kind == "수분" {
            buildWaterDetail()
            return
        } else if kind == "체중" {
            buildWeightDetail()
            return
        }

        let root = UIStackView()
        root.axis = .vertical
        root.spacing = 24
        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)

        let header = UIView()
        header.backgroundColor = AppTheme.brand
        header.layer.cornerRadius = 0
        header.layer.maskedCorners = []

        let headerStack = UIStackView()
        headerStack.axis = .vertical
        headerStack.spacing = 24
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(headerStack)

        let top = UIStackView()
        top.axis = .horizontal
        top.alignment = .center
        top.distribution = .equalSpacing
        let back = IconButton(symbol: "chevron.left", color: .white, pointSize: 28)
        back.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)
        top.addArrangedSubview(back)
        top.addArrangedSubview(UILabel(AppDateText.detailTitle(for: selectedDate), size: 20, weight: .black, color: .white, lines: 1))
        top.addArrangedSubview(UIImageView(symbol: "gearshape", color: .white, size: 24, weight: .medium))
        headerStack.addArrangedSubview(top)
        headerStack.addArrangedSubview(weekStrip())
        root.addArrangedSubview(header)

        let card = UIView()
        card.applyCard(radius: 32)
        let cardStack = UIStackView()
        cardStack.axis = .vertical
        cardStack.alignment = .center
        cardStack.spacing = 16
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(cardStack)
        cardStack.addArrangedSubview(UILabel(kind, size: 15, weight: .black, color: AppTheme.muted, lines: 1))
        cardStack.addArrangedSubview(UIImageView(symbol: symbol, color: color, size: 42, weight: .medium))
        cardStack.addArrangedSubview(UILabel(value, size: 36, weight: .black, color: AppTheme.text, lines: 1))
        cardStack.addArrangedSubview(UILabel(note, size: 14, weight: .bold, color: AppTheme.muted, lines: 1))

        let wrap = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(card)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: wrap.topAnchor, constant: -36),
            card.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -24),
            card.bottomAnchor.constraint(equalTo: wrap.bottomAnchor),
            card.heightAnchor.constraint(equalToConstant: 198),
            cardStack.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            cardStack.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
        root.addArrangedSubview(wrap)

        let body = UIStackView()
        body.axis = .vertical
        body.spacing = 24
        body.isLayoutMarginsRelativeArrangement = true
        body.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 30, right: 24)
        let segmented = UISegmentedControl(items: ["일간", "주간", "월간"])
        segmented.selectedSegmentIndex = waterRangeIndex
        segmented.selectedSegmentTintColor = .white
        segmented.backgroundColor = AppTheme.softFill
        segmented.setTitleTextAttributes([.font: AppTheme.font(14, .black), .foregroundColor: AppTheme.brand], for: .selected)
        segmented.setTitleTextAttributes([.font: AppTheme.font(14, .black), .foregroundColor: AppTheme.muted], for: .normal)
        segmented.addAction(UIAction { [weak self, weak segmented] _ in
            guard let self, let segmented else { return }
            self.waterRangeIndex = segmented.selectedSegmentIndex
            self.build()
        }, for: .valueChanged)
        body.addArrangedSubview(segmented)
        body.addArrangedSubview(UILabel("\(kind) 현황", size: 22, weight: .black, color: AppTheme.text, lines: 1))
        body.addArrangedSubview(chart())
        root.addArrangedSubview(body)
        root.addArrangedSubview(UIView())

        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            root.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            header.heightAnchor.constraint(equalToConstant: 194),
            headerStack.topAnchor.constraint(equalTo: header.topAnchor, constant: 20),
            headerStack.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 22),
            headerStack.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -22),
            segmented.heightAnchor.constraint(equalToConstant: 46)
        ])
    }

    private func weekStrip() -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.alignment = .top
        for item in AppDateText.week(containing: selectedDate, selectedDate: selectedDate) {
            row.addArrangedSubview(detailDayColumn(day: item.weekday, date: item.day, selected: item.isSelected) { [weak self] in
                self?.selectedDate = item.date
                self?.build()
            })
        }
        return row
    }

    private func detailDayColumn(day: String, date: String, selected: Bool, action: @escaping () -> Void) -> UIView {
        let control = UIControl()
        control.addAction(UIAction { _ in action() }, for: .touchUpInside)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.heightAnchor.constraint(equalToConstant: 63).isActive = true

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        control.addSubview(stack)

        stack.addArrangedSubview(UILabel(day, size: 11, weight: .black, color: UIColor.white.withAlphaComponent(0.6), lines: 1))

        let numberWrap = UIView()
        numberWrap.backgroundColor = selected ? .white : .clear
        numberWrap.layer.cornerRadius = 22
        numberWrap.translatesAutoresizingMaskIntoConstraints = false
        let number = UILabel(date, size: 15, weight: .black, color: selected ? AppTheme.brand : .white, lines: 1)
        number.textAlignment = .center
        number.translatesAutoresizingMaskIntoConstraints = false
        numberWrap.addSubview(number)

        NSLayoutConstraint.activate([
            numberWrap.widthAnchor.constraint(equalToConstant: 44),
            numberWrap.heightAnchor.constraint(equalToConstant: 44),
            number.centerXAnchor.constraint(equalTo: numberWrap.centerXAnchor),
            number.centerYAnchor.constraint(equalTo: numberWrap.centerYAnchor),
            stack.topAnchor.constraint(equalTo: control.topAnchor),
            stack.leadingAnchor.constraint(equalTo: control.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: control.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: control.bottomAnchor)
        ])

        stack.addArrangedSubview(numberWrap)
        return control
    }

    private func chart() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 220).isActive = true
        for index in 0..<4 {
            let line = UIView()
            line.backgroundColor = UIColor.systemGray5
            line.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(line)
            NSLayoutConstraint.activate([
                line.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 46),
                line.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                line.heightAnchor.constraint(equalToConstant: 1),
                line.topAnchor.constraint(equalTo: view.topAnchor, constant: CGFloat(index) * 55)
            ])
        }
        return view
    }

    private func buildWeightDetail() {
        view.backgroundColor = .white

        let header = UIView()
        header.backgroundColor = AppTheme.weight
        header.layer.cornerRadius = 0
        header.layer.maskedCorners = []
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        let headerStack = UIStackView()
        headerStack.axis = .vertical
        headerStack.spacing = 18
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(headerStack)

        let top = UIStackView()
        top.axis = .horizontal
        top.alignment = .center
        top.distribution = .equalSpacing
        let back = IconButton(symbol: "chevron.left", color: .white, pointSize: 28)
        back.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)
        top.addArrangedSubview(back)
        top.addArrangedSubview(UILabel(AppDateText.detailTitle(for: selectedDate), size: 20, weight: .black, color: .white, lines: 1))
        let settings = IconButton(symbol: "gearshape", color: .white, pointSize: 20, weight: .medium)
        settings.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settings.widthAnchor.constraint(equalToConstant: 30),
            settings.heightAnchor.constraint(equalToConstant: 30)
        ])
        top.addArrangedSubview(settings)
        headerStack.addArrangedSubview(top)
        headerStack.addArrangedSubview(weekStrip())

        let content = UIScrollView()
        weightScrollView = content
        content.showsVerticalScrollIndicator = false
        content.clipsToBounds = false
        content.translatesAutoresizingMaskIntoConstraints = false
        content.backgroundColor = .clear
        view.addSubview(content)

        let body = UIStackView()
        body.axis = .vertical
        body.spacing = 18
        body.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(body)

        body.addArrangedSubview(weightSummaryCard())

        let metricsRow = UIStackView()
        metricsRow.axis = .horizontal
        metricsRow.spacing = 14
        metricsRow.distribution = .fillEqually
        metricsRow.addArrangedSubview(metricSelector(title: "체중 (kg)", selected: true))
        metricsRow.addArrangedSubview(metricSelector(title: "골격근량 (kg)", selected: false))
        metricsRow.addArrangedSubview(metricSelector(title: "체지방률 (%)", selected: false))
        body.addArrangedSubview(metricsRow)

        let record = makePill("바로 기록  +", foreground: AppTheme.muted, background: AppTheme.softFill, fontSize: 15)
        record.widthAnchor.constraint(equalToConstant: 120).isActive = true
        let recordWrap = UIStackView()
        recordWrap.axis = .horizontal
        recordWrap.addArrangedSubview(UIView())
        recordWrap.addArrangedSubview(record)
        body.addArrangedSubview(recordWrap)

        body.addArrangedSubview(weightChart())

        let segmented = UISegmentedControl(items: ["일간", "주간", "월간"])
        segmented.selectedSegmentIndex = weightRangeIndex
        segmented.selectedSegmentTintColor = .white
        segmented.backgroundColor = AppTheme.softFill
        segmented.setTitleTextAttributes([.font: AppTheme.font(14, .black), .foregroundColor: AppTheme.weight], for: .selected)
        segmented.setTitleTextAttributes([.font: AppTheme.font(14, .black), .foregroundColor: AppTheme.muted], for: .normal)
        segmented.addAction(UIAction { [weak self, weak segmented] _ in
            guard let self, let segmented else { return }
            self.weightRangeIndex = segmented.selectedSegmentIndex
            self.build()
        }, for: .valueChanged)
        body.addArrangedSubview(segmented)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 250),
            headerStack.topAnchor.constraint(equalTo: header.topAnchor, constant: 20),
            headerStack.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 22),
            headerStack.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -22),
            content.topAnchor.constraint(equalTo: header.bottomAnchor, constant: -72),
            content.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            body.topAnchor.constraint(equalTo: content.contentLayoutGuide.topAnchor),
            body.leadingAnchor.constraint(equalTo: content.frameLayoutGuide.leadingAnchor, constant: 18),
            body.trailingAnchor.constraint(equalTo: content.frameLayoutGuide.trailingAnchor, constant: -18),
            body.bottomAnchor.constraint(equalTo: content.contentLayoutGuide.bottomAnchor, constant: -34),
            segmented.heightAnchor.constraint(equalToConstant: 56)
        ])

        DispatchQueue.main.async { [weak content, offset = weightPendingOffset] in
            content?.setContentOffset(offset, animated: false)
        }
    }

    private func weightSummaryCard() -> UIView {
        let card = UIView()
        card.applyCard(radius: 32)
        card.clipsToBounds = true
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 202).isActive = true

        let title = UILabel("체중", size: 17, weight: .black, color: AppTheme.muted, lines: 1)
        let update = makePill("업데이트  ↻", foreground: AppTheme.muted, background: AppTheme.softFill, fontSize: 15)
        let top = UIStackView(arrangedSubviews: [title, UIView(), update])
        top.axis = .horizontal
        top.alignment = .center
        top.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(top)

        let minus = weightRoundButton("minus")
        let plus = weightRoundButton("plus")
        let valueRow = UIStackView()
        valueRow.axis = .horizontal
        valueRow.alignment = .lastBaseline
        valueRow.spacing = 8
        valueRow.addArrangedSubview(UILabel(String(format: "%.1f", weightValue), size: 42, weight: .black, color: AppTheme.text, lines: 1))
        valueRow.addArrangedSubview(UILabel("kg", size: 24, weight: .black, color: AppTheme.text, lines: 1))
        valueRow.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(valueRow)
        card.addSubview(minus)
        card.addSubview(plus)

        NSLayoutConstraint.activate([
            top.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            top.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            top.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            valueRow.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            valueRow.topAnchor.constraint(equalTo: card.topAnchor, constant: 82),
            minus.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 26),
            minus.centerYAnchor.constraint(equalTo: valueRow.centerYAnchor),
            plus.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -26),
            plus.centerYAnchor.constraint(equalTo: valueRow.centerYAnchor)
        ])
        return card
    }

    private func metricSelector(title: String, selected: Bool) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 20
        card.layer.borderWidth = selected ? 4 : 0
        card.layer.borderColor = selected ? UIColor(red: 0.41, green: 0.68, blue: 0.98, alpha: 1).cgColor : UIColor.clear.cgColor
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.05
        card.layer.shadowRadius = 14
        card.layer.shadowOffset = CGSize(width: 0, height: 6)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 108).isActive = true

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        stack.addArrangedSubview(UILabel(title, size: 14, weight: .bold, color: AppTheme.muted, lines: 2))
        stack.addArrangedSubview(UILabel("-", size: 28, weight: .black, color: UIColor.systemGray5, lines: 1))

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 22),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12)
        ])
        return card
    }

    private func weightRoundButton(_ symbol: String) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = AppTheme.weight
        button.tintColor = .white
        button.layer.cornerRadius = 33
        button.setImage(UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 66),
            button.heightAnchor.constraint(equalToConstant: 66)
        ])
        return button
    }

    private func weightChart() -> UIView {
        let chart = WeightTrendChartView()
        chart.mode = WeightTrendChartView.Mode(rawValue: weightRangeIndex) ?? .daily
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.heightAnchor.constraint(equalToConstant: 330).isActive = true
        return chart
    }

    private func buildWaterDetail() {
        view.backgroundColor = .white

        let header = UIView()
        header.backgroundColor = AppTheme.brand
        header.layer.cornerRadius = 0
        header.layer.maskedCorners = []
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        let headerStack = UIStackView()
        headerStack.axis = .vertical
        headerStack.spacing = 18
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(headerStack)

        let top = UIStackView()
        top.axis = .horizontal
        top.alignment = .center
        top.distribution = .equalSpacing
        let back = IconButton(symbol: "chevron.left", color: .white, pointSize: 28)
        back.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)
        top.addArrangedSubview(back)
        top.addArrangedSubview(UILabel(AppDateText.detailTitle(for: selectedDate), size: 20, weight: .black, color: .white, lines: 1))
        let settings = IconButton(symbol: "gearshape", color: .white, pointSize: 20, weight: .medium)
        settings.addAction(UIAction { [weak self] _ in self?.presentWaterSettings() }, for: .touchUpInside)
        settings.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settings.widthAnchor.constraint(equalToConstant: 30),
            settings.heightAnchor.constraint(equalToConstant: 30)
        ])
        top.addArrangedSubview(settings)
        headerStack.addArrangedSubview(top)
        headerStack.addArrangedSubview(weekStrip())

        let content = UIScrollView()
        waterScrollView = content
        content.showsVerticalScrollIndicator = false
        content.clipsToBounds = false
        content.translatesAutoresizingMaskIntoConstraints = false
        content.backgroundColor = .clear
        view.addSubview(content)

        let body = UIStackView()
        body.axis = .vertical
        body.spacing = 24
        body.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(body)

        body.addArrangedSubview(waterSummaryCard())

        let segmented = UISegmentedControl(items: ["일간", "주간", "월간"])
        segmented.selectedSegmentIndex = waterRangeIndex
        segmented.selectedSegmentTintColor = .white
        segmented.backgroundColor = AppTheme.softFill
        segmented.setTitleTextAttributes([.font: AppTheme.font(14, .black), .foregroundColor: AppTheme.brand], for: .selected)
        segmented.setTitleTextAttributes([.font: AppTheme.font(14, .black), .foregroundColor: AppTheme.muted], for: .normal)
        segmented.addAction(UIAction { [weak self, weak segmented] _ in
            guard let self, let segmented else { return }
            self.waterRangeIndex = segmented.selectedSegmentIndex
            self.build()
        }, for: .valueChanged)
        body.addArrangedSubview(segmented)

        body.addArrangedSubview(UILabel("수분 섭취 현황", size: 24, weight: .black, color: AppTheme.text, lines: 1))
        body.addArrangedSubview(waterStatusCard())

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 270),
            headerStack.topAnchor.constraint(equalTo: header.topAnchor, constant: 20),
            headerStack.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 22),
            headerStack.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -22),
            content.topAnchor.constraint(equalTo: header.bottomAnchor, constant: -100),
            content.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            body.topAnchor.constraint(equalTo: content.contentLayoutGuide.topAnchor, constant: 0),
            body.leadingAnchor.constraint(equalTo: content.frameLayoutGuide.leadingAnchor, constant: 18),
            body.trailingAnchor.constraint(equalTo: content.frameLayoutGuide.trailingAnchor, constant: -18),
            body.bottomAnchor.constraint(equalTo: content.contentLayoutGuide.bottomAnchor, constant: -34),
            segmented.heightAnchor.constraint(equalToConstant: 56)
        ])

        DispatchQueue.main.async { [weak content, offset = waterPendingOffset] in
            content?.setContentOffset(offset, animated: false)
        }
    }

    private func waterSummaryCard() -> UIView {
        let card = UIView()
        card.applyCard(radius: 38)
        card.clipsToBounds = true
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 318).isActive = true

        let water = AnimatedWaterView()
        water.progress = CGFloat(waterAmount) / CGFloat(waterGoal)
        water.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(water)

        let title = UILabel("수분", size: 17, weight: .black, color: AppTheme.muted, lines: 1)
        title.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(title)

        let valueRow = UIStackView()
        valueRow.axis = .horizontal
        valueRow.alignment = .lastBaseline
        valueRow.spacing = 8
        valueRow.translatesAutoresizingMaskIntoConstraints = false
        valueRow.addArrangedSubview(UILabel("\(waterAmount)", size: 42, weight: .black, color: AppTheme.text, lines: 1))
        valueRow.addArrangedSubview(UILabel("ml", size: 24, weight: .black, color: AppTheme.text, lines: 1))
        card.addSubview(valueRow)

        let goal = UILabel("목표 섭취량:\n\(waterGoal)ml", size: 16, weight: .black, color: AppTheme.muted, lines: 2)
        goal.textAlignment = .center
        goal.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(goal)

        let minus = waterRoundButton("minus") { [weak self] in
            guard let self else { return }
            self.waterAmount = max(0, self.waterAmount - self.waterStep)
            self.build()
        }
        let plus = waterRoundButton("plus") { [weak self] in
            guard let self else { return }
            self.waterAmount += self.waterStep
            self.build()
        }
        card.addSubview(minus)
        card.addSubview(plus)

        let percent = min(100, Int(round((Double(waterAmount) / Double(waterGoal)) * 100)))
        let badge = makePill("\(percent)%  섭취 완료 🙌", foreground: AppTheme.text, background: .white, fontSize: 15)
        badge.textColor = AppTheme.text
        badge.layer.shadowColor = UIColor.black.cgColor
        badge.layer.shadowOpacity = 0.12
        badge.layer.shadowRadius = 8
        badge.layer.shadowOffset = CGSize(width: 0, height: 3)
        card.addSubview(badge)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 42),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 30),
            valueRow.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            valueRow.topAnchor.constraint(equalTo: card.topAnchor, constant: 106),
            goal.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            goal.topAnchor.constraint(equalTo: valueRow.bottomAnchor, constant: 14),
            minus.centerYAnchor.constraint(equalTo: valueRow.centerYAnchor, constant: 8),
            minus.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 30),
            plus.centerYAnchor.constraint(equalTo: minus.centerYAnchor),
            plus.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -30),
            water.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            water.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            water.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            water.heightAnchor.constraint(equalToConstant: 122),
            badge.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            badge.centerYAnchor.constraint(equalTo: water.topAnchor, constant: 48),
            badge.widthAnchor.constraint(greaterThanOrEqualToConstant: 148)
        ])
        return card
    }

    private func waterRoundButton(_ symbol: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = AppTheme.brand
        button.tintColor = .white
        button.layer.cornerRadius = 33
        button.setImage(UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)), for: .normal)
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 66),
            button.heightAnchor.constraint(equalToConstant: 66)
        ])
        return button
    }

    private func waterStatusCard() -> UIView {
        let chart = WaterIntakeChartView()
        chart.amount = waterAmount
        chart.goal = waterGoal
        chart.mode = WaterIntakeChartView.Mode(rawValue: waterRangeIndex) ?? .daily
        chart.date = selectedDate
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.heightAnchor.constraint(equalToConstant: 360).isActive = true
        return chart
    }

    private func presentWaterSettings() {
        let sheet = WaterSettingsViewController(step: waterStep, goal: waterGoal)
        sheet.onConfirm = { [weak self] step, goal in
            guard let self else { return }
            self.waterStep = step
            self.waterGoal = goal
            self.build()
        }
        sheet.modalPresentationStyle = .overFullScreen
        sheet.modalTransitionStyle = .crossDissolve
        present(sheet, animated: true)
    }

    @objc private func showWaterSettingsTapped() {
        presentWaterSettings()
    }

    private func waterProgressRow(title: String, value: String, progress: CGFloat, color: UIColor) -> UIView {
        let card = UIView()
        card.applyCard(radius: 20, shadow: false)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 76).isActive = true

        let titleLabel = UILabel(title, size: 14, weight: .black, color: AppTheme.text, lines: 1)
        let valueLabel = UILabel(value, size: 13, weight: .black, color: AppTheme.muted, lines: 1)
        let barBack = UIView()
        barBack.backgroundColor = AppTheme.softFill
        barBack.layer.cornerRadius = 5
        let bar = UIView()
        bar.backgroundColor = color
        bar.layer.cornerRadius = 5

        [titleLabel, valueLabel, barBack, bar].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            valueLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            barBack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            barBack.trailingAnchor.constraint(equalTo: valueLabel.trailingAnchor),
            barBack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            barBack.heightAnchor.constraint(equalToConstant: 10),
            bar.leadingAnchor.constraint(equalTo: barBack.leadingAnchor),
            bar.topAnchor.constraint(equalTo: barBack.topAnchor),
            bar.bottomAnchor.constraint(equalTo: barBack.bottomAnchor),
            bar.widthAnchor.constraint(equalTo: barBack.widthAnchor, multiplier: max(0.03, progress))
        ])
        return card
    }
}

final class WaterIntakeChartView: UIView {
    enum Mode: Int {
        case daily
        case weekly
        case monthly
    }

    var amount = 0 { didSet { setNeedsDisplay() } }
    var goal = 1500 { didSet { setNeedsDisplay() } }
    var mode: Mode = .daily { didSet { setNeedsDisplay() } }
    var date = Date() { didSet { setNeedsDisplay() } }

    private let barColor = UIColor(red: 0.51, green: 0.88, blue: 0.89, alpha: 1)
    private let targetColor = UIColor(red: 0.74, green: 0.96, blue: 0.96, alpha: 1)
    private let axisColor = UIColor(red: 0.78, green: 0.80, blue: 0.84, alpha: 1)
    private let lineColor = UIColor(red: 0.92, green: 0.94, blue: 0.97, alpha: 1)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        isOpaque = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let left: CGFloat = 18
        let right: CGFloat = rect.width - 58
        let top: CGFloat = 108
        let bottom: CGFloat = 296
        let dataRight = right - 22
        let dataWidth = dataRight - left
        let maxValue = max(2000, CGFloat(((max(amount, goal) + 999) / 1000) * 1000))
        let actualValue = CGFloat(amount)
        let visibleValue = min(actualValue, maxValue)
        let targetY = yPosition(for: CGFloat(goal), maxValue: maxValue, top: top, bottom: bottom)
        let barHeight = max(amount > 0 ? 8 : 0, bottom - yPosition(for: visibleValue, maxValue: maxValue, top: top, bottom: bottom))
        let selectedIndex = xLabels.count - 1
        let xStep = dataWidth / CGFloat(max(1, xLabels.count - 1))
        let barCenterX = left + CGFloat(selectedIndex) * xStep
        let barWidth: CGFloat
        switch mode {
        case .daily:
            barWidth = 30
        case .weekly:
            barWidth = 32
        case .monthly:
            barWidth = 18
        }
        let barRect = CGRect(x: barCenterX - barWidth / 2, y: bottom - barHeight, width: barWidth, height: barHeight)

        drawLegend(in: rect)
        drawGrid(context: context, left: left, right: right, top: top, bottom: bottom, maxValue: maxValue)
        drawTargetLine(context: context, left: left, right: right, y: targetY)
        drawPreviousBars(left: left, bottom: bottom, maxValue: maxValue, chartTop: top, xStep: xStep)

        if amount > 0 {
            let path = UIBezierPath(roundedRect: barRect, cornerRadius: 6)
            barColor.setFill()
            path.fill()
        }

        drawBubble(centerX: barCenterX, pointerEndY: max(top + 4, barRect.minY), chartTop: top, maxRight: right)
        drawXAxisLabels(left: left, bottom: bottom, xStep: xStep)
    }

    private var xLabels: [String] {
        switch mode {
        case .daily:
            return ["화", "수", "목", "금", "토", "일", "월"]
        case .weekly:
            return [
                weekRangeLabel(offset: -3),
                weekRangeLabel(offset: -2),
                weekRangeLabel(offset: -1),
                "이번주"
            ]
        case .monthly:
            return monthlyLabels()
        }
    }

    private var bubbleSubtitle: String {
        switch mode {
        case .daily:
            return monthDay(date)
        case .weekly:
            return "\(monthDay(startOfWeek(date))) - \(monthDay(endOfWeek(date)))"
        case .monthly:
            let year = Calendar.current.component(.year, from: date) % 100
            let month = Calendar.current.component(.month, from: date)
            return "\(year)년 \(month)월"
        }
    }

    private func drawLegend(in rect: CGRect) {
        let dotRect = CGRect(x: 0, y: 14, width: 14, height: 14)
        UIBezierPath(roundedRect: dotRect, cornerRadius: 4).fill(with: barColor)
        drawText("수분 섭취량", in: CGRect(x: 22, y: 8, width: 96, height: 28), size: 13, weight: .bold, color: AppTheme.muted)

        let line = UIBezierPath(roundedRect: CGRect(x: 128, y: 20, width: 24, height: 3), cornerRadius: 1.5)
        targetColor.setFill()
        line.fill()
        drawText("목표 \(goal)ml", in: CGRect(x: 160, y: 8, width: 120, height: 28), size: 13, weight: .bold, color: AppTheme.muted)
    }

    private func drawGrid(context: CGContext, left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat, maxValue: CGFloat) {
        context.setLineWidth(1)
        context.setStrokeColor(lineColor.cgColor)
        for value in [maxValue, maxValue / 2, CGFloat(0)] {
            let y = yPosition(for: value, maxValue: maxValue, top: top, bottom: bottom)
            context.move(to: CGPoint(x: left, y: y))
            context.addLine(to: CGPoint(x: right, y: y))
            context.strokePath()
        }

        drawText(formatAxis(maxValue), in: CGRect(x: right + 10, y: top - 12, width: 50, height: 24), size: 12, weight: .bold, color: axisColor)
        drawText(formatAxis(maxValue / 2), in: CGRect(x: right + 10, y: (top + bottom) / 2 - 12, width: 50, height: 24), size: 12, weight: .bold, color: axisColor)
        drawText("0", in: CGRect(x: right + 10, y: bottom - 12, width: 50, height: 24), size: 12, weight: .bold, color: axisColor)
    }

    private func drawTargetLine(context: CGContext, left: CGFloat, right: CGFloat, y: CGFloat) {
        context.setLineWidth(1.5)
        context.setStrokeColor(targetColor.cgColor)
        context.move(to: CGPoint(x: left, y: y))
        context.addLine(to: CGPoint(x: right, y: y))
        context.strokePath()
    }

    private func drawPreviousBars(left: CGFloat, bottom: CGFloat, maxValue: CGFloat, chartTop: CGFloat, xStep: CGFloat) {
        guard amount > 0 else { return }
        let values: [CGFloat]
        switch mode {
        case .daily:
            values = []
        case .weekly:
            values = [260, 0, 0]
        case .monthly:
            values = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 230]
        }

        for (index, value) in values.enumerated() where value > 0 {
            let height = bottom - yPosition(for: value, maxValue: maxValue, top: chartTop, bottom: bottom)
            let centerX = left + CGFloat(index) * xStep
            let width: CGFloat = mode == .monthly ? 18 : 30
            let rect = CGRect(x: centerX - width / 2, y: bottom - height, width: width, height: height)
            UIBezierPath(roundedRect: rect, cornerRadius: 6).fill(with: barColor.withAlphaComponent(0.25))
        }
    }

    private func drawBubble(centerX: CGFloat, pointerEndY: CGFloat, chartTop: CGFloat, maxRight: CGFloat) {
        let bubbleWidth: CGFloat = mode == .daily ? 74 : 86
        let bubbleHeight: CGFloat = 48
        let bubbleX = min(max(centerX - bubbleWidth / 2, 0), maxRight - bubbleWidth + 8)
        let bubbleY = max(chartTop - 68, pointerEndY - 92)
        let bubble = CGRect(x: bubbleX, y: bubbleY, width: bubbleWidth, height: bubbleHeight)

        let dashPath = UIBezierPath()
        dashPath.move(to: CGPoint(x: centerX, y: bubble.maxY))
        dashPath.addLine(to: CGPoint(x: centerX, y: pointerEndY))
        barColor.setStroke()
        dashPath.lineWidth = 2
        dashPath.setLineDash([5, 5], count: 2, phase: 0)
        dashPath.stroke()

        let bubblePath = UIBezierPath(roundedRect: bubble, cornerRadius: 14)
        UIColor(red: 0.07, green: 0.09, blue: 0.13, alpha: 1).setFill()
        bubblePath.fill()

        drawText("\(amount) ml", in: CGRect(x: bubble.minX, y: bubble.minY + 6, width: bubble.width, height: 20), size: 15, weight: .black, color: .white, alignment: .center)
        drawText(bubbleSubtitle, in: CGRect(x: bubble.minX, y: bubble.minY + 26, width: bubble.width, height: 18), size: 12, weight: .bold, color: UIColor.white.withAlphaComponent(0.72), alignment: .center)
    }

    private func drawXAxisLabels(left: CGFloat, bottom: CGFloat, xStep: CGFloat) {
        for (index, label) in xLabels.enumerated() {
            let x = left + CGFloat(index) * xStep
            let selected = index == xLabels.count - 1
            let width: CGFloat = mode == .weekly ? 78 : 38
            let labelX = min(max(x - width / 2, 0), bounds.width - width)
            let labelRect = CGRect(x: labelX, y: bottom + 10, width: width, height: mode == .weekly ? 44 : 24)
            drawText(label, in: labelRect, size: 12, weight: selected ? .black : .bold, color: selected ? AppTheme.text : axisColor, alignment: .center)
        }
    }

    private func yPosition(for value: CGFloat, maxValue: CGFloat, top: CGFloat, bottom: CGFloat) -> CGFloat {
        bottom - ((min(value, maxValue) / maxValue) * (bottom - top))
    }

    private func drawText(_ text: String, in rect: CGRect, size: CGFloat, weight: UIFont.Weight, color: UIColor, alignment: NSTextAlignment = .left) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = alignment
        paragraph.lineBreakMode = .byWordWrapping
        (text as NSString).draw(in: rect, withAttributes: [
            .font: AppTheme.font(size, weight),
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ])
    }

    private func formatAxis(_ value: CGFloat) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: Double(value))) ?? "\(Int(value))"
    }

    private func weekRangeLabel(offset: Int) -> String {
        let calendar = Calendar.current
        let shifted = calendar.date(byAdding: .weekOfYear, value: offset, to: date) ?? date
        return "\(paddedMonthDay(startOfWeek(shifted)))\n- \(paddedMonthDay(endOfWeek(shifted)))"
    }

    private func monthlyLabels() -> [String] {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: date)
        return (-11...0).map { offset in
            let month = ((currentMonth + offset - 1 + 12) % 12) + 1
            return offset == 0 ? "\(month)월" : "\(month)"
        }
    }

    private func startOfWeek(_ date: Date) -> Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let daysFromMonday = (weekday + 5) % 7
        return calendar.date(byAdding: .day, value: -daysFromMonday, to: calendar.startOfDay(for: date)) ?? date
    }

    private func endOfWeek(_ date: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek(date)) ?? date
    }

    private func monthDay(_ date: Date) -> String {
        let calendar = Calendar.current
        return "\(calendar.component(.month, from: date)).\(calendar.component(.day, from: date))"
    }

    private func paddedMonthDay(_ date: Date) -> String {
        let calendar = Calendar.current
        return String(format: "%02d.%02d", calendar.component(.month, from: date), calendar.component(.day, from: date))
    }
}

final class WeightTrendChartView: UIView {
    enum Mode: Int {
        case daily
        case weekly
        case monthly
    }

    var mode: Mode = .daily { didSet { setNeedsDisplay() } }

    private let axisColor = UIColor(red: 0.76, green: 0.79, blue: 0.85, alpha: 1)
    private let lineColor = UIColor(red: 0.51, green: 0.71, blue: 0.97, alpha: 1)
    private let pointColor = UIColor(red: 0.62, green: 0.79, blue: 0.99, alpha: 1)
    private let gridColor = UIColor(red: 0.93, green: 0.94, blue: 0.97, alpha: 1)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let left: CGFloat = 16
        let right: CGFloat = rect.width - 54
        let top: CGFloat = 40
        let bottom: CGFloat = rect.height - 48
        let dataRight = right - 16
        let dataWidth = dataRight - left
        let values: [CGFloat]
        let labels: [String]

        switch mode {
        case .daily:
            values = [45.6, 43.7]
            labels = ["5월 19일", "5월 20일"]
        case .weekly:
            values = [46.1, 45.4, 44.6, 43.7]
            labels = ["5.19", "5.20", "5.21", "이번주"]
        case .monthly:
            values = [46.0, 45.2, 44.4, 43.7]
            labels = ["5월", "6월", "7월", "8월"]
        }

        let maxValue = max(47, ceil((values.max() ?? 47) + 0.5))
        let minValue = floor((values.min() ?? 43) - 0.5)
        let range = max(1, maxValue - minValue)
        let xStep = values.count > 1 ? dataWidth / CGFloat(values.count - 1) : dataWidth

        context.setLineWidth(1)
        context.setStrokeColor(gridColor.cgColor)
        for tick in stride(from: maxValue, through: minValue, by: -1.0) {
            let y = yPosition(for: tick, minValue: minValue, maxValue: maxValue, top: top, bottom: bottom)
            context.move(to: CGPoint(x: left, y: y))
            context.addLine(to: CGPoint(x: right, y: y))
            context.strokePath()
            drawText(String(format: "%.1f", tick), in: CGRect(x: right + 8, y: y - 11, width: 42, height: 22), size: 12, weight: .bold, color: axisColor)
        }

        let points = values.enumerated().map { index, value -> CGPoint in
            let x = left + CGFloat(index) * xStep
            let y = yPosition(for: value, minValue: minValue, maxValue: maxValue, top: top, bottom: bottom)
            return CGPoint(x: x, y: y)
        }

        if points.count > 1 {
            let path = UIBezierPath()
            path.lineWidth = 4
            path.lineJoinStyle = .round
            path.lineCapStyle = .round
            path.move(to: points[0])
            for point in points.dropFirst() { path.addLine(to: point) }
            lineColor.setStroke()
            path.stroke()
        }

        for point in points {
            let outer = UIBezierPath(ovalIn: CGRect(x: point.x - 10, y: point.y - 10, width: 20, height: 20))
            UIColor.white.setFill()
            outer.fill()
            let inner = UIBezierPath(ovalIn: CGRect(x: point.x - 5, y: point.y - 5, width: 10, height: 10))
            pointColor.setFill()
            inner.fill()
        }

        for (index, label) in labels.enumerated() {
            let x = left + CGFloat(index) * xStep
            let rect = CGRect(x: x - 48, y: bottom + 12, width: 96, height: 20)
            drawText(label, in: rect, size: 12, weight: .bold, color: axisColor, alignment: .center)
        }
    }

    private func yPosition(for value: CGFloat, minValue: CGFloat, maxValue: CGFloat, top: CGFloat, bottom: CGFloat) -> CGFloat {
        bottom - ((value - minValue) / max(1, (maxValue - minValue))) * (bottom - top)
    }

    private func drawText(_ text: String, in rect: CGRect, size: CGFloat, weight: UIFont.Weight, color: UIColor, alignment: NSTextAlignment = .left) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = alignment
        paragraph.lineBreakMode = .byWordWrapping
        (text as NSString).draw(in: rect, withAttributes: [
            .font: AppTheme.font(size, weight),
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ])
    }
}

final class WaterSettingsViewController: UIViewController {
    private let step: Int
    private let goal: Int
    private let sheetView = UIView()
    private let stepField = UITextField()
    private let goalField = UITextField()
    private var didAnimateIn = false
    var onConfirm: ((Int, Int) -> Void)?

    init(step: Int, goal: Int) {
        self.step = step
        self.goal = goal
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        build()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !didAnimateIn else { return }
        view.alpha = 0
        sheetView.transform = CGAffineTransform(translationX: 0, y: 420)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didAnimateIn else { return }
        didAnimateIn = true
        UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.92, initialSpringVelocity: 0.6, options: [.curveEaseOut]) {
            self.view.alpha = 1
            self.sheetView.transform = .identity
        }
    }

    private func build() {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blur)

        let dim = UIView()
        dim.backgroundColor = UIColor.black.withAlphaComponent(0.30)
        dim.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dim)

        sheetView.applyCard(radius: 28, shadow: true)
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sheetView)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(stack)

        stack.addArrangedSubview(UILabel("수분 설정", size: 25, weight: .black, color: AppTheme.text, lines: 1))
        stack.addArrangedSubview(settingRow(icon: "🥛", title: "1회 섭취량", value: "\(step) ml"))
        stack.addArrangedSubview(settingRow(icon: "💧", title: "목표 섭취량", value: "\(goal) ml"))
        stack.addArrangedSubview(recommendationCard())

        let confirm = UIButton(type: .system)
        confirm.backgroundColor = AppTheme.brand
        confirm.setTitle("확인", for: .normal)
        confirm.setTitleColor(.white, for: .normal)
        confirm.titleLabel?.font = AppTheme.font(18, .black)
        confirm.layer.cornerRadius = 12
        confirm.addAction(UIAction { [weak self] _ in self?.confirmAndDismiss() }, for: .touchUpInside)
        confirm.translatesAutoresizingMaskIntoConstraints = false
        confirm.heightAnchor.constraint(equalToConstant: 56).isActive = true
        stack.addArrangedSubview(confirm)

        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: view.topAnchor),
            blur.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blur.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dim.topAnchor.constraint(equalTo: view.topAnchor),
            dim.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dim.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dim.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: sheetView.topAnchor, constant: 34),
            stack.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 38),
            stack.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -38),
            stack.bottomAnchor.constraint(equalTo: sheetView.safeAreaLayoutGuide.bottomAnchor, constant: -28)
        ])
    }

    private func settingRow(icon: String, title: String, value: String) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 14

        let iconLabel = UILabel(icon, size: 22, weight: .regular, color: AppTheme.text, lines: 1)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.widthAnchor.constraint(equalToConstant: 34).isActive = true
        row.addArrangedSubview(iconLabel)

        row.addArrangedSubview(UILabel(title, size: 19, weight: .bold, color: AppTheme.text, lines: 1))
        row.addArrangedSubview(UIView())

        let field = title == "1회 섭취량" ? stepField : goalField
        field.text = value
        field.font = AppTheme.font(18, .regular)
        field.textColor = AppTheme.text
        field.textAlignment = .right
        field.backgroundColor = .white
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor(red: 0.89, green: 0.90, blue: 0.93, alpha: 1).cgColor
        field.clipsToBounds = true
        field.keyboardType = .numberPad
        field.rightView = paddingView(width: 16)
        field.rightViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            field.widthAnchor.constraint(equalToConstant: 142),
            field.heightAnchor.constraint(equalToConstant: 62)
        ])
        row.addArrangedSubview(field)
        return row
    }

    private func paddingView(width: CGFloat) -> UIView {
        UIView(frame: CGRect(x: 0, y: 0, width: width, height: 1))
    }

    private func recommendationCard() -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor(red: 0.965, green: 0.965, blue: 0.98, alpha: 1)
        card.layer.cornerRadius = 20
        card.translatesAutoresizingMaskIntoConstraints = false

        let text = NSMutableAttributedString(
            string: "다운님의 추천 섭취량: 1500ml\n일반적으로 추천하는 가장 건강한 물 섭취량은 1L\n~ 1.5L 예요.",
            attributes: [
                .font: AppTheme.font(16, .bold),
                .foregroundColor: UIColor(red: 0.45, green: 0.48, blue: 0.55, alpha: 1)
            ]
        )
        text.addAttributes([
            .font: AppTheme.font(16, .black),
            .foregroundColor: UIColor(red: 0.43, green: 0.17, blue: 0.93, alpha: 1)
        ], range: (text.string as NSString).range(of: "1500ml"))

        let label = UILabel()
        label.attributedText = text
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.82
        label.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(label)

        let more = UILabel("더보기", size: 15, weight: .bold, color: AppTheme.muted, lines: 1)
        more.textAlignment = .right
        more.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(more)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 132),
            label.topAnchor.constraint(equalTo: card.topAnchor, constant: 22),
            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            more.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            more.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])
        return card
    }

    private func dismissSheet() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn]) {
            self.view.alpha = 0
            self.sheetView.transform = CGAffineTransform(translationX: 0, y: 420)
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }

    private func confirmAndDismiss() {
        let parsedStep = parsedMilliliters(from: stepField.text, fallback: step)
        let parsedGoal = parsedMilliliters(from: goalField.text, fallback: goal)
        onConfirm?(max(1, parsedStep), max(1, parsedGoal))
        dismissSheet()
    }

    private func parsedMilliliters(from text: String?, fallback: Int) -> Int {
        let digits = (text ?? "").filter(\.isNumber)
        return Int(digits) ?? fallback
    }
}

private extension UIBezierPath {
    func fill(with color: UIColor) {
        color.setFill()
        fill()
    }
}

final class AnimatedWaterView: UIView {
    private let backWave = CAShapeLayer()
    private let frontWave = CAShapeLayer()
    private var lastBounds: CGRect = .zero
    var progress: CGFloat = 0 {
        didSet {
            progress = min(1, max(0, progress))
            lastBounds = .zero
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = .clear
        backWave.fillColor = UIColor(red: 0.72, green: 0.92, blue: 1.0, alpha: 1).cgColor
        frontWave.fillColor = UIColor(red: 0.31, green: 0.76, blue: 0.96, alpha: 1).cgColor
        layer.addSublayer(backWave)
        layer.addSublayer(frontWave)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, bounds.height > 0, bounds != lastBounds else { return }
        lastBounds = bounds
        let isEmpty = progress <= 0
        backWave.isHidden = isEmpty
        frontWave.isHidden = isEmpty
        guard !isEmpty else { return }

        let fillTop = bounds.height - (bounds.height * progress)
        let backY = max(6, fillTop - 18)
        let frontY = max(18, fillTop + 10)
        configure(layer: backWave, y: backY, amplitude: 7, phase: 0)
        configure(layer: frontWave, y: frontY, amplitude: 9, phase: .pi)
        animate(backWave, duration: 3.8)
        animate(frontWave, duration: 3.0)
    }

    private func configure(layer wave: CAShapeLayer, y: CGFloat, amplitude: CGFloat, phase: CGFloat) {
        let width = bounds.width
        let height = bounds.height
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: y))

        let extendedWidth = width * 2
        let step: CGFloat = 8
        var x: CGFloat = 0
        while x <= extendedWidth {
            let progress = (x / width) * CGFloat.pi * 2
            let pointY = y + sin(progress + phase) * amplitude
            path.addLine(to: CGPoint(x: x, y: pointY))
            x += step
        }

        path.addLine(to: CGPoint(x: extendedWidth, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.close()

        wave.frame = CGRect(x: 0, y: 0, width: extendedWidth, height: height)
        wave.path = path.cgPath
    }

    private func animate(_ wave: CAShapeLayer, duration: CFTimeInterval) {
        wave.removeAnimation(forKey: "wave")
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = 0
        animation.toValue = -bounds.width
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        wave.add(animation, forKey: "wave")
    }
}
