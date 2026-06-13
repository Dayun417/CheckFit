//
//  SearchListViewController.swift
//  CheckFit
//
//  운동 검색 목록 화면 + 정렬 시트
//

import UIKit

final class SearchListViewController: UIViewController {
    private let placeholder: String
    private let tabs: [String]
    private let rows: [String]
    private let actionTitle: String
    private let marksStreak: Bool
    private var selectedTabIndex = 1
    private var favorites = Set<String>()
    private var selectedExercises = Set<String>()
    private var sortMode = "최신순"
    private var searchText = ""
    private weak var listStack: UIStackView?
    private weak var searchFieldRef: UITextField?
    private let tabAccent = AppTheme.brand

    /// 설정 시, '기록하기'가 이 콜백으로 선택 운동을 넘기고 닫힌다(기록 상세 화면에서 운동 추가용).
    var onRecord: (([String]) -> Void)?

    static func exercise() -> SearchListViewController {
        SearchListViewController(
            placeholder: "운동 이름을 검색해주세요",
            tabs: ["분류", "전체", "자주 했어요", "즐겨찾기", "직접 등록"],
            rows: ["러닝(빠르게 달리기)", "리버스 컬 (덤벨)", "마이마운틴", "검도", "플라잉요가", "스피닝", "폴댄스"],
            actionTitle: "기록하기",
            marksStreak: true
        )
    }

    private init(placeholder: String, tabs: [String], rows: [String], actionTitle: String, marksStreak: Bool = false) {
        self.placeholder = placeholder
        self.tabs = tabs
        self.rows = rows
        self.actionTitle = actionTitle
        self.marksStreak = marksStreak
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 화면이 뜨면 검색창에 바로 포커스를 줘 키보드를 띄운다.
        searchFieldRef?.becomeFirstResponder()
    }

    private func build() {
        view.subviews.forEach { $0.removeFromSuperview() }
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let top = UIStackView()
        top.axis = .horizontal
        top.alignment = .center
        top.spacing = 8
        top.isLayoutMarginsRelativeArrangement = true
        top.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 10, right: 16)
        let back = IconButton(symbol: "chevron.left", color: AppTheme.text, pointSize: 24)
        back.addAction(UIAction { [weak self] _ in self?.dismiss(animated: true) }, for: .touchUpInside)
        back.contentHorizontalAlignment = .leading
        back.setContentHuggingPriority(.required, for: .horizontal)
        back.setContentCompressionResistancePriority(.required, for: .horizontal)
        back.widthAnchor.constraint(equalToConstant: 32).isActive = true
        top.addArrangedSubview(back)
        top.addArrangedSubview(searchField())
        stack.addArrangedSubview(top)

