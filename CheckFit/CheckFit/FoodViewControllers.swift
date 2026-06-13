//
//  FoodViewControllers.swift
//  CheckFit
//
//  음식 검색·식사 기록·식단 상세·직접등록 화면
//

import UIKit

struct FoodItem {
    let name: String
    let portion: String
    let kcal: Int
    let carb: Double
    let protein: Double
    let fat: Double
}

/// 홈의 끼니 타일(아침/점심/저녁/간식)을 누르면 나오는 식단 기록 화면.
final class FoodSearchViewController: UIViewController {
    private let accent = AppTheme.brand
    private let meals = ["아침", "점심", "저녁", "야식", "간식"]
    private let tabs = ["자주 드셨어요", "즐겨찾기", "직접 등록"]
    private let categories = ["전체", "음식", "인기"]
    private let genders = ["여성", "남성"]
    private let femaleFoods: [FoodItem] = [
        FoodItem(name: "삶은 달걀", portion: "1개 (45g)", kcal: 65, carb: 0.6, protein: 6.1, fat: 3.9),
        FoodItem(name: "사과", portion: "1개 (200g)", kcal: 104, carb: 27.6, protein: 0.5, fat: 0.3),
        FoodItem(name: "바나나", portion: "1개 (150g)", kcal: 114, carb: 29.2, protein: 1.3, fat: 0.4),
        FoodItem(name: "방울토마토", portion: "1개 (12g)", kcal: 3, carb: 0.6, protein: 0.1, fat: 0.0),
        FoodItem(name: "흰쌀밥", portion: "1공기 (210g)", kcal: 336, carb: 74.0, protein: 6.0, fat: 0.6),
        FoodItem(name: "구운 달걀(구운란)", portion: "1개 (45g)", kcal: 73, carb: 0.5, protein: 6.5, fat: 5.0),
        FoodItem(name: "블루베리", portion: "1줌 (12g)", kcal: 9, carb: 2.1, protein: 0.1, fat: 0.05),
        FoodItem(name: "그릭요거트", portion: "1개 (100g)", kcal: 59, carb: 3.6, protein: 10.0, fat: 0.4),
        FoodItem(name: "고구마", portion: "1개 (150g)", kcal: 192, carb: 44.7, protein: 2.0, fat: 0.3),
        FoodItem(name: "아보카도", portion: "1/2개 (70g)", kcal: 112, carb: 6.0, protein: 1.4, fat: 10.3),
        FoodItem(name: "닭가슴살", portion: "1개 (100g)", kcal: 109, carb: 0.0, protein: 23.0, fat: 1.5),
        FoodItem(name: "오트밀", portion: "1회 (40g)", kcal: 150, carb: 27.0, protein: 5.0, fat: 3.0),
        FoodItem(name: "두부", portion: "1/2모 (150g)", kcal: 126, carb: 3.0, protein: 12.6, fat: 7.5),
        FoodItem(name: "방울양배추", portion: "1줌 (80g)", kcal: 34, carb: 7.0, protein: 2.7, fat: 0.3),
        FoodItem(name: "아몬드", portion: "10알 (12g)", kcal: 70, carb: 2.4, protein: 2.6, fat: 6.1),
        FoodItem(name: "딸기", portion: "5알 (75g)", kcal: 24, carb: 5.8, protein: 0.5, fat: 0.2)
    ]
    private let maleFoods: [FoodItem] = [
        FoodItem(name: "삶은 달걀", portion: "1개 (45g)", kcal: 65, carb: 0.6, protein: 6.1, fat: 3.9),
        FoodItem(name: "흰쌀밥", portion: "1공기 (210g)", kcal: 336, carb: 74.0, protein: 6.0, fat: 0.6),
        FoodItem(name: "바나나", portion: "1개 (150g)", kcal: 114, carb: 29.2, protein: 1.3, fat: 0.4),
        FoodItem(name: "계란후라이", portion: "1장 (46g)", kcal: 95, carb: 0.5, protein: 6.5, fat: 7.0),
        FoodItem(name: "사과", portion: "1개 (200g)", kcal: 104, carb: 27.6, protein: 0.5, fat: 0.3),
        FoodItem(name: "잡곡밥", portion: "1인분 (210g)", kcal: 306, carb: 65.0, protein: 7.0, fat: 2.0),
        FoodItem(name: "닭가슴살", portion: "1개 (100g)", kcal: 109, carb: 0.0, protein: 23.0, fat: 1.5),
        FoodItem(name: "소고기 안심", portion: "1인분 (100g)", kcal: 175, carb: 0.0, protein: 22.0, fat: 9.3),
        FoodItem(name: "연어", portion: "1토막 (100g)", kcal: 208, carb: 0.0, protein: 20.0, fat: 13.0),
        FoodItem(name: "고구마", portion: "1개 (150g)", kcal: 192, carb: 44.7, protein: 2.0, fat: 0.3),
        FoodItem(name: "현미밥", portion: "1공기 (210g)", kcal: 310, carb: 67.0, protein: 6.5, fat: 1.7),
        FoodItem(name: "닭다리살", portion: "1개 (100g)", kcal: 144, carb: 0.0, protein: 19.0, fat: 7.5),
        FoodItem(name: "통밀빵", portion: "1쪽 (33g)", kcal: 79, carb: 13.8, protein: 4.0, fat: 1.1),
        FoodItem(name: "땅콩버터", portion: "1큰술 (16g)", kcal: 94, carb: 3.5, protein: 4.0, fat: 8.0),
        FoodItem(name: "우유", portion: "1잔 (200ml)", kcal: 122, carb: 9.6, protein: 6.4, fat: 6.6),
        FoodItem(name: "브로콜리", portion: "1줌 (100g)", kcal: 34, carb: 6.6, protein: 2.8, fat: 0.4)
    ]
    private var favorites = Set<String>()
    private var allFoods: [FoodItem] {
        var seen = Set<String>()
        return (femaleFoods + maleFoods).filter { seen.insert($0.name).inserted }
    }

    private var meal: String
    private var selectedTab = "자주 드셨어요"
    private var selectedCategory = "인기"
    private var gender = "여성"
    private var selected: [FoodItem] = []
    private var searchText = ""
    private weak var recordButton: UIButton?
    private weak var listStack: UIStackView?

    /// 설정되면 '기록 화면에 음식 추가/교체' 모드. 선택을 전달하고 화면을 닫는다.
    var onPick: (([FoodItem]) -> Void)?

    private var rankedFoods: [FoodItem] { gender == "남성" ? maleFoods : femaleFoods }

    init(meal: String) {
        self.meal = meal
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
        view.subviews.forEach { $0.removeFromSuperview() }

        let topStack = UIStackView(arrangedSubviews: [searchRow(), tabRow()])
        // 카테고리 칩은 '자주 드셨어요' 탭에서만, '유저들이 자주 먹어요' 헤더는 '인기'에서만 보인다.
        if selectedTab == "자주 드셨어요" {
            topStack.addArrangedSubview(categoryRow())
            if selectedCategory == "인기" {
                topStack.addArrangedSubview(subtitleBlock())
            }
        }
        topStack.axis = .vertical
        topStack.spacing = 0
        topStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topStack)

        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let list = UIStackView()
        list.axis = .vertical
        list.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(list)
        listStack = list
        populateList(list)

        let bottom = bottomBar()
        view.addSubview(bottom)

        NSLayoutConstraint.activate([
            topStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            topStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scroll.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 4),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: bottom.topAnchor),

