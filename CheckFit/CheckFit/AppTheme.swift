//
//  AppTheme.swift
//  CheckFit
//

import UIKit

/// 기록된 음식 한 가지 (날짜·끼니별로 저장).
struct DietEntry: Codable {
    let day: String
    let meal: String
    let name: String
    let kcal: Double
    let carb: Double
    let protein: Double
    let fat: Double
}

/// 기록된 운동 한 건 (날짜별로 저장).
struct ExerciseEntry: Codable {
    let day: String
    let name: String
    let minutes: Int
    let kcal: Int
    let intensity: Int   // 0 가볍게, 1 적당히, 2 격하게
    let time: Date
}

/// 완료된 단식 1건. end = 종료 시각, hours = 실제 단식 시간.
struct FastingRecord: Codable {
    let end: Date
    let hours: Double
}

/// 화면 간 공유되고 UserDefaults에 저장되는 건강 데이터 저장소.
final class HealthStore {
    static let shared = HealthStore()
    private let d = UserDefaults.standard
    private init() {}

    var weight: Double {
        get { d.object(forKey: "checkfit.weight") as? Double ?? 43.7 }
        set { d.set(newValue, forKey: "checkfit.weight") }
    }
    var muscleMass: Double? {
        get { d.object(forKey: "checkfit.muscleMass") as? Double }
        set { d.set(newValue, forKey: "checkfit.muscleMass") }
    }
    var bodyFat: Double? {
        get { d.object(forKey: "checkfit.bodyFat") as? Double }
        set { d.set(newValue, forKey: "checkfit.bodyFat") }
    }
    /// 날짜별 수분 섭취량(ml). 기록이 없는 날은 0.
    private var waterByDay: [String: Int] {
        get { (d.dictionary(forKey: "checkfit.waterByDay") as? [String: Int]) ?? [:] }
        set { d.set(newValue, forKey: "checkfit.waterByDay") }
    }
    func waterAmount(for date: Date) -> Int { waterByDay[dayKey(date)] ?? 0 }
    func setWaterAmount(_ amount: Int, for date: Date) {
        var all = waterByDay
        all[dayKey(date)] = max(0, amount)
        waterByDay = all
    }
    /// 오늘 수분 섭취량. 기록 없으면 0.
    var waterAmount: Int {
        get { waterAmount(for: Date()) }
        set { setWaterAmount(newValue, for: Date()) }
    }
    var waterGoal: Int {
        get { d.object(forKey: "checkfit.waterGoal") as? Int ?? 1500 }
        set { d.set(newValue, forKey: "checkfit.waterGoal") }
    }
    var waterStep: Int {
        get { d.object(forKey: "checkfit.waterStep") as? Int ?? 100 }
        set { d.set(newValue, forKey: "checkfit.waterStep") }
    }

    // MARK: - 단식

    /// 진행 중인 단식의 시작 시각. nil이면 단식 중이 아님.
    var fastingStart: Date? {
        get { d.object(forKey: "checkfit.fastingStart") as? Date }
        set { d.set(newValue, forKey: "checkfit.fastingStart") }
    }
    var fastingHours: Int {
        get { d.object(forKey: "checkfit.fastingHours") as? Int ?? 16 }
        set { d.set(newValue, forKey: "checkfit.fastingHours") }
    }

    /// 완료된 단식 기록(종료 시각 + 실제 단식 시간).
    var fastingRecords: [FastingRecord] {
        get { d.data(forKey: "checkfit.fastingRecords").flatMap { try? JSONDecoder().decode([FastingRecord].self, from: $0) } ?? [] }
        set { d.set(try? JSONEncoder().encode(newValue), forKey: "checkfit.fastingRecords"); d.synchronize() }
    }

    /// 단식 종료 시 호출 — 실제 경과 시간을 기록한다.
    func endFasting(start: Date, end: Date = Date()) {
        let hours = end.timeIntervalSince(start) / 3600
        fastingStart = nil
        guard hours > 0 else { return }
        var all = fastingRecords
        all.append(FastingRecord(end: end, hours: hours))
        fastingRecords = all
    }

    /// [from, to) 구간의 단식 시간 합(시간). 진행 중인 단식은 현재까지 경과분을 포함한다.
    func totalFastingHours(from: Date, to: Date) -> Double {
        var sum = fastingRecords
            .filter { $0.end >= from && $0.end < to }
            .reduce(0.0) { $0 + $1.hours }
        if let start = fastingStart {
            let now = Date()
            if now >= from && now < to {
                sum += max(0, now.timeIntervalSince(start) / 3600)
            }
        }
        return sum
    }

