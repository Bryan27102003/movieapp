import 'package:flutter/material.dart';
import 'package:movieapp/ui/widgets/cinepolis_logo.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendRecoveryLink() {
    // Aquí iría la lógica para llamar a la API de recuperación.
    // Por ahora, mostraremos un mensaje de confirmación.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Si existe una cuenta, se ha enviado un enlace a ${_emailController.text}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // El AppBar usará el color y estilo de nuestro tema.
        title: const Text('Recuperar Contraseña'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CinepolisLogo(size: 100),
              const SizedBox(height: 24.0),
              Text(
                '¿Problemas para iniciar sesión?',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Ingresa tu correo electrónico y te enviaremos un enlace para que recuperes el acceso a tu cuenta.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
              ),
              const SizedBox(height: 32.0),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _sendRecoveryLink,
                child: const Text('Enviar enlace'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