            list.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            list.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            list.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor),
            list.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor),
            list.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),

            bottom.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottom.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottom.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// 리스트 내용만 다시 채운다(검색어 변경 시 검색창 포커스를 유지하기 위해 전체 build()를 피한다).
    private func reloadList() {
        guard let list = listStack else { return }
        list.arrangedSubviews.forEach { list.removeArrangedSubview($0); $0.removeFromSuperview() }
        populateList(list)
    }

    private func populateList(_ list: UIStackView) {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        if !query.isEmpty {
            let results = allFoods.filter { $0.name.localizedCaseInsensitiveContains(query) }
            if results.isEmpty {
                list.addArrangedSubview(emptyState("'\(query)'\n검색 결과가 없어요"))
            } else {
                for (index, food) in results.enumerated() {
                    list.addArrangedSubview(foodRow(rank: index + 1, food: food))
                }
            }
            return
        }

        if selectedTab == "직접 등록" {
            list.addArrangedSubview(registerRow())
        } else if selectedTab == "즐겨찾기" {
            let favs = allFoods.filter { favorites.contains($0.name) }
            if favs.isEmpty {
                list.addArrangedSubview(emptyState("즐겨찾기한 음식이\n아직 없어요"))
            } else {
                for (index, food) in favs.enumerated() {
                    list.addArrangedSubview(foodRow(rank: index + 1, food: food))
                }
            }
        } else if selectedCategory == "인기" {
            for (index, food) in rankedFoods.enumerated() {
                list.addArrangedSubview(foodRow(rank: index + 1, food: food))
            }
        } else {
            list.addArrangedSubview(emptyState("자주 먹는 음식이\n자동으로 추가될 거예요"))
        }
    }

    // MARK: - 상단

    private func searchRow() -> UIView {
        let back = IconButton(symbol: "chevron.left", color: AppTheme.text, pointSize: 22)
        back.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)
        back.setContentHuggingPriority(.required, for: .horizontal)
        back.translatesAutoresizingMaskIntoConstraints = false
        back.widthAnchor.constraint(equalToConstant: 30).isActive = true

        let field = UITextField()
        field.attributedPlaceholder = NSAttributedString(
            string: "음식명, 브랜드명으로 검색",
            attributes: [.foregroundColor: AppTheme.muted, .font: AppTheme.font(14, .semibold)]
        )
        field.backgroundColor = AppTheme.softFill
        field.layer.cornerRadius = 18
        field.font = AppTheme.font(14, .semibold)
        field.textColor = AppTheme.text
        field.tintColor = AppTheme.brand
        field.autocorrectionType = .no
        field.text = searchText
        field.clearButtonMode = .whileEditing
        field.returnKeyType = .search
        field.addAction(UIAction { [weak self, weak field] _ in
            self?.searchText = field?.text ?? ""
            self?.reloadList()
        }, for: .editingChanged)
        let icon = UIImageView(symbol: "magnifyingglass", color: AppTheme.muted, size: 16, weight: .medium)
        icon.translatesAutoresizingMaskIntoConstraints = true
        icon.frame = CGRect(x: 14, y: 11, width: 20, height: 20)
        let leftWrap = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 44))
        leftWrap.addSubview(icon)
        field.leftView = leftWrap
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 44).isActive = true

        let row = UIStackView(arrangedSubviews: [back, field])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 10, right: 16)
        return row
    }

    private func tabRow() -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .fillEqually
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 4, left: 16, bottom: 8, right: 16)
        for tab in tabs {
            let selected = tab == selectedTab
            let label = UILabel(tab, size: 15, weight: .black, color: selected ? AppTheme.brand : AppTheme.muted, lines: 1)
            label.textAlignment = .center
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(TapAction { [weak self] in
                self?.selectedTab = tab
                self?.build()
            })
            row.addArrangedSubview(label)
        }
        return row
    }

    private func categoryRow() -> UIView {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 9
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 6, left: 16, bottom: 10, right: 16)
        row.translatesAutoresizingMaskIntoConstraints = false
        for category in categories {
            row.addArrangedSubview(categoryPill(category))
        }
        scroll.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            row.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            row.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            row.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor),
            scroll.heightAnchor.constraint(equalToConstant: 50)
        ])
        return scroll
    }

    private func categoryPill(_ title: String) -> UIView {
        let selected = title == selectedCategory
        let pill = PaddingLabel(title, size: 13, weight: .black, color: selected ? .white : AppTheme.muted)
        pill.textAlignment = .center
        pill.insets = UIEdgeInsets(top: 8, left: 18, bottom: 8, right: 18)
        pill.backgroundColor = selected ? accent : AppTheme.softFill
        pill.layer.cornerRadius = 17
        pill.clipsToBounds = true
        pill.isUserInteractionEnabled = true
        pill.addGestureRecognizer(TapAction { [weak self] in
            self?.selectedCategory = title
            self?.build()
        })
        return pill
    }

    private func subtitleBlock() -> UIView {
        let genderButton = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(gender, attributes: AttributeContainer([.font: AppTheme.font(13, .black)]))
        config.image = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 9, weight: .black))
        config.imagePlacement = .trailing
        config.imagePadding = 4
        config.baseForegroundColor = AppTheme.text
        config.background.backgroundColor = AppTheme.softFill
        config.background.cornerRadius = 13
        config.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 11, bottom: 5, trailing: 9)
        genderButton.configuration = config
        genderButton.menu = UIMenu(children: genders.map { option in
            UIAction(title: option, state: option == gender ? .on : .off) { [weak self] _ in
                self?.gender = option
                self?.build()
            }
        })
        genderButton.showsMenuAsPrimaryAction = true
        genderButton.setContentHuggingPriority(.required, for: .horizontal)

        let headline = UILabel("유저들이 자주 먹어요 🔥", size: 14, weight: .black, color: AppTheme.text, lines: 1)
        let titleRow = UIStackView(arrangedSubviews: [genderButton, headline, UIView()])
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = 8

        let basis = UILabel("6월 10일 \(meal) 식사 기준", size: 12, weight: .semibold, color: AppTheme.muted, lines: 1)

        let column = UIStackView(arrangedSubviews: [titleRow, basis])
        column.axis = .vertical
        column.spacing = 5
        column.isLayoutMarginsRelativeArrangement = true
        column.layoutMargins = UIEdgeInsets(top: 4, left: 16, bottom: 10, right: 16)
        return column
    }

    // MARK: - 리스트

    private func foodRow(rank: Int, food: FoodItem) -> UIView {
        let number = UILabel("\(rank)", size: 15, weight: .black, color: accent, lines: 1)
        number.textAlignment = .center
        number.translatesAutoresizingMaskIntoConstraints = false
        number.widthAnchor.constraint(equalToConstant: 24).isActive = true

        let name = UILabel(food.name, size: 15, weight: .black, color: AppTheme.text, lines: 1)
        let portion = UILabel(food.portion, size: 12, weight: .semibold, color: AppTheme.muted, lines: 1)
        let textCol = UIStackView(arrangedSubviews: [name, portion])
        textCol.axis = .vertical
        textCol.spacing = 3

        let kcal = UILabel("\(food.kcal)kcal", size: 14, weight: .bold, color: AppTheme.muted, lines: 1)
        kcal.setContentHuggingPriority(.required, for: .horizontal)

        let isFav = favorites.contains(food.name)
        let star = IconButton(symbol: isFav ? "star.fill" : "star",
                              color: isFav ? .systemYellow : UIColor.systemGray3, pointSize: 20, weight: .medium)
        star.addAction(UIAction { [weak self] _ in self?.toggleFoodFavorite(food) }, for: .touchUpInside)
        star.translatesAutoresizingMaskIntoConstraints = false
        star.widthAnchor.constraint(equalToConstant: 30).isActive = true
        star.heightAnchor.constraint(equalToConstant: 30).isActive = true

        let plus = IconButton(symbol: "plus.circle", color: accent, pointSize: 22, weight: .medium)
        plus.addAction(UIAction { [weak self, weak plus] _ in self?.addFood(food, from: plus) }, for: .touchUpInside)
        plus.translatesAutoresizingMaskIntoConstraints = false
        plus.widthAnchor.constraint(equalToConstant: 30).isActive = true
        plus.heightAnchor.constraint(equalToConstant: 30).isActive = true

        let row = UIStackView(arrangedSubviews: [number, textCol, UIView(), kcal, star, plus])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 18)
        return row
    }

    private func toggleFoodFavorite(_ food: FoodItem) {
        if favorites.contains(food.name) { favorites.remove(food.name) } else { favorites.insert(food.name) }
        build()
    }

    private func addFood(_ food: FoodItem, from button: UIButton?) {
        selected.append(food)
        updateRecordButton()
        pulseRecordButton()
        guard let button else { return }

        // 버튼 바운스 + 잠깐 체크 아이콘으로 바뀌었다가 되돌아온다.
        UIView.animate(withDuration: 0.12, animations: { button.transform = CGAffineTransform(scaleX: 1.35, y: 1.35) }) { _ in
            UIView.animate(withDuration: 0.14) { button.transform = .identity }
        }
        let original = button.image(for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)), for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            button.setImage(original, for: .normal)
        }

        flyPlusOne(from: button)
    }

    /// 버튼 위에서 "+1"이 떠오르며 사라지는 애니메이션.
    private func flyPlusOne(from button: UIButton) {
        let label = UILabel()
        label.text = "+1"
        label.font = AppTheme.font(16, .black)
        label.textColor = AppTheme.brand
        label.sizeToFit()
        let start = button.convert(CGPoint(x: button.bounds.midX, y: button.bounds.minY), to: view)
        label.center = start
        view.addSubview(label)
        UIView.animate(withDuration: 0.6, delay: 0, options: [.curveEaseOut], animations: {
            label.center = CGPoint(x: start.x, y: start.y - 46)
            label.alpha = 0
        }, completion: { _ in label.removeFromSuperview() })
    }

    /// 하단 '기록하기' 버튼을 살짝 펄스시켜 추가됨을 알린다.
    private func pulseRecordButton() {
        guard let button = recordButton else { return }
        UIView.animate(withDuration: 0.1, animations: { button.transform = CGAffineTransform(scaleX: 1.04, y: 1.04) }) { _ in
            UIView.animate(withDuration: 0.12) { button.transform = .identity }
        }
    }

    private func updateRecordButton() {
        recordButton?.setTitle(selected.isEmpty ? "기록하기" : "기록하기 (\(selected.count))", for: .normal)
    }

    private func emptyState(_ text: String) -> UIView {
        let illustration = UIImageView(symbol: "fork.knife", color: UIColor.systemGray4, size: 64, weight: .light)
        illustration.tintColor = UIColor.systemGray5

        let label = UILabel(text, size: 15, weight: .bold, color: AppTheme.muted, lines: 0)
        label.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [illustration, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false

        let wrap = UIView()
        wrap.addSubview(stack)
        NSLayoutConstraint.activate([
            wrap.heightAnchor.constraint(equalToConstant: 340),
            stack.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: wrap.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: wrap.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: wrap.trailingAnchor, constant: -24)
        ])
        return wrap
    }

    private func registerRow() -> UIView {
        let button = UIButton(type: .system)
        button.setTitle("직접 등록  +", for: .normal)
        button.setTitleColor(accent, for: .normal)
        button.titleLabel?.font = AppTheme.font(16, .black)
        button.backgroundColor = accent.withAlphaComponent(0.10)
        button.layer.cornerRadius = 16
        button.addAction(UIAction { [weak self] _ in
            let custom = CustomFoodViewController()
            custom.onSave = { [weak self] food in
                guard let self else { return }
                self.selected.append(food)
                self.selectedTab = "자주 드셨어요"
                self.build()
            }
            self?.present(custom, animated: true)
        }, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true

        let wrap = UIView()
        wrap.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: wrap.topAnchor, constant: 18),
            button.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -16),
            button.bottomAnchor.constraint(equalTo: wrap.bottomAnchor)
        ])
        return wrap
    }

    // MARK: - 하단

    private func bottomBar() -> UIView {
        let bar = UIView()
        bar.backgroundColor = .white
        bar.translatesAutoresizingMaskIntoConstraints = false

        let mealButton = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(meal, attributes: AttributeContainer([.font: AppTheme.font(15, .black)]))
        config.image = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .black))
        config.imagePlacement = .trailing
        config.imagePadding = 5
        config.baseForegroundColor = accent
        config.background.backgroundColor = accent.withAlphaComponent(0.12)
        config.background.cornerRadius = 16
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 14)
        mealButton.configuration = config
        mealButton.menu = UIMenu(children: meals.filter { $0 != "야식" }.map { option in
            UIAction(title: option, state: option == meal ? .on : .off) { [weak self] _ in
                self?.meal = option
                self?.build()
            }
        })
        mealButton.showsMenuAsPrimaryAction = true
        mealButton.setContentHuggingPriority(.required, for: .horizontal)

        let onLabel = UILabel("에", size: 15, weight: .bold, color: AppTheme.text, lines: 1)
        onLabel.setContentHuggingPriority(.required, for: .horizontal)

        let record = UIButton(type: .system)
        record.setTitle(selected.isEmpty ? "기록하기" : "기록하기 (\(selected.count))", for: .normal)
        record.setTitleColor(accent, for: .normal)
        record.titleLabel?.font = AppTheme.font(16, .black)
        record.backgroundColor = accent.withAlphaComponent(0.12)
        record.layer.cornerRadius = 18
        record.addAction(UIAction { [weak self] _ in self?.openRecord() }, for: .touchUpInside)
        record.translatesAutoresizingMaskIntoConstraints = false
        record.heightAnchor.constraint(equalToConstant: 54).isActive = true
        recordButton = record

        let row = UIStackView(arrangedSubviews: [mealButton, onLabel, record])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: bar.topAnchor, constant: 10),
            row.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -16),
            row.bottomAnchor.constraint(equalTo: bar.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        return bar
    }

    private func openRecord() {
        guard !selected.isEmpty else { return }
        // 음식 추가/교체 모드: 선택만 전달하고 기록 화면으로 돌아간다.
        if let onPick {
            onPick(selected)
            dismiss(animated: true)
            return
        }
        present(MealRecordViewController(meal: meal, foods: selected), animated: true)
    }
}