    // MARK: - 식단 (날짜·끼니별 음식 기록)

    private var allDietEntries: [DietEntry] {
        get { d.data(forKey: "checkfit.dietEntries").flatMap { try? JSONDecoder().decode([DietEntry].self, from: $0) } ?? [] }
        set { d.set(try? JSONEncoder().encode(newValue), forKey: "checkfit.dietEntries"); d.synchronize() }
    }

    /// 음식 한 가지를 해당 날짜·끼니에 기록한다.
    func addDietEntry(date: Date, meal: String, name: String, kcal: Double, carb: Double, protein: Double, fat: Double) {
        var all = allDietEntries
        all.append(DietEntry(day: dayKey(date), meal: meal, name: name, kcal: kcal, carb: carb, protein: protein, fat: fat))
        allDietEntries = all
    }

    func dietEntries(for date: Date) -> [DietEntry] {
        allDietEntries.filter { $0.day == dayKey(date) }
    }

    func dietEntries(for date: Date, meal: String) -> [DietEntry] {
        dietEntries(for: date).filter { $0.meal == meal }
    }

    /// 해당 날짜·끼니의 합산 열량(kcal).
    func mealKcal(_ date: Date, _ meal: String) -> Int {
        Int(dietEntries(for: date, meal: meal).reduce(0) { $0 + $1.kcal })
    }

    /// 해당 날짜의 식단 누적 합계.
    func dietTotals(_ date: Date) -> (kcal: Int, carb: Double, protein: Double, fat: Double) {
        let entries = dietEntries(for: date)
        return (Int(entries.reduce(0) { $0 + $1.kcal }),
                entries.reduce(0) { $0 + $1.carb },
                entries.reduce(0) { $0 + $1.protein },
                entries.reduce(0) { $0 + $1.fat })
    }

    // MARK: - 운동 (날짜별 운동 기록)

    private var allExerciseEntries: [ExerciseEntry] {
        get { d.data(forKey: "checkfit.exerciseEntries").flatMap { try? JSONDecoder().decode([ExerciseEntry].self, from: $0) } ?? [] }
        set { d.set(try? JSONEncoder().encode(newValue), forKey: "checkfit.exerciseEntries"); d.synchronize() }
    }

    /// 운동 한 건을 해당 날짜에 기록한다.
    func addExercise(date: Date, name: String, minutes: Int, kcal: Int, intensity: Int, time: Date = Date()) {
        var all = allExerciseEntries
        all.append(ExerciseEntry(day: dayKey(date), name: name, minutes: minutes, kcal: kcal, intensity: intensity, time: time))
        allExerciseEntries = all
        markRecordedToday()
    }

    /// 해당 날짜의 운동 기록 목록 (입력 순).
    func exerciseEntries(for date: Date) -> [ExerciseEntry] {
        allExerciseEntries.filter { $0.day == dayKey(date) }
    }

    /// 해당 날짜의 N번째 운동 기록을 삭제한다.
    func deleteExerciseEntry(date: Date, indexInDay: Int) {
        var all = allExerciseEntries
        let key = dayKey(date)
        let dayIndices = all.indices.filter { all[$0].day == key }
        guard dayIndices.indices.contains(indexInDay) else { return }
        all.remove(at: dayIndices[indexInDay])
        allExerciseEntries = all
    }

