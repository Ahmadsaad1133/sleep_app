import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'horizontal_item.dart';

class MeditationHorizontalList extends StatelessWidget {
  const MeditationHorizontalList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: StreamBuilder<QuerySnapshot>(
        stream:
        FirebaseFirestore.instance.collection('meditation_items').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No categories found'));
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: HorizontalItem(
                  imageUrl: data['image'] as String? ?? '',
                  title: data['title'] as String? ?? '',
                  subtitle: data['subtitle'] as String? ?? '',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
