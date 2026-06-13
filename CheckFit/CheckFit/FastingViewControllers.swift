//
//  FastingViewControllers.swift
//  CheckFit
//
//  단식 시작·시간선택·루틴 화면
//

import UIKit

final class FastingStartViewController: UIViewController {
    private let accent = AppTheme.brand
    private var fastingHours = HealthStore.shared.fastingHours
    private let datePicker = UIDatePicker()
    private weak var startValueLabel: UILabel?
    private weak var rangeLabel: UILabel?
    private weak var durValueLabel: UILabel?

    /// 확인 시 선택한 시작 시각과 단식 시간을 전달.
    var onConfirm: ((Date, Int) -> Void)?

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { context in context.maximumDetentValue * 0.74 }]
            } else {
                sheet.detents = [.large()]
            }
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 28
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        build()
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 HH:mm"
        return formatter.string(from: date)
    }

    private func updateLabels() {
        let start = datePicker.date
        let end = start.addingTimeInterval(TimeInterval(fastingHours) * 3600)
        startValueLabel?.text = formatted(start)
        rangeLabel?.text = "\(formatted(start)) - \(formatted(end))"
    }

    private func build() {
        let title = UILabel("단식 시작", size: 19, weight: .black, color: AppTheme.text, lines: 1)
        let routine = makePill("루틴 시간", foreground: AppTheme.muted, background: AppTheme.softFill, fontSize: 13)
        let header = UIStackView(arrangedSubviews: [title, UIView(), routine])
        header.axis = .horizontal
        header.alignment = .center

        let range = UILabel("", size: 14, weight: .bold, color: AppTheme.muted, lines: 1)
        rangeLabel = range

        let startTitle = UILabel("시작 시간", size: 16, weight: .black, color: AppTheme.text, lines: 1)
        let startValue = UILabel("", size: 15, weight: .black, color: AppTheme.text, lines: 1)
        startValueLabel = startValue
        let startRow = UIStackView(arrangedSubviews: [startTitle, UIView(), startValue,
                                                      UIImageView(symbol: "chevron.down", color: AppTheme.muted, size: 13, weight: .bold)])
        startRow.axis = .horizontal
        startRow.alignment = .center
        startRow.spacing = 8

        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.date = HealthStore.shared.fastingStart ?? Date()
        datePicker.addAction(UIAction { [weak self] _ in self?.updateLabels() }, for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        let durTitle = UILabel("단식 시간", size: 16, weight: .black, color: AppTheme.text, lines: 1)
        let durValue = UILabel("\(fastingHours)시간", size: 15, weight: .black, color: AppTheme.text, lines: 1)
        durValueLabel = durValue
        let durRow = UIStackView(arrangedSubviews: [durTitle, UIView(), durValue,
                                                    UIImageView(symbol: "chevron.up", color: AppTheme.muted, size: 13, weight: .bold)])
        durRow.axis = .horizontal
        durRow.alignment = .center
        durRow.spacing = 8
        durRow.isUserInteractionEnabled = true
        durRow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(durationTapped)))

        let no = sheetButton("아니오", titleColor: AppTheme.muted, background: AppTheme.softFill)
        let yes = sheetButton("네, 좋아요", titleColor: .white, background: accent) { [weak self] in
            guard let self else { return }
            self.onConfirm?(self.datePicker.date, self.fastingHours)
        }
        let buttons = UIStackView(arrangedSubviews: [no, yes])
        buttons.axis = .horizontal
        buttons.distribution = .fillEqually
        buttons.spacing = 12

        let content = UIStackView(arrangedSubviews: [header, range, divider(), startRow, datePicker, divider(), durRow, buttons])
        content.axis = .vertical
        content.spacing = 16
        content.setCustomSpacing(6, after: header)
        content.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            content.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            content.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
        updateLabels()
    }

    @objc private func durationTapped() {
        let picker = HoursPickerViewController(hours: fastingHours)
        picker.onSelect = { [weak self] hours in
            guard let self else { return }
            self.fastingHours = hours
            self.durValueLabel?.text = "\(hours)시간"
            self.updateLabels()
        }
        present(picker, animated: true)
    }

    private func sheetButton(_ title: String, titleColor: UIColor, background: UIColor, action: (() -> Void)? = nil) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = AppTheme.font(16, .black)
        button.backgroundColor = background
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 54).isActive = true
        button.addAction(UIAction { [weak self] _ in
            action?()
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        return button
    }

    private func divider() -> UIView {
        let line = UIView()
        line.backgroundColor = UIColor(red: 0.91, green: 0.92, blue: 0.94, alpha: 1)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }
}

