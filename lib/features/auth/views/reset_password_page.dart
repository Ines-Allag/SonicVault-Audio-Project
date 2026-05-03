import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sonic_vault/features/auth/viewmodels/auth_viewmodel.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // tracks if email was sent successfully
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0A0A0A),
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Reset Password',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: _emailSent
                    ? _buildSuccessState() // show success after email sent
                    : _buildFormState(viewModel), // show form by default
              ),
            ),
          ),
        );
      },
    );
  }

  // ── FORM STATE ─────────────────────────────
  // what user sees before sending the email
  Widget _buildFormState(AuthViewModel viewModel) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          const Icon(
            Icons.lock_reset_rounded,
            size: 80,
            color: Color(0xFF6C63FF),
          ),

          const SizedBox(height: 24),

          const Text(
            'Forgot your password?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Enter your email and we will send you a link to reset your password.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white54,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // ── EMAIL FIELD ─────────────────────
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: Colors.white54,
              ),
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF6C63FF),
                ),
              ),
              errorStyle: const TextStyle(color: Colors.redAccent),
            ),
            onChanged: (_) => viewModel.clearError(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // ── ERROR MESSAGE ───────────────────
          if (viewModel.errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade800),
              ),
              child: Text(
                viewModel.errorMessage!,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 13,
                ),
              ),
            ),

          if (viewModel.errorMessage != null)
            const SizedBox(height: 16),

          // ── SEND BUTTON ─────────────────────
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () async {
                if (_formKey.currentState!.validate()) {
                  final bool success = await viewModel.resetPassword(
                    _emailController.text.trim(),
                  );
                  if (success && mounted) {
                    setState(() {
                      _emailSent = true;
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: viewModel.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                'Send Reset Link',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  // ── SUCCESS STATE ───────────────────────────
  // what user sees AFTER email is sent
  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        const Icon(
          Icons.mark_email_read_outlined,
          size: 100,
          color: Color(0xFF6C63FF),
        ),

        const SizedBox(height: 24),

        const Text(
          'Email Sent!',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'We sent a reset link to\n${_emailController.text.trim()}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white54,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        // ── BACK TO LOGIN ───────────────────
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              // pop back to login page
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Back to Login',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

      ],
    );
  }
}