        let tabRow = UIStackView()
        tabRow.axis = .horizontal
        tabRow.alignment = .center
        tabRow.spacing = 13
        tabRow.isLayoutMarginsRelativeArrangement = true
        tabRow.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 10, right: 12)

        let categoryLabel = UILabel(tabs[0], size: 14, weight: .black, color: AppTheme.muted, lines: 1)
        categoryLabel.adjustsFontSizeToFitWidth = false
        tabRow.addArrangedSubview(categoryLabel)
        let divider = UIView()
        divider.backgroundColor = UIColor(red: 0.86, green: 0.87, blue: 0.90, alpha: 1)
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.widthAnchor.constraint(equalToConstant: 1).isActive = true
        divider.heightAnchor.constraint(equalToConstant: 18).isActive = true
        tabRow.addArrangedSubview(divider)
        for index in 1..<tabs.count {
            tabRow.addArrangedSubview(tabItem(title: tabs[index], index: index))
        }
        tabRow.addArrangedSubview(UIView())
        stack.addArrangedSubview(tabRow)

        let filterRow = UIStackView()
        filterRow.axis = .horizontal
        filterRow.alignment = .center
        filterRow.spacing = 18
        filterRow.isLayoutMarginsRelativeArrangement = true
        filterRow.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 22)
        filterRow.addArrangedSubview(sortChip())
        filterRow.addArrangedSubview(UIView())
        filterRow.addArrangedSubview(favoriteChip())
        let filterWrap = UIView()
        filterWrap.backgroundColor = AppTheme.background
        filterRow.translatesAutoresizingMaskIntoConstraints = false
        filterWrap.addSubview(filterRow)
        filterWrap.heightAnchor.constraint(equalToConstant: 52).isActive = true
        filterWrap.setContentCompressionResistancePriority(.required, for: .vertical)
        NSLayoutConstraint.activate([
            filterRow.centerYAnchor.constraint(equalTo: filterWrap.centerYAnchor),
            filterRow.leadingAnchor.constraint(equalTo: filterWrap.leadingAnchor),
            filterRow.trailingAnchor.constraint(equalTo: filterWrap.trailingAnchor)
        ])
        stack.addArrangedSubview(filterWrap)

        let list = UIStackView()
        list.axis = .vertical
        list.translatesAutoresizingMaskIntoConstraints = false
        listStack = list
        populateList()
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.addSubview(list)
        view.addSubview(scroll)

        let action = UIButton(type: .system)
        action.setTitle(actionTitle, for: .normal)
        action.titleLabel?.font = AppTheme.font(16, .black)
        action.tintColor = AppTheme.brand
        action.backgroundColor = AppTheme.brand.withAlphaComponent(0.10)
        action.layer.cornerRadius = 18
        action.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            if self.marksStreak && !self.selectedExercises.isEmpty {
                let names = Array(self.selectedExercises)
                if let onRecord = self.onRecord {
                    onRecord(names)
                    self.dismiss(animated: true)
                } else {
                    self.present(ExerciseRecordDetailViewController(exercises: names), animated: true)
                }
            } else {
                if self.marksStreak { HealthStore.shared.markRecordedToday() }
                self.dismiss(animated: true)
            }
        }, for: .touchUpInside)
        action.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(action)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scroll.topAnchor.constraint(equalTo: stack.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: action.topAnchor, constant: -12),

            list.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            list.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            list.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor),
            list.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor),

            action.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            action.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            action.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            action.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    /// 현재 탭·정렬·검색어에 맞춰 리스트만 다시 채운다. (검색 필드 포커스를 잃지 않도록 전체 build()를 피한다)
    private func populateList() {
        guard let list = listStack else { return }
        list.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let currentTab = tabs.indices.contains(selectedTabIndex) ? tabs[selectedTabIndex] : ""
        if currentTab == "직접 등록" {
            list.addArrangedSubview(registerButton())
            return
        }

        var displayedRows = currentTab == "즐겨찾기" ? rows.filter { favorites.contains($0) } : rows
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        if !query.isEmpty {
            displayedRows = displayedRows.filter { $0.lowercased().contains(query) }
        }
        if sortMode == "빈도순" { displayedRows.reverse() }

        if displayedRows.isEmpty {
            let empty = UILabel("검색 결과가 없어요 🔍", size: 16, weight: .bold, color: AppTheme.muted, lines: 1)
            empty.textAlignment = .center
            empty.translatesAutoresizingMaskIntoConstraints = false
            let wrap = UIView()
            wrap.addSubview(empty)
            NSLayoutConstraint.activate([
                empty.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
                empty.topAnchor.constraint(equalTo: wrap.topAnchor, constant: 48),
                empty.bottomAnchor.constraint(equalTo: wrap.bottomAnchor, constant: -48)
            ])
            list.addArrangedSubview(wrap)
            return
        }

        for row in displayedRows {
            list.addArrangedSubview(rowView(row))
        }
    }

    @objc private func searchChanged(_ field: UITextField) {
        searchText = field.text ?? ""
        populateList()
    }

    private func searchField() -> UITextField {
        let field = UITextField()
        field.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: AppTheme.muted, .font: AppTheme.font(14, .semibold)]
        )
        field.backgroundColor = AppTheme.softFill
        field.layer.cornerRadius = 22
        field.font = AppTheme.font(14, .semibold)
        field.text = searchText
        field.clearButtonMode = .whileEditing
        field.returnKeyType = .search
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.addTarget(self, action: #selector(searchChanged(_:)), for: .editingChanged)
        searchFieldRef = field

        // 돋보기 아이콘은 프레임 기반으로 만든다. (UIImageView(symbol:) 편의 생성자는
        // Auto Layout 제약을 붙여 leftView가 필드 전체 폭으로 늘어나 텍스트/커서 영역을 0폭으로 밀어낸다.)
        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass",
                                              withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)))
        icon.tintColor = AppTheme.muted
        icon.contentMode = .center
        icon.frame = CGRect(x: 16, y: 13, width: 20, height: 20)
        let leftWrap = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 46))
        leftWrap.addSubview(icon)
        field.leftView = leftWrap
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 46).isActive = true
        return field
    }

    private func tabItem(title: String, index: Int) -> UIView {
        let selected = index == selectedTabIndex
        let label = UILabel(title, size: 14, weight: .black, color: selected ? tabAccent : AppTheme.muted, lines: 1)
        label.adjustsFontSizeToFitWidth = false
        label.textAlignment = .center
        label.tag = index
        label.isUserInteractionEnabled = true
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tabItemTapped(_:))))
        return label
    }

    @objc private func tabItemTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag, index != selectedTabIndex else { return }
        selectedTabIndex = index
        build()
    }

    private func sortChip() -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 5
        row.addArrangedSubview(UILabel(sortMode, size: 13, weight: .bold, color: AppTheme.muted, lines: 1))
        let chevron = UIImageView(symbol: "chevron.down", color: AppTheme.muted, size: 10, weight: .bold)
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        row.addArrangedSubview(chevron)
        row.isUserInteractionEnabled = true
        row.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sortChipTapped)))
        return row
    }

    @objc private func sortChipTapped() {
        let sheet = SortOptionSheetViewController(options: ["최신순", "빈도순"], selected: sortMode)
        sheet.onSelect = { [weak self] option in
            self?.sortMode = option
            self?.build()
        }
        present(sheet, animated: true)
    }

    /// 운동 종류에 맞는 동작 아이콘(SF Symbol).
    private func exerciseSymbol(for name: String) -> String {
        func has(_ keys: [String]) -> Bool { keys.contains { name.contains($0) } }
        if has(["러닝", "달리기", "마라톤", "조깅", "트레드밀"]) { return "figure.run" }
        if has(["걷기", "워킹"]) { return "figure.walk" }
        if has(["자전거", "사이클", "스피닝", "마운틴"]) { return "figure.indoor.cycle" }
        if has(["수영"]) { return "figure.pool.swim" }
        if has(["복싱"]) { return "figure.boxing" }
        if has(["줄넘기"]) { return "figure.jumprope" }
        if has(["등산", "클라이밍"]) { return "figure.climbing" }
        if has(["요가"]) { return "figure.yoga" }
        if has(["필라테스", "스트레칭"]) { return "figure.flexibility" }
        if has(["검도", "태권", "유도", "무술"]) { return "figure.martial.arts" }
        if has(["댄스", "폴"]) { return "figure.dance" }
        if has(["덤벨", "바벨", "컬", "프레스", "스쿼트", "데드", "레그", "로우", "익스텐션", "머신", "리프트", "플라이", "웨이트"]) { return "figure.strengthtraining.traditional" }
        return "figure.mixed.cardio"
    }

    private func favoriteChip() -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 5
        let check = UIImageView(symbol: "checkmark", color: AppTheme.muted, size: 12, weight: .bold)
        check.setContentHuggingPriority(.required, for: .horizontal)
        row.addArrangedSubview(check)
        row.addArrangedSubview(UILabel("즐겨찾기", size: 13, weight: .bold, color: AppTheme.muted, lines: 1))
        return row
    }

    private func rowView(_ text: String) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 14
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 15, left: 22, bottom: 15, right: 22)
        let isFood = text.contains("kcal")
        let selected = selectedExercises.contains(text)
        row.addArrangedSubview(symbolTile(symbol: isFood ? "fork.knife" : exerciseSymbol(for: text), color: isFood ? .systemOrange : AppTheme.brand, size: 50, corner: 18))
        row.addArrangedSubview(UILabel(text, size: 15, weight: .black, color: selected ? AppTheme.brand : AppTheme.text, lines: 1))
        row.addArrangedSubview(UIView())

        if isFood {
            row.addArrangedSubview(UIImageView(symbol: "plus.circle.fill", color: AppTheme.brand, size: 22, weight: .medium))
        } else {
            let isFav = favorites.contains(text)
            let star = UIButton(type: .system)
            star.setImage(UIImage(systemName: isFav ? "star.fill" : "star",
                                  withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)), for: .normal)
            star.tintColor = isFav ? UIColor.systemYellow : UIColor.systemGray3
            star.addAction(UIAction { [weak self] _ in self?.toggleFavorite(text) }, for: .touchUpInside)
            star.setContentHuggingPriority(.required, for: .horizontal)
            star.widthAnchor.constraint(equalToConstant: 32).isActive = true
            row.addArrangedSubview(star)
        }

        let container = UIView()
        container.backgroundColor = selected ? AppTheme.brand.withAlphaComponent(0.08) : .clear
        row.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: container.topAnchor),
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        container.isUserInteractionEnabled = true
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rowTapped(_:))))
        objc_setAssociatedObject(container, &SearchListViewController.rowKey, text, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return container
    }

    private static var rowKey: UInt8 = 0

    @objc private func rowTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view,
              let text = objc_getAssociatedObject(view, &SearchListViewController.rowKey) as? String else { return }
        // 운동은 한 번에 하나만 선택할 수 있다.
        if selectedExercises.contains(text) { selectedExercises.removeAll() } else { selectedExercises = [text] }
        build()
    }

    private func toggleFavorite(_ text: String) {
        if favorites.contains(text) {
            favorites.remove(text)
        } else {
            favorites.insert(text)
        }
        build()
    }

    private func registerButton() -> UIView {
        let button = UIButton(type: .system)
        button.setTitle("직접 등록  +", for: .normal)
        button.setTitleColor(AppTheme.brand, for: .normal)
        button.titleLabel?.font = AppTheme.font(16, .black)
        button.backgroundColor = AppTheme.brand.withAlphaComponent(0.10)
        button.layer.cornerRadius = 16
        button.addAction(UIAction { [weak self] _ in
            self?.present(CustomExerciseViewController(), animated: true)
        }, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true

        let wrap = UIView()
        wrap.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: wrap.topAnchor, constant: 18),
            button.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: wrap.bottomAnchor)
        ])
        return wrap
    }
}
final class SortOptionSheetViewController: UIViewController {
    var onSelect: ((String) -> Void)?
    private let options: [String]
    private let selected: String

