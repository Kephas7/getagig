import 'package:flutter/material.dart';

class Gigs extends StatelessWidget {
  const Gigs({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search gigs",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
            ],
          ),

          const SizedBox(height: 20),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Chip(label: Text("All")),
                SizedBox(width: 8),
                Chip(label: Text("Live Band")),
                SizedBox(width: 8),
                Chip(label: Text("Acoustic")),
                SizedBox(width: 8),
                Chip(label: Text("DJ")),
                SizedBox(width: 8),
                Chip(label: Text("Wedding")),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Column(children: List.generate(5, (index) => _gigItem())),
        ],
      ),
    );
  }

  Widget _gigItem() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Live Music Performance",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text("Kathmandu • 20 Aug"),
          SizedBox(height: 6),
          Text("Budget: Rs. 15,000"),
        ],
      ),
    );
  }
}
