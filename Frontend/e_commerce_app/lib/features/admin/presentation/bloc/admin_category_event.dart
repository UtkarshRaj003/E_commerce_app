import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class AdminCategoryEvent extends Equatable {
  const AdminCategoryEvent();

  @override
  List<Object?> get props => [];
}

class FetchCategoriesEvent extends AdminCategoryEvent {}

class CreateCategoryEvent extends AdminCategoryEvent {
  final String name;
  final File? imageFile;

  const CreateCategoryEvent({required this.name, this.imageFile});

  @override
  List<Object?> get props => [name, imageFile];
}

class UpdateCategoryEvent extends AdminCategoryEvent {
  final String id;
  final String name;
  final File? imageFile;

  const UpdateCategoryEvent({required this.id, required this.name, this.imageFile});

  @override
  List<Object?> get props => [id, name, imageFile];
}

class DeleteCategoryEvent extends AdminCategoryEvent {
  final String id;

  const DeleteCategoryEvent(this.id);

  @override
  List<Object?> get props => [id];
}