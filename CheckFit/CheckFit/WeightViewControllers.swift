//
//  WeightViewControllers.swift
//  CheckFit
//
//  체성분 입력 화면
//

import UIKit

final class BodyCompositionInputViewController: UIViewController {
    private let date: Date
    private let weight: CGFloat
    private let weightField = UITextField()
    private let muscleField = UITextField()
    private let fatField = UITextField()

    /// Called when "기록하기" is tapped, passing the entered weight in kg.
    var onRecord: ((CGFloat) -> Void)?

    private let accent = AppTheme.brand

    init(date: Date, weight: CGFloat) {
        self.date = date
        self.weight = weight
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
        let back = IconButton(symbol: "chevron.left", color: AppTheme.text, pointSize: 22)
        back.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)
        back.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(back)

        let titleLabel = UILabel("체성분 입력", size: 18, weight: .black, color: AppTheme.text, lines: 1)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        let form = UIStackView()
        form.axis = .vertical
        form.spacing = 18
        form.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(form)

        form.addArrangedSubview(dateRow())
        form.addArrangedSubview(fieldRow(title: "체중", field: weightField, unit: "kg",
                                         text: String(format: "%.1f", weight)))
        form.addArrangedSubview(fieldRow(title: "골격근량", field: muscleField, unit: "kg", text: nil))
        form.addArrangedSubview(fieldRow(title: "체지방률", field: fatField, unit: "%", text: nil))

        let record = UIButton(type: .system)
        record.backgroundColor = accent
        record.setTitle("기록하기", for: .normal)
        record.setTitleColor(.white, for: .normal)
        record.titleLabel?.font = AppTheme.font(18, .black)
        record.layer.cornerRadius = 16
        record.addAction(UIAction { [weak self] _ in self?.recordAndDismiss() }, for: .touchUpInside)
        record.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(record)

        NSLayoutConstraint.activate([
            back.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            form.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 34),
            form.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
            form.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -22),
            record.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            record.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            record.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            record.heightAnchor.constraint(equalToConstant: 56)
        ])

        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    private func dateRow() -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.addArrangedSubview(UILabel("날짜", size: 16, weight: .bold, color: AppTheme.text, lines: 1))
        row.addArrangedSubview(UIView())

        let box = UIView()
        box.backgroundColor = .white
        box.layer.cornerRadius = 12
        box.layer.borderWidth = 1
        box.layer.borderColor = UIColor(red: 0.89, green: 0.90, blue: 0.93, alpha: 1).cgColor
        box.translatesAutoresizingMaskIntoConstraints = false

        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd"
        let dateLabel = UILabel(formatter.string(from: date), size: 16, weight: .black, color: AppTheme.text, lines: 1)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        let chevron = UIImageView(symbol: "chevron.down", color: AppTheme.muted, size: 12)
        box.addSubview(dateLabel)
        box.addSubview(chevron)

        NSLayoutConstraint.activate([
            box.widthAnchor.constraint(equalToConstant: 142),
            box.heightAnchor.constraint(equalToConstant: 52),
            dateLabel.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 16),
            dateLabel.centerYAnchor.constraint(equalTo: box.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -14),
            chevron.centerYAnchor.constraint(equalTo: box.centerYAnchor)
        ])
        row.addArrangedSubview(box)
        return row
    }

    private func fieldRow(title: String, field: UITextField, unit: String, text: String?) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.addArrangedSubview(UILabel(title, size: 16, weight: .bold, color: AppTheme.text, lines: 1))
        row.addArrangedSubview(UIView())

        field.text = text
        field.font = AppTheme.font(16, .black)
        field.textColor = AppTheme.text
        field.textAlignment = .right
        field.backgroundColor = .white
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor(red: 0.89, green: 0.90, blue: 0.93, alpha: 1).cgColor
        field.clipsToBounds = true
        field.keyboardType = .decimalPad

        let fieldHeight: CGFloat = 52
        let unitLabel = UILabel(unit, size: 15, weight: .bold, color: AppTheme.muted, lines: 1)
        unitLabel.sizeToFit()
        let rightWrap = UIView(frame: CGRect(x: 0, y: 0, width: unitLabel.bounds.width + 22, height: fieldHeight))
        unitLabel.frame = CGRect(x: 4, y: 0, width: unitLabel.bounds.width, height: fieldHeight)
        rightWrap.addSubview(unitLabel)
        field.rightView = rightWrap
        field.rightViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            field.widthAnchor.constraint(equalToConstant: 142),
            field.heightAnchor.constraint(equalToConstant: fieldHeight)
        ])
        row.addArrangedSubview(field)
        return row
    }

    private func recordAndDismiss() {
        let entered = parsedWeight(from: weightField.text) ?? weight
        HealthStore.shared.weight = Double(entered)
        if let muscle = parsedWeight(from: muscleField.text) {
            HealthStore.shared.muscleMass = Double(muscle)
        }
        if let fat = parsedWeight(from: fatField.text) {
            HealthStore.shared.bodyFat = Double(fat)
        }
        HealthStore.shared.markRecordedToday()
        onRecord?(entered)
        dismiss(animated: true)
    }

    private func parsedWeight(from text: String?) -> CGFloat? {
        guard let text, let value = Double(text.filter { $0.isNumber || $0 == "." }), value > 0 else { return nil }
        return CGFloat(value)
    }
}
