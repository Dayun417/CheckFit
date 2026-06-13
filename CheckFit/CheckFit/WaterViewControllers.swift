//
//  WaterViewControllers.swift
//  CheckFit
//
//  수분 설정 화면
//

import UIKit

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
        dim.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundTapped)))
        view.addSubview(dim)

        sheetView.applyCard(radius: 28, shadow: true)
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sheetView)
        sheetView.addSheetGrabber()

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
            string: "\(ProfileStore.shared.nickname)님의 추천 섭취량: 1500ml 일반적으로 추천하는 가장 건강한 물 섭취량은 1L ~ 1.5L 예요.",
            attributes: [
                .font: AppTheme.font(16, .bold),
                .foregroundColor: UIColor(red: 0.45, green: 0.48, blue: 0.55, alpha: 1)
            ]
        )
        text.addAttributes([
            .font: AppTheme.font(16, .black),
            .foregroundColor: AppTheme.brand
        ], range: (text.string as NSString).range(of: "1500ml"))

        let label = UILabel()
        label.attributedText = text
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(label)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 132),
            label.topAnchor.constraint(equalTo: card.topAnchor, constant: 22),
            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20)
        ])
        return card
    }

    @objc private func backgroundTapped() {
        dismissSheet()
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