    /// 해당 날짜의 N번째 운동 기록을 새 값으로 교체한다.
    func updateExerciseEntry(date: Date, indexInDay: Int, name: String, minutes: Int, kcal: Int, intensity: Int, time: Date) {
        var all = allExerciseEntries
        let key = dayKey(date)
        let dayIndices = all.indices.filter { all[$0].day == key }
        guard dayIndices.indices.contains(indexInDay) else { return }
        all[dayIndices[indexInDay]] = ExerciseEntry(day: key, name: name, minutes: minutes, kcal: kcal, intensity: intensity, time: time)
        allExerciseEntries = all
    }
    /// 해당 날짜의 누적 운동 시간(분). 기록 없으면 0.
    func exerciseMinutes(for date: Date) -> Int { exerciseEntries(for: date).reduce(0) { $0 + $1.minutes } }
    /// 해당 날짜의 누적 운동 소모 칼로리(kcal). 기록 없으면 0.
    func exerciseKcal(for date: Date) -> Int { exerciseEntries(for: date).reduce(0) { $0 + $1.kcal } }
    /// 전체 기간 누적 운동 시간(분).
    var totalExerciseMinutes: Int { allExerciseEntries.reduce(0) { $0 + $1.minutes } }
    /// 운동을 기록한 날의 수.
    var exerciseDayCount: Int { Set(allExerciseEntries.filter { $0.minutes > 0 || $0.kcal > 0 }.map { $0.day }).count }
    /// 해당 날짜가 속한 주(월~일)에 운동을 기록한 날의 수.
    func exerciseDaysInWeek(of date: Date) -> Int {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date)
        let start = cal.date(byAdding: .day, value: -(weekday - 1), to: cal.startOfDay(for: date)) ?? date
        let keys = (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start).map { dayKey($0) } }
        let recorded = Set(allExerciseEntries.filter { $0.minutes > 0 || $0.kcal > 0 }.map { $0.day })
        return keys.filter { recorded.contains($0) }.count
    }

    // MARK: - 연속 기록 (체중·운동·수분 중 하나라도 입력한 날을 기록)

    private var recordedDays: [String] {
        get { d.stringArray(forKey: "checkfit.recordedDays") ?? [] }
        set { d.set(newValue, forKey: "checkfit.recordedDays") }
    }

    private func dayKey(_ date: Date) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    /// 해당 날짜를 기록한 날로 표시한다.
    func markRecorded(_ date: Date) {
        let key = dayKey(date)
        var days = recordedDays
        guard !days.contains(key) else { return }
        days.append(key)
        recordedDays = days
    }

    /// 오늘을 기록한 날로 표시한다 (체중·운동·수분 입력 시 호출).
    func markRecordedToday() { markRecorded(Date()) }

    func isRecorded(_ date: Date) -> Bool {
        recordedDays.contains(dayKey(date))
    }

    // MARK: - 코인 (미션 보상 / 상점)

    var coins: Int {
        get { d.object(forKey: "checkfit.coins") as? Int ?? 0 }
        set { d.set(newValue, forKey: "checkfit.coins") }
    }

    // MARK: - 미션 (날짜별 보상 수령 여부)

    private var claimedMissions: [String: [String]] {
        get { (d.dictionary(forKey: "checkfit.claimedMissions") as? [String: [String]]) ?? [:] }
        set { d.set(newValue, forKey: "checkfit.claimedMissions") }
    }
    /// 해당 날짜에 그 미션 보상을 이미 받았는지.
    func isMissionClaimed(_ id: String, date: Date = Date()) -> Bool {
        (claimedMissions[dayKey(date)] ?? []).contains(id)
    }
    /// 지금까지 수령한(완료한) 미션의 총 개수.
    var totalClaimedMissions: Int { claimedMissions.values.reduce(0) { $0 + $1.count } }

    /// 해당 날짜의 미션 보상 수령을 기록한다.
    func claimMission(_ id: String, date: Date = Date()) {
        var all = claimedMissions
        let key = dayKey(date)
        var ids = all[key] ?? []
        guard !ids.contains(id) else { return }
        ids.append(id)
        all[key] = ids
        claimedMissions = all
    }

    /// 현재 연속 기록 바로 앞에서 하루만 끊긴 날(있으면 그 날짜).
    /// 그 끊긴 날 이전에도 기록이 있어야(= 되살릴 연속 기록이 존재) 반환한다.
    var streakGapDay: Date? {
        let calendar = Calendar.current
        var day = calendar.startOfDay(for: Date())
        if !isRecorded(day) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day) else { return nil }
            day = yesterday
        }
        guard isRecorded(day) else { return nil }   // 이어줄 현재 연속 기록이 없음
        while isRecorded(day) {
            guard let prev = calendar.date(byAdding: .day, value: -1, to: day) else { return nil }
            if !isRecorded(prev) {
                guard let beforeGap = calendar.date(byAdding: .day, value: -1, to: prev) else { return nil }
                return isRecorded(beforeGap) ? prev : nil
            }
            day = prev
        }
        return nil
    }

    /// 끊긴 하루를 메워 연속 기록을 이어준다. 성공 시 true.
    @discardableResult
    func bridgeStreak() -> Bool {
        guard let gap = streakGapDay else { return false }
        markRecorded(gap)
        return true
    }

    /// 오늘(미기록 시 어제)부터 거꾸로 세어 연속으로 기록한 일수.
    var currentStreak: Int {
        let calendar = Calendar.current
        var day = calendar.startOfDay(for: Date())
        if !isRecorded(day) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day) else { return 0 }
            day = yesterday
        }
        var count = 0
        while isRecorded(day) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return count
    }
}

/// 닉네임·프로필 사진을 저장하는 사용자 프로필 저장소.
final class ProfileStore {
    static let shared = ProfileStore()
    private let d = UserDefaults.standard
    private init() {}