/// 식단 검색에서 '기록하기'를 누르면 나오는 기록 확인 화면.
final class MealRecordViewController: UIViewController {
    private let accent = AppTheme.brand
    private let carbColor = AppTheme.brand
    private let proteinColor = UIColor.systemTeal
    private let fatColor = UIColor.systemYellow
    private let meals = ["아침", "점심", "저녁", "야식", "간식"]

    private let units = ["개", "g", "인분", "공기", "줌"]

    private var meal: String
    private var foods: [FoodItem]
    private var quantities: [Int]
    private var foodUnits: [String]
    private var editMode = false

    init(meal: String, foods: [FoodItem]) {
        self.meal = meal
        self.foods = foods
        self.quantities = Array(repeating: 1, count: foods.count)
        self.foodUnits = Array(repeating: "개", count: foods.count)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        build()
    }

    private func qty(_ i: Int) -> Int { quantities.indices.contains(i) ? quantities[i] : 1 }
    private var totalKcal: Int { foods.indices.reduce(0) { $0 + foods[$1].kcal * qty($1) } }
    private var totalCarb: Double { foods.indices.reduce(0) { $0 + foods[$1].carb * Double(qty($1)) } }
    private var totalProtein: Double { foods.indices.reduce(0) { $0 + foods[$1].protein * Double(qty($1)) } }
    private var totalFat: Double { foods.indices.reduce(0) { $0 + foods[$1].fat * Double(qty($1)) } }

