import 'package:aimimi/constants/styles.dart';
import 'package:aimimi/models/goal.dart';
import 'package:aimimi/models/user.dart';
import 'package:aimimi/services/auth_service.dart';
import 'package:aimimi/services/goal_service.dart';
import 'package:aimimi/views/shares/goal_shared_view.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class SharedGoalItem extends StatefulWidget {
  final String goalID;
  final String title;
  final String category;
  final String period;
  final int frequency;
  final int timespan;
  final String description;
  final bool publicity;
  final dynamic createdBy;
  final users;

  SharedGoalItem({
    Key key,
    this.goalID,
    this.title,
    this.category,
    this.period,
    this.frequency,
    this.timespan,
    this.description,
    this.publicity,
    this.createdBy,
    this.users,
  }) : super(key: key);

  @override
  State<SharedGoalItem> createState() => _SharedGoalItemState();
}

class _SharedGoalItemState extends State<SharedGoalItem> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<JoinedUser>>(
        stream: GoalService(goalID: widget.goalID).joinedUsers,
        builder: (context, snapshot) {
          List<JoinedUser> joinedUsers = snapshot.data ?? [];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SharedGoalView(
                      goalID: widget.goalID,
                    ),
                  ));
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 20,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              color: themeShadedColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            widget.category,
                            style: TextStyle(
                              color: monoSecondaryColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 42,
                        width: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0xffFF9C9C),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.walking,
                          size: 23,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _buildDateCircles(),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 20,
                            color: monoSecondaryColor,
                          ),
                          SizedBox(width: 5),
                          Text(
                            joinedUsers.length.toString(),
                            style: TextStyle(
                              color: monoSecondaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 14),
                          Icon(
                            Icons.date_range,
                            size: 20,
                            color: monoSecondaryColor,
                          ),
                          SizedBox(width: 5),
                          Text(
                            widget.timespan.toString(),
                            style: TextStyle(
                              color: monoSecondaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            maxRadius: 15,
                          ),
                          SizedBox(width: 7),
                          Text(
                            widget.createdBy,
                            style: TextStyle(
                              color: themeShadedColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  List<Widget> _buildDateCircles() {
    List<String> days = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];

    return days.map((day) {
      return _buildDateCircle(day);
    }).toList();
  }

  Container _buildDateCircle(String dayText) {
    return Container(
      height: 42,
      width: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: themeColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        dayText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
