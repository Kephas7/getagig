import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Search gigs",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Applied: 0"),
              Text("Accepted: 0"),
              Text("Completed: 0"),
            ],
          ),

          const SizedBox(height: 30),

          const Text(
            "Featured Gigs",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FeaturedGigsCard(),
                _FeaturedGigsCard(),
                _FeaturedGigsCard(),
              ],
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "Latest Gigs",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          _GigCard(),
          _GigCard(),
          _GigCard(),
        ],
      ),
    );
  }

  static Widget _FeaturedGigsCard() {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Music Event", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text("Kathmandu"),
          Spacer(),
          Text("Rs. 10,000"),
        ],
      ),
    );
  }

  static Widget _GigCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text("Acoustic Performance"), Text("Rs. 8,000")],
      ),
    );
  }
}
