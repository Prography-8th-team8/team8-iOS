
![포스터](https://github.com/Prography-8th-team8/team8-iOS/assets/63496607/df782877-ddac-42b7-a2af-0885dce25151)
> 앱스토어: https://apps.apple.com/us/app/케이크크/id6449973946

## 🍰 프로그라피 8기 - 8팀

| iOS | iOS | Android | Android |
| :-------: | :-----: | :-----: | :-----: |
| 이승기 | 김대황 | 오원석 | 이준경 |
|  [@WallabyStuff](https://github.com/WallabyStuff)   |  [@Mason Kim](https://github.com/qwerty3345)  |[@Wonseok](https://github.com/ows3090)  | [@lee989898](https://github.com/lee989898) |  |

| Designer | Designer | Backend | Backend |
| :-------: | :-----: | :-----: | :-----: |
| 오승민 | 김혜나 | 박영민 | 배지현 |
|  [@5m_____o](https://www.instagram.com/5m_____o/)    |  [@hae_na_a](https://www.instagram.com/hae_na_a/)  | [@Youngmin Park](https://github.com/ympark99) | [@govl6113](https://github.com/govl6113) |  |



> 프로젝트 기간 : 23.03.11 ~ 

<br>

# 목차
- [프로젝트 소개](#프로젝트-소개)
- [주요 기능](#주요-기능)
- [기술 설명(작성중..)](#기술-설명)

<br>

# 프로젝트 소개
### 케이크크를 이용해 커스텀 케이크샵들을 지도로 한 눈에 확인하세요!


| <img src="https://github.com/Prography-8th-team8/team8-iOS/assets/63496607/8283b4e3-6280-4c6a-a24a-d0770c1d9610" >| <img src="https://github.com/Prography-8th-team8/team8-iOS/assets/63496607/7ac198b8-e12b-4145-b753-eda390ac51ae" >|<img src="https://github.com/Prography-8th-team8/team8-iOS/assets/63496607/e91b1652-01fd-49a2-b349-9f22377c848b" >| <img src="https://github.com/Prography-8th-team8/team8-iOS/assets/63496607/7f585ffc-3ca6-4214-b8c9-b5284d27071d" >|
|---|---|---|---|


<br>
<br>

# 주요 기능  

## 1️⃣ 원하는 지역으로 이동하여 케이크샵을 검색해요
* 지도를 움직여 새로고침하여 케이크샵들을 조회할 수 있어요.  
* 필터를 적용시켜 원하는 종류의 케이크를 취급하는 케이크샵들만 조회할 수 있어요.  
* 케이크샵들을 지역별로 묶어서 쉽고 빠르게 조회할 수 있어요  


| <img src="https://github.com/Prography-8th-team8/team8-iOS/assets/63496607/18ef8ca4-2323-4107-a63b-ad05e1aa0cb7" width="300">|<img src="https://github.com/Prography-8th-team8/team8-iOS/assets/63496607/0344ac6b-3704-4da5-ace9-2d116413abe6" width="300" >|<img src="https://github.com/Prography-8th-team8/team8-iOS/assets/63496607/8ad4e2f7-339e-4d69-a483-aa2e8d025255" width="300">|
|---|---|---|
 
 
## 2️⃣ 케이크샵의 상세 정보를 확인하고 북마크해요
* 피드 화면을 통해 여러 케이크샵의 이미지를 한 눈에 확인할 수 있어요
* 케이크샵의 주소, 케이크 이미지, 블로그 리뷰를 확인할 수 있어요
* 원하는 케이크샵을 북마크로 저장하고 관리할 수 있어요

| <img src="https://github.com/Prography-8th-team8/team8-iOS/assets/63496607/55f069dc-4174-4a72-86d5-e29b9d6a0a1a" width="300">|<img src="https://github.com/Prography-8th-team8/team8-iOS/assets/63496607/0c9a4d92-82ea-4a90-bd1a-5c66529d4fb2" width="300" >|
|---|---|


<br>
<br>

# 기술 설명

### MVVM + input output pattern (with combine)
![app_architecture](https://github.com/Prography-8th-team8/team8-iOS/assets/63496607/83ddc00b-af8a-4e3c-9c46-08396d9fdc5a)
> MVVM 구조에 input output 패턴을 combine으로 구현하여 관리하고 있어요.
<br>


### Coordinator 패턴 계층 구조
![coordinator_flow](https://github.com/Prography-8th-team8/team8-iOS/assets/63496607/e51c0365-8d09-45fa-a251-45dc881f654d)
> 앱 내에서 새로운 뷰컨을 생성하고 띄워주는 로직의 반복이 많이 생기고 데이터를 불러올 타겟(목 데이터, 서버 데이터)을 모든 뷰컨을 한 번에 또는 각 뷰컨에서
> 쉽게 교체해서 테스트 용이성을 챙기기 위해서 코디네이터 패턴을 적용했어요.
<br>


### 스플래시 로직
*Legacy*
![splash_legacy](https://github.com/Prography-8th-team8/team8-iOS/assets/63496607/059e5ca6-8616-4414-ac55-011107151d21)
> 기존에 Splash를 처음 진입하는 ViewController에서 UIView 형태로 보여줬다가 사라지는 애니메이션을 구현해 줬었어요.
> 이렇게 했던 이유는 자연스럽게 Splash를 띄우고 fade out 시키면서 Splash를 제거하기 위함 이었죠.
> 그런데 SplashView가 메모리에서 잘 해지되지 않는 문제도 있었고, 초기 진입하는 뷰컨트롤러에서 SplashView를 직접 띄워줘야하기 때문에 재사용성이 많이 떨어졌었죠🥹
> 예를들면 MainViewController에서 띄우던 SplashView를 TabViewController로 이동 시키려면 SplashView를 띄우고 가리는 로직을 통채로 옮겼어야 했었어요.

*New*
![splash_new](https://github.com/Prography-8th-team8/team8-iOS/assets/63496607/f5f55221-119d-4f34-9e78-bc848ab0ad24)
> 그래서 저희는 SplashView를 UIViewController로 분리했어요!
> 그리고 AppCoordinator에서 초기에 띄워주는 뷰컨트롤러 위에 present 시켜줬어요.
> 이때 ```modalPresentationStyle``` 은 ```overFullScreen```으로 해서 뷰컨 자체를 fade out 시킬때 백그라운드가 투명하게 보여지면서 자연스럽게 fade out 되게 만들어 줬어요.
> 최종적으로 일정 시간이 지난 후 fadeOut 애니메이션을 시키고 completion 핸들러에서 ```dismiss(animated: false)``` 으로 메모리에서 완전히 해지시켰죠.
<br>


### MainViewModel 구조 개선
*Legacy*
![architecture_legacy](https://github.com/Prography-8th-team8/team8-iOS/assets/63496607/e46eb348-c61f-4158-82f9-c40200187f8c)
> 기존에 CakeShopList 에서 아이템이 선택 됐을 때 handler를 통해서 MainViewcontroller에서 미리 정의했던 함수를 실행 시켰었어요.
> 그런데 이렇게 하니까 MainVC의 로직이 너무 복잡해지고 MapView, CakeShopListVC, ShopDetailVC 사이의 의존성이 강해졌었죠.
> 객체간 의존성이 강해지면서 자연스럽게 관리하기가 어려워졌고 유지보수하기 까다로웠었어요.

*New*
![architecture_new](https://github.com/Prography-8th-team8/team8-iOS/assets/63496607/ddd8820c-0b42-4842-b34f-872de9273da2)
> 그래서 CakeShopListVC의 ViewModel인 CakeShopListViewModel을 따로 만들어서 관리하지 않고 MainViewModel을 그대로 사용했어요!
> 어차피 마커와 샵 리스트의 아이템들은 따로 분리해서 받지 않고 서버로부터 받아온 [CakeShop] 배열을 가지고 마커도 보여주고 리스트도 뿌려줬기 때문에 이런 뷰모델 재상용이 가능했었죠.
> (만약 마커 데이터, 리스트 데이터 분리해서 가져오면 MainViewModel을 서브 뷰모델로 가지고 있는 CakeShopListViewModel을 만들었을 것임)

> 따라서 CakeShopList에서 아이템이 선택되면 바로 MainViewModel에게 알려주고 MainViewModel의 output에 바인딩 되어있던 액션들이
> 각 MapView, MainVC에게 전달되어 각자의 역할을 수행할 수 있도록 로직을 개선했어요.
