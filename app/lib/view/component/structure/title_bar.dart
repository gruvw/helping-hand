import "package:flutter/material.dart";
import "package:helping_hand/static/styles.dart";

class TitleScreen extends StatelessWidget {
  // final Color color;
  // final IconData icon;
  final String title;
  final Widget? child;
  final Future<void> Function()? onRefresh;

  const TitleScreen({
    super.key,
    required this.title,
    required this.child,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final child = this.child;
    final onRefresh = this.onRefresh;

    return Column(
      children: [
        Divider(
          color: Styles.colorSecondary,
          height: 2,
        ),
        Container(
          color: Styles.colorPrimary,
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: Styles.textTitle.apply(
                  color: Styles.colorSecondary,
                ),
              ),
            ],
          ),
        ),

        if (child != null)
          Expanded(
            child: onRefresh != null
                ? RefreshIndicator(
                    onRefresh: onRefresh,
                    child: child,
                  )
                : child,
          ),
      ],
    );
  }
}
