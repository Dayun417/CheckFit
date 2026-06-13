//
//  MissionViewController.swift
//  CheckFit
//

import UIKit

final class MissionViewController: BaseScreenViewController {
    private var points: Int {
        get { HealthStore.shared.coins }
        set { HealthStore.shared.coins = newValue }
    }
    private weak var pointsLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        build()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        build()
    }

    private func pointsAttributedText() -> NSAttributedString {
        let formatted = NumberFormatter.localizedString(from: NSNumber(value: points), number: .decimal)
        let string = "● \(formatted)"
        let text = NSMutableAttributedString(
            string: string,
            attributes: [.font: AppTheme.font(20, .black), .foregroundColor: AppTheme.text]
        )
        text.addAttribute(.foregroundColor, value: UIColor.systemYellow, range: (string as NSString).range(of: "●"))
        return text
    }

    private func addPoints(_ amount: Int, from sourceView: UIView? = nil) {
        points += amount
        pointsLabel?.attributedText = pointsAttributedText()
        if let sourceView { flyCoin(amount: amount, from: sourceView) }
        pulsePoints()
    }

    /// 획득한 코인이 상단 점수 쪽으로 날아가며 사라지는 애니메이션.
    private func flyCoin(amount: Int, from sourceView: UIView) {
        guard let target = pointsLabel else { return }
        let label = UILabel()
        let str = "● +\(amount)"
        let attr = NSMutableAttributedString(string: str, attributes: [
            .font: AppTheme.font(18, .black), .foregroundColor: AppTheme.text
        ])
        attr.addAttribute(.foregroundColor, value: UIColor.systemYellow, range: (str as NSString).range(of: "●"))
        label.attributedText = attr
        label.sizeToFit()
        let start = sourceView.convert(CGPoint(x: sourceView.bounds.midX, y: sourceView.bounds.midY), to: view)
        let end = target.convert(CGPoint(x: target.bounds.midX, y: target.bounds.midY), to: view)
        label.center = start
        view.addSubview(label)
        UIView.animate(withDuration: 0.1, animations: {
            label.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }) { _ in
            UIView.animate(withDuration: 0.55, delay: 0.05, options: [.curveEaseIn], animations: {
                label.center = end
                label.alpha = 0
                label.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }, completion: { _ in label.removeFromSuperview() })
        }
    }

    /// 점수 캡슐을 살짝 튕겨 코인이 더해졌음을 강조한다.
    private func pulsePoints() {
        guard let pill = pointsLabel?.superview else { return }
        UIView.animate(withDuration: 0.45, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: [], animations: {
            pill.transform = CGAffineTransform(scaleX: 1.12, y: 1.12)
        }) { _ in
            UIView.animate(withDuration: 0.2) { pill.transform = .identity }
        }
    }

    private func build() {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        stackView.addArrangedSubview(header())
        let body = paddedStack(spacing: 16, insets: UIEdgeInsets(top: 26, left: 24, bottom: 122, right: 24))

        let store = HealthStore.shared
        let streak = store.currentStreak
        let exKcal = store.exerciseKcal(for: Date())
        let mealLogged = !store.dietEntries(for: Date()).isEmpty
        let water = store.waterAmount

        body.addArrangedSubview(mission(id: "streak", symbol: "bolt", color: .systemOrange, caption: "연속 기록", title: "5일 달성하기", reward: "5", achieved: streak >= 5, progress: min(1, Float(streak) / 5)))
        body.addArrangedSubview(mission(id: "meal", symbol: "fork.knife", color: .systemOrange, caption: "오늘 먹은", title: "식사 기록하기", reward: "5", achieved: mealLogged, progress: nil))
        body.addArrangedSubview(mission(id: "move", symbol: "flame", color: .systemOrange, caption: "\(exKcal)/200 kcal", title: "움직이기", reward: "5", achieved: exKcal >= 200, progress: nil))
        body.addArrangedSubview(mission(id: "water", symbol: "drop", color: .systemBlue, caption: "하루 1L 이상", title: "물 마시기", reward: "3", achieved: water >= 1000, progress: nil))
        stackView.addArrangedSubview(body)
    }

    private func header() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .equalSpacing
        row.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(row)
        row.addArrangedSubview(UILabel("미션", size: 30, weight: .black, color: AppTheme.text, lines: 1))

        let pointsLabel = UILabel("● 1,250", size: 20, weight: .black, color: AppTheme.text, lines: 1)
        pointsLabel.attributedText = pointsAttributedText()
        self.pointsLabel = pointsLabel
        pointsLabel.translatesAutoresizingMaskIntoConstraints = false
        let pointsPill = UIView()
        pointsPill.backgroundColor = AppTheme.softFill
        pointsPill.layer.cornerRadius = 26
        pointsPill.translatesAutoresizingMaskIntoConstraints = false
        pointsPill.addSubview(pointsLabel)
        NSLayoutConstraint.activate([
            pointsPill.heightAnchor.constraint(equalToConstant: 52),
            pointsLabel.leadingAnchor.constraint(equalTo: pointsPill.leadingAnchor, constant: 22),
            pointsLabel.trailingAnchor.constraint(equalTo: pointsPill.trailingAnchor, constant: -22),
            pointsLabel.centerYAnchor.constraint(equalTo: pointsPill.centerYAnchor)
        ])
        let shopButton = UIButton(type: .system)
        shopButton.setImage(UIImage(systemName: "bag", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)), for: .normal)
        shopButton.tintColor = AppTheme.text
        shopButton.backgroundColor = AppTheme.softFill
        shopButton.layer.cornerRadius = 26
        shopButton.translatesAutoresizingMaskIntoConstraints = false
        shopButton.addAction(UIAction { [weak self] _ in self?.presentShop() }, for: .touchUpInside)
        NSLayoutConstraint.activate([
            shopButton.widthAnchor.constraint(equalToConstant: 52),
            shopButton.heightAnchor.constraint(equalToConstant: 52)
        ])

        let trailing = UIStackView(arrangedSubviews: [pointsPill, shopButton])
        trailing.axis = .horizontal
        trailing.alignment = .center
        trailing.spacing = 10
        row.addArrangedSubview(trailing)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            row.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            row.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            row.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24)
        ])
        return view
    }

    private func mission(id: String, symbol: String, color: UIColor, caption: String, title: String, reward: String, achieved: Bool, progress: Float?) -> UIView {
        let done = HealthStore.shared.isMissionClaimed(id)
        let card = UIView()
        card.applyCard(radius: 28)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 116).isActive = true

        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 16
        row.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(row)
        row.addArrangedSubview(symbolTile(symbol: symbol, color: color, size: 58, corner: 20))

        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 5
        textStack.addArrangedSubview(UILabel(caption, size: 14, weight: .black, color: AppTheme.muted, lines: 1))
        textStack.addArrangedSubview(UILabel(title, size: 19, weight: .black, color: AppTheme.text, lines: 1))
        if let progress {
            let bar = UIProgressView(progressViewStyle: .bar)
            bar.progress = progress
            bar.progressTintColor = AppTheme.brand
            bar.trackTintColor = AppTheme.softFill
            textStack.addArrangedSubview(bar)
        }
        row.addArrangedSubview(textStack)
        row.addArrangedSubview(UIView())
        let rewardPill = makePill("● \(reward)", foreground: AppTheme.text, background: AppTheme.softFill, fontSize: 16)
        let rewardText = NSMutableAttributedString(
            string: "● \(reward)",
            attributes: [.font: AppTheme.font(16, .black), .foregroundColor: AppTheme.text]
        )
        rewardText.addAttribute(.foregroundColor, value: UIColor.systemYellow, range: ("● \(reward)" as NSString).range(of: "●"))
        rewardPill.attributedText = rewardText
        row.addArrangedSubview(rewardPill)
        let check = UIButton(type: .system)
        check.tintColor = done ? AppTheme.brand : UIColor.systemGray4
        check.setImage(UIImage(systemName: done ? "checkmark.circle.fill" : "checkmark.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 31, weight: .medium)), for: .normal)
        check.translatesAutoresizingMaskIntoConstraints = false
        check.widthAnchor.constraint(equalToConstant: 36).isActive = true
        check.heightAnchor.constraint(equalToConstant: 36).isActive = true
        // 비활성화(isEnabled=false)하면 이미지가 흐려져 회색이 되므로, 대신 claimed 가드로 재클릭만 막는다.
        var claimed = done
        check.addAction(UIAction { [weak self, weak check] _ in
            guard let self, let check, achieved, !claimed else { return }
            claimed = true
            HealthStore.shared.claimMission(id)   // 다른 화면 갔다 와도 체크 유지
            check.tintColor = AppTheme.brand
            check.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 31, weight: .medium)), for: .normal)
            // 체크 바운스 + 코인 획득 모션
            UIView.animate(withDuration: 0.12, animations: { check.transform = CGAffineTransform(scaleX: 1.3, y: 1.3) }) { _ in
                UIView.animate(withDuration: 0.14) { check.transform = .identity }
            }
            self.addPoints(Int(reward) ?? 0, from: check)
        }, for: .touchUpInside)
        row.addArrangedSubview(check)

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])
        return card
    }

    private func presentShop() {
        let shop = ShopViewController()
        shop.onChange = { [weak self] in self?.build() }
        present(shop, animated: true)
    }
}