    init(options: [String], selected: String) {
        self.options = options
        self.selected = selected
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { _ in CGFloat(64 + options.count * 56 + 24) }]
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

        let title = UILabel("정렬", size: 18, weight: .black, color: AppTheme.text, lines: 1)
        title.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(title)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        for option in options {
            let isSelected = option == selected
            let label = UILabel(option, size: 16, weight: isSelected ? .black : .semibold,
                                color: isSelected ? AppTheme.brand : AppTheme.text, lines: 1)
            let check = UIImageView(symbol: "checkmark", color: AppTheme.brand, size: 15, weight: .bold)
            check.isHidden = !isSelected
            check.setContentHuggingPriority(.required, for: .horizontal)
            let row = UIStackView(arrangedSubviews: [label, UIView(), check])
            row.axis = .horizontal
            row.alignment = .center
            row.isLayoutMarginsRelativeArrangement = true
            row.layoutMargins = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
            row.heightAnchor.constraint(equalToConstant: 56).isActive = true
            row.isUserInteractionEnabled = true
            row.addGestureRecognizer(TapAction { [weak self] in
                self?.onSelect?(option)
                self?.dismiss(animated: true)
            })
            stack.addArrangedSubview(row)
        }

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
}

/// 단식 상세의 톱니바퀴를 누르면 나오는 '내 단식 루틴' 화면.
