import 'package:flutter/material.dart';
import 'package:real_estate_auction_system/src/constants/colors.dart';
import 'package:real_estate_auction_system/src/constants/images.dart';
import 'package:real_estate_auction_system/src/features/controllers/login_controller.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  late Size mediaSize;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    mediaSize = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SafeArea(
          child: SizedBox(
              width: mediaSize.width,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Center(
                        child: Text(
                          'Tạo tài khoản',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 30),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('Tên'),
                      const SizedBox(
                        height: 10,
                      ),
                      _buildInputField('Tên', fullNameController),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('Tên đăng nhập'),
                      const SizedBox(
                        height: 10,
                      ),
                      _buildInputField('Tên đăng nhập', userNameController),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('Số điện thoại'),
                      const SizedBox(
                        height: 10,
                      ),
                      _buildInputField('Số điện thoại', phoneController),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('Email'),
                      const SizedBox(
                        height: 10,
                      ),
                      _buildInputField('Email', emailController),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('Mật khẩu'),
                      const SizedBox(
                        height: 10,
                      ),
                      _buildInputField('Mật khẩu', passwordController),
                      const Spacer(),
                      Container(
                        margin: const EdgeInsets.only(bottom: 50),
                        width: mediaSize.width,
                        child: ElevatedButton(
                          onPressed: () {
                            String fullName= fullNameController.text;
                            String userName = userNameController.text;
                            String email = emailController.text;
                            String phone = phoneController.text;
                            String password = passwordController.text;
                            createAccount(context, fullName, userName, email, phone, password);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Text(
                            "Xác nhận".toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ]),
              ),
            ),
        ));
  }

  Widget _buildInputField(String text, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.person_outline_outlined),
          labelText: text,
          hintText: text,
          border: const OutlineInputBorder(),
          suffixIcon: const IconButton(
            onPressed: null,
            icon: Icon(null),
          )),
    );
  }
}
