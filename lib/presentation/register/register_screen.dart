
import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/presentation/login/widgets/left_panel_banner.dart';
import 'package:waste_collection_management_system/presentation/register/widgets/register_panel_form.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints){// constraints là thông tin về kích thước màn hình
            if ( constraints.maxWidth >800){
              return Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: const Color(0xffd2ebd9),
                      child: const Center(
                        child: SingleChildScrollView(child: LeftPanelBanner()),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: RegisterPanelForm()),
                    ),
                  )
                ],
              );
            }else{
              // giao dien mobile
            return Scaffold(
              backgroundColor: Colors.white,
              body: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Center(child: RegisterPanelForm()),
              ),
            );
            }
          },
        ),
      ),
    );
  }
}
