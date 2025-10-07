import 'package:flutter/material.dart';
import 'package:movieapp/core/services/api_service.dart';
import 'package:movieapp/ui/screens/forgot_password_screen.dart'; // <-- REFERENCIA AÑADIDA
import 'package:movieapp/ui/screens/home_screen.dart';
import 'package:movieapp/ui/screens/register_screen.dart'; // <-- REFERENCIA AÑADIDA
import 'package:movieapp/ui/widgets/cinepolis_logo.dart';

enum ButtonState { init, loading, done, error }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isPasswordObscured = true;
  ButtonState _buttonState = ButtonState.init;
  
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text;
    final bool isValid = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    if(mounted) setState(() => _isEmailValid = isValid);
  }

  void _validatePassword() {
    final password = _passwordController.text;
    final bool isValid = password.length >= 6;
    if(mounted) setState(() => _isPasswordValid = isValid);
  }
  
  Future<void> _performLogin() async {
    if (!_isEmailValid || !_isPasswordValid || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      return;
    }
    
    setState(() => _buttonState = ButtonState.loading);
    
    try {
      final _ = await _apiService.login(_emailController.text, _passwordController.text);
      setState(() => _buttonState = ButtonState.done);
      await Future.delayed(const Duration(milliseconds: 1500));
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      final errorMessage = e.toString().replaceAll("Exception: ", "");
      setState(() => _buttonState = ButtonState.error);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      
      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        setState(() => _buttonState = ButtonState.init);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = _buttonState == ButtonState.done;
    final isError = _buttonState == ButtonState.error;
    final bool isFormValid = _isEmailValid && _isPasswordValid && _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CinepolisLogo(size: 120),
                const SizedBox(height: 24.0),
                Text(
                  'Bienvenido',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Inicia sesión para continuar',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
                ),
                const SizedBox(height: 32.0),
                
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    errorText: _emailController.text.isNotEmpty && !_isEmailValid ? 'Formato de email incorrecto' : null, 
                  ),
                ),
                const SizedBox(height: 16.0),

                TextField(
                  controller: _passwordController,
                  obscureText: _isPasswordObscured,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    errorText: _passwordController.text.isNotEmpty && !_isPasswordValid ? 'Mínimo 6 caracteres' : null,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordObscured = !_isPasswordObscured;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                      );
                    },
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                       style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: isFormValid && _buttonState == ButtonState.init ? _performLogin : null, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDone ? Colors.green : (isError ? Colors.red : Theme.of(context).colorScheme.primary),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(scale: animation, child: child),
                        );
                      },
                      child: buildButtonChild(),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("¿No tienes una cuenta?", style: Theme.of(context).textTheme.bodyMedium),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: Text(
                        'Crear cuenta',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // --- CAMBIO: AJUSTAMOS EL ESTILO DEL ÍCONO CIRCULAR PARA QUE NO SEA OPACO ---
  Widget buildButtonChild() {
    if (_buttonState == ButtonState.loading) {
      return const SizedBox(
        key: ValueKey('loading'),
        width: 24,
        height: 24,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      );
    } else if (_buttonState == ButtonState.done) {
      return Row(
        key: const ValueKey('done'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white, // <-- CAMBIO: Color sólido
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 18, color: Colors.green), // <-- CAMBIO: Icono con color de contraste
          ),
          const SizedBox(width: 8),
          const Text("¡Éxito!", style: TextStyle(fontSize: 18, color: Colors.white)),
        ],
      );
    } else if (_buttonState == ButtonState.error) {
      return Row(
        key: const ValueKey('error'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white, // <-- CAMBIO: Color sólido
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 18, color: Colors.red), // <-- CAMBIO: Icono con color de contraste
          ),
          const SizedBox(width: 8),
          const Text("Reintentar", style: TextStyle(fontSize: 18, color: Colors.white)),
        ],
      );
    } else {
      return const Text(
        'Iniciar Sesión',
        key: ValueKey('init'),
        style: TextStyle(fontSize: 18, color: Colors.white),
      );
    }
  }
}

