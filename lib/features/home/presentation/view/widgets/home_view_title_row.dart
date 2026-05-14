import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_app/core/helper_widgets/responsive_text.dart';
import 'package:graduation_app/core/utils/assets.dart';
import 'package:graduation_app/features/profile/presentation/view/profile_view.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../models/user_model_auth.dart';
import '../../../../../services/firestore_service.dart';

class HomeViewTitleRow extends StatelessWidget {
   HomeViewTitleRow({
    super.key,
  });
  FireStoreService userStore=FireStoreService();
  final currentUser = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

          FutureBuilder<UserModel?>(
        future: userStore.getUserFromFireStore(currentUser.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return  Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: 120,
                  height: 18,
                  color: Colors.white,
                ),
              );
            }

            var user = snapshot.data!;
           return ResponsiveText(
              child: Text(
                user.name,
                style: TextStyle(
                  fontFamily:
                  Assets.resourceFontsPatrickHandSCRegular,
                  fontSize: 30,
                  color: Color(0xFF000000),
                ),
              ),
            )
            ;
          } ),
          Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, ProfileView.routeName);
            },
            child: CircleAvatar(
              minRadius: 11,
              maxRadius: 21,
              backgroundImage:
                  AssetImage(Assets.assetsImagesPersonalAvatar),
            ),
          ),
        ]),
      ),
    );
  }
}

