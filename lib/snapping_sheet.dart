import 'package:flutter/material.dart';
import 'package:hello_me/profile_page.dart';
import 'package:hello_me/user_aut_repository.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

class HomePageSnappingSheet extends StatefulWidget {
  const HomePageSnappingSheet({Key? key}) : super(key: key);

  @override
  _HomePageSnappingSheetState createState() => _HomePageSnappingSheetState();
}

class _HomePageSnappingSheetState extends State<HomePageSnappingSheet> {
  final snappingSheetController = SnappingSheetController();
  bool opened = false;

  @override
  Widget build(BuildContext context) {
    final authRepo = context.watch<AuthRepository>();
    return SnappingSheet(
      controller: snappingSheetController,
      lockOverflowDrag: true,
      snappingPositions: const [
        SnappingPosition.factor(
          positionFactor: 0.0,
          snappingCurve: Curves.easeOutExpo,
          snappingDuration: Duration(seconds: 1),
          grabbingContentOffset: GrabbingContentOffset.top,
        ),
        SnappingPosition.factor(
          snappingCurve: Curves.elasticOut,
          snappingDuration: Duration(milliseconds: 1750),
          positionFactor: 0.5,
        ),
        SnappingPosition.factor(
          snappingCurve: Curves.bounceIn,
          snappingDuration: Duration(milliseconds: 1750),
          positionFactor: 0.9,
        ),
      ],
      grabbing: GestureDetector(
        onTap: () {
          opened
              ? snappingSheetController
                  .snapToPosition(const SnappingPosition.factor(
                  grabbingContentOffset: GrabbingContentOffset.top,
                  snappingCurve: Curves.easeOut,
                  snappingDuration: Duration(milliseconds: 500),
                  positionFactor: 0.0,
                ))
              : snappingSheetController
                  .snapToPosition(const SnappingPosition.factor(
                  grabbingContentOffset: GrabbingContentOffset.bottom,
                  snappingCurve: Curves.easeOut,
                  snappingDuration: Duration(milliseconds: 500),
                  positionFactor: 0.3,
                ));
          setState(() {
            opened = !opened;
          });
        },
        child: Container(
          height: 10,
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
          color: Colors.grey,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Welcome back, " + authRepo.user!.email.toString()),
              const Icon(Icons.expand_less),
            ],
          ),
        ),
      ),
      grabbingHeight: 50,
      sheetAbove: null,
      sheetBelow: SnappingSheetContent(
        child: const ProfilePage(),
      ),
    );
  }
}
