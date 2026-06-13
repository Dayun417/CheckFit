# CheckFit

식단, 운동, 수분 섭취, 체중, 단식 기록을 한 화면에서 관리할 수 있도록 만든 iOS 건강관리 도우미 애플리케이션


## 1. 프로젝트 수행 목적

### 1.1 프로젝트 정의

CheckFit은 사용자가 매일의 건강 습관을 쉽고 빠르게 기록하고, 기록된 데이터를 기반으로 자신의 생활 패턴을 확인할 수 있도록 돕는 모바일 헬스케어 앱입니다. 단순 기록 기능에 그치지 않고 연속 기록, 미션, 코인 보상, 운동 콘텐츠 탐색 기능을 함께 제공하여 건강관리 활동을 지속할 수 있도록 설계했습니다.

### 1.2 프로젝트 배경

건강관리는 꾸준한 식단 관리, 운동, 수분 섭취, 체중 변화 확인이 중요하지만 여러 항목을 따로 기록하면 번거롭고 지속하기 어렵습니다. 특히 사용자가 직접 기록해야 하는 앱은 입력 과정이 복잡할수록 사용 빈도가 낮아질 수 있습니다.

CheckFit은 이러한 문제를 해결하기 위해 핵심 건강 지표를 하나의 앱에서 통합 관리하고, 빠른 기록과 시각적 피드백을 제공하여 사용자가 부담 없이 건강 습관을 이어갈 수 있도록 기획되었습니다.

### 1.3 프로젝트 목표

- 식단, 운동, 수분, 체중, 단식 정보를 통합 기록하는 건강관리 앱 구현
- 사용자가 오늘의 건강 상태를 한눈에 확인할 수 있는 대시보드 제공
- 연속 기록, 미션, 코인 보상 기능을 통한 습관 형성 유도
- 운동 콘텐츠 검색 및 카테고리 필터링을 통한 홈트레이닝 접근성 향상

## 2. 프로젝트 개요

### 2.1 프로젝트 설명

CheckFit은 바쁜 일상 속에서도 사용자가 자신의 건강 상태를 꾸준히 관리할 수 있도록 돕는 iOS 기반 건강관리 애플리케이션입니다. 사용자는 식사, 운동, 수분 섭취, 체중, 단식 기록을 날짜별로 입력하고 확인할 수 있으며, 앱은 기록된 데이터를 바탕으로 하루 건강 상태를 요약해 보여줍니다. 또한 미션과 보상 시스템, 연속 기록 기능을 통해 단순한 건강 기록을 습관 형성 활동으로 확장하는 것을 목표로 합니다.

CheckFit은 iOS 환경에서 동작하는 Swift 기반 애플리케이션입니다. 메인 화면에서는 날짜별 건강 기록을 확인할 수 있으며, 중앙 빠른 추가 버튼을 통해 체중, 수분, 운동, 식사 기록 화면으로 바로 이동할 수 있습니다.

주요 기능은 다음과 같습니다.

- 내 건강: 식단 칼로리, 영양소, 체중, 수분, 운동, 단식 정보를 요약 표시
- 식단 기록: 음식 검색, 끼니별 기록, 직접 등록, 칼로리 및 탄단지 정보 관리
- 운동 기록: 운동명, 운동 시간, 소모 칼로리, 강도 기록 및 통계 확인
- 수분 기록: 목표 섭취량과 섭취 단위 설정, 일일 수분 섭취량 기록
- 체중 및 신체 구성 기록: 체중, 골격근량, 체지방 정보 입력
- 단식 관리: 단식 시작 시간과 목표 시간 설정, 완료 기록 관리
- 연속 기록: 건강 정보를 기록한 날짜를 기반으로 스트릭 표시
- 미션 및 보상: 식사 기록, 물 마시기, 움직이기 등 미션 완료 시 코인 획득
- 콘텐츠: 전신, 요가, 복근, 스트레칭 등 운동 영상 검색 및 YouTube 연결
- 마이페이지: 닉네임, 프로필 이미지, 메모, 누적 운동 시간, 완료 미션 확인

### 2.2 기대효과

