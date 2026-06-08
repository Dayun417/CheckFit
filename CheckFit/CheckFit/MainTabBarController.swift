//
//  MainTabBarController.swift
//  CheckFit
//

import UIKit

final class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    private let centerButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        if viewControllers?.isEmpty ?? true {
            configureTabs()
        } else {
            configureStoryboardTabs()
        }
        configureAppearance()
        configureCenterButton()
    }

    private func configureStoryboardTabs() {
        let normalIconConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let selectedIconConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let items: [(String, String, String)] = [
            ("내 건강", "heart", "heart.fill"),
            ("미션", "flag", "flag.fill"),
            ("", "plus", "plus"),
            ("콘텐츠", "square.grid.2x2", "square.grid.2x2.fill"),
            ("마이페이지", "person", "person.fill")
        ]

        viewControllers?.enumerated().forEach { index, viewController in
            guard index < items.count else { return }
            let itemInfo = items[index]
            let item = UITabBarItem(
                title: itemInfo.0,
                image: UIImage(systemName: itemInfo.1, withConfiguration: normalIconConfig)?.withRenderingMode(.alwaysTemplate),
                selectedImage: UIImage(systemName: itemInfo.2, withConfiguration: selectedIconConfig)?.withRenderingMode(.alwaysTemplate)
            )
            item.tag = index
            item.imageInsets = UIEdgeInsets(top: 2, left: 0, bottom: -2, right: 0)
            if index == 2 {
                item.image = UIImage()
                item.selectedImage = UIImage()
                item.isEnabled = false
            }
            viewController.tabBarItem = item
        }
    }

    private func configureTabs() {
        let normalIconConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let selectedIconConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let screens: [(UIViewController, String, String, String)] = [
            (HealthViewController(), "내 건강", "heart", "heart.fill"),
            (MissionViewController(), "미션", "flag", "flag.fill"),
            (UIViewController(), "", "plus", "plus"),
            (ContentViewController(), "콘텐츠", "square.grid.2x2", "square.grid.2x2.fill"),
            (MyPageViewController(), "마이페이지", "person", "person.fill")
        ]

        viewControllers = screens.enumerated().map { index, screen in
            let item = UITabBarItem(
                title: screen.1,
                image: UIImage(systemName: screen.2, withConfiguration: normalIconConfig)?.withRenderingMode(.alwaysTemplate),
                selectedImage: UIImage(systemName: screen.3, withConfiguration: selectedIconConfig)?.withRenderingMode(.alwaysTemplate)
            )
            item.tag = index
            item.imageInsets = UIEdgeInsets(top: 2, left: 0, bottom: -2, right: 0)
            if index == 2 {
                item.image = UIImage()
                item.selectedImage = UIImage()
                item.isEnabled = false
            }
            screen.0.tabBarItem = item
            return screen.0
        }
    }

    private func configureAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.97)
        appearance.shadowColor = UIColor.systemGray5

        let normal: [NSAttributedString.Key: Any] = [
            .font: AppTheme.font(10, .bold),
            .foregroundColor: UIColor.systemGray3
        ]
        let selected: [NSAttributedString.Key: Any] = [
            .font: AppTheme.font(10, .bold),
            .foregroundColor: AppTheme.brand
        ]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray3
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normal
        appearance.stackedLayoutAppearance.selected.iconColor = AppTheme.brand
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selected

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = AppTheme.brand
        tabBar.unselectedItemTintColor = UIColor.systemGray3
        tabBar.itemPositioning = .fill
        tabBar.isTranslucent = false
    }

    private func configureCenterButton() {
        centerButton.translatesAutoresizingMaskIntoConstraints = false
        centerButton.backgroundColor = AppTheme.brand
        centerButton.tintColor = .white
        centerButton.layer.cornerRadius = 29
        centerButton.layer.borderWidth = 0
        centerButton.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .semibold))?.withRenderingMode(.alwaysTemplate), for: .normal)
        centerButton.addAction(UIAction { [weak self] _ in self?.presentQuickAdd() }, for: .touchUpInside)
        view.addSubview(centerButton)

        NSLayoutConstraint.activate([
            centerButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            centerButton.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -8),
            centerButton.widthAnchor.constraint(equalToConstant: 58),
            centerButton.heightAnchor.constraint(equalToConstant: 58)
        ])
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let index = viewControllers?.firstIndex(of: viewController), index == 2 else {
            return true
        }
        presentQuickAdd()
        return false
    }

    private func presentQuickAdd() {
        let sheet = QuickAddMenuViewController()
        sheet.modalPresentationStyle = .overFullScreen
        sheet.modalTransitionStyle = .crossDissolve
        sheet.onSelect = { [weak self] option in
            self?.dismiss(animated: true) {
                switch option {
                case .weight:
                    self?.selectedIndex = 0
                    (self?.viewControllers?.first as? HealthViewController)?.presentWeightDetail()
                case .water:
                    self?.selectedIndex = 0
                    (self?.viewControllers?.first as? HealthViewController)?.presentWaterDetail()
                case .exercise:
                    self?.selectedIndex = 0
                    (self?.viewControllers?.first as? HealthViewController)?.presentExerciseSearch()
                case .meal:
                    self?.selectedIndex = 0
                    (self?.viewControllers?.first as? HealthViewController)?.presentFoodSearch(meal: "아침")
                }
            }
        }
        present(sheet, animated: true)
    }
}

