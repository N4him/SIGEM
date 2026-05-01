import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/api/service_locator.dart';
import '../../data/datasources/attendance_remote_datasource.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  late final AttendanceRemoteDataSource _dataSource;

  AttendanceBloc() : super(AttendanceInitial()) {
    _dataSource = AttendanceRemoteDataSource(sl());
    on<CheckInRequested>(_onCheckIn);
    on<CheckOutRequested>(_onCheckOut);
  }

  Future<void> _onCheckIn(CheckInRequested event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    try {
      final record = await _dataSource.checkIn(
        roomId: event.roomId,
        latitude: event.latitude,
        longitude: event.longitude,
      );
      emit(CheckInSuccess(record));
    } catch (e) {
      emit(AttendanceError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCheckOut(CheckOutRequested event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    try {
      final record = await _dataSource.checkOut(
        latitude: event.latitude,
        longitude: event.longitude,
        photoPath: event.photoPath,
        
      );
      emit(CheckOutSuccess(record));
    } catch (e) {
      emit(AttendanceError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}