//
//  DetailViewController.swift
//  CheckFit
//
//  체중·단식·운동·수분 통합 상세 화면
//

import UIKit

final class DetailViewController: UIViewController {
    private let kind: String
    private let value: String
    private let symbol: String
    private let color: UIColor
    private let note: String
    private var selectedDate = Date()
    private var waterAmount = HealthStore.shared.waterAmount { didSet { HealthStore.shared.waterAmount = waterAmount } }
    private var waterRangeIndex = 0
    private var waterGoal = HealthStore.shared.waterGoal { didSet { HealthStore.shared.waterGoal = waterGoal } }
    private var waterStep = HealthStore.shared.waterStep { didSet { HealthStore.shared.waterStep = waterStep } }
    private weak var waterScrollView: UIScrollView?
    private var waterPendingOffset: CGPoint = .zero
    private var weightRangeIndex = 0
    private var weightMetricIndex = 0
    private var fastingRangeIndex = 0
    private weak var fastingScrollView: UIScrollView?
    private var fastingPendingOffset: CGPoint = .zero
    private weak var weightScrollView: UIScrollView?
    private var weightPendingOffset: CGPoint = .zero
    private var weightValue: CGFloat = CGFloat(HealthStore.shared.weight) { didSet { HealthStore.shared.weight = Double(weightValue) } }
    private var committedWeight: CGFloat? = CGFloat(HealthStore.shared.weight)
    private weak var weightValueLabel: UITextField?
    private weak var weightChartView: WeightTrendChartView?

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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        (kind == "수분" || kind == "체중" || kind == "운동" || kind == "단식") ? .lightContent : .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        build()
        // 체중 입력 중 화면을 탭하면 키보드를 닫고 입력값을 적용한다(편집 종료 → 저장).
        if kind == "체중" {
            let dismissTap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
            dismissTap.cancelsTouchesInView = false
            view.addGestureRecognizer(dismissTap)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 운동 기록 후 돌아오면 최신 상태로 다시 그린다.
        if kind == "운동" && isViewLoaded { build() }
    }

    private func addGreenStatusFill() {
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
    }

    private func build() {
        if kind == "수분" {
            waterPendingOffset = waterScrollView?.contentOffset ?? .zero
        } else if kind == "체중" {
            weightPendingOffset = weightScrollView?.contentOffset ?? .zero
        } else if kind == "단식" {
            fastingPendingOffset = fastingScrollView?.contentOffset ?? .zero
        }
        view.subviews.forEach { $0.removeFromSuperview() }
        if kind == "수분" {
            buildWaterDetail()
            addGreenStatusFill()
            return
        } else if kind == "체중" {
            buildWeightDetail()
            addGreenStatusFill()
            return
        } else if kind == "운동" {
            buildExerciseDetail()
            addGreenStatusFill()
            return
        } else if kind == "단식" {
            buildFastingDetail()
            addGreenStatusFill()
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
        top.addArrangedSubview(dateTitleGroup())
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

    /// 상세 화면 상단의 날짜 제목 + 화살표 (탭하면 캘린더 표시)
    private func dateTitleGroup() -> UIView {
        let group = UIStackView()
        group.axis = .horizontal
        group.alignment = .center
        group.spacing = 5
        group.addArrangedSubview(UILabel(AppDateText.detailTitle(for: selectedDate), size: 20, weight: .black, color: .white, lines: 1))
        group.addArrangedSubview(UIImageView(symbol: "chevron.down", color: .white, size: 13, weight: .bold))
        group.isUserInteractionEnabled = true
        group.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(detailDateTapped)))
        return group
    }

    @objc private func detailDateTapped() {
        let calendar = CalendarPickerViewController(date: selectedDate)
        calendar.onSelect = { [weak self] date in
            self?.selectedDate = date
            self?.build()
        }
        present(calendar, animated: true)
    }