    private func build() {
        view.subviews.forEach { $0.removeFromSuperview() }

        let bar = topBar()
        view.addSubview(bar)

        let bottom = bottomBar()
        view.addSubview(bottom)

        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let body = UIStackView()
        body.axis = .vertical
        body.spacing = 18
        body.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(body)

        body.addArrangedSubview(totalRow())
        body.addArrangedSubview(macroLegend())
        body.addArrangedSubview(macroBar())
        body.addArrangedSubview(foodCard())
        body.addArrangedSubview(footnote())

        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            bottom.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottom.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottom.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            scroll.topAnchor.constraint(equalTo: bar.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: bottom.topAnchor),

            body.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 20),
            body.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -20),
            body.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 22),
            body.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -22)
        ])
    }

    private func topBar() -> UIView {
        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false

        let back = IconButton(symbol: "chevron.left", color: AppTheme.text, pointSize: 22)
        back.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)
        back.translatesAutoresizingMaskIntoConstraints = false
        back.widthAnchor.constraint(equalToConstant: 36).isActive = true

        let date = UILabel(MealRecordViewController.todayText(), size: 12, weight: .bold, color: AppTheme.muted, lines: 1)
        date.textAlignment = .center
        let title = UILabel(foods.count == 1 ? foods[0].name : "음식 \(foods.count)개", size: 17, weight: .black, color: AppTheme.text, lines: 1)
        title.textAlignment = .center
        let titleCol = UIStackView(arrangedSubviews: [date, title])
        titleCol.axis = .vertical
        titleCol.alignment = .center
        titleCol.spacing = 1

        // 제목이 가운데 정렬되도록 back과 같은 너비의 빈 공간만 둔다.
        let trailingSpacer = UIView()
        trailingSpacer.translatesAutoresizingMaskIntoConstraints = false
        trailingSpacer.widthAnchor.constraint(equalToConstant: 36).isActive = true

        let row = UIStackView(arrangedSubviews: [back, titleCol, trailingSpacer])
        row.axis = .horizontal
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        titleCol.setContentHuggingPriority(.defaultLow, for: .horizontal)
        bar.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: bar.topAnchor, constant: 6),
            row.bottomAnchor.constraint(equalTo: bar.bottomAnchor, constant: -10),
            row.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 12),
            row.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -12)
        ])
        return bar
    }

    private func totalRow() -> UIView {
        let title = UILabel("총 열량", size: 16, weight: .black, color: AppTheme.text, lines: 1)
        let value = UILabel("\(totalKcal) kcal", size: 22, weight: .black, color: AppTheme.text, lines: 1)
        value.setContentHuggingPriority(.required, for: .horizontal)
        let row = UIStackView(arrangedSubviews: [title, UIView(), value])
        row.axis = .horizontal
        row.alignment = .center
        return row
    }

    private func macroLegend() -> UIView {
        let row = UIStackView(arrangedSubviews: [
            macroChip(color: carbColor, text: String(format: "탄 %.1fg", totalCarb), info: true),
            macroChip(color: proteinColor, text: String(format: "단 %.1fg", totalProtein), info: false),
            macroChip(color: fatColor, text: String(format: "지 %.1fg", totalFat), info: false),
            UIView()
        ])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 14
        return row
    }

    private func macroChip(color: UIColor, text: String, info: Bool) -> UIView {
        let dot = UIView()
        dot.backgroundColor = color
        dot.layer.cornerRadius = 5
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.widthAnchor.constraint(equalToConstant: 10).isActive = true
        dot.heightAnchor.constraint(equalToConstant: 10).isActive = true
        let label = UILabel(text, size: 13, weight: .black, color: AppTheme.text, lines: 1)
        let row = UIStackView(arrangedSubviews: [dot, label])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 6
        if info {
            row.addArrangedSubview(UIImageView(symbol: "info.circle", color: AppTheme.muted, size: 12, weight: .semibold))
        }
        return row
    }

    private func macroBar() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 34).isActive = true

        // 색 막대는 둥근 모서리를 위해 클리핑하되, % 라벨은 그 위(컨테이너)에 얹어 잘리지 않게 한다.
        let track = UIView()
        track.layer.cornerRadius = 8
        track.clipsToBounds = true
        track.backgroundColor = AppTheme.softFill
        track.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(track)
        NSLayoutConstraint.activate([
            track.topAnchor.constraint(equalTo: container.topAnchor),
            track.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            track.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            track.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        let cCal = totalCarb * 4, pCal = totalProtein * 4, fCal = totalFat * 9
        let sum = max(cCal + pCal + fCal, 0.0001)
        let segments: [(UIColor, Double)] = [(carbColor, cCal / sum), (proteinColor, pCal / sum), (fatColor, fCal / sum)]

        var leading = track.leadingAnchor
        for (color, fraction) in segments where fraction > 0.0005 {
            let seg = UIView()
            seg.backgroundColor = color
            seg.translatesAutoresizingMaskIntoConstraints = false
            track.addSubview(seg)
            NSLayoutConstraint.activate([
                seg.topAnchor.constraint(equalTo: track.topAnchor),
                seg.bottomAnchor.constraint(equalTo: track.bottomAnchor),
                seg.leadingAnchor.constraint(equalTo: leading),
                seg.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: fraction)
            ])
            leading = seg.trailingAnchor

            let label = UILabel("\(Int(round(fraction * 100)))%", size: 12, weight: .black, color: .white, lines: 1)
            label.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(label)
            let center = label.centerXAnchor.constraint(equalTo: seg.centerXAnchor)
            center.priority = .defaultHigh
            NSLayoutConstraint.activate([
                center,
                label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                label.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 5),
                label.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -5)
            ])
        }
        return container
    }

    private func foodCard() -> UIView {
        let card = UIView()
        card.backgroundColor = AppTheme.softFill
        card.layer.cornerRadius = 22
        card.translatesAutoresizingMaskIntoConstraints = false

        let mealButton = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(meal, attributes: AttributeContainer([.font: AppTheme.font(15, .black)]))
        config.image = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .black))
        config.imagePlacement = .trailing
        config.imagePadding = 6
        config.baseForegroundColor = .white
        config.background.backgroundColor = UIColor(red: 0.44, green: 0.47, blue: 0.52, alpha: 1)
        config.background.cornerRadius = 16
        config.contentInsets = NSDirectionalEdgeInsets(top: 9, leading: 16, bottom: 9, trailing: 14)
        mealButton.configuration = config
        // 선택 메뉴에서는 '야식'을 제외한다.
        mealButton.menu = UIMenu(children: meals.filter { $0 != "야식" }.map { option in
            UIAction(title: option, state: option == meal ? .on : .off) { [weak self] _ in
                self?.meal = option
                self?.build()
            }
        })
        mealButton.showsMenuAsPrimaryAction = true
        mealButton.setContentHuggingPriority(.required, for: .horizontal)

        let mealTime = UILabel("식사 시간  ›", size: 14, weight: .bold, color: AppTheme.muted, lines: 1)
        mealTime.setContentHuggingPriority(.required, for: .horizontal)
        let mealRow = UIStackView(arrangedSubviews: [mealButton, UIView(), mealTime])
        mealRow.axis = .horizontal
        mealRow.alignment = .center

        let editLabel = UILabel("수정 모드", size: 14, weight: .black, color: editMode ? accent : AppTheme.muted, lines: 1)
        let editSwitch = UISwitch()
        editSwitch.onTintColor = accent
        editSwitch.isOn = editMode
        editSwitch.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        editSwitch.addAction(UIAction { [weak self, weak editSwitch] _ in
            self?.editMode = editSwitch?.isOn ?? false
            self?.build()
        }, for: .valueChanged)
        let editRow = UIStackView(arrangedSubviews: [editLabel, UIView(), editSwitch])
        editRow.axis = .horizontal
        editRow.alignment = .center

        let stack = UIStackView(arrangedSubviews: [mealRow, editRow])
        stack.axis = .vertical
        stack.spacing = 16

        for (index, food) in foods.enumerated() {
            stack.addArrangedSubview(recordFoodRow(index: index, food: food))
        }

        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        return card
    }

    private func recordFoodRow(index: Int, food: FoodItem) -> UIView {
        let count = qty(index)
        let name = UILabel(food.name, size: 16, weight: .black, color: AppTheme.text, lines: 1)
        let portionText: String
        if editMode, let grams = grams(from: food.portion) {
            portionText = "\(count)\(foodUnits[index]) = \(grams * count)g"
        } else {
            portionText = food.portion
        }
        let portion = UILabel(portionText, size: 12, weight: .semibold, color: AppTheme.muted, lines: 1)
        let textCol = UIStackView(arrangedSubviews: [name, portion])
        textCol.axis = .vertical
        textCol.spacing = 3

        let kcal = UILabel("\(food.kcal * count)kcal", size: 14, weight: .bold, color: AppTheme.muted, lines: 1)
        kcal.setContentHuggingPriority(.required, for: .horizontal)

        let minus = IconButton(symbol: "minus.circle.fill", color: accent, pointSize: 22)
        minus.addAction(UIAction { [weak self] _ in self?.removeFood(at: index) }, for: .touchUpInside)
        minus.translatesAutoresizingMaskIntoConstraints = false
        minus.widthAnchor.constraint(equalToConstant: 28).isActive = true
        minus.heightAnchor.constraint(equalToConstant: 28).isActive = true

        let topRow = UIStackView(arrangedSubviews: [textCol, UIView(), kcal, minus])
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = 12

        guard editMode else { return topRow }

        let controls = UIStackView(arrangedSubviews: [stepperView(index: index), unitDropdown(index: index)])
        controls.axis = .horizontal
        controls.distribution = .fillEqually
        controls.spacing = 12

        let column = UIStackView(arrangedSubviews: [topRow, controls, searchPill(index: index)])
        column.axis = .vertical
        column.alignment = .fill
        column.spacing = 12
        column.setCustomSpacing(10, after: controls)
        return column
    }

    private func stepperView(index: Int) -> UIView {
        let container = UIView()
        container.layer.cornerRadius = 14
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor(red: 0.88, green: 0.89, blue: 0.92, alpha: 1).cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 56).isActive = true

        let minus = IconButton(symbol: "minus", color: AppTheme.text, pointSize: 18, weight: .bold)
        minus.addAction(UIAction { [weak self] _ in self?.changeQuantity(index, delta: -1) }, for: .touchUpInside)
        let count = UILabel("\(qty(index))", size: 17, weight: .black, color: AppTheme.text, lines: 1)
        count.textAlignment = .center
        let plus = IconButton(symbol: "plus", color: AppTheme.text, pointSize: 18, weight: .bold)
        plus.addAction(UIAction { [weak self] _ in self?.changeQuantity(index, delta: 1) }, for: .touchUpInside)

        let row = UIStackView(arrangedSubviews: [minus, count, plus])
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: container.topAnchor),
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8)
        ])
        return container
    }

    private func unitDropdown(index: Int) -> UIView {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(foodUnits[index], attributes: AttributeContainer([.font: AppTheme.font(15, .bold)]))
        config.image = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .bold))
        config.imagePlacement = .trailing
        config.baseForegroundColor = AppTheme.text
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        // 라벨은 왼쪽, 화살표는 오른쪽 끝으로
        config.titleAlignment = .leading
        button.configuration = config
        button.contentHorizontalAlignment = .fill
        button.menu = UIMenu(children: units.map { option in
            UIAction(title: option, state: option == foodUnits[index] ? .on : .off) { [weak self] _ in
                guard let self, self.foodUnits.indices.contains(index) else { return }
                self.foodUnits[index] = option
                self.build()
            }
        })
        button.showsMenuAsPrimaryAction = true
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0.88, green: 0.89, blue: 0.92, alpha: 1).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return button
    }

    private func searchPill(index: Int) -> UIView {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString("직접 검색", attributes: AttributeContainer([.font: AppTheme.font(13, .bold)]))
        config.image = UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .bold))
        config.imagePlacement = .leading
        config.imagePadding = 5
        config.baseForegroundColor = AppTheme.muted
        config.background.backgroundColor = AppTheme.softFill
        config.background.cornerRadius = 15
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14)
        button.configuration = config
        button.addAction(UIAction { [weak self] _ in self?.replaceFood(at: index) }, for: .touchUpInside)
        let wrap = UIStackView(arrangedSubviews: [button, UIView()])
        wrap.axis = .horizontal
        return wrap
    }

    /// "1개 (45g)" 같은 제공량 문자열에서 괄호 안 그램 숫자를 뽑아낸다.
    private func grams(from portion: String) -> Int? {
        guard let open = portion.firstIndex(of: "("),
              let gIndex = portion[open...].firstIndex(of: "g") else { return nil }
        let digits = portion[open..<gIndex].filter(\.isNumber)
        return Int(digits)
    }

    private func changeQuantity(_ index: Int, delta: Int) {
        guard quantities.indices.contains(index) else { return }
        quantities[index] = max(1, quantities[index] + delta)
        build()
    }

    private func removeFood(at index: Int) {
        guard foods.indices.contains(index) else { return }
        foods.remove(at: index)
        quantities.remove(at: index)
        foodUnits.remove(at: index)
        build()
    }

    private func appendFoods(_ items: [FoodItem]) {
        for item in items {
            foods.append(item)
            quantities.append(1)
            foodUnits.append("개")
        }
        build()
    }

    private func replaceFood(at index: Int) {
        let search = FoodSearchViewController(meal: meal)
        search.onPick = { [weak self] picked in
            guard let self, let first = picked.first, self.foods.indices.contains(index) else { return }
            self.foods[index] = first
            self.quantities[index] = 1
            self.build()
        }
        present(search, animated: true)
    }

    private func footnote() -> UIView {
        let label = UILabel("식품의 영양성분정보는 수확물의 품종, 발육, 생장환경 등에 따라 달라질 수 있으며, 조리법에 따라 달라질 수 있습니다. 계산된 칼로리 및 성분 정보는 평균적인 수치로 참고용으로 사용해야 하며, 일부 정보에 오류가 있거나 누락이 있을 수 있습니다.",
                            size: 12, weight: .semibold, color: AppTheme.muted, lines: 0)
        label.adjustsFontSizeToFitWidth = false
        return label
    }

    private func bottomBar() -> UIView {
        let bar = UIView()
        bar.backgroundColor = .white
        bar.translatesAutoresizingMaskIntoConstraints = false

        let addMore = UIButton(type: .system)
        addMore.setTitle("음식 추가", for: .normal)
        addMore.setTitleColor(accent, for: .normal)
        addMore.titleLabel?.font = AppTheme.font(16, .black)
        addMore.backgroundColor = accent.withAlphaComponent(0.12)
        addMore.layer.cornerRadius = 18
        addMore.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            let search = FoodSearchViewController(meal: self.meal)
            search.onPick = { [weak self] picked in self?.appendFoods(picked) }
            self.present(search, animated: true)
        }, for: .touchUpInside)
        addMore.translatesAutoresizingMaskIntoConstraints = false
        addMore.heightAnchor.constraint(equalToConstant: 54).isActive = true

        let done = UIButton(type: .system)
        done.setTitle("기록 완료", for: .normal)
        done.setTitleColor(.white, for: .normal)
        done.titleLabel?.font = AppTheme.font(16, .black)
        done.backgroundColor = accent
        done.layer.cornerRadius = 18
        done.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            for i in self.foods.indices {
                let q = Double(self.qty(i))
                let f = self.foods[i]
                HealthStore.shared.addDietEntry(date: Date(), meal: self.meal, name: f.name,
                                                kcal: Double(f.kcal) * q, carb: f.carb * q, protein: f.protein * q, fat: f.fat * q)
            }
            HealthStore.shared.markRecordedToday()
            self.dismissToHome()
        }, for: .touchUpInside)
        done.translatesAutoresizingMaskIntoConstraints = false
        done.heightAnchor.constraint(equalToConstant: 54).isActive = true

        let row = UIStackView(arrangedSubviews: [addMore, done])
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: bar.topAnchor, constant: 10),
            row.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 22),
            row.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -22),
            row.bottomAnchor.constraint(equalTo: bar.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        return bar
    }

    private static func todayText() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: Date())
    }

    /// 검색·식단상세 등 위에 쌓인 모달을 모두 닫고 홈 화면으로 돌아간다.
    private func dismissToHome() {
        if let root = view.window?.rootViewController, root.presentedViewController != nil {
            root.dismiss(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

/// 홈에서 '식단 ›'을 누르면 나오는 식단 상세 화면.
final class DietDetailViewController: UIViewController {
    private let accent = AppTheme.brand
    private let carbColor = AppTheme.brand
    private let proteinColor = UIColor.systemTeal
    private let fatColor = UIColor.systemYellow

    private let goalKcal = 1449
    private let goalCarb = 159.0
    private let goalProtein = 87.0
    private let goalFat = 40.0
    private let mealIcon: [String: (String, UIColor)] = [
        "아침": ("sunrise.fill", .systemOrange),
        "점심": ("sun.max.fill", .systemYellow),
        "저녁": ("moon.fill", .systemTeal),
        "야식": ("moon.stars.fill", .systemIndigo),
        "간식": ("fork.knife", .systemRed)
    ]

    private var date: Date
    private var collapsed: Set<String> = []
    private var totals: (kcal: Int, carb: Double, protein: Double, fat: Double) { HealthStore.shared.dietTotals(date) }

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        build()   // 음식 기록 후 돌아오면 최신 상태로 다시 그린다.
    }

    private func build() {
        view.subviews.forEach { $0.removeFromSuperview() }
        let bar = topBar()
        view.addSubview(bar)

        let topFill = UIView()
        topFill.backgroundColor = accent
        topFill.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(topFill, belowSubview: bar)

        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let body = UIStackView()
        body.axis = .vertical
        body.spacing = 22
        body.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(body)

        body.addArrangedSubview(kcalProgress())
        body.addArrangedSubview(thinDivider())
        body.addArrangedSubview(macroGoalHeader())
        body.addArrangedSubview(macroCircles())
        body.addArrangedSubview(thinDivider())
        body.addArrangedSubview(extraNutrients())
        body.addArrangedSubview(thinDivider())
        body.addArrangedSubview(mealSections())

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
            body.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -40),
            body.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 20),
            body.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -20)
        ])
    }

    private func topBar() -> UIView {
        let bar = UIView()
        bar.backgroundColor = accent
        bar.translatesAutoresizingMaskIntoConstraints = false

        let back = IconButton(symbol: "chevron.left", color: .white, pointSize: 24)
        back.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)
        back.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(back)

        let title = UILabel(AppDateText.mainTitle(for: date), size: 18, weight: .black, color: .white, lines: 1)
        let chevron = UIImageView(symbol: "chevron.down", color: .white, size: 13, weight: .bold)
        let titleGroup = UIStackView(arrangedSubviews: [title, chevron])
        titleGroup.axis = .horizontal
        titleGroup.alignment = .center
        titleGroup.spacing = 5
        titleGroup.isUserInteractionEnabled = true
        titleGroup.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dietDateTapped)))
        titleGroup.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(titleGroup)

        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 16),
            back.widthAnchor.constraint(equalToConstant: 36),
            back.centerYAnchor.constraint(equalTo: titleGroup.centerYAnchor),
            titleGroup.centerXAnchor.constraint(equalTo: bar.centerXAnchor),
            titleGroup.topAnchor.constraint(equalTo: bar.topAnchor, constant: 6),
            titleGroup.bottomAnchor.constraint(equalTo: bar.bottomAnchor, constant: -12)
        ])
        return bar
    }

    @objc private func dietDateTapped() {
        let calendar = CalendarPickerViewController(date: date)
        calendar.onSelect = { [weak self] selected in
            self?.date = selected
            self?.build()
        }
        present(calendar, animated: true)
    }

    private func kcalProgress() -> UIView {
        let eaten = totals.kcal
        let remaining = max(0, goalKcal - eaten)
        let headline = remaining > 0
            ? "\(NumberFormatter.localizedString(from: NSNumber(value: remaining), number: .decimal))kcal 더 먹어도 돼요"
            : "목표 열량을 채웠어요 🎉"
        let head = UILabel(headline, size: 14, weight: .bold, color: AppTheme.muted, lines: 1)

        let value = UILabel()
        let attr = NSMutableAttributedString(string: "\(NumberFormatter.localizedString(from: NSNumber(value: eaten), number: .decimal))", attributes: [
            .font: AppTheme.font(30, .black), .foregroundColor: AppTheme.text
        ])
        attr.append(NSAttributedString(string: " / \(NumberFormatter.localizedString(from: NSNumber(value: goalKcal), number: .decimal))kcal", attributes: [
            .font: AppTheme.font(16, .black), .foregroundColor: AppTheme.muted
        ]))
        value.attributedText = attr

        let plus = IconButton(symbol: "plus.circle.fill", color: accent, pointSize: 34)
        plus.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            let search = FoodSearchViewController(meal: "아침")
            self.present(search, animated: true)
        }, for: .touchUpInside)
        plus.setContentHuggingPriority(.required, for: .horizontal)

        let valueRow = UIStackView(arrangedSubviews: [value, UIView(), plus])
        valueRow.axis = .horizontal
        valueRow.alignment = .center

        let track = UIView()
        track.backgroundColor = AppTheme.softFill
        track.layer.cornerRadius = 6
        track.clipsToBounds = true
        track.translatesAutoresizingMaskIntoConstraints = false
        track.heightAnchor.constraint(equalToConstant: 12).isActive = true
        let fill = UIView()
        fill.backgroundColor = accent
        fill.translatesAutoresizingMaskIntoConstraints = false
        track.addSubview(fill)
        let progress = min(1, max(0.02, Double(eaten) / Double(goalKcal)))
        NSLayoutConstraint.activate([
            fill.topAnchor.constraint(equalTo: track.topAnchor),
            fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            fill.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: progress)
        ])

        let stack = UIStackView(arrangedSubviews: [head, valueRow, track])
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }

    private func macroGoalHeader() -> UIView {
        let title = UILabel("목표 탄단지%", size: 16, weight: .black, color: AppTheme.text, lines: 1)
        let chevron = UIImageView(symbol: "chevron.right", color: AppTheme.muted, size: 12, weight: .bold)
        let row = UIStackView(arrangedSubviews: [title, UIView(), chevron])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
        return row
    }

    private func macroCircles() -> UIView {
        let cCal = totals.carb * 4, pCal = totals.protein * 4, fCal = totals.fat * 9
        let sum = max(cCal + pCal + fCal, 0.0001)
        let pct: (Double) -> Int = { self.totals.kcal > 0 ? Int(round($0 / sum * 100)) : 0 }
        let row = UIStackView(arrangedSubviews: [
            macroCircle("탄", carbColor, pct(cCal), consumed: totals.carb, goal: goalCarb),
            macroCircle("단", proteinColor, pct(pCal), consumed: totals.protein, goal: goalProtein),
            macroCircle("지", fatColor, pct(fCal), consumed: totals.fat, goal: goalFat)
        ])
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 10
        return row
    }

    private func macroCircle(_ letter: String, _ color: UIColor, _ percent: Int, consumed: Double, goal: Double) -> UIView {
        let circle = UILabel(letter, size: 15, weight: .black, color: .white, lines: 1)
        circle.textAlignment = .center
        circle.backgroundColor = color
        circle.layer.cornerRadius = 19
        circle.clipsToBounds = true
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.widthAnchor.constraint(equalToConstant: 38).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 38).isActive = true

        let pctLabel = UILabel("\(percent)%", size: 16, weight: .black, color: AppTheme.text, lines: 1)
        let goalLabel = UILabel("\(Int(round(consumed))) / \(Int(goal))g", size: 12, weight: .semibold, color: AppTheme.muted, lines: 1)
        let textCol = UIStackView(arrangedSubviews: [pctLabel, goalLabel])
        textCol.axis = .vertical
        textCol.spacing = 2

        let stack = UIStackView(arrangedSubviews: [circle, textCol])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 9
        return stack
    }

    private func extraNutrients() -> UIView {
        let stack = UIStackView(arrangedSubviews: [
            nutrientRow("당류", .systemYellow, consumed: "0", goal: "72g"),
            nutrientRow("나트륨", .systemOrange, consumed: "0", goal: "3,000mg"),
            nutrientRow("알코올", .systemPink, consumed: "0", goal: "20g")
        ])
        stack.axis = .vertical
        stack.spacing = 18
        return stack
    }

    private func nutrientRow(_ name: String, _ color: UIColor, consumed: String, goal: String) -> UIView {
        let dot = UILabel(String(name.prefix(1)), size: 12, weight: .black, color: .white, lines: 1)
        dot.textAlignment = .center
        dot.backgroundColor = color
        dot.layer.cornerRadius = 15
        dot.clipsToBounds = true
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.widthAnchor.constraint(equalToConstant: 30).isActive = true
        dot.heightAnchor.constraint(equalToConstant: 30).isActive = true

        let nameLabel = UILabel(name, size: 15, weight: .bold, color: AppTheme.text, lines: 1)
        let value = UILabel()
        value.attributedText = NSAttributedString(string: "\(consumed) / \(goal)", attributes: [
            .font: AppTheme.font(15, .black), .foregroundColor: AppTheme.muted
        ])
        value.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [dot, nameLabel, UIView(), value])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        return row
    }

    private func mealSections() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 26

        var meals = ["아침", "점심", "저녁", "간식"]
        if !HealthStore.shared.dietEntries(for: date, meal: "야식").isEmpty {
            meals.insert("야식", at: 3)
        }
        for meal in meals {
            stack.addArrangedSubview(mealSection(meal))
        }
        return stack
    }

    private func mealSection(_ meal: String) -> UIView {
        let (symbol, color) = mealIcon[meal] ?? ("fork.knife", accent)
        let entries = HealthStore.shared.dietEntries(for: date, meal: meal)
        let isCollapsed = collapsed.contains(meal)

        let titleLabel = UILabel(meal, size: 18, weight: .black, color: AppTheme.text, lines: 1)
        let chevron = UIImageView(symbol: isCollapsed ? "chevron.right" : "chevron.down", color: AppTheme.muted, size: 13, weight: .bold)
        let titleRow = UIStackView(arrangedSubviews: [titleLabel, UIView(), chevron])
        titleRow.axis = .horizontal
        titleRow.alignment = .center

        let bullet = UIView()
        bullet.backgroundColor = proteinColor
        bullet.layer.cornerRadius = 3
        bullet.translatesAutoresizingMaskIntoConstraints = false
        bullet.widthAnchor.constraint(equalToConstant: 6).isActive = true
        bullet.heightAnchor.constraint(equalToConstant: 6).isActive = true
        let note = UILabel(entries.isEmpty ? "아직 기록하지 않았어요" : "나트륨 적게 들었어요.", size: 13, weight: .semibold, color: AppTheme.muted, lines: 1)
        let noteRow = UIStackView(arrangedSubviews: [bullet, note, UIView()])
        noteRow.axis = .horizontal
        noteRow.alignment = .center
        noteRow.spacing = 7

        let textCol = UIStackView(arrangedSubviews: [titleRow, noteRow])
        textCol.axis = .vertical
        textCol.spacing = 9
        // 화살표(헤더)를 눌러 목록 접기/펼치기
        if !entries.isEmpty {
            textCol.isUserInteractionEnabled = true
            textCol.addGestureRecognizer(TapAction { [weak self] in
                guard let self else { return }
                if self.collapsed.contains(meal) { self.collapsed.remove(meal) } else { self.collapsed.insert(meal) }
                self.build()
            })
        }

        let header = UIStackView(arrangedSubviews: [mealTile(symbol: symbol, color: color, meal: meal), textCol])
        header.axis = .horizontal
        header.alignment = .center
        header.spacing = 16

        let section = UIStackView(arrangedSubviews: [header])
        section.axis = .vertical
        section.spacing = 12
        if !isCollapsed {
            // 같은 음식끼리 합쳐서 개수로 표시
            for item in mergedEntries(entries) {
                section.addArrangedSubview(foodEntryRow(name: item.name, count: item.count, kcal: item.kcal))
            }
        }
        return section
    }

    private func mergedEntries(_ entries: [DietEntry]) -> [(name: String, count: Int, kcal: Double)] {
        var order: [String] = []
        var map: [String: (count: Int, kcal: Double)] = [:]
        for entry in entries {
            if map[entry.name] == nil { order.append(entry.name) }
            let current = map[entry.name] ?? (0, 0)
            map[entry.name] = (current.count + 1, current.kcal + entry.kcal)
        }
        return order.map { (name: $0, count: map[$0]!.count, kcal: map[$0]!.kcal) }
    }

    private func mealTile(symbol: String, color: UIColor, meal: String) -> UIView {
        let wrap = UIView()
        wrap.translatesAutoresizingMaskIntoConstraints = false

        let tile = UIButton(type: .system)
        tile.backgroundColor = AppTheme.softFill
        tile.tintColor = color
        tile.layer.cornerRadius = 20
        if meal == "간식" {
            tile.setImage(appleFilledImage(size: 50).withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            tile.setImage(UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium)), for: .normal)
        }
        tile.addAction(UIAction { [weak self] _ in self?.addToMeal(meal) }, for: .touchUpInside)
        tile.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(tile)

        let plus = UIButton(type: .system)
        plus.backgroundColor = accent
        plus.tintColor = .white
        plus.layer.cornerRadius = 11
        plus.layer.borderWidth = 2
        plus.layer.borderColor = UIColor.white.cgColor
        plus.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)), for: .normal)
        plus.addAction(UIAction { [weak self] _ in self?.addToMeal(meal) }, for: .touchUpInside)
        plus.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(plus)

        NSLayoutConstraint.activate([
            tile.widthAnchor.constraint(equalToConstant: 84),
            tile.heightAnchor.constraint(equalToConstant: 84),
            tile.topAnchor.constraint(equalTo: wrap.topAnchor, constant: 6),
            tile.leadingAnchor.constraint(equalTo: wrap.leadingAnchor),
            tile.trailingAnchor.constraint(equalTo: wrap.trailingAnchor),
            tile.bottomAnchor.constraint(equalTo: wrap.bottomAnchor),
            plus.widthAnchor.constraint(equalToConstant: 22),
            plus.heightAnchor.constraint(equalToConstant: 22),
            plus.topAnchor.constraint(equalTo: wrap.topAnchor),
            plus.trailingAnchor.constraint(equalTo: tile.trailingAnchor, constant: 4)
        ])
        return wrap
    }

    private func addToMeal(_ meal: String) {
        present(FoodSearchViewController(meal: meal), animated: true)
    }

    private func foodEntryRow(name: String, count: Int, kcal: Double) -> UIView {
        let title = count > 1 ? "\(name)  ×\(count)" : name
        let nameLabel = UILabel(title, size: 15, weight: .black, color: AppTheme.text, lines: 1)
        let kcalLabel = UILabel("\(Int(kcal)) kcal", size: 14, weight: .bold, color: AppTheme.muted, lines: 1)
        kcalLabel.setContentHuggingPriority(.required, for: .horizontal)
        let chevron = UIImageView(symbol: "chevron.down", color: AppTheme.muted, size: 12, weight: .bold)

        let row = UIStackView(arrangedSubviews: [nameLabel, UIView(), kcalLabel, chevron])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 10
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 14)
        row.backgroundColor = AppTheme.softFill
        row.layer.cornerRadius = 16
        return row
    }

    private func thinDivider() -> UIView {
        let line = UIView()
        line.backgroundColor = UIColor(red: 0.92, green: 0.93, blue: 0.95, alpha: 1)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }
}

