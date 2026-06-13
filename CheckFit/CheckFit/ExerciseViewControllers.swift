//
//  ExerciseViewControllers.swift
//  CheckFit
//
//  운동 직접등록·통계·기록 상세 화면
//

import UIKit

final class CustomExerciseViewController: UIViewController {
    private let nameField = UITextField()
    private let counterLabel = UILabel("0 / 20자", size: 12, weight: .bold, color: AppTheme.muted, lines: 1)
    private let calorieField = UITextField()
    private let minuteField = UITextField()
    private let secondField = UITextField()
    private let doneButton = UIButton(type: .system)

    private var minutes = 0
    private var seconds = 0
    private var intensity = 1
    private var intensityCircles: [UIView] = []

    private let accent = UIColor(red: 0.42, green: 0.30, blue: 0.93, alpha: 1)
    private let borderColor = UIColor(red: 0.89, green: 0.90, blue: 0.93, alpha: 1)
    private let nameLimit = 20

    init() {
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
        updateDoneState()
    }

    private func build() {
        let back = IconButton(symbol: "chevron.left", color: AppTheme.text, pointSize: 22)
        back.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)
        back.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(back)

        let titleLabel = UILabel("직접 등록", size: 18, weight: .black, color: AppTheme.text, lines: 1)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.keyboardDismissMode = .onDrag
        view.addSubview(scroll)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        // 운동명
        let topSpacer = UIView()
        topSpacer.heightAnchor.constraint(equalToConstant: 24).isActive = true
        stack.addArrangedSubview(topSpacer)
        stack.addArrangedSubview(sectionTitle("운동명", required: true))
        nameField.attributedPlaceholder = NSAttributedString(string: "이름을 입력해 주세요",
            attributes: [.foregroundColor: AppTheme.muted, .font: AppTheme.font(15, .semibold)])
        styleField(nameField, keyboard: .default)
        nameField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        stack.addArrangedSubview(nameField)
        counterLabel.textAlignment = .right
        stack.addArrangedSubview(counterLabel)
        stack.setCustomSpacing(22, after: counterLabel)

        // 운동 시간
        stack.addArrangedSubview(sectionTitle("운동 시간", required: true))
        let timeRow = UIStackView()
        timeRow.axis = .horizontal
        timeRow.alignment = .center
        timeRow.spacing = 10
        let minuteStepper = stepper(valueField: minuteField, unit: "분", minus: #selector(minuteMinus), plus: #selector(minutePlus))
        let colon = UILabel(":", size: 20, weight: .black, color: AppTheme.text, lines: 1)
        colon.setContentHuggingPriority(.required, for: .horizontal)
        colon.setContentCompressionResistancePriority(.required, for: .horizontal)
        let secondStepper = stepper(valueField: secondField, unit: "초", minus: #selector(secondMinus), plus: #selector(secondPlus))
        timeRow.addArrangedSubview(minuteStepper)
        timeRow.addArrangedSubview(colon)
        timeRow.addArrangedSubview(secondStepper)
        minuteStepper.widthAnchor.constraint(equalTo: secondStepper.widthAnchor).isActive = true
        minuteField.text = "\(minutes)"
        secondField.text = "\(seconds)"
        minuteField.addTarget(self, action: #selector(minuteFieldChanged), for: .editingChanged)
        secondField.addTarget(self, action: #selector(secondFieldChanged), for: .editingChanged)
        stack.addArrangedSubview(timeRow)
        stack.setCustomSpacing(22, after: timeRow)

        // 칼로리
        stack.addArrangedSubview(sectionTitle("칼로리", required: true))
        calorieField.attributedPlaceholder = NSAttributedString(string: "0kcal",
            attributes: [.foregroundColor: AppTheme.muted, .font: AppTheme.font(15, .semibold)])
        styleField(calorieField, keyboard: .numberPad)
        stack.addArrangedSubview(calorieField)
        let note = UILabel("* 운동 직접 입력의 경우 자동 칼로리 계산이 되지 않습니다.", size: 12, weight: .semibold, color: AppTheme.muted, lines: 2)
        stack.addArrangedSubview(note)
        stack.setCustomSpacing(24, after: note)

        // 운동 강도
        stack.addArrangedSubview(sectionTitle("운동 강도", required: false))
        let intensityRow = UIStackView()
        intensityRow.axis = .horizontal
        intensityRow.distribution = .fillEqually
        intensityRow.spacing = 12
        intensityCircles = []
        let items = [("😌", "가볍게"), ("🙂", "적당히"), ("😣", "격하게")]
        for (index, item) in items.enumerated() {
            intensityRow.addArrangedSubview(intensityCard(index: index, emoji: item.0, title: item.1))
        }
        stack.addArrangedSubview(intensityRow)
        stack.setCustomSpacing(20, after: intensityRow)
        let intensityNote = UILabel("• 가볍게: 땀이 별로 나지 않고 대화와 노래가 가능한 정도\n• 적당히: 땀이 나고 대화는 가능하나 노래는 어려운 정도\n• 격하게: 땀이 많이 나고 대화가 어려운 정도", size: 12, weight: .semibold, color: AppTheme.muted, lines: 0)
        stack.addArrangedSubview(intensityNote)

        // 완료
        doneButton.setTitle("완료", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.titleLabel?.font = AppTheme.font(18, .black)
        doneButton.layer.cornerRadius = 16
        doneButton.addAction(UIAction { [weak self] _ in self?.saveAndDismiss() }, for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            back.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            scroll.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 18),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -12),

            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -20),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 56)
        ])

        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    private func sectionTitle(_ title: String, required: Bool) -> UILabel {
        let label = UILabel()
        let text = NSMutableAttributedString(string: title, attributes: [
            .font: AppTheme.font(15, .black), .foregroundColor: AppTheme.text
        ])
        if required {
            text.append(NSAttributedString(string: "  *", attributes: [
                .font: AppTheme.font(13, .black), .foregroundColor: UIColor.systemRed
            ]))
        }
        label.attributedText = text
        return label
    }

