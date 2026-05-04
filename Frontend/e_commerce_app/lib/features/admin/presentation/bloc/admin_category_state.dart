import 'package:e_commerce_app/common/models/category_model.dart';
import 'package:equatable/equatable.dart';

abstract class AdminCategoryState extends Equatable {
  const AdminCategoryState();

  @override
  List<Object?> get props => [];
}

class AdminCategoryInitial extends AdminCategoryState {}

class AdminCategoryLoading extends AdminCategoryState {}

class AdminCategoryLoaded extends AdminCategoryState {
  final List<Category> categories;

  const AdminCategoryLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class AdminCategorySuccess extends AdminCategoryState {
  final String message;

  const AdminCategorySuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminCategoryError extends AdminCategoryState {
  final String message;

  const AdminCategoryError(this.message);

  @override
  List<Object?> get props => [message];
}