final class QuickAddMenuViewController: UIViewController {
    enum Option { case weight, water, exercise, meal }

    var onSelect: ((Option) -> Void)?
    private let sheetView = UIView()
    private var didAnimateIn = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        build()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !didAnimateIn else { return }
        view.alpha = 0
        sheetView.transform = CGAffineTransform(translationX: 0, y: 320)
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
        dim.backgroundColor = UIColor.black.withAlphaComponent(0.18)
        dim.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dim)

        sheetView.applyCard(radius: 40, shadow: true)
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sheetView)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 28
        stack.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(stack)

        let top = UIStackView()
        top.axis = .horizontal
        top.alignment = .center
        top.distribution = .equalSpacing
        top.addArrangedSubview(UILabel("기록하기 📝", size: 26, weight: .black))
        let close = IconButton(symbol: "xmark", color: AppTheme.muted, pointSize: 24, weight: .medium)
        close.addAction(UIAction { [weak self] _ in self?.dismissSheet() }, for: .touchUpInside)
        top.addArrangedSubview(close)
        stack.addArrangedSubview(top)

        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 18
        row.addArrangedSubview(action("waveform.path.ecg", "체중", .systemPink, .weight))
        row.addArrangedSubview(action("drop", "수분", .systemBlue, .water))
        row.addArrangedSubview(action("figure.strengthtraining.traditional", "운동", AppTheme.brand, .exercise))
        row.addArrangedSubview(action("fork.knife", "식단", .systemOrange, .meal))
        stack.addArrangedSubview(row)

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
            stack.topAnchor.constraint(equalTo: sheetView.topAnchor, constant: 36),
            stack.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -32),
            stack.bottomAnchor.constraint(equalTo: sheetView.safeAreaLayoutGuide.bottomAnchor, constant: -30)
        ])
    }

    private func dismissSheet() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn]) {
            self.view.alpha = 0
            self.sheetView.transform = CGAffineTransform(translationX: 0, y: 320)
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }

    private func action(_ symbol: String, _ title: String, _ color: UIColor, _ option: Option) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12

        let button = UIButton(type: .system)
        button.backgroundColor = AppTheme.softFill
        button.tintColor = color
        button.layer.cornerRadius = 20
        button.setImage(UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)), for: .normal)
        button.addAction(UIAction { [weak self] _ in self?.onSelect?(option) }, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 66),
            button.heightAnchor.constraint(equalToConstant: 66)
        ])

        stack.addArrangedSubview(button)
        stack.addArrangedSubview(UILabel(title, size: 14, weight: .black))
        return stack
    }
}