/// 단식 시간(1~23시간)을 휠로 고르는 시트.
final class HoursPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var onSelect: ((Int) -> Void)?
    private let hours: Int
    private let picker = UIPickerView()
    private let range = Array(1...23)

    init(hours: Int) {
        self.hours = hours
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { context in context.maximumDetentValue * 0.46 }]
            } else {
                sheet.detents = [.medium()]
            }
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 28
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let title = UILabel("단식 시간", size: 20, weight: .black, color: AppTheme.text, lines: 1)
        title.translatesAutoresizingMaskIntoConstraints = false

        picker.dataSource = self
        picker.delegate = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        if let index = range.firstIndex(of: hours) {
            picker.selectRow(index, inComponent: 0, animated: false)
        }

        let done = UIButton(type: .system)
        done.setTitle("완료", for: .normal)
        done.setTitleColor(.white, for: .normal)
        done.titleLabel?.font = AppTheme.font(18, .black)
        done.backgroundColor = AppTheme.brand
        done.layer.cornerRadius = 14
        done.translatesAutoresizingMaskIntoConstraints = false
        done.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.onSelect?(self.range[self.picker.selectedRow(inComponent: 0)])
            self.dismiss(animated: true)
        }, for: .touchUpInside)

        view.addSubview(title)
        view.addSubview(picker)
        view.addSubview(done)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            picker.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            picker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            picker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            done.topAnchor.constraint(greaterThanOrEqualTo: picker.bottomAnchor, constant: 8),
            done.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            done.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            done.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            done.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { range.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        "\(range[row])시간"
    }
}

/// 시각(시:분)을 휠로 고르는 시트.
final class TimePickerSheetViewController: UIViewController {
    var onSelect: ((Date) -> Void)?
    private let time: Date
    private let picker = UIDatePicker()

    init(time: Date) {
        self.time = time
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { context in context.maximumDetentValue * 0.46 }]
            } else {
                sheet.detents = [.medium()]
            }
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 28
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let title = UILabel("운동 시각", size: 20, weight: .black, color: AppTheme.text, lines: 1)
        title.translatesAutoresizingMaskIntoConstraints = false

        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko_KR")
        picker.date = time
        picker.translatesAutoresizingMaskIntoConstraints = false

        let done = UIButton(type: .system)
        done.setTitle("완료", for: .normal)
        done.setTitleColor(.white, for: .normal)
        done.titleLabel?.font = AppTheme.font(18, .black)
        done.backgroundColor = AppTheme.brand
        done.layer.cornerRadius = 14
        done.translatesAutoresizingMaskIntoConstraints = false
        done.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.onSelect?(self.picker.date)
            self.dismiss(animated: true)
        }, for: .touchUpInside)

        view.addSubview(title)
        view.addSubview(picker)
        view.addSubview(done)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            picker.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            picker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            picker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            done.topAnchor.constraint(greaterThanOrEqualTo: picker.bottomAnchor, constant: 8),
            done.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            done.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            done.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            done.heightAnchor.constraint(equalToConstant: 54)
        ])
    }
}

