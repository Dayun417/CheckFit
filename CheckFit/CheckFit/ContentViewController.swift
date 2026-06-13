//
//  ContentViewController.swift
//  CheckFit
//

import UIKit

final class ContentViewController: BaseScreenViewController {
    private struct VideoItem {
        let title: String
        let channel: String
        let duration: String
        let videoID: String
        let category: String
    }

    private let categories = ["전체", "전신", "요가", "복근", "스트레칭"]
    private var selectedCategory = "전체"
    private var searchText = ""

    private let videos: [VideoItem] = [
        VideoItem(title: "걸으면서 살이 쭉쭉 빠지는 운동 [걸쭉빠]", channel: "땅끄부부 Thankyou BUBU", duration: "21:00", videoID: "E_WBjEFXzKU", category: "전신"),
        VideoItem(title: "요가 입문자를 위한 30분 기초 요가 스트레칭", channel: "요가소년", duration: "30:00", videoID: "5mk8JhIS938", category: "요가"),
        VideoItem(title: "일주일만에 뱃살 빼기 🔥 30분 서서하는 복근 운동", channel: "MIZI", duration: "30:00", videoID: "u_9untoVK7w", category: "복근"),
        VideoItem(title: "골반 교정 스트레칭 루틴 (자세 불균형 완화)", channel: "소미핏 somifit", duration: "12:00", videoID: "fC36CluWbAA", category: "스트레칭"),
        VideoItem(title: "하루 15분! 전신 칼로리 불태우는 다이어트 운동", channel: "홈트레이닝", duration: "15:00", videoID: "swRNeYw1JkY", category: "전신"),
        VideoItem(title: "초보를 위한 기초요가 30분 클래스", channel: "요가 클래스", duration: "30:00", videoID: "stXWZlBIbq8", category: "요가"),
        VideoItem(title: "30분 서서 뱃살 태우기 (무릎 부담 NO)", channel: "MIZI", duration: "30:00", videoID: "yME62h30QLI", category: "복근"),
        VideoItem(title: "틀어진 골반 체형교정 스트레칭", channel: "스트레칭", duration: "10:00", videoID: "mmQvdNYDtjw", category: "스트레칭"),
        VideoItem(title: "전신 다이어트 유산소 운동 [홈트레이닝]", channel: "홈트레이닝", duration: "20:00", videoID: "3VouSaW_LPw", category: "전신"),
        VideoItem(title: "요가 왕초보를 위한 찍먹 기초 요가", channel: "요가 클래스", duration: "35:00", videoID: "jdwsP-QQ_FY", category: "요가"),
        VideoItem(title: "30분 서서 하는 필라테스 (전신 슬림)", channel: "MIZI", duration: "30:00", videoID: "2qMSuv7V0cU", category: "복근"),
        VideoItem(title: "골반 체형교정 스트레칭 (하비·비대칭)", channel: "소미핏 somifit", duration: "14:00", videoID: "nQlbDogfCpE", category: "스트레칭"),
        VideoItem(title: "전신 다이어트 최고의 운동 [칼소폭]", channel: "땅끄부부 Thankyou BUBU", duration: "33:00", videoID: "gSz5n4sLENI", category: "전신"),
        VideoItem(title: "뻐근한 몸을 가볍게 깨워주는 25분 요가", channel: "요가소년", duration: "25:00", videoID: "4rdAqLKkkjc", category: "요가"),
        VideoItem(title: "11자 복근 복부 최고의 운동 [핵매운맛]", channel: "땅끄부부 Thankyou BUBU", duration: "12:00", videoID: "PjGcOP-TQPE", category: "복근"),
        VideoItem(title: "아침 30분 모닝 필라테스 (스트레칭)", channel: "MIZI", duration: "30:00", videoID: "L_Ug22hKik8", category: "스트레칭"),
        VideoItem(title: "10분 전신 운동 (No Equipment)", channel: "홈트레이닝", duration: "10:00", videoID: "Iaa8YNDRbhg", category: "전신"),
        VideoItem(title: "아침 20분 모닝 요가 (전신 스트레칭)", channel: "요가소년", duration: "20:00", videoID: "CgZBACUudps", category: "요가"),
        VideoItem(title: "9분! 초간단 누워서 하는 11자 복근운동", channel: "땅끄부부 Thankyou BUBU", duration: "09:00", videoID: "zcQ16cfJN9Q", category: "복근"),
        VideoItem(title: "근육과 관절을 부드럽게 10분 스트레칭", channel: "서리요가", duration: "10:00", videoID: "MiJeryjGI9k", category: "스트레칭"),
        VideoItem(title: "30분 서서 유산소 HIIT (점프 NO)", channel: "MIZI", duration: "30:00", videoID: "bMv-9oeYJVY", category: "전신"),
        VideoItem(title: "온몸을 부드럽게 풀어주는 10분 모닝 요가", channel: "요가소년", duration: "10:00", videoID: "q8EWJhZPDc8", category: "요가"),
        VideoItem(title: "하루 딱 10분! 11자 복근 보장 운동 루틴", channel: "홈트레이닝", duration: "10:00", videoID: "IFE1VT-iuZs", category: "복근"),
        VideoItem(title: "자기전 숙면을 도와주는 10분 스트레칭", channel: "심으뜸", duration: "10:00", videoID: "8VtkpMGw0hw", category: "스트레칭"),
        VideoItem(title: "아침 공복 전신요가 30분 모닝 요가", channel: "요가소년", duration: "30:00", videoID: "Kqs23wX6ZVU", category: "요가"),
        VideoItem(title: "탄탄한 11자 복근 만들기 10분 홈트", channel: "홈트레이닝", duration: "10:00", videoID: "nIPaz2wKo0Q", category: "복근"),
        VideoItem(title: "자기전 스트레칭으로 전신피로 풀고 숙면", channel: "스트레칭", duration: "10:00", videoID: "1GCq8dKzbRw", category: "스트레칭"),
        VideoItem(title: "초심자를 위한 기초 요가 20분", channel: "요가소년", duration: "20:00", videoID: "BUgMt91EQwQ", category: "요가"),
        VideoItem(title: "꿀잠을 부르는 10분 스트레칭 🌜", channel: "스트레칭", duration: "10:00", videoID: "A3tO5mxYAzI", category: "스트레칭"),
        VideoItem(title: "매일 10분 가볍게 하는 전신 스트레칭 체조", channel: "스트레칭", duration: "10:00", videoID: "kB0_xQdt2ow", category: "스트레칭")
    ]

