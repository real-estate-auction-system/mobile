import 'package:flutter/material.dart';
import 'package:real_estate_auction_system/src/constants/images.dart';
import 'package:real_estate_auction_system/src/features/controllers/login_controller.dart';
import 'package:real_estate_auction_system/src/features/controllers/user_controller.dart';
import 'package:real_estate_auction_system/src/features/models/user.dart';
import 'package:real_estate_auction_system/src/constants/colors.dart';
import 'package:real_estate_auction_system/src/features/widgets/box.dart';

class Setting extends StatefulWidget {
  final VoidCallback? onPressedCallback;

  const Setting({super.key, this.onPressedCallback});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  late User _user;
  late bool _loading;
  @override
  void initState() {
    initializeData();
    super.initState();
  }

  Future<void> initializeData() async {
    setState(() {
      _loading = true;
    });
    User fetchedData = await getUserDetail();
    setState(() {
      _user = fetchedData;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double imageSize = MediaQuery.of(context).size.width * 2 / 3;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            'Cài đặt',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
        ),
        body: FutureBuilder(
            future: null,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  _loading) {
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 200),
                    Center(
                      child: CircularProgressIndicator(
                        color: mainColor,
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('Error fetching data'),
                );
              } else {
                return SizedBox(
                    child: Column(
                      children: [
                        SizedBox(
                          width: imageSize,
                          height: imageSize,
                          child: const ClipOval(
                            child: Image(
                                    image: AssetImage(userLogo),
                                    height: 200,
                                    width: 200,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _user.fullName,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Box(
                          titleString: 'Quản lý thông tin',
                          onPressedCallback: () {},
                        ),
                        const SizedBox(height: 10),
                        Box(
                          titleString: 'Đổi mật khẩu',
                          onPressedCallback: () {
                          },
                        ),
                        const SizedBox(height: 10),
                        Box(
                          titleString: 'Đăng xuất',
                          onPressedCallback: () {
                            logoutFuture(context);
                          },
                          isLogout: true,
                        ),
                      ],
                    ));
              }
            }));
  }
}