    private func styleField(_ field: UITextField, keyboard: UIKeyboardType) {
        field.font = AppTheme.font(15, .black)
        field.textColor = AppTheme.text
        field.backgroundColor = .white
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = borderColor.cgColor
        field.keyboardType = keyboard
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 52).isActive = true
    }

    private func stepper(valueField: UITextField, unit: String, minus: Selector, plus: Selector) -> UIView {
        let container = UIView()
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = borderColor.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 52).isActive = true

        let minusBtn = stepperButton("minus", action: minus)
        let plusBtn = stepperButton("plus", action: plus)

        valueField.font = AppTheme.font(16, .black)
        valueField.textColor = AppTheme.text
        valueField.textAlignment = .right
        valueField.keyboardType = .numberPad
        valueField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        valueField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let unitLabel = UILabel(unit, size: 16, weight: .black, color: AppTheme.text, lines: 1)
        unitLabel.setContentHuggingPriority(.required, for: .horizontal)
        unitLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let valueRow = UIStackView(arrangedSubviews: [valueField, unitLabel])
        valueRow.axis = .horizontal
        valueRow.alignment = .center
        valueRow.spacing = 2

        let row = UIStackView(arrangedSubviews: [minusBtn, valueRow, plusBtn])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .equalSpacing
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        row.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: container.topAnchor),
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        return container
    }

    private func stepperButton(_ symbol: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)), for: .normal)
        button.tintColor = AppTheme.text
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 26).isActive = true
        return button
    }

    private func intensityCard(index: Int, emoji: String, title: String) -> UIView {
        let selected = index == intensity
        let circle = UIView()
        circle.backgroundColor = selected ? AppTheme.brand : AppTheme.softFill
        circle.layer.cornerRadius = 28
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.widthAnchor.constraint(equalToConstant: 56).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 56).isActive = true
        let emojiLabel = UILabel(emoji, size: 26, weight: .regular, color: AppTheme.text, lines: 1)
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        circle.addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: circle.centerYAnchor)
        ])
        intensityCircles.append(circle)

        let label = UILabel(title, size: 13, weight: .bold, color: selected ? AppTheme.text : AppTheme.muted, lines: 1)
        label.textAlignment = .center
        let column = UIStackView(arrangedSubviews: [circle, label])
        column.axis = .vertical
        column.alignment = .center
        column.spacing = 8
        column.tag = index
        column.isUserInteractionEnabled = true
        column.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(intensityTapped(_:))))
        return column
    }

    @objc private func intensityTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }
        intensity = index
        for (i, circle) in intensityCircles.enumerated() {
            circle.backgroundColor = i == index ? AppTheme.brand : AppTheme.softFill
        }
    }

    @objc private func nameChanged() {
        if let text = nameField.text, text.count > nameLimit {
            nameField.text = String(text.prefix(nameLimit))
        }
        counterLabel.text = "\(nameField.text?.count ?? 0) / \(nameLimit)자"
        updateDoneState()
    }

    private func updateDoneState() {
        let valid = !(nameField.text ?? "").isEmpty
        doneButton.isEnabled = valid
        doneButton.backgroundColor = valid ? AppTheme.brand : AppTheme.brand.withAlphaComponent(0.45)
    }

    private func saveAndDismiss() {
        let kcal = Int((calorieField.text ?? "").filter { $0.isNumber }) ?? 0
        let totalMinutes = minutes + (seconds >= 30 ? 1 : 0)
        let name = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !name.isEmpty && (totalMinutes > 0 || kcal > 0) {
            HealthStore.shared.addExercise(date: Date(), name: name, minutes: totalMinutes, kcal: kcal, intensity: intensity)
        }
        dismiss(animated: true)
    }

    @objc private func minuteMinus() { minutes = max(0, minutes - 1); minuteField.text = "\(minutes)" }
    @objc private func minutePlus() { minutes += 1; minuteField.text = "\(minutes)" }
    @objc private func secondMinus() { seconds = max(0, seconds - 1); secondField.text = "\(seconds)" }
    @objc private func secondPlus() { seconds = min(59, seconds + 1); secondField.text = "\(seconds)" }

    @objc private func minuteFieldChanged() {
        minutes = max(0, Int((minuteField.text ?? "").filter { $0.isNumber }) ?? 0)
    }
    @objc private func secondFieldChanged() {
        let entered = Int((secondField.text ?? "").filter { $0.isNumber }) ?? 0
        seconds = min(59, max(0, entered))
        if seconds != entered { secondField.text = "\(seconds)" }
    }
}
final class ExerciseStatsViewController: UIViewController {
    private let purple = AppTheme.brand
    private var date: Date
    private var metric: ExerciseStatsChartView.Metric = .time
    private var mode: ExerciseStatsChartView.Mode = .daily

