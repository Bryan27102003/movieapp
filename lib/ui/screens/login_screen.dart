import 'package:flutter/material.dart';
import 'package:movieapp/core/services/api_service.dart';
import 'package:movieapp/ui/screens/home_screen.dart';

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
  ButtonState _buttonState = ButtonState.init;
  
  // --- NUEVO: VARIABLE PARA GUARDAR EL MENSAJE DE ERROR ---
  String? _errorMessage;
  
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
    setState(() {
      _isEmailValid = isValid;
    });
  }

  void _validatePassword() {
    final password = _passwordController.text;
    final bool isValid = password.length >= 6;
    setState(() {
      _isPasswordValid = isValid;
    });
  }
  
  Future<void> _performLogin() async {
    if (!_isEmailValid || !_isPasswordValid || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      return;
    }
    
    // --- CAMBIO: LIMPIAMOS ERRORES ANTERIORES AL INICIAR ---
    setState(() {
      _buttonState = ButtonState.loading;
      _errorMessage = null; 
    });
    
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
      // --- CAMBIO: GUARDAMOS EL ERROR EN NUESTRA VARIABLE DE ESTADO ---
      final errorMessage = e.toString().replaceAll("Exception: ", "");
      setState(() {
        _buttonState = ButtonState.error;
        _errorMessage = errorMessage;
      });
      
      // Ya no necesitamos la SnackBar, nuestro texto en la UI es mejor.
      
      await Future.delayed(const Duration(seconds: 3));

      // Reseteamos el estado para que el usuario pueda intentar de nuevo
      if (mounted) {
        setState(() {
          _buttonState = ButtonState.init;
          _errorMessage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = _buttonState == ButtonState.done;
    final isError = _buttonState == ButtonState.error;
    final bool isFormValid = _isEmailValid && _isPasswordValid && _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF1D1D27),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.15), 
              const Text(
                'MovieApp',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48.0),
              
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),
                  errorText: _emailController.text.isNotEmpty && !_isEmailValid ? 'Formato de email incorrecto' : null, 
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16.0),

              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                  errorText: _passwordController.text.isNotEmpty && !_isPasswordValid ? 'Mínimo 6 caracteres' : null,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24.0),

              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
                height: 60,
                child: ElevatedButton(
                  onPressed: isFormValid ? _performLogin : null, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDone ? Colors.green : (isError ? Colors.red : const Color(0xFFE50914)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: buildButtonChild(), 
                ),
              ),
              
              // --- NUEVO: WIDGET PARA MOSTRAR EL MENSAJE DE ERROR ---
              const SizedBox(height: 16.0),
              AnimatedOpacity(
                // Animamos la opacidad para que el texto aparezca y desaparezca suavemente
                duration: const Duration(milliseconds: 300),
                opacity: _errorMessage != null ? 1.0 : 0.0,
                child: Text(
                  // Mostramos el mensaje de error, o un texto vacío si no hay error
                  _errorMessage ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget buildButtonChild() {
    if (_buttonState == ButtonState.loading) {
      return const CircularProgressIndicator(color: Colors.white, strokeWidth: 2);
    } 
    else if (_buttonState == ButtonState.done) {
      return const Text("¡Éxito!", style: TextStyle(fontSize: 18, color: Colors.white));
    } 
    // --- CAMBIO: TEXTO DEL BOTÓN EN CASO DE ERROR ---
    else if (_buttonState == ButtonState.error) {
      return const Text("Reintentar", style: TextStyle(fontSize: 18, color: Colors.white));
    } 
    else {
      return const Text(
        'Iniciar Sesión',
        style: TextStyle(fontSize: 18, color: Colors.white),
      );
    }
  }
}