/// 식단 검색의 '직접 등록'에서 나오는 음식 직접 입력 화면.
final class CustomFoodViewController: UIViewController {
    var onSave: ((FoodItem) -> Void)?

    private let accent = AppTheme.brand
    private let borderColor = UIColor(red: 0.89, green: 0.90, blue: 0.93, alpha: 1)
    private let units = ["g", "ml", "개", "인분", "컵"]
    private var unit = "g"

    private let nameField = UITextField()
    private let amountField = UITextField()
    private let kcalField = UITextField()
    private let carbField = UITextField()
    private let proteinField = UITextField()
    private let fatField = UITextField()
    private let doneButton = UIButton(type: .system)

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

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

        let titleLabel = UILabel("직접 입력", size: 18, weight: .black, color: AppTheme.text, lines: 1)
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
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        // 음식명
        stack.addArrangedSubview(sectionTitle("음식명", required: true))
        placeholder(nameField, "음식명")
        styleField(nameField, keyboard: .default)
        nameField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        stack.addArrangedSubview(nameField)
        stack.setCustomSpacing(22, after: nameField)

        // 내용량 + 단위
        stack.addArrangedSubview(sectionTitle("내용량", required: true))
        placeholder(amountField, "0")
        styleField(amountField, keyboard: .decimalPad)
        amountField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        let amountRow = UIStackView(arrangedSubviews: [amountField, unitDropdown()])
        amountRow.axis = .horizontal
        amountRow.spacing = 12
        amountRow.distribution = .fillEqually
        stack.addArrangedSubview(amountRow)
        stack.setCustomSpacing(26, after: amountRow)