    /// 화면 상단에 고정되는 초록 바 (뒤로가기 + 날짜 + 우측 액세서리). 스크롤되지 않음.
    private func fixedTopBar(trailing: UIView) -> UIView {
        let bar = UIView()
        bar.backgroundColor = AppTheme.brand
        bar.translatesAutoresizingMaskIntoConstraints = false
        let top = UIStackView()
        top.axis = .horizontal
        top.alignment = .center
        top.distribution = .equalSpacing
        top.translatesAutoresizingMaskIntoConstraints = false
        let back = IconButton(symbol: "chevron.left", color: .white, pointSize: 28)
        back.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)
        top.addArrangedSubview(back)
        top.addArrangedSubview(dateTitleGroup())
        top.addArrangedSubview(trailing)
        bar.addSubview(top)
        NSLayoutConstraint.activate([
            top.topAnchor.constraint(equalTo: bar.topAnchor, constant: 6),
            top.bottomAnchor.constraint(equalTo: bar.bottomAnchor, constant: -14),
            top.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 22),
            top.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -22)
        ])
        return bar
    }

    /// 스크롤 영역 상단의 초록 주간 패널 (요일/날짜). 본문과 함께 스크롤됨.
    private func scrollableWeekPanel() -> UIView {
        let panel = UIView()
        panel.backgroundColor = AppTheme.brand
        panel.layer.cornerRadius = 34
        panel.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        panel.clipsToBounds = true
        panel.translatesAutoresizingMaskIntoConstraints = false
        let strip = weekStrip()
        strip.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(strip)
        NSLayoutConstraint.activate([
            strip.topAnchor.constraint(equalTo: panel.topAnchor, constant: 8),
            strip.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 22),
            strip.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -22),
            strip.bottomAnchor.constraint(equalTo: panel.bottomAnchor, constant: -22)
        ])
        return panel
    }

    /// 위로 당겨 오버스크롤할 때 초록 패널 위쪽이 흰색으로 보이지 않도록 채우는 초록 배경.
    private func addTopBounceFiller(to content: UIScrollView, above weekPanel: UIView) {
        let filler = UIView()
        filler.backgroundColor = AppTheme.brand
        filler.translatesAutoresizingMaskIntoConstraints = false
        content.insertSubview(filler, belowSubview: weekPanel)
        NSLayoutConstraint.activate([
            filler.leadingAnchor.constraint(equalTo: content.frameLayoutGuide.leadingAnchor),
            filler.trailingAnchor.constraint(equalTo: content.frameLayoutGuide.trailingAnchor),
            filler.bottomAnchor.constraint(equalTo: weekPanel.topAnchor, constant: 24),
            filler.heightAnchor.constraint(equalToConstant: 1000)
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

        // 톱니바퀴 없이, 제목이 가운데 정렬되도록 같은 너비의 빈 공간만 둔다.
        let trailingSpacer = UIView()
        trailingSpacer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trailingSpacer.widthAnchor.constraint(equalToConstant: 30),
            trailingSpacer.heightAnchor.constraint(equalToConstant: 30)
        ])
        let bar = fixedTopBar(trailing: trailingSpacer)
        view.addSubview(bar)

        let content = UIScrollView()
        weightScrollView = content
        content.showsVerticalScrollIndicator = false
        content.clipsToBounds = true
        content.translatesAutoresizingMaskIntoConstraints = false
        content.backgroundColor = .clear
        view.addSubview(content)

        let weekPanel = scrollableWeekPanel()
        content.addSubview(weekPanel)
        addTopBounceFiller(to: content, above: weekPanel)

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
        metricsRow.addArrangedSubview(metricSelector(title: "체중 (kg)", index: 0))
        metricsRow.addArrangedSubview(metricSelector(title: "골격근량 (kg)", index: 1))
        metricsRow.addArrangedSubview(metricSelector(title: "체지방률 (%)", index: 2))
        body.addArrangedSubview(metricsRow)

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

        body.addArrangedSubview(weightChart())

        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            content.topAnchor.constraint(equalTo: bar.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            weekPanel.topAnchor.constraint(equalTo: content.contentLayoutGuide.topAnchor),
            weekPanel.leadingAnchor.constraint(equalTo: content.frameLayoutGuide.leadingAnchor),
            weekPanel.trailingAnchor.constraint(equalTo: content.frameLayoutGuide.trailingAnchor),
            body.topAnchor.constraint(equalTo: weekPanel.bottomAnchor, constant: 16),
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
        let updateLabel = UILabel("바로입력  +", size: 15, weight: .black, color: AppTheme.muted, lines: 1)
        updateLabel.translatesAutoresizingMaskIntoConstraints = false
        let update = UIView()
        update.backgroundColor = AppTheme.softFill
        update.layer.cornerRadius = 22
        update.translatesAutoresizingMaskIntoConstraints = false
        update.isUserInteractionEnabled = true
        update.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(recordTapped)))
        update.addSubview(updateLabel)
        NSLayoutConstraint.activate([
            update.heightAnchor.constraint(equalToConstant: 44),
            updateLabel.leadingAnchor.constraint(equalTo: update.leadingAnchor, constant: 18),
            updateLabel.trailingAnchor.constraint(equalTo: update.trailingAnchor, constant: -18),
            updateLabel.centerYAnchor.constraint(equalTo: update.centerYAnchor)
        ])
        let top = UIStackView(arrangedSubviews: [title, UIView(), update])
        top.axis = .horizontal
        top.alignment = .center
        top.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(top)

        let minus = weightRoundButton("minus")
        let plus = weightRoundButton("plus")
        minus.addTarget(self, action: #selector(weightMinusTapped), for: .touchUpInside)
        plus.addTarget(self, action: #selector(weightPlusTapped), for: .touchUpInside)
        let valueField = UITextField()
        valueField.text = String(format: "%.1f", weightValue)
        valueField.font = AppTheme.font(42, .black)
        valueField.textColor = AppTheme.text
        valueField.keyboardType = .decimalPad
        valueField.textAlignment = .center
        valueField.setContentHuggingPriority(.required, for: .horizontal)
        valueField.setContentCompressionResistancePriority(.required, for: .horizontal)
        valueField.addTarget(self, action: #selector(weightAmountEditingDidEnd(_:)), for: .editingDidEnd)
        weightValueLabel = valueField

        let valueRow = UIStackView()
        valueRow.axis = .horizontal
        valueRow.alignment = .lastBaseline
        valueRow.spacing = 8
        valueRow.addArrangedSubview(valueField)
        valueRow.addArrangedSubview(UILabel("kg", size: 24, weight: .black, color: AppTheme.text, lines: 1))
        valueRow.translatesAutoresizingMaskIntoConstraints = false

        let fieldBG = UIView()
        fieldBG.backgroundColor = AppTheme.softFill
        fieldBG.layer.cornerRadius = 30
        fieldBG.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(fieldBG)
        card.addSubview(valueRow)
        card.addSubview(minus)
        card.addSubview(plus)

        NSLayoutConstraint.activate([
            top.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            top.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            top.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            valueRow.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            valueRow.topAnchor.constraint(equalTo: card.topAnchor, constant: 82),
            fieldBG.topAnchor.constraint(equalTo: valueField.topAnchor, constant: -6),
            fieldBG.bottomAnchor.constraint(equalTo: valueField.bottomAnchor, constant: 6),
            fieldBG.leadingAnchor.constraint(equalTo: valueRow.leadingAnchor, constant: -18),
            fieldBG.trailingAnchor.constraint(equalTo: valueRow.trailingAnchor, constant: 18),
            minus.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 26),
            minus.centerYAnchor.constraint(equalTo: valueRow.centerYAnchor),
            plus.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -26),
            plus.centerYAnchor.constraint(equalTo: valueRow.centerYAnchor)
        ])
        return card
    }

    private func metricSelector(title: String, index: Int) -> UIView {
        let selected = index == weightMetricIndex
        let card = UIView()
        card.tag = index
        card.isUserInteractionEnabled = true
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(metricCardTapped(_:))))
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

        let storedValue: Double?
        switch index {
        case 0: storedValue = HealthStore.shared.weight
        case 1: storedValue = HealthStore.shared.muscleMass
        default: storedValue = HealthStore.shared.bodyFat
        }
        let valueText = storedValue.map { String(format: "%.1f", $0) } ?? "-"
        let valueColor = storedValue == nil ? UIColor.systemGray5 : AppTheme.text
        stack.addArrangedSubview(UILabel(valueText, size: 28, weight: .black, color: valueColor, lines: 1))

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
        button.layer.cornerRadius = 27
        button.setImage(UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 54),
            button.heightAnchor.constraint(equalToConstant: 54)
        ])
        return button
    }

    @objc private func weightMinusTapped() {
        weightValue = max(0, weightValue - 0.1)
        updateWeightValueLabel()
    }

    @objc private func weightPlusTapped() {
        weightValue += 0.1
        updateWeightValueLabel()
    }

    private func updateWeightValueLabel() {
        weightValueLabel?.text = String(format: "%.1f", weightValue)
    }

    @objc private func weightAmountEditingDidEnd(_ field: UITextField) {
        let entered = Double((field.text ?? "").replacingOccurrences(of: ",", with: ".")) ?? Double(weightValue)
        weightValue = max(0, CGFloat(entered))
        committedWeight = weightValue
        // 지표 카드·표(차트)·값 라벨을 모두 새 값으로 다시 그린다.
        build()
    }

    @objc private func weightUpdateTapped() {
        committedWeight = weightValue
        build()
    }

    @objc private func metricCardTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag, index != weightMetricIndex else { return }
        weightMetricIndex = index
        build()
    }

    @objc private func recordTapped() {
        let input = BodyCompositionInputViewController(date: selectedDate, weight: weightValue)
        input.onRecord = { [weak self] enteredWeight in
            guard let self else { return }
            self.weightValue = enteredWeight
            self.committedWeight = enteredWeight
            self.build()
        }
        present(input, animated: true)
    }

    private func weightChart() -> UIView {
        let chart = WeightTrendChartView()
        chart.mode = WeightTrendChartView.Mode(rawValue: weightRangeIndex) ?? .daily
        chart.metricIndex = weightMetricIndex
        chart.latestValue = weightMetricIndex == 0 ? committedWeight : nil
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.heightAnchor.constraint(equalToConstant: 330).isActive = true
        weightChartView = chart
        return chart
    }

    private func buildExerciseDetail() {
        view.backgroundColor = .white

        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.widthAnchor.constraint(equalToConstant: 30).isActive = true
        let bar = fixedTopBar(trailing: spacer)
        view.addSubview(bar)

        let content = UIScrollView()
        content.showsVerticalScrollIndicator = false
        content.clipsToBounds = true
        content.translatesAutoresizingMaskIntoConstraints = false
        content.backgroundColor = .clear
        content.keyboardDismissMode = .onDrag
        view.addSubview(content)

        let weekPanel = scrollableWeekPanel()
        content.addSubview(weekPanel)
        addTopBounceFiller(to: content, above: weekPanel)

        let body = UIStackView()
        body.axis = .vertical
        body.spacing = 22
        body.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(body)

        body.addArrangedSubview(exerciseSummaryCard())
        body.addArrangedSubview(exerciseChipsRow())
        if HealthStore.shared.exerciseEntries(for: selectedDate).isEmpty {
            body.addArrangedSubview(exercisePromptView())
            body.addArrangedSubview(addExerciseCard())
        } else {
            body.addArrangedSubview(recordedExerciseSection())
        }
        body.addArrangedSubview(exerciseMemoSection())

        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            content.topAnchor.constraint(equalTo: bar.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            weekPanel.topAnchor.constraint(equalTo: content.contentLayoutGuide.topAnchor),
            weekPanel.leadingAnchor.constraint(equalTo: content.frameLayoutGuide.leadingAnchor),
            weekPanel.trailingAnchor.constraint(equalTo: content.frameLayoutGuide.trailingAnchor),
            body.topAnchor.constraint(equalTo: weekPanel.bottomAnchor, constant: 16),
            body.leadingAnchor.constraint(equalTo: content.frameLayoutGuide.leadingAnchor, constant: 18),
            body.trailingAnchor.constraint(equalTo: content.frameLayoutGuide.trailingAnchor, constant: -18),
            body.bottomAnchor.constraint(equalTo: content.contentLayoutGuide.bottomAnchor, constant: -34)
        ])
    }

    private func exerciseSummaryCard() -> UIView {
        let exMinutes = HealthStore.shared.exerciseMinutes(for: selectedDate)
        let exKcal = HealthStore.shared.exerciseKcal(for: selectedDate)
        return exMinutes > 0 || exKcal > 0
            ? recordedSummaryCard(minutes: exMinutes, kcal: exKcal)
            : emptySummaryCard()
    }

    private func emptySummaryCard() -> UIView {
        let card = UIView()
        card.applyCard(radius: 28)
        card.clipsToBounds = true
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 150).isActive = true

        let title = UILabel("운동", size: 16, weight: .black, color: AppTheme.muted, lines: 1)
        title.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(title)

        let status = UILabel("운동을\n하지 않았어요", size: 22, weight: .black, color: AppTheme.text, lines: 2)
        status.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(status)

        let badge = UIView()
        badge.backgroundColor = AppTheme.softFill
        badge.layer.cornerRadius = 34
        badge.translatesAutoresizingMaskIntoConstraints = false
        let badgeLabel = UILabel("운동량", size: 13, weight: .bold, color: AppTheme.muted, lines: 1)
        badgeLabel.textAlignment = .center
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badge.addSubview(badgeLabel)
        card.addSubview(badge)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 22),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            status.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            status.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24),
            badge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            badge.centerYAnchor.constraint(equalTo: status.centerYAnchor),
            badge.widthAnchor.constraint(equalToConstant: 68),
            badge.heightAnchor.constraint(equalToConstant: 68),
            badgeLabel.centerXAnchor.constraint(equalTo: badge.centerXAnchor),
            badgeLabel.centerYAnchor.constraint(equalTo: badge.centerYAnchor)
        ])
        return card
    }

    private func recordedSummaryCard(minutes: Int, kcal: Int) -> UIView {
        let card = GradientCardView(colors: [
            UIColor(red: 0.78, green: 0.93, blue: 0.85, alpha: 1),
            UIColor(red: 0.95, green: 1.0, blue: 0.97, alpha: 1)
        ], radius: 28)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 150).isActive = true

        let title = UILabel("운동", size: 16, weight: .black, color: AppTheme.text.withAlphaComponent(0.6), lines: 1)
        let topRow = UIStackView(arrangedSubviews: [title, UIView()])
        topRow.axis = .horizontal
        topRow.alignment = .center

        let status = UILabel()
        let attr = NSMutableAttributedString(string: "\(minutes)분", attributes: [
            .font: AppTheme.font(22, .black), .foregroundColor: AppTheme.text
        ])
        attr.append(NSAttributedString(string: " 운동으로\n", attributes: [
            .font: AppTheme.font(20, .black), .foregroundColor: AppTheme.text.withAlphaComponent(0.7)
        ]))
        attr.append(NSAttributedString(string: "\(kcal)kcal", attributes: [
            .font: AppTheme.font(22, .black), .foregroundColor: AppTheme.text
        ]))
        attr.append(NSAttributedString(string: " 태웠어요", attributes: [
            .font: AppTheme.font(20, .black), .foregroundColor: AppTheme.text.withAlphaComponent(0.7)
        ]))
        status.attributedText = attr
        status.numberOfLines = 2

        let medal = UILabel("🏅", size: 56, weight: .black, lines: 1)
        medal.setContentHuggingPriority(.required, for: .horizontal)

        let bottomRow = UIStackView(arrangedSubviews: [status, UIView(), medal])
        bottomRow.axis = .horizontal
        bottomRow.alignment = .center

        let col = UIStackView(arrangedSubviews: [topRow, bottomRow])
        col.axis = .vertical
        col.spacing = 12
        col.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(col)
        NSLayoutConstraint.activate([
            col.topAnchor.constraint(equalTo: card.topAnchor, constant: 22),
            col.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            col.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -22),
            col.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -22)
        ])
        return card
    }

    private func recordedExerciseSection() -> UIView {
        let store = HealthStore.shared
        let entries = store.exerciseEntries(for: selectedDate)
        let weekDays = store.exerciseDaysInWeek(of: selectedDate)

        let badge = PaddingLabel("🔥 주 \(weekDays)일 운동 완료", size: 13, weight: .black, color: AppTheme.text)
        badge.insets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        badge.backgroundColor = AppTheme.softFill
        badge.layer.cornerRadius = 12
        badge.clipsToBounds = true
        let badgeWrap = UIStackView(arrangedSubviews: [badge, UIView()])
        badgeWrap.axis = .horizontal

        let titleLabel = UILabel("\(ProfileStore.shared.nickname)님의 운동", size: 22, weight: .black, color: AppTheme.text, lines: 1)
        let add = UIButton(type: .system)
        add.setTitle("추가", for: .normal)
        add.setTitleColor(AppTheme.muted, for: .normal)
        add.titleLabel?.font = AppTheme.font(15, .black)
        add.setContentHuggingPriority(.required, for: .horizontal)
        add.addAction(UIAction { [weak self] _ in
            self?.present(SearchListViewController.exercise(), animated: true)
        }, for: .touchUpInside)
        let titleRow = UIStackView(arrangedSubviews: [titleLabel, UIView(), add])
        titleRow.axis = .horizontal
        titleRow.alignment = .center

        let stack = UIStackView(arrangedSubviews: [badgeWrap, titleRow])
        stack.axis = .vertical
        stack.spacing = 12

        for (index, entry) in entries.enumerated() {
            stack.addArrangedSubview(exerciseEntryRow(entry, index: index))
        }
        stack.setCustomSpacing(18, after: titleRow)
        return stack
    }

    private func exerciseEntryRow(_ entry: ExerciseEntry, index: Int) -> UIView {
        let colors: [UIColor] = [AppTheme.brand, .systemOrange, .systemRed]
        let color = colors[min(max(entry.intensity, 0), 2)]
        let icon = symbolTile(symbol: "figure.run", color: color, size: 48, corner: 24)

        let nameLabel = UILabel(entry.name, size: 14, weight: .bold, color: AppTheme.muted, lines: 1)
        let kcalLabel = UILabel("\(entry.kcal)kcal", size: 19, weight: .black, color: AppTheme.text, lines: 1)

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        let metaLabel = UILabel("\(entry.minutes)분 · \(formatter.string(from: entry.time))", size: 12, weight: .semibold, color: AppTheme.muted, lines: 1)

        let textCol = UIStackView(arrangedSubviews: [nameLabel, kcalLabel, metaLabel])
        textCol.axis = .vertical
        textCol.spacing = 2

        let chevron = IconButton(symbol: "chevron.down", color: AppTheme.muted, pointSize: 14)
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.widthAnchor.constraint(equalToConstant: 30).isActive = true
        chevron.addAction(UIAction { [weak self] _ in self?.showExerciseEntryMenu(index: index, entry: entry) }, for: .touchUpInside)

        let row = UIStackView(arrangedSubviews: [icon, textCol, UIView(), chevron])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 14
        return row
    }

    private func showExerciseEntryMenu(index: Int, entry: ExerciseEntry) {
        let sheet = UIAlertController(title: entry.name, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "수정하기", style: .default) { [weak self] _ in
            guard let self else { return }
            let editor = ExerciseRecordDetailViewController(editingEntry: entry, indexInDay: index, date: self.selectedDate)
            self.present(editor, animated: true)
        })
        sheet.addAction(UIAlertAction(title: "삭제하기", style: .destructive) { [weak self] _ in
            guard let self else { return }
            HealthStore.shared.deleteExerciseEntry(date: self.selectedDate, indexInDay: index)
            self.build()
        })
        sheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(sheet, animated: true)
    }

    private func exerciseChipsRow() -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .center
        let stats = makePill("통계  📊", foreground: AppTheme.text, background: AppTheme.softFill, fontSize: 14)
        stats.isUserInteractionEnabled = true
        stats.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(exerciseStatsTapped)))
        row.addArrangedSubview(stats)
        row.addArrangedSubview(UIView())
        return row
    }

    @objc private func exerciseStatsTapped() {
        present(ExerciseStatsViewController(date: selectedDate), animated: true)
    }

    private func exercisePromptView() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.addArrangedSubview(UILabel("운동을 기록해주세요", size: 20, weight: .black, color: AppTheme.text, lines: 1))
        stack.addArrangedSubview(UILabel("운동을 기록해주시면 꼼꼼히 분석해드릴게요", size: 13, weight: .bold, color: AppTheme.muted, lines: 1))
        return stack
    }

    private func addExerciseCard() -> UIView {
        let card = UIControl()
        card.backgroundColor = .white
        card.layer.cornerRadius = 24
        card.layer.borderWidth = 2
        card.layer.borderColor = UIColor(red: 0.90, green: 0.91, blue: 0.94, alpha: 1).cgColor
        card.addAction(UIAction { [weak self] _ in
            self?.present(SearchListViewController.exercise(), animated: true)
        }, for: .touchUpInside)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 150).isActive = true

        let label = UILabel("추가하기", size: 16, weight: .black, color: AppTheme.muted, lines: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        card.addSubview(label)

        let circle = UIView()
        circle.backgroundColor = AppTheme.softFill
        circle.layer.cornerRadius = 28
        circle.isUserInteractionEnabled = false
        circle.translatesAutoresizingMaskIntoConstraints = false
        let plus = UIImageView(symbol: "plus", color: AppTheme.muted, size: 22, weight: .bold)
        circle.addSubview(plus)
        card.addSubview(circle)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: card.topAnchor, constant: 28),
            label.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            circle.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
            circle.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            circle.widthAnchor.constraint(equalToConstant: 56),
            circle.heightAnchor.constraint(equalToConstant: 56),
            plus.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            plus.centerYAnchor.constraint(equalTo: circle.centerYAnchor)
        ])
        return card
    }

    private func exerciseMemoSection() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill

        let tagLabel = UILabel("🔥 운동 메모", size: 15, weight: .black, color: UIColor(red: 0.95, green: 0.45, blue: 0.30, alpha: 1), lines: 1)
        tagLabel.textAlignment = .left
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        let tag = UIView()
        tag.backgroundColor = .clear
        tag.translatesAutoresizingMaskIntoConstraints = false
        tag.addSubview(tagLabel)
        tag.heightAnchor.constraint(equalToConstant: 38).isActive = true
        tag.widthAnchor.constraint(greaterThanOrEqualToConstant: 130).isActive = true
        let tagWrap = UIView()
        tagWrap.addSubview(tag)
        NSLayoutConstraint.activate([
            tagLabel.leadingAnchor.constraint(equalTo: tag.leadingAnchor),
            tagLabel.trailingAnchor.constraint(lessThanOrEqualTo: tag.trailingAnchor, constant: -12),
            tagLabel.centerYAnchor.constraint(equalTo: tag.centerYAnchor),
            tag.topAnchor.constraint(equalTo: tagWrap.topAnchor),
            tag.bottomAnchor.constraint(equalTo: tagWrap.bottomAnchor),
            tag.leadingAnchor.constraint(equalTo: tagWrap.leadingAnchor),
            tag.trailingAnchor.constraint(lessThanOrEqualTo: tagWrap.trailingAnchor)
        ])
        stack.addArrangedSubview(tagWrap)

        let memo = PlaceholderTextView()
        memo.placeholder = "운동 메모를 기록해보세요"
        memo.textColor = AppTheme.text
        memo.font = AppTheme.font(15, .semibold)
        memo.backgroundColor = .white
        memo.layer.cornerRadius = 16
        memo.layer.borderWidth = 1
        memo.layer.borderColor = UIColor(red: 0.89, green: 0.90, blue: 0.93, alpha: 1).cgColor
        memo.textContainerInset = UIEdgeInsets(top: 16, left: 14, bottom: 16, right: 14)
        memo.isScrollEnabled = false
        memo.translatesAutoresizingMaskIntoConstraints = false
        memo.heightAnchor.constraint(equalToConstant: 130).isActive = true
        stack.addArrangedSubview(memo)
        return stack
    }

    // MARK: - 단식 상세

    private func buildFastingDetail() {
        view.backgroundColor = .white

        let settings = IconButton(symbol: "gearshape", color: .white, pointSize: 20, weight: .medium)
        settings.addAction(UIAction { [weak self] _ in self?.presentFastingRoutine() }, for: .touchUpInside)
        settings.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settings.widthAnchor.constraint(equalToConstant: 30),
            settings.heightAnchor.constraint(equalToConstant: 30)
        ])
        let bar = fixedTopBar(trailing: settings)
        view.addSubview(bar)

        let content = UIScrollView()
        fastingScrollView = content
        content.showsVerticalScrollIndicator = false
        content.clipsToBounds = true
        content.translatesAutoresizingMaskIntoConstraints = false
        content.backgroundColor = .clear
        view.addSubview(content)

        let weekPanel = scrollableWeekPanel()
        content.addSubview(weekPanel)
        addTopBounceFiller(to: content, above: weekPanel)

        let body = UIStackView()
        body.axis = .vertical
        body.spacing = 22
        body.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(body)

        body.addArrangedSubview(fastingRingCard())
        body.addArrangedSubview(UILabel("단식 현황", size: 24, weight: .black, color: AppTheme.text, lines: 1))

        let segmented = UISegmentedControl(items: ["일간", "주간", "월간"])
        segmented.selectedSegmentIndex = fastingRangeIndex
        segmented.selectedSegmentTintColor = .white
        segmented.backgroundColor = AppTheme.softFill
        segmented.setTitleTextAttributes([.font: AppTheme.font(14, .black), .foregroundColor: UIColor.systemOrange], for: .selected)
        segmented.setTitleTextAttributes([.font: AppTheme.font(14, .black), .foregroundColor: AppTheme.muted], for: .normal)
        segmented.addAction(UIAction { [weak self, weak segmented] _ in
            guard let self, let segmented else { return }
            self.fastingRangeIndex = segmented.selectedSegmentIndex
            self.build()
        }, for: .valueChanged)
        segmented.heightAnchor.constraint(equalToConstant: 56).isActive = true
        body.addArrangedSubview(segmented)

        body.addArrangedSubview(fastingLegend())
        body.addArrangedSubview(fastingChart())
        body.setCustomSpacing(30, after: body.arrangedSubviews.last!)
        body.addArrangedSubview(UILabel("단식의 효과", size: 24, weight: .black, color: AppTheme.text, lines: 1))
        body.addArrangedSubview(fastingStages())

        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            content.topAnchor.constraint(equalTo: bar.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            weekPanel.topAnchor.constraint(equalTo: content.contentLayoutGuide.topAnchor),
            weekPanel.leadingAnchor.constraint(equalTo: content.frameLayoutGuide.leadingAnchor),
            weekPanel.trailingAnchor.constraint(equalTo: content.frameLayoutGuide.trailingAnchor),
            body.topAnchor.constraint(equalTo: weekPanel.bottomAnchor, constant: 16),
            body.leadingAnchor.constraint(equalTo: content.frameLayoutGuide.leadingAnchor, constant: 18),
            body.trailingAnchor.constraint(equalTo: content.frameLayoutGuide.trailingAnchor, constant: -18),
            body.bottomAnchor.constraint(equalTo: content.contentLayoutGuide.bottomAnchor, constant: -34)
        ])

        DispatchQueue.main.async { [weak content, offset = fastingPendingOffset] in
            content?.setContentOffset(offset, animated: false)
        }
    }

    private func fastingRingCard() -> UIView {
        let accent = UIColor.systemOrange
        let store = HealthStore.shared
        let card = UIView()
        card.applyCard(radius: 30)
        card.translatesAutoresizingMaskIntoConstraints = false

        // 진행 중인 단식 상태 계산
        let active = store.fastingStart != nil
        let now = Date()
        let start = store.fastingStart ?? now
        let total = TimeInterval(store.fastingHours) * 3600
        let elapsed = active ? max(0, min(total, now.timeIntervalSince(start))) : 0
        let percent = total > 0 ? Int((elapsed / total) * 100) : 0
        let end = start.addingTimeInterval(total)

        let ring = UIView()
        ring.backgroundColor = .clear
        ring.layer.borderWidth = 16
        ring.layer.borderColor = accent.withAlphaComponent(active ? 0.85 : 0.18).cgColor
        ring.layer.cornerRadius = 105
        ring.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(ring)

        let percentPill = PaddingLabel("\(percent)%", size: 13, weight: .black, color: accent)
        percentPill.backgroundColor = accent.withAlphaComponent(0.12)
        percentPill.layer.cornerRadius = 12
        percentPill.clipsToBounds = true
        percentPill.translatesAutoresizingMaskIntoConstraints = false

        let caption = UILabel(active ? "단식 중" : "단식", size: 15, weight: .black, color: AppTheme.muted, lines: 1)
        let titleText: String
        if active {
            let h = Int(elapsed) / 3600
            let m = (Int(elapsed) % 3600) / 60
            titleText = "\(h)시간 \(m)분"
        } else {
            titleText = "시작할까요?"
        }
        let title = UILabel(titleText, size: 26, weight: .black, color: accent, lines: 1)

        let startButton = UIButton(type: .system)
        startButton.setTitle(active ? "단식 종료" : "시작하기", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.titleLabel?.font = AppTheme.font(15, .black)
        startButton.backgroundColor = active ? accent : AppTheme.brand
        startButton.layer.cornerRadius = 19
        startButton.addAction(UIAction { [weak self] _ in
            if active {
                if let start = store.fastingStart { store.endFasting(start: start) }
                self?.build()
            } else {
                self?.presentFastingStart()
            }
        }, for: .touchUpInside)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.heightAnchor.constraint(equalToConstant: 38).isActive = true
        startButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 112).isActive = true

        let innerStack = UIStackView(arrangedSubviews: [percentPill, caption, title, startButton])
        innerStack.axis = .vertical
        innerStack.alignment = .center
        innerStack.spacing = 6
        innerStack.setCustomSpacing(12, after: percentPill)
        innerStack.setCustomSpacing(12, after: title)
        innerStack.translatesAutoresizingMaskIntoConstraints = false
        ring.addSubview(innerStack)

        let scheduleText = active
            ? "\(fastingTimeText(start)) - \(fastingTimeText(end))"
            : "오늘 오후 7:00 - 내일 오전 11:00"
        let schedule = UILabel(scheduleText, size: 14, weight: .bold, color: AppTheme.muted, lines: 1)
        schedule.textAlignment = .center
        schedule.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(schedule)

        NSLayoutConstraint.activate([
            ring.topAnchor.constraint(equalTo: card.topAnchor, constant: 30),
            ring.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            ring.widthAnchor.constraint(equalToConstant: 210),
            ring.heightAnchor.constraint(equalToConstant: 210),
            innerStack.centerXAnchor.constraint(equalTo: ring.centerXAnchor),
            innerStack.centerYAnchor.constraint(equalTo: ring.centerYAnchor),
            innerStack.leadingAnchor.constraint(greaterThanOrEqualTo: ring.leadingAnchor, constant: 24),
            innerStack.trailingAnchor.constraint(lessThanOrEqualTo: ring.trailingAnchor, constant: -24),
            schedule.topAnchor.constraint(equalTo: ring.bottomAnchor, constant: 22),
            schedule.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            schedule.leadingAnchor.constraint(greaterThanOrEqualTo: card.leadingAnchor, constant: 16),
            schedule.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -26)
        ])
        return card
    }

    private func fastingLegend() -> UIView {
        let square = UIView()
        square.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.35)
        square.layer.cornerRadius = 3
        square.translatesAutoresizingMaskIntoConstraints = false
        square.widthAnchor.constraint(equalToConstant: 14).isActive = true
        square.heightAnchor.constraint(equalToConstant: 14).isActive = true
        let item1 = UIStackView(arrangedSubviews: [square, UILabel("단식 시간", size: 13, weight: .bold, color: AppTheme.muted, lines: 1)])
        item1.axis = .horizontal
        item1.spacing = 6
        item1.alignment = .center

        let row = UIStackView(arrangedSubviews: [item1, UIView()])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 18
        return row
    }

    /// 범위(일간/주간/월간)별 단식 시간 버킷. 저장된 실제 단식 기록을 집계한다.
    /// 일간 = 그 날 단식 시간, 주간·월간 = 해당 기간의 하루 평균 단식 시간(0~24 스케일 유지).
    private func fastingBuckets() -> [(label: String, hours: Int)] {
        let cal = Calendar.current
        let store = HealthStore.shared
        let today = Date()

        switch fastingRangeIndex {
        case 1: // 주간 — 최근 6주, 각 주의 하루 평균
            let count = 6
            return (0..<count).map { i in
                let weeksAgo = count - 1 - i
                let ref = cal.date(byAdding: .day, value: -weeksAgo * 7, to: today) ?? today
                let weekStart = cal.dateInterval(of: .weekOfYear, for: ref)?.start ?? ref
                let weekEnd = cal.date(byAdding: .day, value: 7, to: weekStart) ?? ref
                let avg = store.totalFastingHours(from: weekStart, to: weekEnd) / 7.0
                let label = "\(cal.component(.month, from: weekStart))/\(cal.component(.day, from: weekStart))"
                return (label, Int(avg.rounded()))
            }
        case 2: // 월간 — 최근 6개월, 각 달의 하루 평균
            let count = 6
            return (0..<count).map { i in
                let monthsAgo = count - 1 - i
                let ref = cal.date(byAdding: .month, value: -monthsAgo, to: today) ?? today
                let monthStart = cal.dateInterval(of: .month, for: ref)?.start ?? ref
                let monthEnd = cal.date(byAdding: .month, value: 1, to: monthStart) ?? ref
                let days = cal.range(of: .day, in: .month, for: ref)?.count ?? 30
                let avg = store.totalFastingHours(from: monthStart, to: monthEnd) / Double(days)
                let label = "\(cal.component(.month, from: monthStart))월"
                return (label, Int(avg.rounded()))
            }
        default: // 일간 — 최근 7일, 그 날의 단식 시간
            let weekdaySymbols = ["일", "월", "화", "수", "목", "금", "토"]
            let count = 7
            return (0..<count).map { i in
                let daysAgo = count - 1 - i
                let day = cal.date(byAdding: .day, value: -daysAgo, to: today) ?? today
                let dayStart = cal.startOfDay(for: day)
                let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart) ?? day
                let hours = store.totalFastingHours(from: dayStart, to: dayEnd)
                let label = weekdaySymbols[cal.component(.weekday, from: day) - 1]
                return (label, Int(hours.rounded()))
            }
        }
    }

    private func fastingChart() -> UIView {
        let accent = UIColor.systemOrange
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 340).isActive = true

        let plotTop: CGFloat = 60
        let plotBottom: CGFloat = 300
        let plotHeight = plotBottom - plotTop   // 0~24시간

        // 가로 그리드 (24/12/0 시간)
        let levels: [(String, CGFloat)] = [("24", plotTop), ("12", (plotTop + plotBottom) / 2), ("0", plotBottom)]
        for (text, y) in levels {
            let line = UIView()
            line.backgroundColor = UIColor.systemGray5
            line.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(line)
            let label = UILabel(text, size: 12, weight: .bold, color: AppTheme.muted, lines: 1)
            label.textAlignment = .right
            label.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(label)
            NSLayoutConstraint.activate([
                line.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                line.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -28),
                line.heightAnchor.constraint(equalToConstant: 1),
                line.topAnchor.constraint(equalTo: container.topAnchor, constant: y),
                label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                label.centerYAnchor.constraint(equalTo: line.centerYAnchor)
            ])
        }

        // 범위별 막대 + x축 라벨
        let buckets = fastingBuckets()
        let barsRow = UIStackView()
        barsRow.axis = .horizontal
        barsRow.distribution = .fillEqually
        barsRow.alignment = .fill
        barsRow.translatesAutoresizingMaskIntoConstraints = false

        let xRow = UIStackView()
        xRow.axis = .horizontal
        xRow.distribution = .fillEqually
        xRow.translatesAutoresizingMaskIntoConstraints = false

        for (i, bucket) in buckets.enumerated() {
            let isLast = i == buckets.count - 1

            let col = UIView()
            let bar = UIView()
            bar.backgroundColor = isLast ? accent : accent.withAlphaComponent(0.35)
            bar.layer.cornerRadius = 6
            bar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            bar.translatesAutoresizingMaskIntoConstraints = false
            col.addSubview(bar)
            let barH = max(3, plotHeight * CGFloat(min(24, bucket.hours)) / 24.0)
            NSLayoutConstraint.activate([
                bar.bottomAnchor.constraint(equalTo: col.bottomAnchor),
                bar.centerXAnchor.constraint(equalTo: col.centerXAnchor),
                bar.widthAnchor.constraint(equalToConstant: 20),
                bar.heightAnchor.constraint(equalToConstant: barH)
            ])

            // 마지막(현재) 막대 위에 값 라벨
            if isLast {
                let valueLabel = UILabel("\(bucket.hours)시간", size: 12, weight: .black, color: accent, lines: 1)
                valueLabel.textAlignment = .center
                valueLabel.translatesAutoresizingMaskIntoConstraints = false
                col.addSubview(valueLabel)
                NSLayoutConstraint.activate([
                    valueLabel.bottomAnchor.constraint(equalTo: bar.topAnchor, constant: -6),
                    valueLabel.centerXAnchor.constraint(equalTo: bar.centerXAnchor)
                ])
            }
            barsRow.addArrangedSubview(col)

            let label = UILabel(bucket.label, size: 12, weight: isLast ? .black : .bold,
                                color: isLast ? AppTheme.text : AppTheme.muted, lines: 1)
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.7
            xRow.addArrangedSubview(label)
        }

        container.addSubview(barsRow)
        container.addSubview(xRow)

        NSLayoutConstraint.activate([
            barsRow.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            barsRow.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -28),
            barsRow.topAnchor.constraint(equalTo: container.topAnchor, constant: plotTop),
            barsRow.bottomAnchor.constraint(equalTo: container.topAnchor, constant: plotBottom),
            xRow.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            xRow.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -28),
            xRow.topAnchor.constraint(equalTo: container.topAnchor, constant: plotBottom + 8)
        ])
        return container
    }

    private func fastingStages() -> UIView {
        let stages: [(tag: String, color: UIColor, time: String, desc: String)] = [
            ("소화", .systemOrange, "단식 시작 ~ 4시간",
             "몸이 방금 먹은 음식에서 에너지를 얻고 있어요. 아직 저장된 지방은 손대지 않는 시간이에요."),
            ("지방 에너지 소모", UIColor(red: 0.93, green: 0.66, blue: 0.13, alpha: 1), "4 ~ 8시간",
             "혈당이 안정되면서, 간에 비축해둔 에너지를 조금씩 꺼내 쓰기 시작해요."),
            ("지방 전환", AppTheme.brand, "8 ~ 12시간",
             "비축해둔 탄수화물이 거의 바닥나면서, 몸이 지방을 에너지로 전환하기 시작해요. 여기서부터가 단식의 진짜 시작이에요!"),
            ("지방 분해", .systemTeal, "12 ~ 16시간",
             "인슐린이 낮게 유지되면서 지방 분해에 유리한 환경이 만들어졌어요. 지금 잘 하고 있어요!"),
            ("케톤·오토파지", .systemPurple, "16시간 이상",
             "지방에서 '케톤'이라는 에너지가 만들어지고 있어요. 케톤은 뇌와 근육의 좋은 연료이면서, 동시에 낡은 세포를 청소하고 재생하는 '오토파지'를 촉진해요. 지금 몸이 스스로를 리셋하는 시간이에요.")
        ]

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        for stage in stages {
            let tagLabel = PaddingLabel(stage.tag, size: 12, weight: .black, color: stage.color)
            tagLabel.backgroundColor = stage.color.withAlphaComponent(0.14)
            tagLabel.layer.cornerRadius = 11
            tagLabel.clipsToBounds = true
            let tagRow = UIStackView(arrangedSubviews: [tagLabel, UIView()])
            tagRow.axis = .horizontal

            let timeLabel = UILabel(stage.time, size: 17, weight: .black, color: AppTheme.text, lines: 1)
            let descLabel = UILabel(stage.desc, size: 13, weight: .semibold, color: AppTheme.muted, lines: 0)
            descLabel.adjustsFontSizeToFitWidth = false

            let column = UIStackView(arrangedSubviews: [tagRow, timeLabel, descLabel])
            column.axis = .vertical
            column.spacing = 6
            column.setCustomSpacing(8, after: tagRow)
            stack.addArrangedSubview(column)
        }
        stack.translatesAutoresizingMaskIntoConstraints = false

        let line = DashedLineView()
        line.color = UIColor.systemGray4
        line.translatesAutoresizingMaskIntoConstraints = false

        let wrap = UIView()
        wrap.addSubview(line)
        wrap.addSubview(stack)
        NSLayoutConstraint.activate([
            line.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 4),
            line.topAnchor.constraint(equalTo: wrap.topAnchor, constant: 8),
            line.bottomAnchor.constraint(equalTo: wrap.bottomAnchor, constant: -8),
            line.widthAnchor.constraint(equalToConstant: 8),
            stack.topAnchor.constraint(equalTo: wrap.topAnchor),
            stack.bottomAnchor.constraint(equalTo: wrap.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: wrap.trailingAnchor)
        ])
        return wrap
    }

    private func presentFastingStart() {
        let sheet = FastingStartViewController()
        sheet.onConfirm = { [weak self] start, hours in
            HealthStore.shared.fastingStart = start
            HealthStore.shared.fastingHours = hours
            HealthStore.shared.markRecordedToday()
            self?.build()
        }
        present(sheet, animated: true)
    }

    private func presentFastingRoutine() {
        present(FastingRoutineViewController(), animated: true)
    }

    /// 단식 시작/종료 시각을 "M월 d일 오후 h:mm" 형태로 표시.
    private func fastingTimeText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 a h:mm"
        return formatter.string(from: date)
    }

    private func buildWaterDetail() {
        view.backgroundColor = .white

        let settings = IconButton(symbol: "gearshape", color: .white, pointSize: 20, weight: .medium)
        settings.addAction(UIAction { [weak self] _ in self?.presentWaterSettings() }, for: .touchUpInside)
        settings.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settings.widthAnchor.constraint(equalToConstant: 30),
            settings.heightAnchor.constraint(equalToConstant: 30)
        ])
        let bar = fixedTopBar(trailing: settings)
        view.addSubview(bar)

        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissWaterKeyboard))
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)

        let content = UIScrollView()
        waterScrollView = content
        content.showsVerticalScrollIndicator = false
        content.clipsToBounds = true
        content.keyboardDismissMode = .onDrag
        content.translatesAutoresizingMaskIntoConstraints = false
        content.backgroundColor = .clear
        view.addSubview(content)

        let weekPanel = scrollableWeekPanel()
        content.addSubview(weekPanel)
        addTopBounceFiller(to: content, above: weekPanel)

        let body = UIStackView()
        body.axis = .vertical
        body.spacing = 24
        body.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(body)

        body.addArrangedSubview(waterSummaryCard())

        body.addArrangedSubview(UILabel("수분 섭취 현황", size: 24, weight: .black, color: AppTheme.text, lines: 1))

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

        body.addArrangedSubview(waterStatusCard())

        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            content.topAnchor.constraint(equalTo: bar.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            weekPanel.topAnchor.constraint(equalTo: content.contentLayoutGuide.topAnchor),
            weekPanel.leadingAnchor.constraint(equalTo: content.frameLayoutGuide.leadingAnchor),
            weekPanel.trailingAnchor.constraint(equalTo: content.frameLayoutGuide.trailingAnchor),
            body.topAnchor.constraint(equalTo: weekPanel.bottomAnchor, constant: 16),
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

        let amountField = UITextField()
        amountField.text = "\(waterAmount)"
        amountField.font = AppTheme.font(42, .black)
        amountField.textColor = AppTheme.text
        amountField.keyboardType = .numberPad
        amountField.textAlignment = .center
        amountField.setContentHuggingPriority(.required, for: .horizontal)
        amountField.setContentCompressionResistancePriority(.required, for: .horizontal)
        amountField.addTarget(self, action: #selector(waterAmountEditingDidEnd(_:)), for: .editingDidEnd)

        let fieldBG = UIView()
        fieldBG.backgroundColor = AppTheme.softFill
        fieldBG.layer.cornerRadius = 30
        fieldBG.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(fieldBG)

        let valueRow = UIStackView()
        valueRow.axis = .horizontal
        valueRow.alignment = .lastBaseline
        valueRow.spacing = 8
        valueRow.translatesAutoresizingMaskIntoConstraints = false
        valueRow.addArrangedSubview(amountField)
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
            HealthStore.shared.markRecordedToday()
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
            fieldBG.topAnchor.constraint(equalTo: amountField.topAnchor, constant: -6),
            fieldBG.bottomAnchor.constraint(equalTo: amountField.bottomAnchor, constant: 6),
            fieldBG.leadingAnchor.constraint(equalTo: valueRow.leadingAnchor, constant: -18),
            fieldBG.trailingAnchor.constraint(equalTo: valueRow.trailingAnchor, constant: 18),
            goal.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            goal.topAnchor.constraint(equalTo: valueRow.bottomAnchor, constant: 24),
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

    @objc private func dismissWaterKeyboard() {
        view.endEditing(true)
    }

    @objc private func waterAmountEditingDidEnd(_ field: UITextField) {
        let digits = (field.text ?? "").filter(\.isNumber)
        waterAmount = max(0, Int(digits) ?? 0)
        if waterAmount > 0 { HealthStore.shared.markRecordedToday() }
        build()
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
