import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:kakao_flutter_sdk_navi/kakao_flutter_sdk_navi.dart';

void main() {
  // Kakao SDK 초기화 - 네이티브 앱 키 설정
  KakaoSdk.init(
    nativeAppKey: 'e0d646fb8b530736372d5b725b323514',
  );
  runApp(const KakaoLoginTest());
}

// +J+3yf/mrgPgKeg1llIttpSjcws=
class KakaoLoginTest extends StatelessWidget {
  const KakaoLoginTest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kakao Login Test',
      // 앱의 전체적인 테마 설정
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7E600),
          foregroundColor: Color.fromRGBO(56, 35, 36, 1),
          titleTextStyle: TextStyle(
            color: Color.fromRGBO(56, 35, 36, 1),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const KakaoLogin(),
    );
  }
}

// 카카오 로그인 화면 위젯
class KakaoLogin extends StatefulWidget {
  const KakaoLogin({super.key});

  @override
  State<KakaoLogin> createState() => _KakaoLoginState();
}

class _KakaoLoginState extends State<KakaoLogin> {
  // 카카오톡 앱 설치 여부 상태
  bool _isKakaoTalkInstalled = false;

  @override
  void initState() {
    super.initState();
    _initKakaoTalkInstalled();
  }

  // 카카오톡 설치 여부 확인 함수
  Future<void> _initKakaoTalkInstalled() async {
    final installed = await isKakaoTalkInstalled();
    print('isKakaoTalkInstalled : $installed');
    print(await KakaoSdk.origin);
    setState(() {
      _isKakaoTalkInstalled = installed;
    });
  }

  // 로그인 처리 함수
  Future<void> _handleLogin() async {
    try {
      if (_isKakaoTalkInstalled) {
        print('카카오톡 설치됨');
        await _loginWithTalk(); // 카카오톡 설치되어 있으면 카카오톡으로 로그인
      } else {
        await _loginWithKakao(); // 미설치시 카카오 계정으로 로그인
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: $e')),
      );
    }
  }

  Future<void> _loginWithKakao() async {
    try {
      OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
      print('카카오계정으로 로그인 성공 ${token.accessToken}');
      _moveToLoginDone();
    } catch (e) {
      print('카카오계정으로 로그인 실패 $e');
      rethrow;
    }
  }

  Future<void> _loginWithTalk() async {
    try {
      OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
      print('카카오톡으로 로그인 성공 ${token.accessToken}');
      _moveToLoginDone();
    } catch (e) {
      print('카카오톡으로 로그인 실패 $e');
      // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인 시도
      await _loginWithKakao();
    }
  }

  Future<void> _handleLogout() async {
    try {
      await UserApi.instance.unlink();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그아웃 성공')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃 실패: $e')),
      );
    }
  }

  // 로그인 성공 후 화면 이동
  void _moveToLoginDone() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginDone()),
      //MaterialPageRoute(builder: (context) => const ColorChangeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카카오 로그인 테스트'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로그인 버튼
            ElevatedButton(
              onPressed: _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF7E600),
                foregroundColor: const Color.fromRGBO(56, 35, 36, 1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                _isKakaoTalkInstalled ? '카카오톡으로 로그인' : '카카오계정으로 로그인',
              ),
            ),
            const SizedBox(height: 16),
            // 로그아웃 버튼
            ElevatedButton(
              onPressed: _handleLogout,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('로그아웃'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginDone extends StatefulWidget {
  const LoginDone({super.key});

  @override
  State<LoginDone> createState() => _LoginDoneState();
}

class _LoginDoneState extends State<LoginDone> {
  User? _user;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User user = await UserApi.instance.me();
      setState(() {
        _user = user;
        _errorMessage = null;
      });
      print('사용자 정보 요청 성공'
          '\n회원번호: ${user.id}'
          '\n닉네임: ${user.properties}');
      print('${_user?.kakaoAccount?.profile!.profileImageUrl}');
    } catch (e) {
      setState(() {
        _errorMessage = '사용자 정보를 불러오는데 실패했습니다: $e';
      });
      print('사용자 정보 요청 실패 $e');
    }
  }

// 카카오내비 실행 함수
  Future<void> _navigateWithKakaoNavi() async {
    try {
      if (await NaviApi.instance.isKakaoNaviInstalled()) {
        // 카카오내비 앱으로 길 안내
        await NaviApi.instance.navigate(
          // destination: Location(name: '카카오 판교오피스', x: '127.108640', y: '37.402111'), wgs84
          destination: Location(name: '카카오 판교오피스', x: '321525', y: '532951'),
          viaList: [
            Location(name: '판교역 1번출구', x: '321525', y: '532951'),
          ],
        );
      } else {
        // 카카오내비 설치 페이지로 이동
        await launchBrowserTab(Uri.parse(NaviApi.webNaviInstall));
        // 설치 안내 메시지 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('카카오내비 앱이 설치되어 있지 않습니다. 설치 페이지로 이동합니다.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카카오내비 실행 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인 성공'),
      ),
      // Stack을 사용하여 배경 터치 영역과 컨텐츠를 분리
      body: Stack(
        children: [
          // 배경 터치 영역
          Positioned.fill(
            child: GestureDetector(
              onTap: _navigateWithKakaoNavi,
              // 투명한 배경을 사용하여 터치 이벤트 캐치
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // 메인 컨텐츠
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                // 컨텐츠를 터치해도 배경 터치 이벤트가 발생하지 않도록 래핑
                child: IgnorePointer(
                  ignoring: false, // 컨텐츠 자체의 터치는 활성화
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        )
                      else if (_user == null)
                        const CircularProgressIndicator()
                      else ...[
                        if (_user?.kakaoAccount?.profile!.profileImageUrl !=
                            null)
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(
                              _user!.kakaoAccount!.profile!.profileImageUrl!,
                            ),
                          ),
                        const SizedBox(height: 16),
                        Text(
                          '환영합니다, ${_user?.kakaoAccount?.profile?.nickname ?? '사용자'}님!',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '배경을 터치하여 카카오내비 실행',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                      if (_errorMessage != null)
                        ElevatedButton(
                          onPressed: _loadUserData,
                          child: const Text('다시 시도'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