    var nickname: String {
        get { d.string(forKey: "checkfit.nickname") ?? "고먐미" }
        set { d.set(newValue, forKey: "checkfit.nickname") }
    }
    var avatarImageData: Data? {
        get { d.data(forKey: "checkfit.avatar") }
        set { d.set(newValue, forKey: "checkfit.avatar") }
    }
    var avatarImage: UIImage? { avatarImageData.flatMap { UIImage(data: $0) } }

    /// 내 정보 수정에서 남기는 한 줄 메모. 홈 프로필을 누르면 보여준다.
    var memo: String {
        get { d.string(forKey: "checkfit.memo") ?? "" }
        set { d.set(newValue, forKey: "checkfit.memo") }
    }
}

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
        return "\(calendar.component(.month, from: date)) . \(calendar.component(.day, from: date))"
    }

    private static func weekday(_ date: Date) -> String {
        let index = Calendar.current.component(.weekday, from: date) - 1
        return weekdays[max(0, min(index, weekdays.count - 1))]
    }
}

extension UIView {
    /// 시트(아래에서 올라오는 카드) 상단 중앙에 회색 손잡이(그래버)를 추가한다.
    @discardableResult
    func addSheetGrabber(topInset: CGFloat = 8) -> UIView {
        let grabber = UIView()
        grabber.backgroundColor = UIColor(white: 0.82, alpha: 1)
        grabber.layer.cornerRadius = 2.5
        grabber.translatesAutoresizingMaskIntoConstraints = false
        addSubview(grabber)
        NSLayoutConstraint.activate([
            grabber.topAnchor.constraint(equalTo: topAnchor, constant: topInset),
            grabber.centerXAnchor.constraint(equalTo: centerXAnchor),
            grabber.widthAnchor.constraint(equalToConstant: 40),
            grabber.heightAnchor.constraint(equalToConstant: 5)
        ])
        return grabber
    }

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

/// 좌우/상하 여백을 가진 라벨 (태그·칩에 사용).
/// 대각선 그라데이션 배경을 가진 둥근 카드.
final class GradientCardView: UIView {
    private let gradient = CAGradientLayer()

    init(colors: [UIColor], radius: CGFloat = 24) {
        super.init(frame: .zero)
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.cornerRadius = radius
        layer.insertSublayer(gradient, at: 0)
        layer.cornerRadius = radius
        clipsToBounds = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
}

/// 포커스(클릭) 시 안내문이 사라지는 입력용 텍스트뷰.
final class PlaceholderTextView: UITextView {
    private let placeholderLabel = UILabel()

    var placeholder: String = "" {
        didSet { placeholderLabel.text = placeholder; setNeedsLayout() }
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textColor = AppTheme.muted
        placeholderLabel.font = AppTheme.font(15, .semibold)
        addSubview(placeholderLabel)
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(refreshPlaceholder), name: UITextView.textDidChangeNotification, object: self)
        center.addObserver(self, selector: #selector(refreshPlaceholder), name: UITextView.textDidBeginEditingNotification, object: self)
        center.addObserver(self, selector: #selector(refreshPlaceholder), name: UITextView.textDidEndEditingNotification, object: self)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func refreshPlaceholder() {
        placeholderLabel.isHidden = isFirstResponder || !text.isEmpty
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let x = textContainerInset.left + textContainer.lineFragmentPadding
        let width = bounds.width - x - textContainerInset.right - textContainer.lineFragmentPadding
        placeholderLabel.frame = CGRect(x: x, y: textContainerInset.top, width: max(0, width), height: 0)
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: x, y: textContainerInset.top)
    }
}

/// 말풍선 꼬리로 쓰는 위쪽을 가리키는 삼각형.
final class TriangleView: UIView {
    var color: UIColor = .white { didSet { setNeedsDisplay() } }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.close()
        color.setFill()
        path.fill()
    }
}

final class PaddingLabel: UILabel {
    var insets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
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

/// SF Symbols에 외곽선 사과가 없어서 직접 그린 사과 테두리 이미지.
func appleOutlineImage(size: CGFloat, color: UIColor, lineWidth: CGFloat) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
    return renderer.image { _ in
        color.setStroke()
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * size, y: y * size) }

