//
//  MetricChartViews.swift
//  CheckFit
//
//  지표 차트/그리기 뷰 (수분·체중·운동 차트, 물방울, 점선)
//

import UIKit

private extension UIBezierPath {
    func fill(with color: UIColor) {
        color.setFill()
        fill()
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
    var latestValue: CGFloat? { didSet { setNeedsDisplay() } }
    /// 0: 체중, 1: 골격근량, 2: 체지방률
    var metricIndex: Int = 0 { didSet { setNeedsDisplay() } }

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
        var values = metricValues()
        let labels: [String]

        switch mode {
        case .daily:
            labels = dailyLabels()
        case .weekly:
            labels = weeklyLabels()
        case .monthly:
            labels = monthlyLabels()
        }

        if let latest = latestValue, !values.isEmpty {
            values[values.count - 1] = latest
        }

        let maxValue = ceil((values.max() ?? 1) + 0.5)
        let minValue = floor((values.min() ?? 0) - 0.5)
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

    // MARK: - x축 날짜 라벨 (오늘 기준으로 생성)

    private func dailyLabels() -> [String] {
        let cal = Calendar.current
        let today = Date()
        let yesterday = cal.date(byAdding: .day, value: -1, to: today) ?? today
        return [monthDayFull(yesterday), monthDayFull(today)]
    }

    private func weeklyLabels() -> [String] {
        [weekStartTag(-3), weekStartTag(-2), weekStartTag(-1), "이번주"]
    }

    private func monthlyLabels() -> [String] {
        let cal = Calendar.current
        return (-3...0).map { offset in
            let d = cal.date(byAdding: .month, value: offset, to: Date()) ?? Date()
            return "\(cal.component(.month, from: d))월"
        }
    }

    private func monthDayFull(_ date: Date) -> String {
        let cal = Calendar.current
        return "\(cal.component(.month, from: date))월 \(cal.component(.day, from: date))일"
    }

    private func weekStartTag(_ weekOffset: Int) -> String {
        let cal = Calendar.current
        let shifted = cal.date(byAdding: .weekOfYear, value: weekOffset, to: Date()) ?? Date()
        let weekday = cal.component(.weekday, from: shifted)
        let monday = cal.date(byAdding: .day, value: -((weekday + 5) % 7), to: cal.startOfDay(for: shifted)) ?? shifted
        return "\(cal.component(.month, from: monday)).\(cal.component(.day, from: monday))"
    }

    private func metricValues() -> [CGFloat] {
        switch (metricIndex, mode) {
        case (1, .daily):   return [19.9, 20.2]
        case (1, .weekly):  return [19.4, 19.6, 19.9, 20.2]
        case (1, .monthly): return [19.0, 19.4, 19.8, 20.2]
        case (2, .daily):   return [24.6, 23.9]
        case (2, .weekly):  return [25.2, 24.8, 24.3, 23.9]
        case (2, .monthly): return [26.1, 25.3, 24.6, 23.9]
        case (_, .daily):   return [45.6, 43.7]
        case (_, .weekly):  return [46.1, 45.4, 44.6, 43.7]
        case (_, .monthly): return [46.0, 45.2, 44.4, 43.7]
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

/// 아이폰 기본 캘린더 UI로 날짜를 선택하는 시트.
final class DashedLineView: UIView {
    var color: UIColor = .systemOrange { didSet { setNeedsDisplay() } }
    var lineWidth: CGFloat = 2
    var isVertical = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        if isVertical {
            path.move(to: CGPoint(x: rect.midX, y: 0))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.height))
        } else {
            path.move(to: CGPoint(x: 0, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        }
        path.lineWidth = lineWidth
        path.setLineDash([4, 4], count: 2, phase: 0)
        color.setStroke()
        path.stroke()
    }
}

/// 단식 시작 버튼을 누르면 올라오는 시트. 시작 시간을 고르고 확인한다.
final class ExerciseStatsChartView: UIView {
    enum Metric { case time, calorie }
    enum Mode: Int { case daily, weekly, monthly }

    var metric: Metric = .time { didSet { setNeedsDisplay() } }
    var mode: Mode = .daily { didSet { setNeedsDisplay() } }
    var date = Date() { didSet { setNeedsDisplay() } }

    private let barColor = AppTheme.brand
    private let dashColor = UIColor(red: 1.0, green: 0.55, blue: 0.26, alpha: 1)
    private let axisColor = UIColor(red: 0.78, green: 0.80, blue: 0.84, alpha: 1)
    private let lineColor = UIColor(red: 0.92, green: 0.94, blue: 0.97, alpha: 1)
    private let weekdaySymbols = ["일", "월", "화", "수", "목", "금", "토"]

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        isOpaque = false
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private struct Bucket { let label: String; let value: Int }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let (buckets, selectedIndex) = makeBuckets()

        let left: CGFloat = 18
        let right: CGFloat = rect.width - 44
        let top: CGFloat = 56
        let bottom: CGFloat = rect.height - 46
        // 마지막 막대가 우측 y축 숫자를 가리지 않도록 막대 영역을 눈금선보다 안쪽에서 끝낸다.
        let dataRight = right - 24
        let dataWidth = dataRight - left
        let baseline = metric == .time ? 10 : 200
        let rawMax = buckets.map { $0.value }.max() ?? 0
        let maxValue = CGFloat(max(baseline, Int((ceil(Double(rawMax) / Double(baseline))) * Double(baseline))))

        drawGrid(context: context, left: left, right: right, top: top, bottom: bottom, maxValue: maxValue)

        let xStep = dataWidth / CGFloat(max(1, buckets.count - 1))
        let barWidth: CGFloat = mode == .monthly ? 16 : (mode == .weekly ? 28 : 26)

        for (index, bucket) in buckets.enumerated() where bucket.value > 0 {
            let height = bottom - yPosition(for: CGFloat(bucket.value), maxValue: maxValue, top: top, bottom: bottom)
            let centerX = left + CGFloat(index) * xStep
            let alpha: CGFloat = index == selectedIndex ? 1.0 : 0.28
            let barRect = CGRect(x: centerX - barWidth / 2, y: bottom - height, width: barWidth, height: max(6, height))
            UIBezierPath(roundedRect: barRect, cornerRadius: 6).fill(with: barColor.withAlphaComponent(alpha))
        }

        let selectedCenterX = left + CGFloat(selectedIndex) * xStep
        let selectedValue = buckets[selectedIndex].value
        let barTop = bottom - (bottom - yPosition(for: CGFloat(selectedValue), maxValue: maxValue, top: top, bottom: bottom))
        drawBubble(centerX: selectedCenterX, pointerEndY: max(top + 4, barTop), chartTop: top, maxRight: right, value: selectedValue)
        drawXAxisLabels(buckets: buckets, selectedIndex: selectedIndex, left: left, bottom: bottom, xStep: xStep)
    }

    private func makeBuckets() -> ([Bucket], Int) {
        let cal = Calendar.current
        let store = HealthStore.shared
        func dayValue(_ d: Date) -> Int { metric == .time ? store.exerciseMinutes(for: d) : store.exerciseKcal(for: d) }

        switch mode {
        case .daily:
            let weekday = cal.component(.weekday, from: date)
            let start = cal.date(byAdding: .day, value: -(weekday - 1), to: cal.startOfDay(for: date)) ?? date
            let buckets = (0..<7).map { i -> Bucket in
                let day = cal.date(byAdding: .day, value: i, to: start) ?? start
                return Bucket(label: weekdaySymbols[i], value: dayValue(day))
            }
            return (buckets, weekday - 1)
        case .weekly:
            let count = 4
            let buckets = (0..<count).map { i -> Bucket in
                let offset = -(count - 1 - i)
                let weekDate = cal.date(byAdding: .weekOfYear, value: offset, to: date) ?? date
                let sow = startOfWeek(weekDate)
                let sum = (0..<7).reduce(0) { acc, d in acc + dayValue(cal.date(byAdding: .day, value: d, to: sow) ?? sow) }
                let label = offset == 0 ? "이번주" : "\(-offset)주 전"
                return Bucket(label: label, value: sum)
            }
            return (buckets, count - 1)
        case .monthly:
            let count = 6
            let buckets = (0..<count).map { i -> Bucket in
                let offset = -(count - 1 - i)
                let monthDate = cal.date(byAdding: .month, value: offset, to: date) ?? date
                let sum = monthSum(monthDate, value: dayValue)
                let month = cal.component(.month, from: monthDate)
                return Bucket(label: "\(month)월", value: sum)
            }
            return (buckets, count - 1)
        }
    }

    private func monthSum(_ date: Date, value: (Date) -> Int) -> Int {
        let cal = Calendar.current
        guard let range = cal.range(of: .day, in: .month, for: date),
              let first = cal.date(from: cal.dateComponents([.year, .month], from: date)) else { return 0 }
        return range.reduce(0) { acc, day in
            let d = cal.date(byAdding: .day, value: day - 1, to: first) ?? first
            return acc + value(d)
        }
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
        drawText(formatAxis(maxValue), in: CGRect(x: right + 8, y: top - 11, width: 40, height: 22), size: 12, weight: .bold, color: axisColor)
        drawText(formatAxis(maxValue / 2), in: CGRect(x: right + 8, y: (top + bottom) / 2 - 11, width: 40, height: 22), size: 12, weight: .bold, color: axisColor)
        drawText("0", in: CGRect(x: right + 8, y: bottom - 11, width: 40, height: 22), size: 12, weight: .bold, color: axisColor)
    }

    private func drawBubble(centerX: CGFloat, pointerEndY: CGFloat, chartTop: CGFloat, maxRight: CGFloat, value: Int) {
        let bubbleWidth: CGFloat = 78
        let bubbleHeight: CGFloat = 48
        let bubbleX = min(max(centerX - bubbleWidth / 2, 0), maxRight - bubbleWidth + 8)
        let bubbleY = max(chartTop - 50, pointerEndY - 92)
        let bubble = CGRect(x: bubbleX, y: bubbleY, width: bubbleWidth, height: bubbleHeight)

        let dashPath = UIBezierPath()
        dashPath.move(to: CGPoint(x: centerX, y: bubble.maxY))
        dashPath.addLine(to: CGPoint(x: centerX, y: pointerEndY))
        dashColor.setStroke()
        dashPath.lineWidth = 2
        dashPath.setLineDash([5, 5], count: 2, phase: 0)
        dashPath.stroke()

        let bubblePath = UIBezierPath(roundedRect: bubble, cornerRadius: 14)
        UIColor(red: 0.07, green: 0.09, blue: 0.13, alpha: 1).setFill()
        bubblePath.fill()

        let valueText = metric == .time ? "\(value)분" : "\(value)kcal"
        drawText(valueText, in: CGRect(x: bubble.minX, y: bubble.minY + 7, width: bubble.width, height: 20), size: 15, weight: .black, color: .white, alignment: .center)
        drawText(bubbleSubtitle, in: CGRect(x: bubble.minX, y: bubble.minY + 27, width: bubble.width, height: 16), size: 11, weight: .bold, color: UIColor.white.withAlphaComponent(0.72), alignment: .center)
    }

    private var bubbleSubtitle: String {
        let cal = Calendar.current
        switch mode {
        case .daily:
            return "\(cal.component(.month, from: date)).\(cal.component(.day, from: date))"
        case .weekly:
            let sow = startOfWeek(date)
            let eow = cal.date(byAdding: .day, value: 6, to: sow) ?? date
            return "\(cal.component(.month, from: sow)).\(cal.component(.day, from: sow))-\(cal.component(.month, from: eow)).\(cal.component(.day, from: eow))"
        case .monthly:
            return "\(cal.component(.year, from: date) % 100)년 \(cal.component(.month, from: date))월"
        }
    }

    private func drawXAxisLabels(buckets: [Bucket], selectedIndex: Int, left: CGFloat, bottom: CGFloat, xStep: CGFloat) {
        for (index, bucket) in buckets.enumerated() {
            let x = left + CGFloat(index) * xStep
            let selected = index == selectedIndex
            let width: CGFloat = 44
            let labelX = min(max(x - width / 2, 0), bounds.width - width)
            let labelRect = CGRect(x: labelX, y: bottom + 12, width: width, height: 22)
            drawText(bucket.label, in: labelRect, size: 12, weight: selected ? .black : .bold, color: selected ? AppTheme.text : axisColor, alignment: .center)
        }
    }

    private func startOfWeek(_ date: Date) -> Date {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date)
        return cal.date(byAdding: .day, value: -(weekday - 1), to: cal.startOfDay(for: date)) ?? date
    }

    private func yPosition(for value: CGFloat, maxValue: CGFloat, top: CGFloat, bottom: CGFloat) -> CGFloat {
        bottom - ((min(value, maxValue) / maxValue) * (bottom - top))
    }

    private func formatAxis(_ value: CGFloat) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: Double(value))) ?? "\(Int(value))"
    }

    private func drawText(_ text: String, in rect: CGRect, size: CGFloat, weight: UIFont.Weight, color: UIColor, alignment: NSTextAlignment = .left) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = alignment
        (text as NSString).draw(in: rect, withAttributes: [
            .font: AppTheme.font(size, weight),
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ])
    }
}

// MARK: - 운동 기록 상세

/// 검색 목록에서 운동을 골라 '기록하기'를 누르면 나오는 상세 기록 화면.
/// 운동 종류에 맞춰 세트별 입력 칼럼(거리/시간·무게/횟수 등)을 자동 구성한다.
