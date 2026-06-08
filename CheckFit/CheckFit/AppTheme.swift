//
//  AppTheme.swift
//  CheckFit
//

import UIKit

enum AppTheme {
    static let brand = UIColor(red: 0.02, green: 0.60, blue: 0.39, alpha: 1.0)
    static let weight = brand
    static let background = UIColor(red: 0.965, green: 0.973, blue: 0.973, alpha: 1.0)
    static let card = UIColor.white
    static let text = UIColor(red: 0.09, green: 0.13, blue: 0.19, alpha: 1.0)
    static let muted = UIColor(red: 0.60, green: 0.64, blue: 0.70, alpha: 1.0)
    static let softFill = UIColor(red: 0.955, green: 0.96, blue: 0.97, alpha: 1.0)

    static func font(_ size: CGFloat, _ weight: UIFont.Weight) -> UIFont {
        .systemFont(ofSize: size, weight: weight)
    }
}

enum AppDateText {
    private static let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

    static var mainTitle: String {
        mainTitle(for: Date())
    }

    static var detailTitle: String {
        detailTitle(for: Date())
    }

    static var currentWeek: [(date: Date, weekday: String, day: String, isSelected: Bool, isToday: Bool)] {
        week(containing: Date(), selectedDate: Date())
    }

    static func mainTitle(for date: Date) -> String {
        "\(monthDay(date)) \(weekday(date))"
    }

    static func detailTitle(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "\(monthDay(date)) 오늘"
        }
        return "\(monthDay(date)) \(weekday(date))"
    }

    static func week(containing date: Date, selectedDate: Date) -> [(date: Date, weekday: String, day: String, isSelected: Bool, isToday: Bool)] {
        let calendar = Calendar.current
        let baseDate = calendar.startOfDay(for: date)
        let selected = calendar.startOfDay(for: selectedDate)
        let baseWeekday = calendar.component(.weekday, from: baseDate)
        let daysFromMonday = (baseWeekday + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: baseDate) else {
            return []
        }

        return (0..<7).compactMap { offset -> (date: Date, weekday: String, day: String, isSelected: Bool, isToday: Bool)? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: monday) else {
                return nil
            }
            return (
                date,
                weekday(date),
                "\(calendar.component(.day, from: date))",
                calendar.isDate(date, inSameDayAs: selected),
                calendar.isDateInToday(date)
            )
        }
    }

    private static func monthDay(_ date: Date) -> String {
        let calendar = Calendar.current
        return "\(calendar.component(.month, from: date)).\(calendar.component(.day, from: date))"
    }

    private static func weekday(_ date: Date) -> String {
        let index = Calendar.current.component(.weekday, from: date) - 1
        return weekdays[max(0, min(index, weekdays.count - 1))]
    }
}

extension UIView {
    func pinEdges(to other: UIView, insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: other.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: other.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: other.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: -insets.bottom)
        ])
    }

    func applyCard(radius: CGFloat = 26, shadow: Bool = true) {
        backgroundColor = AppTheme.card
        layer.cornerRadius = radius
        if shadow {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.07
            layer.shadowRadius = 18
            layer.shadowOffset = CGSize(width: 0, height: 8)
        }
    }
}

extension UILabel {
    convenience init(_ text: String, size: CGFloat, weight: UIFont.Weight, color: UIColor = AppTheme.text, lines: Int = 0) {
        self.init()
        self.text = text
        self.font = AppTheme.font(size, weight)
        self.textColor = color
        self.numberOfLines = lines
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = 0.78
    }
}

extension UIImageView {
    convenience init(symbol: String, color: UIColor, size: CGFloat, weight: UIImage.SymbolWeight = .semibold) {
        self.init(image: UIImage(systemName: symbol))
        tintColor = color
        preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: size, weight: weight)
        contentMode = .scaleAspectFit
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size + 4),
            heightAnchor.constraint(equalToConstant: size + 4)
        ])
    }
}

final class IconButton: UIButton {
    init(symbol: String, color: UIColor, pointSize: CGFloat = 22, weight: UIImage.SymbolWeight = .semibold) {
        super.init(frame: .zero)
        tintColor = color
        setImage(UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)), for: .normal)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func makePill(_ text: String, foreground: UIColor = .white, background: UIColor = AppTheme.brand, fontSize: CGFloat = 15) -> UILabel {
    let label = UILabel(text, size: fontSize, weight: .black, color: foreground, lines: 1)
    label.textAlignment = .center
    label.backgroundColor = background
    label.layer.cornerRadius = 20
    label.clipsToBounds = true
    label.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        label.heightAnchor.constraint(equalToConstant: 40),
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: 74)
    ])
    return label
}

func symbolTile(symbol: String, color: UIColor, size: CGFloat = 58, corner: CGFloat = 18) -> UIView {
    let tile = UIView()
    tile.backgroundColor = AppTheme.softFill
    tile.layer.cornerRadius = corner
    tile.translatesAutoresizingMaskIntoConstraints = false
    let icon = UIImageView(symbol: symbol, color: color, size: 26, weight: .medium)
    tile.addSubview(icon)
    NSLayoutConstraint.activate([
        tile.widthAnchor.constraint(equalToConstant: size),
        tile.heightAnchor.constraint(equalToConstant: size),
        icon.centerXAnchor.constraint(equalTo: tile.centerXAnchor),
        icon.centerYAnchor.constraint(equalTo: tile.centerYAnchor)
    ])
    return tile
}

func avatar(size: CGFloat) -> UIView {
    let view = UIView()
    view.backgroundColor = UIColor(red: 0.56, green: 0.82, blue: 0.66, alpha: 1)
    view.layer.cornerRadius = size / 2
    view.layer.borderWidth = size > 60 ? 3 : 2
    view.layer.borderColor = UIColor.white.cgColor
    view.translatesAutoresizingMaskIntoConstraints = false
    let face = UILabel("🐱", size: size * 0.43, weight: .regular)
    face.textAlignment = .center
    face.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(face)
    NSLayoutConstraint.activate([
        view.widthAnchor.constraint(equalToConstant: size),
        view.heightAnchor.constraint(equalToConstant: size),
        face.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        face.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
    return view
}

class BaseScreenViewController: UIViewController {
    let scrollView = UIScrollView()
    let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.subviews.forEach { $0.removeFromSuperview() }
        view.backgroundColor = AppTheme.background
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView)

        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)
        ])
    }

    func paddedStack(spacing: CGFloat = 16, insets: UIEdgeInsets = UIEdgeInsets(top: 18, left: 26, bottom: 110, right: 26)) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = spacing
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = insets
        return stack
    }
}
