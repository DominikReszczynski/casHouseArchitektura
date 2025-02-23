import 'package:cas_house/providers/user_provider.dart';
import 'package:cas_house/sections/user/user_section_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserSectionMain extends StatefulWidget {
  const UserSectionMain({super.key});

  @override
  State<UserSectionMain> createState() => _UserSectionMainState();
}

class _UserSectionMainState extends State<UserSectionMain> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      return ListView(
        children: [
          const UserSectionHeader(),
          Column(
            children: [
              Center(
                child: Text(
                  "User ${userProvider.count}",
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              IconButton(
                  onPressed: () => {userProvider.increment()},
                  icon: const Icon(Icons.plus_one)),
              IconButton(
                  onPressed: () => {userProvider.decrement()},
                  icon: const Icon(Icons.exposure_minus_1_outlined)),
            ],
          ),
        ],
      );
    });
  }
}
