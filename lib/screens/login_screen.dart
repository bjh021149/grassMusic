import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

class LoginForm extends StatefulWidget {
  final AuthProvider authProvider;
  final VoidCallback? onSuccess; // 登录成功回调
  final ValueChanged<String>? onError; // 错误回调

  const LoginForm({
    super.key,
    required this.authProvider,
    this.onSuccess,
    this.onError,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _phoneController.text = prefs.getString('savedPhone') ?? '';
      _passwordController.text = prefs.getString('savedPassword') ?? '';
      _rememberMe = prefs.getBool('rememberMe') ?? false;
    });
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', _rememberMe);
    if (_rememberMe) {
      await prefs.setString('savedPhone', _phoneController.text);
      await prefs.setString('savedPassword', _passwordController.text);
    } else {
      await prefs.remove('savedPhone');
      await prefs.remove('savedPassword');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await widget.authProvider.login(
        _phoneController.text,
        _passwordController.text,
      );

      if (widget.authProvider.isLoggedIn) {
        await _saveCredentials();
        widget.onSuccess?.call();
      }
    } catch (e) {
      widget.onError?.call(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 手机号输入框
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: '手机号',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator:
                (value) =>
                    value == null || value.isEmpty
                        ? '请输入手机号'
                        : !RegExp(r'^1[3-9]\d{9}$').hasMatch(value)
                        ? '请输入有效的手机号'
                        : null,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          // 密码输入框
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: '密码',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed:
                    () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator:
                (value) =>
                    value == null || value.isEmpty
                        ? '请输入密码'
                        : value.length < 6
                        ? '密码长度不能少于6位'
                        : null,
          ),
          const SizedBox(height: 16),

          // 记住我选项
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged:
                    (value) => setState(() => _rememberMe = value ?? false),
              ),
              const Text('记住我'),
              const Spacer(),
              TextButton(
                onPressed: () => widget.onError?.call('忘记密码功能待实现'),
                child: const Text('忘记密码?'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 登录按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _isSubmitting ? null : _submitForm,
              child:
                  _isSubmitting
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('登 录', style: TextStyle(fontSize: 16)),
            ),
          ),

          // 错误信息
          if (widget.authProvider.error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.authProvider.error!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