    private var chipQueries: [ObjectIdentifier: String] = [:]
    private var videoIDs: [ObjectIdentifier: String] = [:]
    private weak var chipsRow: UIStackView?
    private weak var videosStack: UIStackView?

    override func viewDidLoad() {
        super.viewDidLoad()
        build()
    }

    private func build() {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let body = paddedStack(spacing: 18, insets: UIEdgeInsets(top: 24, left: 22, bottom: 122, right: 22))
        body.addArrangedSubview(UILabel("콘텐츠", size: 30, weight: .black, color: AppTheme.text, lines: 1))
        body.addArrangedSubview(searchField())
        body.addArrangedSubview(chips())

        let list = UIStackView()
        list.axis = .vertical
        list.spacing = 18
        videosStack = list
        body.addArrangedSubview(list)

        stackView.addArrangedSubview(body)
        refreshVideos()
    }

    // MARK: - Filtering

    private func filteredVideos() -> [VideoItem] {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        return videos.filter { item in
            let matchesCategory = selectedCategory == "전체" || item.category == selectedCategory
            let matchesQuery = query.isEmpty
                || item.title.lowercased().contains(query)
                || item.channel.lowercased().contains(query)
                || item.category.lowercased().contains(query)
            return matchesCategory && matchesQuery
        }
    }

    private func refreshVideos() {
        guard let list = videosStack else { return }
        list.arrangedSubviews.forEach {
            list.removeArrangedSubview($0)
            $0.removeFromSuperview()
            if let id = ($0 as? UIStackView).map({ ObjectIdentifier($0) }) { videoIDs[id] = nil }
        }

        let results = filteredVideos()
        if results.isEmpty {
            let empty = UILabel("검색 결과가 없어요 🔍", size: 16, weight: .bold, color: AppTheme.muted, lines: 1)
            empty.textAlignment = .center
            empty.heightAnchor.constraint(equalToConstant: 120).isActive = true
            list.addArrangedSubview(empty)
            return
        }
        for item in results {
            list.addArrangedSubview(video(item))
        }
    }

    // MARK: - Actions

    private func openYouTube(videoID: String) {
        let appURL = URL(string: "youtube://watch?v=\(videoID)")
        let webURL = URL(string: "https://www.youtube.com/watch?v=\(videoID)")
        if let appURL, UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else if let webURL {
            UIApplication.shared.open(webURL)
        }
    }