    init(date: Date) {
        self.date = date
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        build()
    }

    private func build() {
        view.subviews.forEach { $0.removeFromSuperview() }

        let bar = topBar()
        view.addSubview(bar)

        let topFill = UIView()
        topFill.backgroundColor = purple
        topFill.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(topFill, belowSubview: bar)

        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let body = UIStackView()
        body.axis = .vertical
        body.spacing = 20
        body.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(body)

        body.addArrangedSubview(summaryCard())
        body.addArrangedSubview(UILabel("운동 현황", size: 20, weight: .black, color: AppTheme.text, lines: 1))
        body.addArrangedSubview(metricToggle())
        body.addArrangedSubview(modeSegmented())
        body.addArrangedSubview(chart())

        NSLayoutConstraint.activate([
            topFill.topAnchor.constraint(equalTo: view.topAnchor),
            topFill.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topFill.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topFill.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

            bar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scroll.topAnchor.constraint(equalTo: bar.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            body.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 18),
            body.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -34),
            body.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 20),
            body.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -20)
        ])
    }

    private func topBar() -> UIView {
        let bar = UIView()
        bar.backgroundColor = purple
        bar.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel(AppDateText.mainTitle(for: date), size: 18, weight: .black, color: .white, lines: 1)
        let chevron = UIImageView(symbol: "chevron.down", color: .white, size: 13, weight: .bold)
        let titleGroup = UIStackView(arrangedSubviews: [title, chevron])
        titleGroup.axis = .horizontal
        titleGroup.alignment = .center
        titleGroup.spacing = 5
        titleGroup.isUserInteractionEnabled = true
        titleGroup.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dateTapped)))
        titleGroup.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(titleGroup)

        let close = IconButton(symbol: "xmark", color: .white, pointSize: 18)
        close.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)
        close.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(close)

        NSLayoutConstraint.activate([
            titleGroup.centerXAnchor.constraint(equalTo: bar.centerXAnchor),
            titleGroup.topAnchor.constraint(equalTo: bar.topAnchor, constant: 6),
            titleGroup.bottomAnchor.constraint(equalTo: bar.bottomAnchor, constant: -12),
            close.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -16),
            close.widthAnchor.constraint(equalToConstant: 36),
            close.centerYAnchor.constraint(equalTo: titleGroup.centerYAnchor)
        ])
        return bar
    }

    @objc private func dateTapped() {
        let calendar = CalendarPickerViewController(date: date)
        calendar.onSelect = { [weak self] selected in
            self?.date = selected
            self?.build()
        }
        present(calendar, animated: true)
    }

    private func summaryCard() -> UIView {
        let card = UIView()
        card.applyCard(radius: 26)
        card.translatesAutoresizingMaskIntoConstraints = false

        let store = HealthStore.shared
        let minutes = store.exerciseMinutes(for: date)
        let kcal = store.exerciseKcal(for: date)

        let caption = UILabel("운동 시간", size: 14, weight: .bold, color: AppTheme.muted, lines: 1)

        let value = UILabel()
        let attr = NSMutableAttributedString(string: "\(minutes)", attributes: [
            .font: AppTheme.font(34, .black), .foregroundColor: AppTheme.text
        ])
        attr.append(NSAttributedString(string: " 분 ", attributes: [
            .font: AppTheme.font(18, .black), .foregroundColor: AppTheme.text
        ]))
        attr.append(NSAttributedString(string: "\(kcal)kcal", attributes: [
            .font: AppTheme.font(16, .black), .foregroundColor: AppTheme.muted
        ]))
        value.attributedText = attr

        let subtitle = UILabel(minutes > 0 ? "오늘도 잘하고 있어요 💪" : "꾸준한 운동으로 건강 챙기세요 💪",
                               size: 13, weight: .bold, color: AppTheme.muted, lines: 1)

        let textCol = UIStackView(arrangedSubviews: [caption, value, subtitle])
        textCol.axis = .vertical
        textCol.spacing = 6

        let topRow = UIStackView(arrangedSubviews: [textCol, UIView()])
        topRow.axis = .horizontal
        topRow.alignment = .center

        let line = UIView()
        line.backgroundColor = UIColor(red: 0.91, green: 0.92, blue: 0.94, alpha: 1)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let cumTitle = UILabel("누적 운동 일수", size: 15, weight: .bold, color: AppTheme.text, lines: 1)
        let cumValue = UILabel("\(store.exerciseDayCount)일", size: 15, weight: .black, color: AppTheme.text, lines: 1)
        cumValue.setContentHuggingPriority(.required, for: .horizontal)
        let cumRow = UIStackView(arrangedSubviews: [cumTitle, UIView(), cumValue])
        cumRow.axis = .horizontal
        cumRow.alignment = .center

        let col = UIStackView(arrangedSubviews: [topRow, line, cumRow])
        col.axis = .vertical
        col.spacing = 18
        col.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(col)
        NSLayoutConstraint.activate([
            col.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            col.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            col.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            col.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        return card
    }

    private func metricToggle() -> UIView {
        let timePill = togglePill("시간", selected: metric == .time)
        timePill.addAction(UIAction { [weak self] _ in self?.metric = .time; self?.build() }, for: .touchUpInside)
        let kcalPill = togglePill("칼로리", selected: metric == .calorie)
        kcalPill.addAction(UIAction { [weak self] _ in self?.metric = .calorie; self?.build() }, for: .touchUpInside)
        let row = UIStackView(arrangedSubviews: [timePill, kcalPill, UIView()])
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .center
        return row
    }

    private func togglePill(_ title: String, selected: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = AppTheme.font(15, .black)
        button.setTitleColor(selected ? .white : AppTheme.muted, for: .normal)
        button.backgroundColor = selected ? purple : AppTheme.softFill
        button.layer.cornerRadius = 18
        button.contentEdgeInsets = UIEdgeInsets(top: 9, left: 20, bottom: 9, right: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func modeSegmented() -> UIView {
        let segmented = UISegmentedControl(items: ["일간", "주간", "월간"])
        segmented.selectedSegmentIndex = mode.rawValue
        segmented.selectedSegmentTintColor = .white
        segmented.backgroundColor = AppTheme.softFill
        segmented.setTitleTextAttributes([.font: AppTheme.font(14, .black), .foregroundColor: purple], for: .selected)
        segmented.setTitleTextAttributes([.font: AppTheme.font(14, .black), .foregroundColor: AppTheme.muted], for: .normal)
        segmented.addAction(UIAction { [weak self, weak segmented] _ in
            guard let self, let segmented else { return }
            self.mode = ExerciseStatsChartView.Mode(rawValue: segmented.selectedSegmentIndex) ?? .daily
            self.build()
        }, for: .valueChanged)
        segmented.translatesAutoresizingMaskIntoConstraints = false
        segmented.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return segmented
    }

    private func chart() -> UIView {
        let chart = ExerciseStatsChartView()
        chart.metric = metric
        chart.mode = mode
        chart.date = date
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.heightAnchor.constraint(equalToConstant: 320).isActive = true
        return chart
    }
}

/// 운동 시간/칼로리를 일간·주간·월간 막대 그래프로 그리는 뷰.
final class ExerciseRecordDetailViewController: UIViewController {
    private struct FieldSpec { let title: String; let unit: String }

    private final class ExerciseModel {
        let name: String
        let specs: [FieldSpec]
        var sets: [[String]]
        var deletingSets = false
        init(name: String, specs: [FieldSpec]) {
            self.name = name
            self.specs = specs
            self.sets = [Array(repeating: "", count: specs.count)]
        }
    }

    private let accent = AppTheme.brand
    private let borderColor = UIColor(red: 0.89, green: 0.90, blue: 0.93, alpha: 1)
    private var date = Date()
    private var exercises: [ExerciseModel]
    private weak var timeValueLabel: UILabel?
    private weak var kcalValueLabel: UILabel?
    /// nil이면 새 기록, 값이 있으면 해당 날짜의 그 인덱스 기록을 수정하는 모드.
    private let editIndexInDay: Int?

    init(exercises names: [String]) {
        self.exercises = names.map { ExerciseModel(name: $0, specs: ExerciseRecordDetailViewController.specs(for: $0)) }
        self.editIndexInDay = nil
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    /// 기존 운동 기록을 수정하는 모드로 연다.
    init(editingEntry entry: ExerciseEntry, indexInDay: Int, date: Date) {
        let model = ExerciseModel(name: entry.name, specs: ExerciseRecordDetailViewController.specs(for: entry.name))
        if let timeIndex = model.specs.firstIndex(where: { $0.title == "시간" }), entry.minutes > 0 {
            model.sets[0][timeIndex] = "\(entry.minutes)"
        }
        self.exercises = [model]
        self.editIndexInDay = indexInDay
        super.init(nibName: nil, bundle: nil)
        self.date = entry.time
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// 운동 이름으로 입력 칼럼(세트 외)을 결정한다.
    private static func specs(for name: String) -> [FieldSpec] {
        func has(_ keys: [String]) -> Bool { keys.contains { name.contains($0) } }
        if has(["러닝", "달리기", "걷기", "조깅", "마라톤", "워킹", "트레드밀"]) {
            return [FieldSpec(title: "km", unit: "km"), FieldSpec(title: "시간", unit: "분")]
        }
        if has(["자전거", "사이클", "스피닝", "마운틴"]) {
            return [FieldSpec(title: "km", unit: "km"), FieldSpec(title: "시간", unit: "분")]
        }
        if has(["덤벨", "바벨", "컬", "프레스", "스쿼트", "데드", "레그", "로우", "익스텐션", "머신", "리프트", "플라이"]) {
            return [FieldSpec(title: "kg", unit: "kg"), FieldSpec(title: "횟수", unit: "회")]
        }
        if has(["수영", "복싱", "줄넘기", "등산", "클라이밍"]) {
            return [FieldSpec(title: "시간", unit: "분"), FieldSpec(title: "횟수", unit: "회")]
        }
        // 요가·필라테스·검도·댄스·폴댄스 등: 시간만
        return [FieldSpec(title: "시간", unit: "분")]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        build()
    }

    private func build() {
        view.subviews.forEach { $0.removeFromSuperview() }

        let bar = topBar()
        view.addSubview(bar)

        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.keyboardDismissMode = .onDrag
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let body = UIStackView()
        body.axis = .vertical
        body.spacing = 16
        body.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(body)

        body.addArrangedSubview(timeRow())
        body.addArrangedSubview(summaryRow())
        body.addArrangedSubview(thinLine())
        for (index, model) in exercises.enumerated() {
            body.addArrangedSubview(exerciseCard(model, index: index))
        }

        let buttons = bottomButtons()
        view.addSubview(buttons)

        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scroll.topAnchor.constraint(equalTo: bar.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: buttons.topAnchor, constant: -10),

            body.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 16),
            body.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24),
            body.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 20),
            body.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -20),

            buttons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            buttons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            buttons.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),
            buttons.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    private func topBar() -> UIView {
        let bar = UIView()
        bar.backgroundColor = .white
        bar.translatesAutoresizingMaskIntoConstraints = false

        let back = IconButton(symbol: "chevron.left", color: AppTheme.text, pointSize: 22)
        back.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)
        back.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(back)

        let ellipsis = IconButton(symbol: "ellipsis", color: AppTheme.text, pointSize: 20)
        ellipsis.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(ellipsis)

        let title = UILabel(exercises.first?.name ?? "운동 기록", size: 18, weight: .black, color: AppTheme.text, lines: 1)
        title.textAlignment = .center
        let dateLabel = UILabel(monthDayText(date), size: 12, weight: .bold, color: AppTheme.muted, lines: 1)
        dateLabel.textAlignment = .center
        let titleCol = UIStackView(arrangedSubviews: [dateLabel, title])
        titleCol.axis = .vertical
        titleCol.alignment = .center
        titleCol.spacing = 2
        titleCol.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(titleCol)

        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 14),
            back.centerYAnchor.constraint(equalTo: titleCol.centerYAnchor),
            back.widthAnchor.constraint(equalToConstant: 36),
            ellipsis.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -16),
            ellipsis.centerYAnchor.constraint(equalTo: titleCol.centerYAnchor),
            ellipsis.widthAnchor.constraint(equalToConstant: 36),
            titleCol.centerXAnchor.constraint(equalTo: bar.centerXAnchor),
            titleCol.topAnchor.constraint(equalTo: bar.topAnchor, constant: 8),
            titleCol.bottomAnchor.constraint(equalTo: bar.bottomAnchor, constant: -12)
        ])
        return bar
    }

    private func monthDayText(_ date: Date) -> String {
        let cal = Calendar.current
        return "\(cal.component(.month, from: date))월 \(cal.component(.day, from: date))일"
    }

    private func timeRow() -> UIView {
        let clock = UIImageView(symbol: "clock", color: AppTheme.muted, size: 16, weight: .bold)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        let time = UILabel(formatter.string(from: date), size: 14, weight: .bold, color: AppTheme.text, lines: 1)
        let pencil = IconButton(symbol: "pencil", color: AppTheme.muted, pointSize: 14)
        pencil.addAction(UIAction { [weak self] _ in self?.editTime() }, for: .touchUpInside)
        pencil.translatesAutoresizingMaskIntoConstraints = false
        pencil.widthAnchor.constraint(equalToConstant: 26).isActive = true
        let row = UIStackView(arrangedSubviews: [clock, time, pencil, UIView()])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 6
        return row
    }

    private func editTime() {
        let picker = TimePickerSheetViewController(time: date)
        picker.onSelect = { [weak self] newTime in
            guard let self else { return }
            // 선택한 시각을 오늘 날짜에 합쳐 기록 시각으로 쓴다.
            let cal = Calendar.current
            let t = cal.dateComponents([.hour, .minute], from: newTime)
            self.date = cal.date(bySettingHour: t.hour ?? 0, minute: t.minute ?? 0, second: 0, of: Date()) ?? newTime
            self.build()
        }
        present(picker, animated: true)
    }

    private func summaryRow() -> UIView {
        let timeCol = summaryColumn(title: "운동 시간", info: false)
        let timeValue = UILabel("\(totalMinutes())분", size: 20, weight: .black, color: AppTheme.text, lines: 1)
        timeValueLabel = timeValue
        let timeStack = UIStackView(arrangedSubviews: [timeCol, timeValue])
        timeStack.axis = .vertical
        timeStack.spacing = 6

        let kcalCol = summaryColumn(title: "소모 칼로리", info: true)
        let kcal = UILabel("\(totalKcal())kcal", size: 20, weight: .black, color: AppTheme.text, lines: 1)
        kcalValueLabel = kcal
        let kcalStack = UIStackView(arrangedSubviews: [kcalCol, kcal])
        kcalStack.axis = .vertical
        kcalStack.spacing = 6

        let row = UIStackView(arrangedSubviews: [timeStack, kcalStack])
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.alignment = .top
        return row
    }

    private func summaryColumn(title: String, info: Bool) -> UIView {
        let label = UILabel(title, size: 13, weight: .bold, color: AppTheme.muted, lines: 1)
        var views: [UIView] = [label]
        if info { views.append(UIImageView(symbol: "info.circle", color: AppTheme.muted, size: 13, weight: .bold)) }
        views.append(UIView())
        let row = UIStackView(arrangedSubviews: views)
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 4
        return row
    }

    private func exerciseCard(_ model: ExerciseModel, index: Int) -> UIView {
        let card = UIView()
        card.applyCard(radius: 22)
        card.translatesAutoresizingMaskIntoConstraints = false

        let name = UILabel(model.name, size: 17, weight: .black, color: AppTheme.text, lines: 1)
        let icon = symbolTile(symbol: "figure.run", color: accent, size: 38, corner: 12)
        let menu = IconButton(symbol: "ellipsis", color: AppTheme.muted, pointSize: 18)
        menu.setContentHuggingPriority(.required, for: .horizontal)
        menu.translatesAutoresizingMaskIntoConstraints = false
        menu.widthAnchor.constraint(equalToConstant: 30).isActive = true
        menu.addAction(UIAction { [weak self] _ in self?.showCardMenu(at: index) }, for: .touchUpInside)
        let header = UIStackView(arrangedSubviews: [name, UIView(), icon, menu])
        header.axis = .horizontal
        header.alignment = .center
        header.spacing = 10

        let stack = UIStackView(arrangedSubviews: [header, columnHeader(model), thinLine()])
        stack.axis = .vertical
        stack.spacing = 14

        for setIndex in model.sets.indices {
            stack.addArrangedSubview(setRow(model, exerciseIndex: index, setIndex: setIndex))
        }

        let removeTitle = model.deletingSets ? "수정 완료" : "−  세트 삭제"
        let remove = textActionButton(removeTitle) { [weak self] in
            model.deletingSets.toggle()
            self?.build()
        }
        if model.deletingSets { remove.setTitleColor(accent, for: .normal) }
        let add = textActionButton("+  세트 추가") { [weak self] in
            model.sets.append(Array(repeating: "", count: model.specs.count))
            self?.build()
        }
        let actions = UIStackView(arrangedSubviews: [remove, add])
        actions.axis = .horizontal
        actions.distribution = .fillEqually
        stack.addArrangedSubview(actions)
        stack.setCustomSpacing(18, after: actions)

        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        return card
    }

    private func columnHeader(_ model: ExerciseModel) -> UIView {
        let setLabel = UILabel("세트", size: 13, weight: .bold, color: AppTheme.muted, lines: 1)
        setLabel.textAlignment = .center
        setLabel.widthAnchor.constraint(equalToConstant: 44).isActive = true

        var fieldLabels: [UIView] = []
        for spec in model.specs {
            let label = UILabel(spec.title, size: 13, weight: .bold, color: AppTheme.muted, lines: 1)
            label.textAlignment = .center
            fieldLabels.append(label)
        }

        var views: [UIView] = [setLabel] + fieldLabels
        if model.deletingSets {
            let spacer = UIView()
            spacer.widthAnchor.constraint(equalToConstant: 34).isActive = true
            views.append(spacer)
        }
        let row = UIStackView(arrangedSubviews: views)
        row.axis = .horizontal
        row.spacing = 12
        row.distribution = .fill
        // 공통 superview(스택)에 들어간 뒤 동일 너비 제약을 건다.
        for label in fieldLabels.dropFirst() {
            label.widthAnchor.constraint(equalTo: fieldLabels[0].widthAnchor).isActive = true
        }
        return row
    }

    private func setRow(_ model: ExerciseModel, exerciseIndex: Int, setIndex: Int) -> UIView {
        let number = UILabel("\(setIndex + 1)", size: 16, weight: .black, color: AppTheme.text, lines: 1)
        number.textAlignment = .center
        number.widthAnchor.constraint(equalToConstant: 44).isActive = true

        var fieldViews: [UIView] = []
        for specIndex in model.specs.indices {
            let spec = model.specs[specIndex]
            let field = fieldBox(value: model.sets[setIndex][specIndex], unit: spec.unit) { [weak self] text in
                guard let self else { return }
                self.exercises[exerciseIndex].sets[setIndex][specIndex] = text
                self.timeValueLabel?.text = "\(self.totalMinutes())분"
                self.kcalValueLabel?.text = "\(self.totalKcal())kcal"
            }
            fieldViews.append(field)
        }

        var views: [UIView] = [number] + fieldViews
        if model.deletingSets {
            let trash = IconButton(symbol: "trash", color: .systemRed, pointSize: 17)
            trash.translatesAutoresizingMaskIntoConstraints = false
            trash.widthAnchor.constraint(equalToConstant: 34).isActive = true
            trash.addAction(UIAction { [weak self] _ in self?.deleteSet(model, at: setIndex) }, for: .touchUpInside)
            views.append(trash)
        }
        let row = UIStackView(arrangedSubviews: views)
        row.axis = .horizontal
        row.spacing = 12
        row.distribution = .fill
        // 공통 superview(스택)에 들어간 뒤 동일 너비 제약을 건다.
        for field in fieldViews.dropFirst() {
            field.widthAnchor.constraint(equalTo: fieldViews[0].widthAnchor).isActive = true
        }
        return row
    }

    private func deleteSet(_ model: ExerciseModel, at setIndex: Int) {
        guard model.sets.count > 1, model.sets.indices.contains(setIndex) else { return }
        model.sets.remove(at: setIndex)
        build()
    }

    private func showCardMenu(at index: Int) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "운동 교체", style: .default) { [weak self] _ in self?.replaceExercise(at: index) })
        sheet.addAction(UIAlertAction(title: "운동 삭제", style: .destructive) { [weak self] _ in self?.deleteExercise(at: index) })
        sheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(sheet, animated: true)
    }

    private func replaceExercise(at index: Int) {
        let picker = SearchListViewController.exercise()
        picker.onRecord = { [weak self] names in
            guard let self, let name = names.first, self.exercises.indices.contains(index) else { return }
            self.exercises[index] = ExerciseModel(name: name, specs: ExerciseRecordDetailViewController.specs(for: name))
            self.build()
        }
        present(picker, animated: true)
    }

    private func deleteExercise(at index: Int) {
        guard exercises.indices.contains(index) else { return }
        exercises.remove(at: index)
        if exercises.isEmpty { dismiss(animated: true) } else { build() }
    }

    private func fieldBox(value: String, unit: String, onChange: @escaping (String) -> Void) -> UIView {
        let box = UIView()
        box.layer.cornerRadius = 12
        box.layer.borderWidth = 1
        box.layer.borderColor = borderColor.cgColor
        box.translatesAutoresizingMaskIntoConstraints = false
        box.heightAnchor.constraint(equalToConstant: 48).isActive = true

        let field = UITextField()
        field.text = value
        field.attributedPlaceholder = NSAttributedString(string: "0", attributes: [
            .foregroundColor: AppTheme.text, .font: AppTheme.font(16, .black)
        ])
        field.font = AppTheme.font(16, .black)
        field.textColor = AppTheme.text
        field.textAlignment = .center
        field.keyboardType = .decimalPad
        field.addAction(UIAction { [weak field] _ in onChange(field?.text ?? "") }, for: .editingChanged)

        let unitLabel = UILabel(unit, size: 13, weight: .bold, color: AppTheme.muted, lines: 1)
        unitLabel.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [field, unitLabel])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 2
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        row.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: box.topAnchor),
            row.bottomAnchor.constraint(equalTo: box.bottomAnchor),
            row.leadingAnchor.constraint(equalTo: box.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: box.trailingAnchor)
        ])
        return box
    }

    private func bottomButtons() -> UIView {
        let isEditing = editIndexInDay != nil

        let done = UIButton(type: .system)
        done.setTitle(isEditing ? "수정 완료" : "기록 완료", for: .normal)
        done.setTitleColor(.white, for: .normal)
        done.titleLabel?.font = AppTheme.font(16, .black)
        done.backgroundColor = accent
        done.layer.cornerRadius = 16
        done.addAction(UIAction { [weak self] _ in self?.complete() }, for: .touchUpInside)

        // 수정 모드에서는 '운동 추가' 없이 '수정 완료'만 보여준다.
        guard !isEditing else {
            done.translatesAutoresizingMaskIntoConstraints = false
            return done
        }

        let addMore = UIButton(type: .system)
        addMore.setTitle("운동 추가", for: .normal)
        addMore.setTitleColor(accent, for: .normal)
        addMore.titleLabel?.font = AppTheme.font(16, .black)
        addMore.backgroundColor = accent.withAlphaComponent(0.12)
        addMore.layer.cornerRadius = 16
        addMore.addAction(UIAction { [weak self] _ in self?.addMoreExercise() }, for: .touchUpInside)

        let row = UIStackView(arrangedSubviews: [addMore, done])
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        return row
    }

    private func addMoreExercise() {
        let picker = SearchListViewController.exercise()
        picker.onRecord = { [weak self] names in
            guard let self else { return }
            for name in names where !self.exercises.contains(where: { $0.name == name }) {
                self.exercises.append(ExerciseModel(name: name, specs: ExerciseRecordDetailViewController.specs(for: name)))
            }
            self.build()
        }
        present(picker, animated: true)
    }

    private func complete() {
        let store = HealthStore.shared
        if let editIndex = editIndexInDay, let model = exercises.first {
            // 수정 모드: 기존 기록을 교체하고, 이 화면을 띄운 운동상세로 바로 돌아간다.
            store.updateExerciseEntry(date: date, indexInDay: editIndex, name: model.name,
                                      minutes: minutesOf(model), kcal: kcalOf(model), intensity: 1, time: date)
            dismiss(animated: true)
            return
        }
        for model in exercises {
            store.addExercise(date: date, name: model.name, minutes: minutesOf(model), kcal: kcalOf(model), intensity: 1, time: date)
        }
        // (운동상세 → 검색목록 → 이 화면) 순이므로, 검색목록을 띄운 운동상세에서 dismiss해
        // 검색목록과 이 화면을 함께 닫고 운동상세로 돌아간다.
        if let exerciseDetail = presentingViewController?.presentingViewController {
            exerciseDetail.dismiss(animated: true)
        } else {
            presentingViewController?.dismiss(animated: true)
        }
    }

    private func minutesOf(_ model: ExerciseModel) -> Int {
        guard let timeIndex = model.specs.firstIndex(where: { $0.title == "시간" }) else { return 0 }
        return model.sets.reduce(0) { acc, set in
            acc + (Int(set[timeIndex].filter { $0.isNumber }) ?? 0)
        }
    }

    private func totalMinutes() -> Int {
        exercises.reduce(0) { $0 + minutesOf($1) }
    }

    /// 운동 종류·운동 시간·체중을 바탕으로 소모 칼로리를 추정한다(MET 공식).
    private func kcalOf(_ model: ExerciseModel) -> Int {
        let weight = HealthStore.shared.weight   // kg
        let minutes = activeMinutes(model)
        guard minutes > 0 else { return 0 }
        let kcal = metValue(for: model.name) * weight * (Double(minutes) / 60.0)
        return Int(kcal.rounded())
    }

    /// 칼로리 계산에 쓸 활동 시간(분). 시간 칼럼이 없으면 횟수로 추정한다(1회 ≈ 4초).
    private func activeMinutes(_ model: ExerciseModel) -> Int {
        if let timeIndex = model.specs.firstIndex(where: { $0.title == "시간" }) {
            return model.sets.reduce(0) { $0 + (Int($1[timeIndex].filter { $0.isNumber }) ?? 0) }
        }
        if let repIndex = model.specs.firstIndex(where: { $0.title == "횟수" }) {
            let reps = model.sets.reduce(0) { $0 + (Int($1[repIndex].filter { $0.isNumber }) ?? 0) }
            return Int((Double(reps) * 4.0 / 60.0).rounded())
        }
        return 0
    }

    /// 운동 이름에 따른 MET(대사당량) 값.
    private func metValue(for name: String) -> Double {
        func has(_ keys: [String]) -> Bool { keys.contains { name.contains($0) } }
        if has(["러닝", "달리기", "마라톤", "트레드밀"]) { return 9.8 }
        if has(["걷기", "워킹"]) { return 3.5 }
        if has(["자전거", "사이클", "스피닝", "마운틴"]) { return 7.0 }
        if has(["수영"]) { return 7.0 }
        if has(["복싱"]) { return 7.8 }
        if has(["줄넘기"]) { return 11.0 }
        if has(["등산", "클라이밍"]) { return 7.5 }
        if has(["덤벨", "바벨", "컬", "프레스", "스쿼트", "데드", "레그", "로우", "익스텐션", "머신", "리프트", "플라이"]) { return 5.0 }
        if has(["요가", "필라테스", "스트레칭"]) { return 3.0 }
        if has(["검도", "댄스", "폴"]) { return 5.5 }
        return 4.0
    }

    private func totalKcal() -> Int {
        exercises.reduce(0) { $0 + kcalOf($1) }
    }

    private func thinLine() -> UIView {
        let line = UIView()
        line.backgroundColor = UIColor(red: 0.91, green: 0.92, blue: 0.94, alpha: 1)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }

    private func textActionButton(_ title: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(AppTheme.muted, for: .normal)
        button.titleLabel?.font = AppTheme.font(14, .bold)
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return button
    }
}