        // 영양정보
        stack.addArrangedSubview(sectionTitle("영양정보", required: false))
        let infoNote = UILabel("성분표에 함량이 0으로 나와있는 성분은 아래에 0으로 적어주세요.\n(빈칸 말고 0으로 적어주시면 돼요!)", size: 12, weight: .semibold, color: AppTheme.muted, lines: 0)
        infoNote.adjustsFontSizeToFitWidth = false
        let infoBox = UIView()
        infoBox.backgroundColor = AppTheme.softFill
        infoBox.layer.cornerRadius = 12
        infoNote.translatesAutoresizingMaskIntoConstraints = false
        infoBox.addSubview(infoNote)
        NSLayoutConstraint.activate([
            infoNote.topAnchor.constraint(equalTo: infoBox.topAnchor, constant: 12),
            infoNote.bottomAnchor.constraint(equalTo: infoBox.bottomAnchor, constant: -12),
            infoNote.leadingAnchor.constraint(equalTo: infoBox.leadingAnchor, constant: 14),
            infoNote.trailingAnchor.constraint(equalTo: infoBox.trailingAnchor, constant: -14)
        ])
        stack.addArrangedSubview(infoBox)
        stack.setCustomSpacing(20, after: infoBox)

        // 열량
        stack.addArrangedSubview(sectionTitle("열량", required: true))
        styleField(kcalField, keyboard: .numberPad, suffix: "kcal")
        kcalField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        stack.addArrangedSubview(kcalField)
        stack.setCustomSpacing(18, after: kcalField)