/// 아래에서 올라오는 정렬 선택 시트(최신순/빈도순 등).
final class FastingRoutineViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        build()
    }

    private func build() {
        let back = IconButton(symbol: "chevron.left", color: AppTheme.text, pointSize: 24)
        back.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)
        back.contentHorizontalAlignment = .leading
        back.translatesAutoresizingMaskIntoConstraints = false
        back.widthAnchor.constraint(equalToConstant: 40).isActive = true
        back.heightAnchor.constraint(equalToConstant: 40).isActive = true
        view.addSubview(back)

        let title = UILabel("내 단식 루틴", size: 26, weight: .black, color: AppTheme.text, lines: 1)

        let add = UIButton(type: .system)
        add.tintColor = .white
        add.backgroundColor = AppTheme.brand
        add.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)), for: .normal)
        add.layer.cornerRadius = 18
        add.addAction(UIAction { [weak self] _ in self?.presentEditor() }, for: .touchUpInside)
        add.translatesAutoresizingMaskIntoConstraints = false
        add.widthAnchor.constraint(equalToConstant: 36).isActive = true
        add.heightAnchor.constraint(equalToConstant: 36).isActive = true

        let titleRow = UIStackView(arrangedSubviews: [title, UIView(), add])
        titleRow.axis = .horizontal
        titleRow.alignment = .center

        let body = UIStackView(arrangedSubviews: [titleRow, routineCard(), footerNote()])
        body.axis = .vertical
        body.spacing = 22
        body.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(body)

        NSLayoutConstraint.activate([
            back.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            body.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 12),
            body.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
            body.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -22)
        ])
    }

    private func routineCard() -> UIView {
        let card = UIView()
        card.applyCard(radius: 24)

        let clock = symbolTile(symbol: "clock", color: .systemOrange, size: 44, corner: 16)
        let titleLabel = UILabel("16:8 단식", size: 18, weight: .black, color: AppTheme.text, lines: 1)
        let everyday = UILabel("매일", size: 14, weight: .bold, color: AppTheme.muted, lines: 1)
        let titleCol = UIStackView(arrangedSubviews: [titleLabel, everyday])
        titleCol.axis = .vertical
        titleCol.spacing = 4
        let headRow = UIStackView(arrangedSubviews: [clock, titleCol, UIView()])
        headRow.axis = .horizontal
        headRow.alignment = .center
        headRow.spacing = 14

        let line = UIView()
        line.backgroundColor = UIColor(red: 0.91, green: 0.92, blue: 0.94, alpha: 1)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let stack = UIStackView(arrangedSubviews: [
            headRow,
            timeRow(title: "시작 시간", tag: "저녁 식후 1시간", value: "7:00 PM"),
            timeRow(title: "종료 시간", tag: "16시간 후", value: "다음날 11:00 AM"),
            line,
            actionRow()
        ])
        stack.axis = .vertical
        stack.spacing = 18
        stack.setCustomSpacing(20, after: headRow)
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 22),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])
        return card
    }

    private func timeRow(title: String, tag: String, value: String) -> UIView {
        let titleLabel = UILabel(title, size: 15, weight: .bold, color: AppTheme.muted, lines: 1)
        let tagPill = PaddingLabel(tag, size: 11, weight: .black, color: AppTheme.brand)
        tagPill.insets = UIEdgeInsets(top: 4, left: 9, bottom: 4, right: 9)
        tagPill.backgroundColor = AppTheme.brand.withAlphaComponent(0.12)
        tagPill.layer.cornerRadius = 9
        tagPill.clipsToBounds = true
        let valueLabel = UILabel(value, size: 16, weight: .black, color: AppTheme.text, lines: 1)
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)
        let row = UIStackView(arrangedSubviews: [titleLabel, tagPill, UIView(), valueLabel])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
        return row
    }

    private func actionRow() -> UIView {
        let edit = textButton("루틴 수정") { [weak self] in self?.presentEditor() }
        let delete = textButton("루틴 삭제") { [weak self] in
            HealthStore.shared.fastingStart = nil
            self?.dismiss(animated: true)
        }

        let vline = UIView()
        vline.backgroundColor = UIColor(red: 0.88, green: 0.89, blue: 0.92, alpha: 1)
        vline.translatesAutoresizingMaskIntoConstraints = false
        vline.widthAnchor.constraint(equalToConstant: 1).isActive = true
        vline.heightAnchor.constraint(equalToConstant: 20).isActive = true

        let row = UIStackView(arrangedSubviews: [edit, vline, delete])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .fill
        // 버튼들이 같은 스택(공통 상위 뷰)에 들어간 뒤에 너비 동등 제약을 건다.
        edit.widthAnchor.constraint(equalTo: delete.widthAnchor).isActive = true
        return row
    }

    private func textButton(_ title: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(AppTheme.text, for: .normal)
        button.titleLabel?.font = AppTheme.font(15, .black)
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return button
    }

    private func footerNote() -> UIView {
        let label = UILabel("성장기 청소년, 임산부·수유 중인 분, 만성 질환이 있는 경우 단식은 권장되지 않습니다.", size: 13, weight: .semibold, color: AppTheme.muted, lines: 0)
        label.adjustsFontSizeToFitWidth = false
        return label
    }

    private func presentEditor() {
        let sheet = FastingStartViewController()
        sheet.onConfirm = { start, hours in
            HealthStore.shared.fastingStart = start
            HealthStore.shared.fastingHours = hours
            HealthStore.shared.markRecordedToday()
        }
        present(sheet, animated: true)
    }
}

/// 음식 한 가지의 정보 (이름·1회 제공량·열량·탄단지 그램).
