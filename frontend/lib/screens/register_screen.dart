import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  // Inicializar las animaciones correctamente
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  
  late final Animation<double> _fadeAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeIn,
  ));

  String _name = '';
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (!_acceptedTerms) {
        _showErrorSnackBar('Debe aceptar los términos y condiciones');
        return;
      }

      setState(() => _isLoading = true);
      _formKey.currentState!.save();

      try {
        bool success = await _authService.register(_name, _email, _password);
        if (success && mounted) {
          Navigator.pushReplacementNamed(context, '/main');
        } else {
          _showErrorSnackBar('Error al crear la cuenta');
        }
      } catch (e) {
        _showErrorSnackBar('Error en el registro');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.background,
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo animado
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1200),
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_add_outlined,
                            size: 50,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      Text(
                        'Crear Cuenta',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                          letterSpacing: 1.5,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Complete sus datos para registrarse',
                        style: TextStyle(
                          color: colorScheme.onBackground.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 40),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Campo de nombre
                            TextFormField(
                              style: TextStyle(color: colorScheme.onBackground),
                              decoration: InputDecoration(
                                hintText: 'Nombre completo',
                                prefixIcon: Icon(Icons.person_outline,
                                  color: colorScheme.primary.withOpacity(0.7)),
                                filled: true,
                                fillColor: colorScheme.surface.withOpacity(0.5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Ingrese su nombre';
                                }
                                return null;
                              },
                              onSaved: (value) => _name = value!,
                            ),

                            const SizedBox(height: 16),

                            // Campo de email
                            TextFormField(
                              style: TextStyle(color: colorScheme.onBackground),
                              decoration: InputDecoration(
                                hintText: 'Correo electrónico',
                                prefixIcon: Icon(Icons.email_outlined,
                                  color: colorScheme.primary.withOpacity(0.7)),
                                filled: true,
                                fillColor: colorScheme.surface.withOpacity(0.5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Ingrese su correo';
                                }
                                if (!value!.contains('@')) {
                                  return 'Ingrese un correo válido';
                                }
                                return null;
                              },
                              onSaved: (value) => _email = value!,
                            ),

                            const SizedBox(height: 16),

                            // Campo de contraseña
                            TextFormField(
                              style: TextStyle(color: colorScheme.onBackground),
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                hintText: 'Contraseña (mín. 6 caracteres)',
                                prefixIcon: Icon(Icons.lock_outline,
                                  color: colorScheme.primary.withOpacity(0.7)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: colorScheme.primary.withOpacity(0.7),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: colorScheme.surface.withOpacity(0.5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Ingrese su contraseña';
                                }
                                if (value!.length < 6) {
                                  return 'La contraseña debe tener al menos 6 caracteres';
                                }
                                return null;
                              },
                              onSaved: (value) => _password = value!,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Checkbox de términos y condiciones
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptedTerms,
                            onChanged: (bool? value) {
                              setState(() {
                                _acceptedTerms = value ?? false;
                              });
                            },
                            activeColor: colorScheme.primary,
                          ),
                          Expanded(
                            child: Text(
                              'Acepto los términos y condiciones',
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Botón de registro
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        colorScheme.onPrimary),
                                  ),
                                )
                              : const Text(
                                  'Crear Cuenta',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Link para iniciar sesión
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "¿Ya tienes una cuenta?",
                            style: TextStyle(
                              color: colorScheme.onBackground.withOpacity(0.7),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Iniciar Sesión',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}