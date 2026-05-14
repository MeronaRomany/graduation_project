import 'package:flutter/material.dart';
import 'package:graduation_app/core/utils/app_colors.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar(
      {super.key, this.onItemTapped, required this.index});

  final Function(int)? onItemTapped;
  final int index;

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  List<String> titles = ['Home', 'Add scenario', 'Chat Practice'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            // mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            textDirection: TextDirection.ltr ,
            children: List.generate(
              titles.length,
              (index) {
                bool isSelected = widget.index == index;
                return Flexible(
                  fit: FlexFit.loose,
                  child: GestureDetector(
                      onTap: () {
                        if (index == 1) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true, // 👈 1. هذا السطر يسمح للـ BottomSheet بالتوسع ليأخذ كامل الشاشة
                            backgroundColor: Colors.white, // لون خلفية النافذة
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)), // زوايا دائرية علوية فقط
                            ),
                            builder: (context) {
                              return Container(
                                height: MediaQuery.of(context).size.height * 0.9,
                                padding: EdgeInsets.only(
                                  top: 20,
                                  left: 20,
                                  right: 20,
                                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 4,
                                      margin: const EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const Text(
                                      'Write your scenario',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    Expanded(
                                      child: TextField(
                                        maxLines: null,
                                        expands: true,
                                        keyboardType: TextInputType.multiline,
                                        textAlignVertical: TextAlignVertical.top,                                        decoration: InputDecoration(
                                          hintText: 'Enter your text...',
                                          alignLabelWithHint: true,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.black)
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide(color: Colors.black)

                                          ),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.black)

                                        ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () {

                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF6200EE),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                      ),
                                      child: const Text(
                                        "Custom Submit",
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),

                                  ],
                                ),
                              );
                            },
                          );

                        } else {
                          widget.onItemTapped!(index);
                        }
                      },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          titles[index],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.primaryColor,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
