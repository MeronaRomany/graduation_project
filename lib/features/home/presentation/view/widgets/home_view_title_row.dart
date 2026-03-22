import 'package:flutter/material.dart';
import 'package:graduation_app/core/helper_widgets/responsive_text.dart';
import 'package:graduation_app/core/utils/assets.dart';

class HomeViewTitleRow extends StatelessWidget {
  const HomeViewTitleRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(children: [
          ResponsiveText(
            child: Text(
              'Hi, Afraym Herz👋',
              style: TextStyle(
                fontFamily:
                    Assets.resourceFontsPatrickHandSCRegular,
                fontSize: 30,
                color: Color(0xFF000000),
              ),
            ),
          ),
          Spacer(),
          CircleAvatar(
            minRadius: 11,
            maxRadius: 21,
            backgroundImage:
                AssetImage(Assets.resourceImagesPersonalAvatar),
          ),
        ]),
      ),
    );
  }
}