/// 모은 코인으로 아이템을 구입하는 상점. 현재는 '연속 기록 이어주기' 아이템을 판다.
final class ShopViewController: UIViewController {
    /// 코인/연속 기록이 바뀌면 호출 (미션 화면 새로고침용).
    var onChange: (() -> Void)?

    private let streakItemPrice = 200
    private weak var balanceLabel: UILabel?
    private weak var streakCard: UIView?

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        build()
    }

    private func build() {
        let back = IconButton(symbol: "chevron.left", color: AppTheme.text, pointSize: 22)
        back.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)
        back.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(back)

        let titleLabel = UILabel("상점", size: 18, weight: .black, color: AppTheme.text, lines: 1)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        view.addSubview(scroll)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        stack.addArrangedSubview(balanceCard())
        let card = streakRecoveryCard()
        streakCard = card
        stack.addArrangedSubview(card)

        NSLayoutConstraint.activate([
            back.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: back.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            scroll.topAnchor.constraint(equalTo: back.bottomAnchor, constant: 18),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 6),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -34),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -20)
        ])
    }

    private func balanceCard() -> UIView {
        let card = UIView()
        card.applyCard(radius: 24)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 92).isActive = true

        let caption = UILabel("보유 코인", size: 14, weight: .bold, color: AppTheme.muted, lines: 1)
        caption.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(caption)

        let balance = UILabel("", size: 26, weight: .black, color: AppTheme.text, lines: 1)
        balance.attributedText = coinText(HealthStore.shared.coins, size: 26)
        balance.translatesAutoresizingMaskIntoConstraints = false
        balanceLabel = balance
        card.addSubview(balance)

        NSLayoutConstraint.activate([
            caption.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            caption.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            balance.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            balance.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        return card
    }

    private func streakRecoveryCard() -> UIView {
        let card = UIView()
        card.applyCard(radius: 24)
        card.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: "bolt.fill"))
        icon.tintColor = .systemOrange
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.widthAnchor.constraint(equalToConstant: 34).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 34).isActive = true

        let title = UILabel("연속 기록 이어주기", size: 18, weight: .black, color: AppTheme.text, lines: 1)
        let desc = UILabel("끊긴 하루를 메워서 연속 기록을 되살려줘요.", size: 13, weight: .semibold, color: AppTheme.muted, lines: 2)
        let textCol = UIStackView(arrangedSubviews: [title, desc])
        textCol.axis = .vertical
        textCol.spacing = 4

        let topRow = UIStackView(arrangedSubviews: [icon, textCol])
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = 14

        let buyButton = UIButton(type: .system)
        buyButton.setAttributedTitle(buyButtonTitle(), for: .normal)
        buyButton.backgroundColor = AppTheme.brand
        buyButton.layer.cornerRadius = 14
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        buyButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        buyButton.addAction(UIAction { [weak self] _ in self?.purchaseStreakRecovery() }, for: .touchUpInside)

        let col = UIStackView(arrangedSubviews: [topRow, buyButton])
        col.axis = .vertical
        col.spacing = 18
        col.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(col)
        NSLayoutConstraint.activate([
            col.topAnchor.constraint(equalTo: card.topAnchor, constant: 22),
            col.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            col.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -22),
            col.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -22)
        ])
        return card
    }

    private func buyButtonTitle() -> NSAttributedString {
        let formatted = NumberFormatter.localizedString(from: NSNumber(value: streakItemPrice), number: .decimal)
        let text = NSMutableAttributedString(string: "● \(formatted) 코인으로 구입", attributes: [
            .font: AppTheme.font(16, .black), .foregroundColor: UIColor.white
        ])
        text.addAttribute(.foregroundColor, value: UIColor.systemYellow, range: ("● \(formatted) 코인으로 구입" as NSString).range(of: "●"))
        return text
    }

    private func coinText(_ amount: Int, size: CGFloat) -> NSAttributedString {
        let formatted = NumberFormatter.localizedString(from: NSNumber(value: amount), number: .decimal)
        let string = "● \(formatted)"
        let text = NSMutableAttributedString(string: string, attributes: [
            .font: AppTheme.font(size, .black), .foregroundColor: AppTheme.text
        ])
        text.addAttribute(.foregroundColor, value: UIColor.systemYellow, range: (string as NSString).range(of: "●"))
        return text
    }

    private func purchaseStreakRecovery() {
        let store = HealthStore.shared
        if store.coins < streakItemPrice {
            showAlert(title: "코인이 부족해요", message: "미션을 완료해서 코인을 더 모아보세요.")
            return
        }
        guard store.streakGapDay != nil else {
            showAlert(title: "이어줄 기록이 없어요", message: "최근에 하루만 끊긴 연속 기록이 있을 때 사용할 수 있어요.")
            return
        }
        store.bridgeStreak()
        store.coins -= streakItemPrice
        balanceLabel?.attributedText = coinText(store.coins, size: 26)
        onChange?()
        showAlert(title: "연속 기록을 이어줬어요 🔥", message: "현재 \(store.currentStreak)일 연속 기록 중이에요!")
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
