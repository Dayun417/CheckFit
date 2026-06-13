//
//  SharedComponents.swift
//  CheckFit
//
//  공용 컴포넌트 (TapAction, 달력 피커, 연속기록 화면)
//

import UIKit

final class TapAction: UITapGestureRecognizer {
    private let handler: () -> Void
    init(_ handler: @escaping () -> Void) {
        self.handler = handler
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(fire))
    }
    @objc private func fire() { handler() }
}

// MARK: - 운동 통계

/// 운동 상세의 '통계' 칩을 누르면 나오는 운동 통계 화면.
/// 보라색 헤더(날짜 선택) + 요약 카드 + 시간/칼로리 토글 + 일간/주간/월간 그래프.
final class CalendarPickerViewController: UIViewController {
    var onSelect: ((Date) -> Void)?
    private let initialDate: Date

    init(date: Date) {
        self.initialDate = date
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 28
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let title = UILabel("날짜 선택", size: 20, weight: .black, color: AppTheme.text, lines: 1)
        title.translatesAutoresizingMaskIntoConstraints = false

        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.tintColor = AppTheme.brand
        picker.date = initialDate
        picker.locale = Locale(identifier: "ko_KR")
        picker.translatesAutoresizingMaskIntoConstraints = false

        let done = UIButton(type: .system)
        done.setTitle("완료", for: .normal)
        done.setTitleColor(.white, for: .normal)
        done.titleLabel?.font = AppTheme.font(18, .black)
        done.backgroundColor = AppTheme.brand
        done.layer.cornerRadius = 14
        done.translatesAutoresizingMaskIntoConstraints = false
        done.addAction(UIAction { [weak self, weak picker] _ in
            guard let self, let picker else { return }
            self.onSelect?(picker.date)
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

/// 홈 헤더의 번개 캡슐을 누르면 나오는 연속 기록 화면.
/// 라벤더 헤더(번개 아이콘 + 연속 일수 + 자정까지 남은 시간) 아래에 이번 달 달력을 보여준다.
final class StreakViewController: UIViewController {
    private let accent = AppTheme.brand
    private let lavender = UIColor(red: 0.90, green: 0.97, blue: 0.94, alpha: 1)
    private var streakDays: Int { HealthStore.shared.currentStreak }
    private var todayRecorded: Bool { HealthStore.shared.isRecorded(Date()) }
    private let displayedMonth = Date()

    private weak var countdownLabel: UILabel?
    private var timer: Timer?

    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCountdown()
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateCountdown()
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }

    private func build() {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.contentInsetAdjustmentBehavior = .never
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 0
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)

        content.addArrangedSubview(headerPanel())

        let body = UIStackView()
        body.axis = .vertical
        body.spacing = 18
        body.isLayoutMarginsRelativeArrangement = true
        body.layoutMargins = UIEdgeInsets(top: 24, left: 22, bottom: 30, right: 22)
        body.addArrangedSubview(monthRow())
        body.addArrangedSubview(tabRow())
        body.addArrangedSubview(weekdayHeader())
        body.addArrangedSubview(calendarGrid())
        content.addArrangedSubview(body)

        // 상태바 영역까지 라벤더로 채우기 (오버스크롤 시 흰색이 보이지 않도록)
        let topFill = UIView()
        topFill.backgroundColor = lavender
        topFill.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(topFill, belowSubview: scroll)
        NSLayoutConstraint.activate([
            topFill.topAnchor.constraint(equalTo: view.topAnchor),
            topFill.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topFill.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topFill.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor)
        ])
    }

    private func headerPanel() -> UIView {
        let panel = UIView()
        panel.backgroundColor = lavender
        panel.layer.cornerRadius = 34
        panel.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        panel.translatesAutoresizingMaskIntoConstraints = false

        let back = IconButton(symbol: "chevron.left", color: AppTheme.text, pointSize: 22)
        back.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)
        back.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(back)

        let bolt = UIImageView(image: UIImage(systemName: "bolt.fill"))
        // 오늘 기록을 완료하면 번개가 주황색으로 바뀐다.
        bolt.tintColor = todayRecorded ? UIColor.systemOrange : UIColor.systemGray3
        bolt.contentMode = .scaleAspectFit
        bolt.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 92, weight: .medium)
        bolt.translatesAutoresizingMaskIntoConstraints = false

