import 'package:e_commerce_app/features/admin/data/repositories/category_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_category_event.dart';
import 'admin_category_state.dart';

class AdminCategoryBloc extends Bloc<AdminCategoryEvent, AdminCategoryState> {
  final AdminCategoryRepository repository;

  AdminCategoryBloc({required this.repository})
      : super(AdminCategoryInitial()) {
    on<FetchCategoriesEvent>(_onFetchCategories);
    on<CreateCategoryEvent>(_onCreateCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  Future<void> _onFetchCategories(
      FetchCategoriesEvent event, Emitter<AdminCategoryState> emit) async {
    emit(AdminCategoryLoading());
    try {
      final categories = await repository.getCategories();
      emit(AdminCategoryLoaded(categories));
    } catch (e) {
      emit(AdminCategoryError(e.toString()));
    }
  }

  Future<void> _onCreateCategory(
      CreateCategoryEvent event, Emitter<AdminCategoryState> emit) async {
    emit(AdminCategoryLoading()); // Loader dikhayein
    try {
      await repository.createCategory(event.name, imageFile: event.imageFile);
      emit(const AdminCategorySuccess('Category created successfully!'));
      add(FetchCategoriesEvent()); // List auto-refresh karein
    } catch (e) {
      emit(AdminCategoryError(e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
      UpdateCategoryEvent event, Emitter<AdminCategoryState> emit) async {
    emit(AdminCategoryLoading());
    try {
      await repository.updateCategory(event.id, event.name,
          imageFile: event.imageFile);
      emit(const AdminCategorySuccess('Category updated successfully!'));
      add(FetchCategoriesEvent());
    } catch (e) {
      emit(AdminCategoryError(e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
      DeleteCategoryEvent event, Emitter<AdminCategoryState> emit) async {
    emit(AdminCategoryLoading());
    try {
      await repository.deleteCategory(event.id);
      emit(const AdminCategorySuccess('Category deleted successfully!'));
      add(FetchCategoriesEvent());
    } catch (e) {
      emit(AdminCategoryError(e.toString()));
    }
  }
}