        // 탄단지
        stack.addArrangedSubview(sectionTitle("탄수화물", required: false))
        styleField(carbField, keyboard: .decimalPad, suffix: "g")
        stack.addArrangedSubview(carbField)
        stack.setCustomSpacing(18, after: carbField)

        stack.addArrangedSubview(sectionTitle("단백질", required: false))
        styleField(proteinField, keyboard: .decimalPad, suffix: "g")
        stack.addArrangedSubview(proteinField)
        stack.setCustomSpacing(18, after: proteinField)

        stack.addArrangedSubview(sectionTitle("지방", required: false))
        styleField(fatField, keyboard: .decimalPad, suffix: "g")
        stack.addArrangedSubview(fatField)

        doneButton.setTitle("완료", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.titleLabel?.font = AppTheme.font(18, .black)
        doneButton.layer.cornerRadius = 16
        doneButton.addAction(UIAction { [weak self] _ in self?.save() }, for: .touchUpInside)
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

    private func unitDropdown() -> UIView {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(unit, attributes: AttributeContainer([.font: AppTheme.font(15, .bold)]))
        config.image = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .bold))
        config.imagePlacement = .trailing
        config.baseForegroundColor = AppTheme.text
        config.titleAlignment = .leading
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        button.configuration = config
        button.contentHorizontalAlignment = .fill
        button.menu = UIMenu(children: units.map { option in
            UIAction(title: option, state: option == unit ? .on : .off) { [weak self] _ in
                self?.unit = option
                self?.refreshUnit()
            }
        })
        button.showsMenuAsPrimaryAction = true
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = borderColor.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 52).isActive = true
        button.tag = 7788
        return button
    }

    private func refreshUnit() {
        if let button = view.viewWithTag(7788) as? UIButton {
            button.configuration?.attributedTitle = AttributedString(unit, attributes: AttributeContainer([.font: AppTheme.font(15, .bold)]))
        }
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

    private func placeholder(_ field: UITextField, _ text: String, alignRight: Bool = false) {
        field.attributedPlaceholder = NSAttributedString(string: text,
            attributes: [.foregroundColor: AppTheme.muted, .font: AppTheme.font(15, .semibold)])
        if alignRight { field.textAlignment = .right }
    }

    private func styleField(_ field: UITextField, keyboard: UIKeyboardType, suffix: String? = nil) {
        field.font = AppTheme.font(15, .black)
        field.textColor = AppTheme.text
        field.backgroundColor = .white
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = borderColor.cgColor
        field.keyboardType = keyboard
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        field.leftViewMode = .always
        if let suffix {
            let label = UILabel(suffix, size: 14, weight: .bold, color: AppTheme.muted, lines: 1)
            let wrap = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 20))
            label.frame = CGRect(x: 6, y: 0, width: 34, height: 20)
            wrap.addSubview(label)
            field.rightView = wrap
            field.rightViewMode = .always
            field.textAlignment = .right
        }
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 52).isActive = true
    }

    @objc private func textChanged() { updateDoneState() }

    private func updateDoneState() {
        let valid = !(nameField.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty
            && !(amountField.text ?? "").isEmpty
            && !(kcalField.text ?? "").isEmpty
        doneButton.backgroundColor = valid ? accent : UIColor(red: 0.78, green: 0.82, blue: 0.86, alpha: 1)
        doneButton.isEnabled = valid
    }

    private func number(_ field: UITextField) -> Double {
        Double((field.text ?? "").filter { $0.isNumber || $0 == "." }) ?? 0
    }

    private func save() {
        let name = (nameField.text ?? "").trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let amount = (amountField.text ?? "").filter { $0.isNumber || $0 == "." }
        let food = FoodItem(
            name: name,
            portion: "\(amount.isEmpty ? "1" : amount)\(unit)",
            kcal: Int(number(kcalField)),
            carb: number(carbField),
            protein: number(proteinField),
            fat: number(fatField)
        )
        onSave?(food)
        dismiss(animated: true)
    }
}

/// 클로저로 동작하는 탭 제스처 (뷰에 강한 참조로 보관됨).
