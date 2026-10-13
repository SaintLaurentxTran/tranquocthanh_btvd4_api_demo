import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'post_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mssvController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkSavedMssv();
  }

  Future<void> _checkSavedMssv() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMssv = prefs.getString('saved_mssv');
    if (savedMssv != null && savedMssv.isNotEmpty && mounted) {
      _mssvController.text = savedMssv;
      _login(savedMssv, isAutoLogin: true);
    }
  }

  Future<void> _login(String mssv, {bool isAutoLogin = false}) async {
    final cleanMssv = mssv.trim();
    if (cleanMssv.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập Mã số sinh viên (MSSV)';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final student = await _apiService.checkStudent(cleanMssv);

      // Lưu MSSV vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_mssv', cleanMssv);

      if (!mounted) return;

      if (!isAutoLogin) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Xin chào ${student.fullName} (${student.mssv})!',
            ),
            backgroundColor: const Color(0xFF00529C),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PostListScreen(
            mssv: cleanMssv,
            initialStudent: student,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _mssvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo / Header Icon
                  Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00529C).withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 44,
                      color: Color(0xFF00529C),
                    ),
                  ),

                  // Tiêu đề
                  Text(
                    'HUTECH REST API',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00529C),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hệ thống quản lý bài viết phân quyền theo MSSV phục vụ thực hành môn Lập trình di động.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Form nhập MSSV
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Thiết lập MSSV của bạn',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _mssvController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) => _login(value),
                            decoration: InputDecoration(
                              labelText: 'Mã số sinh viên (MSSV)',
                              hintText: 'Ví dụ: 21802142145',
                              prefixIcon: const Icon(Icons.badge_outlined),
                              suffixIcon: _mssvController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _mssvController.clear();
                                        setState(() {
                                          _errorMessage = null;
                                        });
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              errorText: _errorMessage,
                            ),
                            onChanged: (_) {
                              if (_errorMessage != null) {
                                setState(() {
                                  _errorMessage = null;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 20),

                          // Nút Kết nối
                          FilledButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () => _login(_mssvController.text),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF00529C),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.login_rounded),
                            label: Text(
                              _isLoading ? 'Đang kết nối API...' : 'Kết nối MSSV',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Nút kiểm tra nhanh với MSSV mẫu
                  OutlinedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () {
                            _mssvController.text = '21802142145';
                            _login('21802142145');
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Color(0xFF00529C)),
                    ),
                    icon: const Icon(Icons.touch_app_outlined,
                        color: Color(0xFF00529C)),
                    label: const Text(
                      'Thử nghiệm với MSSV mẫu (21802142145)',
                      style: TextStyle(
                        color: Color(0xFF00529C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Thông tin nguồn API
                  Center(
                    child: Text(
                      'Máy chủ API: https://buiphukhuyen.io.vn',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
