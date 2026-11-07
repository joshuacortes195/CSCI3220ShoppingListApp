import 'package:flutter/material.dart';

// all the category types an item can be
enum Categories {
  vegetables,
  fruit,
  meat,
  dairy,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other
}

// a category with its name and color
class Category {
  const Category(this.title, this.color);

  final String title; 
  final Color color; 
}