    @objc private func videoTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view, let id = videoIDs[ObjectIdentifier(view)] else { return }
        openYouTube(videoID: id)
    }

    @objc private func chipTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view, let category = chipQueries[ObjectIdentifier(view)] else { return }
        selectedCategory = category
        populateChips()
        refreshVideos()
    }

    @objc private func searchChanged(_ field: UITextField) {
        searchText = field.text ?? ""
        refreshVideos()
    }

    // MARK: - Views

    private func searchField() -> UITextField {
        let field = UITextField()
        field.placeholder = "어떤 운동을 하고 싶으신가요?"
        field.font = AppTheme.font(15, .semibold)
        field.backgroundColor = AppTheme.softFill
        field.layer.cornerRadius = 24
        let glassSize: CGFloat = 18
        let leftPad: CGFloat = 18
        let gap: CGFloat = 14
        let leftContainer = UIView(frame: CGRect(x: 0, y: 0, width: leftPad + glassSize + gap, height: glassSize))
        let glass = UIImageView(image: UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)))
        glass.tintColor = AppTheme.muted
        glass.contentMode = .center
        glass.frame = CGRect(x: leftPad, y: 0, width: glassSize, height: glassSize)
        leftContainer.addSubview(glass)
        field.leftView = leftContainer
        field.leftViewMode = .always
        field.clearButtonMode = .whileEditing
        field.returnKeyType = .search
        field.text = searchText
        field.addTarget(self, action: #selector(searchChanged(_:)), for: .editingChanged)
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return field
    }

    private func chips() -> UIView {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(row)
        chipsRow = row
        populateChips()
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            row.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            row.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            row.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor),
            scroll.heightAnchor.constraint(equalToConstant: 48)
        ])
        return scroll
    }

    private func populateChips() {
        guard let row = chipsRow else { return }
        chipQueries.removeAll()
        row.arrangedSubviews.forEach {
            row.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        for chip in categories {
            let selected = chip == selectedCategory
            let pill = makePill(chip, foreground: selected ? .white : AppTheme.muted, background: selected ? AppTheme.brand : AppTheme.softFill, fontSize: 15)
            pill.isUserInteractionEnabled = true
            pill.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chipTapped(_:))))
            chipQueries[ObjectIdentifier(pill)] = chip
            row.addArrangedSubview(pill)
        }
    }

    private func video(_ item: VideoItem) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.isUserInteractionEnabled = true
        stack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(videoTapped(_:))))
        videoIDs[ObjectIdentifier(stack)] = item.videoID

        let thumbnail = UIView()
        thumbnail.backgroundColor = UIColor(red: 0.07, green: 0.13, blue: 0.14, alpha: 1)
        thumbnail.layer.cornerRadius = 24
        thumbnail.clipsToBounds = true
        thumbnail.translatesAutoresizingMaskIntoConstraints = false

        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        thumbnail.addSubview(image)
        loadThumbnail(into: image, videoID: item.videoID)

        let play = UIImageView(image: UIImage(systemName: "play.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 58, weight: .regular)))
        play.tintColor = UIColor.white.withAlphaComponent(0.92)
        play.translatesAutoresizingMaskIntoConstraints = false
        thumbnail.addSubview(play)

        let time = makePill("◷ \(item.duration)", background: UIColor.black.withAlphaComponent(0.70), fontSize: 13)
        thumbnail.addSubview(time)

        NSLayoutConstraint.activate([
            thumbnail.heightAnchor.constraint(equalTo: thumbnail.widthAnchor, multiplier: 0.56),
            image.topAnchor.constraint(equalTo: thumbnail.topAnchor),
            image.leadingAnchor.constraint(equalTo: thumbnail.leadingAnchor),
            image.trailingAnchor.constraint(equalTo: thumbnail.trailingAnchor),
            image.bottomAnchor.constraint(equalTo: thumbnail.bottomAnchor),
            play.centerXAnchor.constraint(equalTo: thumbnail.centerXAnchor),
            play.centerYAnchor.constraint(equalTo: thumbnail.centerYAnchor),
            time.trailingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: -12),
            time.bottomAnchor.constraint(equalTo: thumbnail.bottomAnchor, constant: -12)
        ])
        stack.addArrangedSubview(thumbnail)
        stack.addArrangedSubview(UILabel(item.title, size: 20, weight: .black, color: AppTheme.text, lines: 2))

        let meta = UIStackView()
        meta.axis = .horizontal
        meta.distribution = .equalSpacing
        meta.addArrangedSubview(UILabel(item.channel, size: 14, weight: .bold, color: AppTheme.muted, lines: 1))
        meta.addArrangedSubview(UILabel("▶ YouTube", size: 14, weight: .bold, color: .systemRed, lines: 1))
        stack.addArrangedSubview(meta)
        return stack
    }

    private func loadThumbnail(into imageView: UIImageView, videoID: String) {
        guard let url = URL(string: "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async { imageView.image = image }
        }.resume()
    }
}

extension ContentViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