        let body = UIBezierPath()
        body.move(to: p(0.50, 0.36))
        body.addCurve(to: p(0.16, 0.46), controlPoint1: p(0.41, 0.22), controlPoint2: p(0.19, 0.24))
        body.addCurve(to: p(0.34, 0.90), controlPoint1: p(0.13, 0.63), controlPoint2: p(0.20, 0.83))
        body.addCurve(to: p(0.50, 0.88), controlPoint1: p(0.41, 0.94), controlPoint2: p(0.46, 0.90))
        body.addCurve(to: p(0.66, 0.90), controlPoint1: p(0.54, 0.90), controlPoint2: p(0.59, 0.94))
        body.addCurve(to: p(0.84, 0.46), controlPoint1: p(0.80, 0.83), controlPoint2: p(0.87, 0.63))
        body.addCurve(to: p(0.50, 0.36), controlPoint1: p(0.81, 0.24), controlPoint2: p(0.59, 0.22))
        body.close()
        body.lineWidth = lineWidth
        body.lineJoinStyle = .round
        body.lineCapStyle = .round
        body.stroke()

        let stem = UIBezierPath()
        stem.move(to: p(0.52, 0.34))
        stem.addCurve(to: p(0.62, 0.13), controlPoint1: p(0.54, 0.24), controlPoint2: p(0.58, 0.17))
        stem.lineWidth = lineWidth
        stem.lineCapStyle = .round
        stem.stroke()

        let leaf = UIBezierPath()
        leaf.move(to: p(0.62, 0.17))
        leaf.addCurve(to: p(0.82, 0.15), controlPoint1: p(0.68, 0.08), controlPoint2: p(0.79, 0.07))
        leaf.addCurve(to: p(0.62, 0.17), controlPoint1: p(0.83, 0.24), controlPoint2: p(0.71, 0.24))
        leaf.close()
        leaf.lineWidth = lineWidth
        leaf.lineJoinStyle = .round
        leaf.stroke()
    }
}

/// 색이 채워진 사과 이미지 (빨간 몸통 + 초록 잎 + 갈색 줄기).
func appleFilledImage(size: CGFloat, color: UIColor = .systemRed) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
    return renderer.image { _ in
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * size, y: y * size) }

        let body = UIBezierPath()
        body.move(to: p(0.50, 0.36))
        body.addCurve(to: p(0.16, 0.46), controlPoint1: p(0.41, 0.22), controlPoint2: p(0.19, 0.24))
        body.addCurve(to: p(0.34, 0.90), controlPoint1: p(0.13, 0.63), controlPoint2: p(0.20, 0.83))
        body.addCurve(to: p(0.50, 0.88), controlPoint1: p(0.41, 0.94), controlPoint2: p(0.46, 0.90))
        body.addCurve(to: p(0.66, 0.90), controlPoint1: p(0.54, 0.90), controlPoint2: p(0.59, 0.94))
        body.addCurve(to: p(0.84, 0.46), controlPoint1: p(0.80, 0.83), controlPoint2: p(0.87, 0.63))
        body.addCurve(to: p(0.50, 0.36), controlPoint1: p(0.81, 0.24), controlPoint2: p(0.59, 0.22))
        body.close()
        color.setFill()
        body.fill()

        let stem = UIBezierPath()
        stem.move(to: p(0.52, 0.34))
        stem.addCurve(to: p(0.62, 0.13), controlPoint1: p(0.54, 0.24), controlPoint2: p(0.58, 0.17))
        stem.lineWidth = size * 0.05
        stem.lineCapStyle = .round
        UIColor(red: 0.45, green: 0.32, blue: 0.20, alpha: 1).setStroke()
        stem.stroke()

        let leaf = UIBezierPath()
        leaf.move(to: p(0.62, 0.17))
        leaf.addCurve(to: p(0.82, 0.15), controlPoint1: p(0.68, 0.08), controlPoint2: p(0.79, 0.07))
        leaf.addCurve(to: p(0.62, 0.17), controlPoint1: p(0.83, 0.24), controlPoint2: p(0.71, 0.24))
        leaf.close()
        UIColor.systemGreen.setFill()
        leaf.fill()
    }
}

func avatar(size: CGFloat) -> UIView {
    let view = UIView()
    view.backgroundColor = UIColor(red: 0.56, green: 0.82, blue: 0.66, alpha: 1)
    view.layer.cornerRadius = size / 2
    view.clipsToBounds = true
    view.layer.borderWidth = size > 60 ? 3 : 2
    view.layer.borderColor = UIColor.white.cgColor
    view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        view.widthAnchor.constraint(equalToConstant: size),
        view.heightAnchor.constraint(equalToConstant: size)
    ])

    if let image = ProfileStore.shared.avatarImage {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    } else {
        let face = UILabel("🐱", size: size * 0.43, weight: .regular)
        face.textAlignment = .center
        face.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(face)
        NSLayoutConstraint.activate([
            face.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            face.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 다른 화면에 갔다가 돌아오면 항상 상단부터 보이도록 스크롤을 초기화
        scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.adjustedContentInset.top), animated: false)
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
