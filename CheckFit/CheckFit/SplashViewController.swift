//
//  SplashViewController.swift
//  CheckFit
//
//  앱 실행 시 홈 화면 전에 잠깐 보여주는 로고 스플래시 화면.
//

import UIKit

final class SplashViewController: UIViewController {
    private let onFinish: () -> Void

    private let halo = UIView()
    private let badge = UIView()
    private let gradientLayer = CAGradientLayer()
    private let glossLayer = CAGradientLayer()
    private let checkLayer = CAShapeLayer()
    private let wordmark = UILabel()
    private let tagline = UILabel()
    private var didAnimate = false

    // 민트 → 브랜드 그린 그라데이션 색
    private let mint = UIColor(red: 0.18, green: 0.82, blue: 0.58, alpha: 1.0)
    private let deep = UIColor(red: 0.02, green: 0.52, blue: 0.34, alpha: 1.0)

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        buildLogo()
    }

    private func buildLogo() {
        // 배지 뒤의 은은한 후광 링
        halo.backgroundColor = .clear
        halo.layer.borderColor = AppTheme.brand.withAlphaComponent(0.10).cgColor
        halo.layer.borderWidth = 1.5
        halo.alpha = 0
        halo.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(halo)

        // 그라데이션 라운드 배지 (앱 아이콘 느낌의 squircle)
        badge.backgroundColor = .clear
        badge.layer.cornerRadius = 31
        badge.layer.cornerCurve = .continuous
        badge.layer.shadowColor = AppTheme.brand.cgColor
        badge.layer.shadowOpacity = 0.4
        badge.layer.shadowRadius = 26
        badge.layer.shadowOffset = CGSize(width: 0, height: 14)
        badge.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(badge)

        gradientLayer.colors = [mint.cgColor, deep.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.1, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.9, y: 1.0)
        gradientLayer.cornerRadius = 31
        gradientLayer.cornerCurve = .continuous
        gradientLayer.masksToBounds = true
        badge.layer.addSublayer(gradientLayer)

        // 상단 광택 하이라이트
        glossLayer.colors = [
            UIColor.white.withAlphaComponent(0.28).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
        glossLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        glossLayer.endPoint = CGPoint(x: 0.5, y: 0.55)
        glossLayer.cornerRadius = 31
        glossLayer.cornerCurve = .continuous
        glossLayer.masksToBounds = true
        badge.layer.addSublayer(glossLayer)

        // "CheckFit" 워드마크 — Check(다크) + Fit(브랜드 그린), 자간 다듬음
        let attr = NSMutableAttributedString(
            string: "Check",
            attributes: [.foregroundColor: AppTheme.text,
                         .font: AppTheme.font(36, .heavy),
                         .kern: 0.5])
        attr.append(NSAttributedString(
            string: "Fit",
            attributes: [.foregroundColor: AppTheme.brand,
                         .font: AppTheme.font(36, .heavy),
                         .kern: 0.5]))
        wordmark.attributedText = attr
        wordmark.alpha = 0
        wordmark.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(wordmark)

        tagline.text = "나만의 건강 기록지"
        tagline.font = AppTheme.font(14, .semibold)
        tagline.textColor = AppTheme.muted
        tagline.alpha = 0
        tagline.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tagline)

        NSLayoutConstraint.activate([
            badge.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            badge.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -56),
            badge.widthAnchor.constraint(equalToConstant: 112),
            badge.heightAnchor.constraint(equalToConstant: 112),

            halo.centerXAnchor.constraint(equalTo: badge.centerXAnchor),
            halo.centerYAnchor.constraint(equalTo: badge.centerYAnchor),
            halo.widthAnchor.constraint(equalToConstant: 188),
            halo.heightAnchor.constraint(equalToConstant: 188),

            wordmark.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            wordmark.topAnchor.constraint(equalTo: badge.bottomAnchor, constant: 26),

            tagline.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tagline.topAnchor.constraint(equalTo: wordmark.bottomAnchor, constant: 9)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        halo.layer.cornerRadius = halo.bounds.width / 2
        gradientLayer.frame = badge.bounds
        glossLayer.frame = badge.bounds

        // 배지 크기가 정해진 뒤 체크마크 경로를 그린다.
        guard checkLayer.superlayer == nil, badge.bounds.width > 0 else { return }
        let b = badge.bounds
        let path = UIBezierPath()
        path.move(to: CGPoint(x: b.width * 0.29, y: b.height * 0.52))
        path.addLine(to: CGPoint(x: b.width * 0.44, y: b.height * 0.67))
        path.addLine(to: CGPoint(x: b.width * 0.73, y: b.height * 0.34))
        checkLayer.path = path.cgPath
        checkLayer.strokeColor = UIColor.white.cgColor
        checkLayer.fillColor = UIColor.clear.cgColor
        checkLayer.lineWidth = 12
        checkLayer.lineCap = .round
        checkLayer.lineJoin = .round
        checkLayer.strokeEnd = 0
        checkLayer.shadowColor = UIColor.black.cgColor
        checkLayer.shadowOpacity = 0.18
        checkLayer.shadowRadius = 3
        checkLayer.shadowOffset = CGSize(width: 0, height: 2)
        badge.layer.addSublayer(checkLayer)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runIntro()
    }

    private func runIntro() {
        guard !didAnimate else { return }
        didAnimate = true

        // 배지 팝인
        badge.alpha = 0
        badge.transform = CGAffineTransform(scaleX: 0.66, y: 0.66)
        UIView.animate(withDuration: 0.6, delay: 0.05,
                       usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5,
                       options: [.curveEaseOut]) {
            self.badge.alpha = 1
            self.badge.transform = .identity
        }

        // 후광 링이 살짝 퍼지며 페이드
        halo.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        UIView.animate(withDuration: 0.9, delay: 0.15, options: [.curveEaseOut]) {
            self.halo.alpha = 1
            self.halo.transform = .identity
        }

        // 체크마크 그려지는 애니메이션
        let stroke = CABasicAnimation(keyPath: "strokeEnd")
        stroke.fromValue = 0
        stroke.toValue = 1
        stroke.duration = 0.45
        stroke.beginTime = CACurrentMediaTime() + 0.4
        stroke.fillMode = .forwards
        stroke.isRemovedOnCompletion = false
        stroke.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        checkLayer.add(stroke, forKey: "draw")
        checkLayer.strokeEnd = 1

        // 워드마크 + 태그라인 페이드업
        wordmark.transform = CGAffineTransform(translationX: 0, y: 14)
        tagline.transform = CGAffineTransform(translationX: 0, y: 14)
        UIView.animate(withDuration: 0.55, delay: 0.62, options: [.curveEaseOut]) {
            self.wordmark.alpha = 1
            self.wordmark.transform = .identity
            self.tagline.alpha = 1
            self.tagline.transform = .identity
        }

        // 끝나면 홈으로 전환
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.85) { [weak self] in
            self?.onFinish()
        }
    }
}
