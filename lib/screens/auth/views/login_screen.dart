import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // دالة تسجيل الدخول أو إنشاء حساب تلقائي بالإيميل والباسورد
  Future<void> _loginOrRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // محاولة تسجيل الدخول لو الحساب موجود
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      // لو الحساب مش موجود، نعمله حساب جديد أوتوماتيك ونحفظ بياناته كعميل/تاجر
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        try {
          UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
          await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
            'email': _emailController.text.trim(),
            'role': 'customer', // ممكن نغيرها لـ vendor للتاجر
            'isPaidVendor': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } catch (regError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في التسجيل: $regError')),
          );
          setState(() => _isLoading = false);
          return;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: ${e.message}')),
        );
        setState(() => _isLoading = false);
        return;
      }
    }

    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        entryPointScreenRoute,
        ModalRoute.withName(logInScreenRoute),
      );
    }
  }

  // دالة تسجيل الدخول بحساب جوجل مباشرة
  Future<void> _signInWithGoogle() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      UserCredential userCred = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      
      await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
        'email': userCred.user!.email,
        'name': userCred.user!.displayName,
        'role': 'customer',
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          entryPointScreenRoute,
          ModalRoute.withName(logInScreenRoute),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تأكد من تفعيل Google في Firebase: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              "assets/images/login_dark.png",
              fit: BoxFit.cover,
              height: size.height * 0.35,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "أهلاً بك في Queen Fashion!",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "سجل دخولك أو اكتب إيميل وباسورد جديد لإنشاء حساب فوراً.",
                  ),
                  const SizedBox(height: defaultPadding),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          validator: emaildValidator.call,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: "البريد الإلكتروني (Email)",
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                        TextFormField(
                          controller: _passwordController,
                          validator: passwordValidator.call,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: "كلمة المرور (Password)",
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: defaultPadding * 1.5),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _loginOrRegister,
                          child: const Text("تسجيل دخول / إنشاء حساب"),
                        ),
                  const SizedBox(height: defaultPadding),
                  OutlinedButton(
                    onPressed: _signInWithGoogle,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login),
                        SizedBox(width: 8),
                        Text("الدخول السريع بحساب Google"),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}