        let captionRow = UIStackView()
        captionRow.axis = .horizontal
        captionRow.alignment = .center
        captionRow.spacing = 4
        captionRow.addArrangedSubview(UILabel("연속 기록", size: 15, weight: .bold, color: AppTheme.muted, lines: 1))
        captionRow.addArrangedSubview(UIImageView(symbol: "info.circle", color: AppTheme.muted, size: 13, weight: .semibold))

        let daysLabel = UILabel("\(streakDays)일", size: 34, weight: .black, color: AppTheme.text, lines: 1)

        let dot = UIView()
        dot.backgroundColor = .systemRed
        dot.layer.cornerRadius = 4
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.widthAnchor.constraint(equalToConstant: 8).isActive = true
        dot.heightAnchor.constraint(equalToConstant: 8).isActive = true
        let countdown = UILabel("00:00:00", size: 15, weight: .bold, color: UIColor(red: 0.90, green: 0.32, blue: 0.32, alpha: 1), lines: 1)
        countdown.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .bold)
        countdownLabel = countdown
        let countdownRow = UIStackView(arrangedSubviews: [dot, countdown])
        countdownRow.axis = .horizontal
        countdownRow.alignment = .center
        countdownRow.spacing = 6

        let statusPill: UILabel
        if todayRecorded {
            statusPill = makePill("오늘 기록 완료! 🎉", foreground: accent, background: UIColor.white.withAlphaComponent(0.85), fontSize: 13)
        } else {
            statusPill = makePill("아직 오늘의 기록이 없어요.", foreground: AppTheme.muted, background: UIColor.white.withAlphaComponent(0.7), fontSize: 13)
        }
        statusPill.textAlignment = .center
        statusPill.widthAnchor.constraint(greaterThanOrEqualToConstant: 250).isActive = true

        // 오늘 기록을 마쳤으면 카운트다운을 숨기고 완료 안내만 보여준다.
        let middleRows: [UIView] = todayRecorded ? [statusPill] : [countdownRow, statusPill]
        let stack = UIStackView(arrangedSubviews: [bolt, captionRow, daysLabel] + middleRows)
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        stack.setCustomSpacing(16, after: bolt)
        stack.setCustomSpacing(6, after: captionRow)
        stack.setCustomSpacing(14, after: daysLabel)
        if !todayRecorded { stack.setCustomSpacing(18, after: countdownRow) }
        stack.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(stack)

        NSLayoutConstraint.activate([
            back.topAnchor.constraint(equalTo: panel.safeAreaLayoutGuide.topAnchor, constant: 6),
            back.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 12),
            bolt.heightAnchor.constraint(equalToConstant: 104),
            stack.topAnchor.constraint(equalTo: panel.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: panel.bottomAnchor, constant: -28),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: panel.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: panel.trailingAnchor, constant: -24),
            stack.centerXAnchor.constraint(equalTo: panel.centerXAnchor)
        ])
        return panel
    }

    private func monthRow() -> UIView {
        let cal = Calendar.current
        let year = cal.component(.year, from: displayedMonth)
        let month = cal.component(.month, from: displayedMonth)
        let title = UILabel("\(year).\(month)", size: 24, weight: .black, color: AppTheme.text, lines: 1)
        let today = makePill("오늘", foreground: AppTheme.muted, background: AppTheme.softFill, fontSize: 13)
        let row = UIStackView(arrangedSubviews: [title, UIView(), today])
        row.axis = .horizontal
        row.alignment = .center
        return row
    }

    private func tabRow() -> UIView {
        let titles = ["연속기록"]
        let selectedIndex = 0
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 18
        for (index, title) in titles.enumerated() {
            let selected = index == selectedIndex
            let label = UILabel(title, size: 15, weight: .black, color: selected ? accent : AppTheme.muted, lines: 1)
            label.adjustsFontSizeToFitWidth = false
            let bar = UIView()
            bar.backgroundColor = selected ? accent : .clear
            bar.layer.cornerRadius = 1.5
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.heightAnchor.constraint(equalToConstant: 3).isActive = true
            let column = UIStackView(arrangedSubviews: [label, bar])
            column.axis = .vertical
            column.alignment = .fill
            column.spacing = 7
            row.addArrangedSubview(column)
        }
        row.addArrangedSubview(UIView())

        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        row.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(row)
        NSLayoutConstraint.activate([
            scroll.heightAnchor.constraint(equalToConstant: 34),
            row.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            row.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            row.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            row.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor)
        ])
        return scroll
    }

    private func weekdayHeader() -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        for day in ["월", "화", "수", "목", "금", "토", "일"] {
            let label = UILabel(day, size: 13, weight: .bold, color: AppTheme.muted, lines: 1)
            label.textAlignment = .center
            row.addArrangedSubview(label)
        }
        return row
    }

    private func calendarGrid() -> UIView {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: displayedMonth)
        guard let firstOfMonth = cal.date(from: comps),
              let range = cal.range(of: .day, in: .month, for: firstOfMonth) else {
            return UIView()
        }
        let numDays = range.count
        // 월요일을 한 주의 시작으로 둔 앞쪽 빈 칸 수
        let firstWeekday = cal.component(.weekday, from: firstOfMonth)
        let leading = (firstWeekday + 5) % 7

        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 6
        grid.distribution = .fillEqually

        var cellIndex = 0
        let totalCells = leading + numDays
        let rows = Int(ceil(Double(totalCells) / 7.0))
        for _ in 0..<rows {
            let weekRow = UIStackView()
            weekRow.axis = .horizontal
            weekRow.distribution = .fillEqually
            for _ in 0..<7 {
                if cellIndex < leading || cellIndex >= leading + numDays {
                    weekRow.addArrangedSubview(UIView())
                } else {
                    let day = cellIndex - leading + 1
                    if let date = cal.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                        weekRow.addArrangedSubview(calendarCell(date: date, day: day))
                    } else {
                        weekRow.addArrangedSubview(UIView())
                    }
                }
                cellIndex += 1
            }
            grid.addArrangedSubview(weekRow)
        }
        return grid
    }

    private func calendarCell(date: Date, day: Int) -> UIView {
        let cal = Calendar.current
        let isToday = cal.isDateInToday(date)
        let isStreak = HealthStore.shared.isRecorded(date)

        let cell = UIView()
        cell.translatesAutoresizingMaskIntoConstraints = false
        cell.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let numberColor = isToday ? UIColor.white : AppTheme.text
        let number = UILabel("\(day)", size: 15, weight: isToday ? .black : .semibold, color: numberColor, lines: 1)
        number.textAlignment = .center
        number.translatesAutoresizingMaskIntoConstraints = false

        if isToday {
            let circle = UIView()
            circle.backgroundColor = AppTheme.text
            circle.layer.cornerRadius = 16
            circle.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(circle)
            NSLayoutConstraint.activate([
                circle.widthAnchor.constraint(equalToConstant: 32),
                circle.heightAnchor.constraint(equalToConstant: 32),
                circle.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
                circle.centerYAnchor.constraint(equalTo: cell.topAnchor, constant: 16)
            ])
        }

        cell.addSubview(number)
        NSLayoutConstraint.activate([
            number.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
            number.centerYAnchor.constraint(equalTo: cell.topAnchor, constant: 16)
        ])

        // 기록한 날은 날짜 아래에 초록색 번개 표시 (오늘 포함)
        if isStreak {
            let bolt = UIImageView(symbol: "bolt.fill", color: accent, size: 12, weight: .bold)
            cell.addSubview(bolt)
            NSLayoutConstraint.activate([
                bolt.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
                bolt.topAnchor.constraint(equalTo: cell.topAnchor, constant: 33)
            ])
        }
        return cell
    }

    private func updateCountdown() {
        let cal = Calendar.current
        let now = Date()
        let startOfDay = cal.startOfDay(for: now)
        guard let endOfDay = cal.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        let remaining = max(0, endOfDay.timeIntervalSince(now))
        let total = Int(remaining)
        countdownLabel?.text = String(format: "%02d:%02d:%02d", total / 3600, (total % 3600) / 60, total % 60)
    }
}

/// 세로/가로 점선을 그리는 뷰 (단식 차트의 기준선·타임라인에 사용).
