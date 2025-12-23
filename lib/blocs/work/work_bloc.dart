import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resume_builder/firestore/user_firestore.dart';
import 'package:resume_builder/model/model.dart';
import 'package:resume_builder/my_singleton.dart';
import 'work_event.dart';
import 'work_state.dart';

class WorkBloc extends Bloc<WorkEvent, WorkState> {
  final FireUser fireUser;

  WorkBloc({required this.fireUser}) : super(WorkInitial()) {
    on<LoadWorkList>(_onLoadWorkList);
    on<AddWork>(_onAddWork);
    on<UpdateWork>(_onUpdateWork);
    on<DeleteWorkplace>(_onDeleteWorkplace);
    on<MoveWorkUp>(_onMoveWorkUp);
    on<MoveWorkDown>(_onMoveWorkDown);
  }

  Future<void> _onLoadWorkList(LoadWorkList event, Emitter<WorkState> emit) async {
    emit(WorkLoading());
    try {
      final workList = await fireUser.getWorkExperiences(userId: event.userId, resumeId: event.id);
      workList.sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));
      emit(WorkLoaded(workList));
    } catch (e) {
      emit(WorkError("Failed to load work list: ${e.toString()}"));
    }
  }

  // --- FIX: OPTIMISTIC UPDATE FOR ADDING A WORK ITEM ---
  Future<void> _onAddWork(AddWork event, Emitter<WorkState> emit) async {
    final currentState = state;
    if (currentState is! WorkLoaded) return; // Can only add if a list is loaded

    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;
    if (userId == null || resumeId == null) return;

    try {
      final maxSortOrder = currentState.works.isEmpty ? -1 : currentState.works.map((e) => e.sortOrder ?? 0).reduce((a, b) => a > b ? a : b);
      final workWithSortOrder = event.work.copyWith(sortOrder: maxSortOrder + 1);

      final docRef = await fireUser.addWorkExperience(
        userId: userId,
        resumeId: resumeId,
        work: workWithSortOrder,
      );

      final newWorkItem = workWithSortOrder.copyWith(id: docRef.id);
      final updatedList = List<WorkModel>.from(currentState.works)..add(newWorkItem);

      // Emit the updated list immediately without re-fetching from the server
      emit(WorkLoaded(updatedList));
    } catch (e) {
      emit(WorkError("Failed to add work: ${e.toString()}"));
    }
  }

  // --- FIX: OPTIMISTIC UPDATE FOR UPDATING A WORK ITEM ---
  Future<void> _onUpdateWork(UpdateWork event, Emitter<WorkState> emit) async {
    final currentState = state;
    if (currentState is WorkLoaded) {
      final userId = MySingleton.userId;
      final resumeId = MySingleton.resumeId;
      if (userId == null || resumeId == null) return;

      try {
        await fireUser.updateWorkExperience(
          userId: userId,
          resumeId: resumeId,
          work: event.work,
        );
        final updatedList = currentState.works.map((work) => work.id == event.work.id ? event.work : work).toList();
        emit(WorkLoaded(updatedList));
      } catch (e) {
        emit(WorkError("Failed to update work: ${e.toString()}"));
      }
    }
  }

  // --- FIX: OPTIMISTIC UPDATE FOR DELETING A WORK ITEM ---
  Future<void> _onDeleteWorkplace(DeleteWorkplace event, Emitter<WorkState> emit) async {
    final currentState = state;
    if (currentState is WorkLoaded) {
      try {
        await fireUser.deleteWorkExperience(
          userId: event.userId,
          resumeId: event.id,
          workId: event.wid,
        );
        final updatedList = currentState.works.where((work) => work.id != event.wid).toList();
        emit(WorkLoaded(updatedList));
      } catch (e) {
        emit(WorkError("Failed to delete work: ${e.toString()}"));
      }
    }
  }

  Future<void> _onMoveWorkUp(MoveWorkUp event, Emitter<WorkState> emit) async {
    if (state is WorkLoaded) {
      final list = (state as WorkLoaded).works;
      final index = event.currentIndex;
      if (index > 0) {
        await _swapSortOrder(list[index], list[index - 1], emit);
      }
    }
  }

  Future<void> _onMoveWorkDown(MoveWorkDown event, Emitter<WorkState> emit) async {
    if (state is WorkLoaded) {
      final list = (state as WorkLoaded).works;
      final index = event.currentIndex;
      if (index < list.length - 1) {
        await _swapSortOrder(list[index], list[index + 1], emit);
      }
    }
  }

  Future<void> _swapSortOrder(WorkModel itemA, WorkModel itemB, Emitter<WorkState> emit) async {
    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;
    if (userId == null || resumeId == null || state is! WorkLoaded) return;

    final originalList = (state as WorkLoaded).works;
    final sortOrderA = itemA.sortOrder;
    final sortOrderB = itemB.sortOrder;

    final newList = List<WorkModel>.from(originalList);
    final indexA = newList.indexWhere((w) => w.id == itemA.id);
    final indexB = newList.indexWhere((w) => w.id == itemB.id);
    newList[indexA] = itemA.copyWith(sortOrder: sortOrderB);
    newList[indexB] = itemB.copyWith(sortOrder: sortOrderA);
    newList.sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));
    emit(WorkLoaded(newList));

    try {
      await fireUser.updateWorkSortOrder(userId: userId, resumeId: resumeId, workId: itemA.id!, newSortOrder: sortOrderB);
      await fireUser.updateWorkSortOrder(userId: userId, resumeId: resumeId, workId: itemB.id!, newSortOrder: sortOrderA);
    } catch (e) {
      emit(WorkLoaded(originalList));
      emit(WorkError("Failed to reorder items: ${e.toString()}"));
    }
  }
}