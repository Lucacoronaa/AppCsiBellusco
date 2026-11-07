import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:squadra_csi/features/auth/data/auth_repository_provider.dart';
import 'package:squadra_csi/features/auth/domain/auth_failure.dart';
import 'package:squadra_csi/features/auth/domain/credentials_validator.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool isNewAccount}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repository = ref.read(authRepositoryProvider);
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      if (isNewAccount) {
        await repository.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await repository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
    } on AuthFailure catch (failure) {
      if (mounted) {
        setState(() => _errorMessage = _messageFor(failure));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _messageFor(AuthFailure failure) {
    return switch (failure) {
      InvalidCredentials() => 'Email o password non corretti.',
      EmailAlreadyInUse() => 'Esiste già un account con questa email.',
      WeakPassword() => 'La password è troppo debole.',
      NetworkFailure() => 'Connessione assente. Riprova.',
      UnknownAuthFailure() => 'Si è verificato un errore. Riprova.',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Squadra CSI')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              validator: (value) => isValidEmail(value ?? '')
                  ? null
                  : "Inserisci un'email valida.",
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) => isValidPassword(value ?? '')
                  ? null
                  : 'Almeno $minPasswordLength caratteri.',
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 16),
            ],
            FilledButton(
              onPressed: _isLoading ? null : () => _submit(isNewAccount: false),
              child: _isLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Accedi'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _isLoading ? null : () => _submit(isNewAccount: true),
              child: const Text('Crea un account'),
            ),
          ],
        ),
      ),
    );
  }
}
