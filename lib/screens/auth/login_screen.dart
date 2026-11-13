import 'package:flutter/material.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/storage/storage_service.dart';
import '../../state/auth_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sign In Form Controllers
  final _loginEmailController = TextEditingController(text: 'admin@omni.com');
  final _loginPasswordController = TextEditingController(text: 'admin123');
  final _loginFormKey = GlobalKey<FormState>();

  // Register Form Controllers
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _registerFormKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPhoneController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await AuthController.instance.login(
      _loginEmailController.text.trim(),
      _loginPasswordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AuthController.instance.errorMessage ?? 'ចូលគណនីមិនបានជោគជ័យ សូមពិនិត្យមើល Email និង Password'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await AuthController.instance.register(
      email: _regEmailController.text.trim(),
      password: _regPasswordController.text,
      fullName: _regNameController.text.trim(),
      phone: _regPhoneController.text.trim().isNotEmpty ? _regPhoneController.text.trim() : null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AuthController.instance.errorMessage ?? 'ការចុះឈ្មោះមានបញ្ហា សូមសាកល្បងម្តងទៀត'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final success = await AuthController.instance.loginAsDemo();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _showServerConfigModal() {
    final controller = TextEditingController(text: ApiConstants.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.dns_outlined, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text('Server Connection (API URL)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'កំណត់អាសយដ្ឋាន API Server សម្រាប់ការតភ្ជាប់:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'http://10.0.2.2:8000/api/v1',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ActionChip(
                  label: const Text('Android (10.0.2.2)', style: TextStyle(fontSize: 11)),
                  onPressed: () => controller.text = 'http://10.0.2.2:8000/api/v1',
                ),
                ActionChip(
                  label: const Text('Localhost (127.0.0.1)', style: TextStyle(fontSize: 11)),
                  onPressed: () => controller.text = 'http://127.0.0.1:8000/api/v1',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('បោះបង់'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUrl = controller.text.trim();
              if (newUrl.isNotEmpty) {
                ApiConstants.setFullBaseUrl(newUrl);
                final storage = await StorageService.getInstance();
                await storage.saveServerUrl(newUrl);
                if (mounted) Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Server URL updated: $newUrl'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('រក្សាទុក'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Server Settings (កំណត់ Server)',
            icon: const Icon(Icons.settings_ethernet, color: AppColors.textSecondary),
            onPressed: _showServerConfigModal,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo Header
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3302569B),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.delivery_dining, size: 44, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Omni Delivery & POS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'សូមជ្រើសរើសដើម្បីចូលគណនី ឬចុះឈ្មោះប្រើប្រាស់',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Tab Bar (Sign In / Register)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'ចូលគណនី (Sign In)'),
                    Tab(text: 'ចុះឈ្មោះ (Register)'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tab Views
              SizedBox(
                height: 340,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // =========================
                    // TAB 1: SIGN IN FORM
                    // =========================
                    Form(
                      key: _loginFormKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _loginEmailController,
                            label: 'Email (អ៊ីមែល)',
                            hint: 'admin@omni.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'សូមបញ្ចូលអ៊ីមែល';
                              if (!val.contains('@')) return 'ទម្រង់អ៊ីមែលមិនត្រឹមត្រូវ';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(
                            controller: _loginPasswordController,
                            label: 'Password (ពាក្យសម្ងាត់)',
                            hint: '••••••••',
                            isPassword: true,
                            prefixIcon: Icons.lock_outline,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'សូមបញ្ចូលពាក្យសម្ងាត់';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            text: 'ចូលគណនី (Sign In)',
                            onPressed: _handleLogin,
                            isLoading: _isLoading,
                          ),
                          const SizedBox(height: 12),
                          // Quick Demo Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('តេស្តរហ័ស: ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              TextButton(
                                onPressed: () {
                                  _loginEmailController.text = 'admin@omni.com';
                                  _loginPasswordController.text = 'admin123';
                                },
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 24)),
                                child: const Text('Admin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                              const Text(' • ', style: TextStyle(color: Colors.grey)),
                              TextButton(
                                onPressed: () {
                                  _loginEmailController.text = 'cashier@omni.com';
                                  _loginPasswordController.text = 'cashier123';
                                },
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 24)),
                                child: const Text('Cashier', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // =========================
                    // TAB 2: REGISTER FORM
                    // =========================
                    Form(
                      key: _registerFormKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _regNameController,
                            label: 'Full Name (ឈ្មោះពេញ)',
                            hint: 'ឧ. ហេង សុវណ្ណារ៉ា',
                            prefixIcon: Icons.person_outline,
                            validator: (val) => val == null || val.trim().isEmpty ? 'សូមបញ្ចូលឈ្មោះរបស់អ្នក' : null,
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            controller: _regEmailController,
                            label: 'Email (អ៊ីមែល)',
                            hint: 'customer@gmail.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'សូមបញ្ចូលអ៊ីមែល';
                              if (!val.contains('@')) return 'ទម្រង់អ៊ីមែលមិនត្រឹមត្រូវ';
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            controller: _regPasswordController,
                            label: 'Password (ពាក្យសម្ងាត់យ៉ាងតិច ៦ ខ្ទង់)',
                            hint: '••••••••',
                            isPassword: true,
                            prefixIcon: Icons.lock_outline,
                            validator: (val) {
                              if (val == null || val.length < 6) return 'ពាក្យសម្ងាត់ត្រូវមានយ៉ាងតិច ៦ ខ្ទង់';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'បង្កើតគណនីថ្មី (Create Account)',
                            onPressed: _handleRegister,
                            isLoading: _isLoading,
                            backgroundColor: AppColors.success,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Row(
                children: [
                  Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('ឬ', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: AppColors.border)),
                ],
              ),
              const SizedBox(height: 16),

              // Google Sign-In Button
              OutlinedButton(
                onPressed: _isLoading ? null : _handleGoogleSignIn,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.g_mobiledata, size: 28, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'ចូលប្រើជាមួយ Google Account',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined, size: 14, color: AppColors.textMuted),
                  SizedBox(width: 4),
                  Text(
                    'Neon PostgreSQL Cloud • Multi-Branch Ready',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