- 사용자는 여러 건강관리 항목을 하나의 앱에서 관리하여 기록 부담을 줄일 수 있습니다.
- 날짜별 건강 기록과 요약 정보를 통해 자신의 생활 습관을 쉽게 파악할 수 있습니다.
- 연속 기록과 미션 보상 구조를 통해 건강관리 활동을 지속하는 동기를 얻을 수 있습니다.
- 운동 콘텐츠 탐색 기능을 통해 사용자가 상황에 맞는 홈트레이닝 영상을 빠르게 찾을 수 있습니다.
- 앱 사용 중 입력한 건강 데이터를 간단하게 유지하고 재확인할 수 있습니다.

### 2.3 결과물
 - 시작 화면
  <img width="171" height="365" alt="스크린샷 2026-06-13 오후 3 09 16" src="https://github.com/user-attachments/assets/46c17b0e-475a-46a6-8478-bd30e666c3f6" />

 - 홈 화면
  <img width="171" height="368" alt="스크린샷 2026-06-13 오후 3 09 59" src="https://github.com/user-attachments/assets/6452bc76-ff34-4386-9028-b409c35716be" />

 - 식단 화면
  <img width="174" height="371" alt="스크린샷 2026-06-13 오후 3 07 05" src="https://github.com/user-attachments/assets/483eeb9f-85f5-4d64-8b68-3c7cead1312b" />
  <img width="176" height="368" alt="스크린샷 2026-06-13 오후 3 03 45" src="https://github.com/user-attachments/assets/ca4ad37a-36b6-411f-8fb3-387c7548ff8d" />
  <img width="172" height="366" alt="스크린샷 2026-06-13 오후 3 04 39" src="https://github.com/user-attachments/assets/b396c3a3-9a3f-484c-ade7-639e5236e741" />
  <img width="170" height="363" alt="스크린샷 2026-06-13 오후 3 05 52" src="https://github.com/user-attachments/assets/89bff9f9-2124-4836-b7fe-3a152a928fc7" />

 - 체중 기록 화면
  <img width="171" height="364" alt="스크린샷 2026-06-13 오후 3 14 01" src="https://github.com/user-attachments/assets/a73f1665-afaa-4c1b-ac39-bb22038a6a51" />
  <img width="170" height="364" alt="스크린샷 2026-06-13 오후 3 14 29" src="https://github.com/user-attachments/assets/c72cad19-d53c-4545-9c99-a400a7873a5a" />

 - 단식 설정 화면
  <img width="170" height="360" alt="스크린샷 2026-06-13 오후 3 17 03" src="https://github.com/user-attachments/assets/80f62151-13ab-4709-89fd-390505174b9b" />
  <img width="169" height="359" alt="스크린샷 2026-06-13 오후 3 17 23" src="https://github.com/user-attachments/assets/19a3029f-0c16-48b7-9e9b-9d96ddc828bb" />
  <img width="167" height="361" alt="스크린샷 2026-06-13 오후 3 18 47" src="https://github.com/user-attachments/assets/77e31c0e-c8ea-4ca8-9942-3f5b6d30b606" />


 - 운동 기록 화면
  <img width="171" height="361" alt="스크린샷 2026-06-13 오후 3 21 08" src="https://github.com/user-attachments/assets/7ebc0116-6ba1-47b9-b4d4-36193c5ebaf3" />
  <img width="172" height="362" alt="스크린샷 2026-06-13 오후 3 21 49" src="https://github.com/user-attachments/assets/4b1a5949-5ff0-4895-a411-e0b8eae4d67d" />
  <img width="171" height="365" alt="스크린샷 2026-06-13 오후 3 22 07" src="https://github.com/user-attachments/assets/fb1a8c90-3a4c-4264-bf4e-adb3c5561758" />
  <img width="171" height="362" alt="스크린샷 2026-06-13 오후 3 23 08" src="https://github.com/user-attachments/assets/3a61479e-cddf-4ad6-963f-56245be8c97a" />

 - 수분 기록 화면
  <img width="173" height="365" alt="스크린샷 2026-06-13 오후 3 24 37" src="https://github.com/user-attachments/assets/c3002fe0-1476-4def-b87d-bbba9cf995bf" />
  <img width="171" height="363" alt="스크린샷 2026-06-13 오후 3 24 53" src="https://github.com/user-attachments/assets/f3bc024d-5f4f-4a3c-9780-61bd04b22215" />
  <img width="169" height="362" alt="스크린샷 2026-06-13 오후 3 28 04" src="https://github.com/user-attachments/assets/f23c2d43-06f4-4909-8876-5634300eeb75" />


 - 미션 화면
  <img width="170" height="368" alt="스크린샷 2026-06-13 오후 3 26 30" src="https://github.com/user-attachments/assets/1716951a-2aa2-4dec-8a80-c3ab454ecc16" />
  <img width="170" height="365" alt="스크린샷 2026-06-13 오후 3 26 52" src="https://github.com/user-attachments/assets/2c5cc32b-3c80-45d6-9f70-91b951e1e9d9" />

 - 콘텐츠 화면
  <img width="170" height="361" alt="스크린샷 2026-06-13 오후 3 29 58" src="https://github.com/user-attachments/assets/7718791e-9277-4fd0-bc81-1711093eaeb2" />
  <img width="170" height="359" alt="스크린샷 2026-06-13 오후 3 30 21" src="https://github.com/user-attachments/assets/0d0af5a3-a462-4228-9c0c-7d9effa126bf" />
  <img width="172" height="365" alt="스크린샷 2026-06-13 오후 3 30 37" src="https://github.com/user-attachments/assets/90d4a453-7076-4e5e-9b58-63bfff39f28a" />

 - 마이페이지 화면
  <img width="171" height="365" alt="스크린샷 2026-06-13 오후 3 32 37" src="https://github.com/user-attachments/assets/06d42078-c7fe-49cf-b88e-b5b7eb04ad16" />
  <img width="172" height="364" alt="스크린샷 2026-06-13 오후 3 33 02" src="https://github.com/user-attachments/assets/98e79fe8-0f3e-4dfa-a353-7d4114d58c9c" />
  <img width="172" height="364" alt="스크린샷 2026-06-13 오후 3 35 21" src="https://github.com/user-attachments/assets/3491231f-e7d6-4e53-aeb6-46c4c68a11c4" />

 - 프로필, 연속기록, 캘린더 화면
  <img width="171" height="364" alt="스크린샷 2026-06-13 오후 3 33 37" src="https://github.com/user-attachments/assets/8e649313-bab0-4fc7-8296-b2dc3a83773b" />
  <img width="172" height="366" alt="스크린샷 2026-06-13 오후 3 33 52" src="https://github.com/user-attachments/assets/de59316f-a6f5-4788-b29b-c2e7ddd7b9a3" />
  <img width="170" height="363" alt="스크린샷 2026-06-13 오후 3 34 09" src="https://github.com/user-attachments/assets/7ab284ab-c882-41b5-b738-0400e41aecf1" />

 - 홈 + 버튼 화면
  <img width="173" height="365" alt="스크린샷 2026-06-13 오후 3 36 04" src="https://github.com/user-attachments/assets/32ea9a8b-8ff3-4e98-9e4b-5705efeec1b1" />


### 2.4 관련 기술

- Swift: iOS 앱 로직 및 화면 구현
- UIKit: ViewController 기반 화면 구성, Auto Layout, 탭바, 모달, 커스텀 UI 컴포넌트 구현
- UserDefaults: 식단, 운동, 수분, 체중, 단식, 프로필, 미션 상태 등 로컬 데이터 저장
- Codable: 식단, 운동, 단식 기록 데이터의 인코딩 및 디코딩 처리
- URL Scheme: YouTube 앱 또는 웹 브라우저로 운동 콘텐츠 연결

### 2.5 개발 도구

- Xcode: iOS 프로젝트 개발 및 빌드
- Swift: 애플리케이션 개발 언어
- Interface Builder / Storyboard: 기본 앱 진입 화면 및 리소스 구성
- iOS Simulator: 화면 동작 및 UI 테스트

## 3. 시현 영상
<a href="https://www.youtube.com/watch?v=lHwqND66MvI&t=1s">
 <img width="245" height="207" alt="스크린샷 2026-06-13 오후 5 22 38" src="https://github.com/user-attachments/assets/4731c8cc-8bfe-462a-9e44-91b689a9162c" />   
</a>

